#include <QNetworkRequest>
#include <QDebug>
#include <QPointF>
#include <QQmlEngine>
#include <QDir>
#include <QFileInfo>
#include <QFile>
#include <QByteArray>

#include "vermeerfirebasemanager.h"
#include "vermeermissionlistmanager.h"
#include "vermeerrefreshtoken.h"
#include "vermeerlogmanager.h"

VermeerFirebaseManager::VermeerFirebaseManager(QObject *parent)
    : QObject{parent}
{
    checkInternetConnectionTimer.setInterval(1000 * checkInternetConnectionIntervalSeconds);
    connect(&checkInternetConnectionTimer,&QTimer::timeout,this,&VermeerFirebaseManager::checkInternetConnection);
    checkInternetConnectionTimer.start();

    connect(&accessTokenTimer,&QTimer::timeout,this,&VermeerFirebaseManager::accessTokenTimedOut);
    connect(&socket,&QUdpSocket::readyRead,this,&VermeerFirebaseManager::udpReadyRead);
    networkManager = new QNetworkAccessManager( this );

    sendingMissionTimeout.setInterval(1000 * sendingMissionTimeoutDelaySeconds);
    connect(&sendingMissionTimeout,&QTimer::timeout,this,&VermeerFirebaseManager::sendSignalSendingMissionTimedOut);

    heartbeatConnectionTimer.setInterval(1000 * xavierConnectionTimeoutDelaySeconds);
    connect(&heartbeatConnectionTimer,&QTimer::timeout,this,&VermeerFirebaseManager::heartbeatTimeOut);
}

VermeerFirebaseManager::~VermeerFirebaseManager()
{
    networkManager->deleteLater();
}

void VermeerFirebaseManager::signInWithEmailAndPassword(QVariant emailString, QVariant passwordString)
{
    if(hasInternetConnection()){
        qInfo() << Q_FUNC_INFO << "has internet, signing in with email and password";
        VermeerUser::setEmail(emailString.toString());
        VermeerUser::setPassword(passwordString.toString());
        QJsonObject emailAndPasswordJson;
        emailAndPasswordJson["email"] = VermeerUser::getEmail();
        emailAndPasswordJson["password"] = VermeerUser::getPassword();
        _authenticateWithEmailAndPassword(emailAndPasswordJson, authenticateUrl,networkManager);
    } else {
        qInfo() << Q_FUNC_INFO << "No Internet sending NoInternetConnection to qml";
        emit(displayMsgToQml("NoInternetConnection"));
    }
}

void VermeerFirebaseManager::setSignOutFlag(bool signOutFlag)
{
    VermeerUser::setSignOutButtonPressed(signOutFlag);
}

bool VermeerFirebaseManager::isSignOutButtonPressed()
{
    return VermeerUser::getSignOutButtonPressed();
}

void VermeerFirebaseManager::fetchFlightPlansReadyRead()
{
    QString firebaseMissionsJsonReply = networkReply->readAll();

    QJsonDocument doc = QJsonDocument::fromJson(firebaseMissionsJsonReply.toUtf8());
    QJsonObject replyJsonObj = doc.object();
    bool isValidFetch = not replyJsonObj.contains("error");

    if(isValidFetch){
        QJsonObject missionJson = _missionToJson(firebaseMissionsJsonReply);
        VermeerUser::setMissionJson(missionJson);
        VermeerUser::setNumberOfMission(missionJson.count());
        emit(displayMsgToQml("numberOfMissionItemsChanged"));
    }
    else {
        emit(displayMsgToQml("invalidAccessToken"));
    }
}

void VermeerFirebaseManager::saveMissionListToMissionFile()
{
    VermeerMissionListManager vermeerMissionListManager;
    auto UID = VermeerUser::getUid();
    auto missionList = VermeerUser::getMissionList();
    vermeerMissionListManager.saveMissionsList(UID,missionList);
}

void VermeerFirebaseManager::loadMissioListsFromMissionFile()
{
    qInfo() << Q_FUNC_INFO;
    VermeerRefreshToken vermeerRefreshToken;
    QString uid = vermeerRefreshToken.getUIDFromRefreshToken();
    VermeerMissionListManager vermeerMissionListManager;
    if(vermeerMissionListManager.missionFileExistsAndNotEmpty(uid)) {
        QString missionListString = vermeerMissionListManager.loadMissionFromFile(uid);
        QJsonObject missionListJson = _missionToJson(missionListString);
        VermeerUser::setMissionJson(missionListJson);
        VermeerUser::setNumberOfMission(missionListJson.count());
        emit(displayMsgToQml("numberOfMissionItemsChanged"));
    }
}

void VermeerFirebaseManager::udpReadyRead()
{
    while(socket.hasPendingDatagrams())
    {
        QNetworkDatagram datagram = socket.receiveDatagram();
        QString notificationJsonString = datagram.data();
        QJsonDocument doc = QJsonDocument::fromJson(notificationJsonString.toUtf8());
        QJsonObject notificationJson = doc.object();        
        QString messagePayload = notificationJson["messagePayload"].toString();
        QString msg = "";

        if("comm_link Received Mission JSON. Mission already running. Ignoring..." == messagePayload) {
                msg  = "missionAlreadyRunning";
        }
        else if("comm_link Received Mission JSON..." == messagePayload) {
                msg = "receivedMissionJson";
        }
        else if("comm_link Mission Complete." == messagePayload) {
                msg = "missionCompleted";
        }
        else if("comm_link unable to decode JSON message..." == messagePayload) {
               msg = "missionCurrupted";
        }
        else if("Home Position received. Ready to upload mission" == messagePayload) {
                msg = "homePositionReceived";
        }
        emit(missionUdpReply(msg));
        emit(sendNotificationsToQml(notificationJsonString));
    }
}

void VermeerFirebaseManager::fetchFlightPlans()
{
    _fetchFlightPlans(fetchFlightPlansUrl,VermeerUser::getAccessToken(),VermeerUser::getUid());
}

void VermeerFirebaseManager::sendMission(QVariant missionKey)
{
    QString missionContent = VermeerUser::getMissionByKey(missionKey.toString());
    QByteArray missionContentByteArray = missionContent.toUtf8();
    QString destinationIp = VermeerUser::getDestinationIpAddress();
    int destinationPort = VermeerUser::getDestinationPortNumber();
    QNetworkDatagram datagram(missionContentByteArray,QHostAddress(destinationIp),destinationPort);
    socket.writeDatagram(datagram);
}

void VermeerFirebaseManager::updateSetting(QVariant ipAddress, QVariant portNumber)
{   
    auto ipaddress = QHostAddress(ipAddress.toString());
    if(!ipaddress.isNull()){
        VermeerUser::setDestinationIpAddress(ipAddress.toString());
        VermeerUser::setDestinationPortNumber(portNumber.toInt());
        emit(displayMsgToQml("SettingsUpdatedSuccessfuly"));
    }
    else{
        emit(displayMsgToQml("InvalidIpAddress"));
    }
}

void VermeerFirebaseManager::saveRefreshToken()
{
    if (!VermeerUser::getRefreshToken().isEmpty()) {
        VermeerRefreshToken vermeerRefreshToken;
        auto saveStatus = vermeerRefreshToken.save(VermeerUser::getRefreshToken().toUtf8(),
                                                   VermeerUser::getUid(),VermeerUser::getExpiresIn(),
                                                   VermeerUser::getEmail());
        auto isSaveSuccessful = std::get<0>(saveStatus);
        auto saveMessage = std::get<1>(saveStatus);

        if (isSaveSuccessful) {
            qInfo() << Q_FUNC_INFO << saveMessage;
        }
    } else {
        qWarning() << Q_FUNC_INFO <<": unable to save, VermeerUser::getRefreshToken() is empty";
    }
}

bool VermeerFirebaseManager::isRefreshTokenExist()
{
    VermeerRefreshToken vermeerRefreshToken;
    qInfo() << Q_FUNC_INFO << "vermeerRefreshToken.exists(): " << vermeerRefreshToken.exists();
    return vermeerRefreshToken.exists();
}

bool VermeerFirebaseManager::isSettingValid()
{
    qInfo() << "chekcing setting if valid";
    auto ipAddress = VermeerUser::getDestinationIpAddress();
    auto portNumber = VermeerUser::getDestinationPortNumber();

    bool isPortNumberValid = false;
    bool isIPAddressValid = false;

    if(portNumber >0){
        isPortNumberValid = true;
    }

    if(!ipAddress.isEmpty()) {
        isIPAddressValid = true;
    }
    return (isPortNumberValid && isIPAddressValid);
}

bool VermeerFirebaseManager::hasInternetConnection()
{
    QTcpSocket socket;
    socket.connectToHost("8.8.8.8", 53);
    if (socket.waitForConnected(2000)) {
        qInfo() << Q_FUNC_INFO << ":" << " There is internet";
        return true;
    }
    qInfo() << Q_FUNC_INFO << ":" << " There is no internet";
    return false;
}

void VermeerFirebaseManager::checkInternetConnection()
{
    VermeerLogManager vermeerLogManager;

    QTcpSocket socket;
    socket.connectToHost("8.8.8.8", 53);
    if (socket.waitForConnected(2000)) {
        if(hasNoInternetPreviously) {
            setInternetReqacquiaredFlag(true);
            qInfo() << Q_FUNC_INFO << " Internet Connection Regained";
            vermeerLogManager.log("System: Internet Connection Regained");
            hasNoInternetPreviously = false;
        }
        hasInternetPreviously = true;
        emit(displayMsgToQml("HasInternet"));
    } else {
        hasNoInternetPreviously = true;

        if(hasInternetPreviously){
            hasInternetPreviously = false;
            qInfo() << Q_FUNC_INFO << " Internet Connection Lost";
            vermeerLogManager.log("System: Internet Connection Lost");
        }
        emit(displayMsgToQml("NoInternet"));
    }
}

void VermeerFirebaseManager::loadExpiresInFromFile()
{
    VermeerRefreshToken vermeerRefreshToken;
    VermeerUser::setExpiresIn(vermeerRefreshToken.getExpiresIn());
}

void VermeerFirebaseManager::loadUserEmailFromFile()
{
    VermeerRefreshToken vermeerRefreshToken;
    VermeerUser::setEmail(vermeerRefreshToken.getUserEmail());
}

bool VermeerFirebaseManager::isInternetReacquired()
{
    return VermeerUser::getInternetAccessReaquired();
}

void VermeerFirebaseManager::setInternetReqacquiaredFlag(bool value)
{
    VermeerUser::setInternetAccessReaquired(value);
}

void VermeerFirebaseManager::showLogPage()
{
    emit(displayMsgToQml("ShowLogPage"));
}

void VermeerFirebaseManager::showMissionPage()
{
    emit(displayMsgToQml("ShowMissionList"));
}

void VermeerFirebaseManager::sendSignalSendingMissionTimedOut()
{
    qInfo() << Q_FUNC_INFO;
    emit(displayMsgToQml("sendingMissionTimedOut"));
}

void VermeerFirebaseManager::signInWithRefreshToken()
{
    VermeerRefreshToken vermeerRefreshToken;
    auto refreshToken = vermeerRefreshToken.getRefreshToken();
    VermeerUser::setRefreshToken(refreshToken);
    QJsonObject refreshTokenJson;
    refreshTokenJson["refreshToken"] = refreshToken;
    _authenticateWithRefreshToken(refreshTokenJson,authenticateWithRefreshTokenUrl,networkManager);
}

void VermeerFirebaseManager::signInOffline()
{
    emit(displayMsgToQml("ValidOfflineSignIn"));
}

QVariant VermeerFirebaseManager::getDestinationIpAddress()
{
    return QVariant(VermeerUser::getDestinationIpAddress());
}

QVariant VermeerFirebaseManager::getDestinationPortNumber()
{
    return QVariant(VermeerUser::getDestinationPortNumber());
}

QVariant VermeerFirebaseManager::getUserEmailAddress()
{
    VermeerRefreshToken vermeerRefreshToken;
    QString userEmail = vermeerRefreshToken.getUserEmail();

    qInfo() << Q_FUNC_INFO << ": " << userEmail;

    return QVariant(userEmail);
}

QVariant VermeerFirebaseManager::getUserPassword()
{
    return QVariant(VermeerUser::getPassword());
}

void VermeerFirebaseManager::_authenticateWithEmailAndPassword(QJsonObject emailAndPasswordJson, QString authenticateURL, QNetworkAccessManager *networkManager)
{
    bool returnValue = false;
    QNetworkRequest authRequest((QUrl(authenticateURL)));
    authRequest.setHeader(QNetworkRequest::ContentTypeHeader, QString("application/json"));
    QJsonDocument emailAndPasswordJsonDoc(emailAndPasswordJson);
    qInfo() << Q_FUNC_INFO << ": emailAndPasswordJsonDoc: "<< emailAndPasswordJsonDoc.toJson(QJsonDocument::Compact);
    networkReply = networkManager->post(authRequest,emailAndPasswordJsonDoc.toJson());
    connect(networkReply,&QNetworkReply::finished, this,&VermeerFirebaseManager::authenticateWithEmailAndPasswordReadyRead);
}

void VermeerFirebaseManager::_authenticateWithRefreshToken(QJsonObject refreshTokenJson, QString authenticateRefreshTokenUrl, QNetworkAccessManager *networkManager)
{
    QNetworkRequest authRefreshRequest((QUrl(authenticateRefreshTokenUrl)));
    authRefreshRequest.setHeader(QNetworkRequest::ContentTypeHeader, QString("application/json"));
    QJsonDocument refreshTokenJsonDoc(refreshTokenJson);
    networkReply = networkManager->post(authRefreshRequest,refreshTokenJsonDoc.toJson());
    connect(networkReply,&QNetworkReply::finished, this,&VermeerFirebaseManager::authenticateWithRefreshTokenReadyRead);
}

void VermeerFirebaseManager::authenticateWithRefreshTokenReadyRead()
{
    if(networkReply->error() == QNetworkReply::NoError) {
        QString replyString = networkReply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(replyString.toUtf8());
        QJsonObject replyJsonObj = doc.object();
        bool isAuthenticationValid = replyJsonObj.contains("access_token") && replyJsonObj.contains("uid") && replyJsonObj.contains("refresh_token");
        if(isAuthenticationValid){
            VermeerUser::setAccessToken(replyJsonObj["access_token"].toString());
            VermeerUser::setExpiresIn(replyJsonObj["expires_in"].toInt());
            VermeerUser::setUid(replyJsonObj["uid"].toString());
            VermeerUser::setRefreshToken(replyJsonObj["refresh_token"].toString());
            QVariant msg = "validRefreshTokenSignIn";
            qInfo() << msg;
            emit(displayMsgToQml(msg));
        } else {
            QVariant errorMsg = replyJsonObj["message"].toVariant();
            emit(displayMsgToQml("InvalidRefreshToken"));
            qInfo() << errorMsg;
        }
    }
    else {
        QString err = networkReply->errorString();
        emit(displayMsgToQml("InvalidRefreshToken"));
        qInfo() << err;
    }
}

void VermeerFirebaseManager::authenticateWithEmailAndPasswordReadyRead()
{
    if(networkReply->error() == QNetworkReply::NoError) {
        QString replyString = networkReply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(replyString.toUtf8());
        QJsonObject replyJsonObj = doc.object();
        bool isAuthenticationValid = replyJsonObj.contains("access_token") && replyJsonObj.contains("uid") && replyJsonObj.contains("refresh_token");
        if(isAuthenticationValid){
            VermeerUser::setAccessToken(replyJsonObj["access_token"].toString());
            VermeerUser::setExpiresIn(replyJsonObj["expires_in"].toInt());
            VermeerUser::setUid(replyJsonObj["uid"].toString());
            VermeerUser::setRefreshToken(replyJsonObj["refresh_token"].toString());
            qInfo() << "Authenticated with user email and password";
            QVariant msg = "validEmailAndPassSignIn";
            qInfo() << msg;
            emit(displayMsgToQml(msg));
        } else {
            QVariant errorMsg = replyJsonObj["message"].toVariant();
            emit(displayMsgToQml("InvalidSignIn"));
            qInfo() << errorMsg;
        }
    }
    else {
        QString err = networkReply->errorString();
        emit(displayMsgToQml("InvalidSignIn"));
        qInfo() << err;
    }
}

void VermeerFirebaseManager::deleteRefreshToken()
{
    VermeerRefreshToken vermeerRefreshToken;
    if(vermeerRefreshToken.deleteRefreshToken()) {
        qInfo() << Q_FUNC_INFO << ": refresh token deleted";
    }
}

void VermeerFirebaseManager::sendingMissionTimeoutStart()
{
    qInfo() << Q_FUNC_INFO;
    sendingMissionTimeout.start();
}

void VermeerFirebaseManager::sendingMissionTimeoutStop()
{
    qInfo() << Q_FUNC_INFO;
    sendingMissionTimeout.stop();
}

void VermeerFirebaseManager::bindSocket()
{
    qInfo() <<Q_FUNC_INFO << ": closing the socket";
    socket.close();

    qInfo() << "Binding to the broadcast";
    if(!socket.bind(QHostAddress(sourceIp), port)) {
        QString msg = socket.errorString();
        qInfo() << "VermeerFirebaseManager: Not Connected" + msg;
        VermeerFirebaseManager::isConnected = false;
    }
    else {
        VermeerFirebaseManager::isConnected = true;
        qInfo() << "VermeerFirebaseManager: bound to: " + sourceIp + ":" + QString::number(port);
    }
}

void VermeerFirebaseManager::accessTokenTimedOut()
{
    qInfo() << Q_FUNC_INFO  << "accessTokenTimedOut";
    emit(displayMsgToQml("accessTokenTimedOut"));
}

void VermeerFirebaseManager::accessTokenStartTimer()
{
    accessTokenTimer.setInterval(1000 * VermeerUser::getExpiresIn());
    qInfo() << "accessTokenStartTimer";
    accessTokenTimer.start();
}

void VermeerFirebaseManager::accessTokenStopTimer()
{
    accessTokenTimer.stop();
}

void VermeerFirebaseManager::heartbeatTimeOut()
{
    VermeerFirebaseManager:isXavierConnected = false;
    emit(displayMsgToQml("xavier_disconnected"));
}

void VermeerFirebaseManager::heartbeatStartTimer()
{
    heartbeatConnectionTimer.start();
}

void VermeerFirebaseManager::heartbeatStopTimer()
{
    heartbeatConnectionTimer.stop();
}

void VermeerFirebaseManager::heartbeatRestartTimer()
{
    heartbeatStopTimer();
    heartbeatStartTimer();
}

void VermeerFirebaseManager::sendHeartbeatMsg()
{
    QString ipaddress = VermeerUser::getDestinationIpAddress();
    int portNumber = VermeerUser::getDestinationPortNumber();

    QJsonObject heartbeatMsgJson;
    if(false == VermeerFirebaseManager::isXavierConnected) {
        heartbeatMsgJson["heartbeat"] = "disconnected";
    } else if(true == VermeerFirebaseManager::isXavierConnected) {
        heartbeatMsgJson["heartbeat"] = "connected";
    }

    QJsonDocument heartbeatMsgJsonDoc(heartbeatMsgJson);
    QString heartbeatMsgString(heartbeatMsgJsonDoc.toJson(QJsonDocument::Compact));
    QByteArray heartbeatMsgByteArray = heartbeatMsgString.toUtf8();
    QNetworkDatagram datagram(heartbeatMsgByteArray,QHostAddress(ipaddress),portNumber);
    socket.writeDatagram(datagram);
}

bool VermeerFirebaseManager::hasHeartBeatMsg(QVariant data)
{
    bool hasHeartBeatMsg{false};
    QString notification(data.toString());
    QJsonObject obj;
    QJsonDocument doc = QJsonDocument::fromJson(notification.toUtf8());
    if(!doc.isNull()){
        if(doc.isObject()){
            obj = doc.object();
            if(obj.contains("msgType")) {
                QString value = obj["msgType"].toString();
                if("heartbeat" == value){
                    hasHeartBeatMsg = true;
                    VermeerFirebaseManager::isXavierConnected = true;
                }
            }
        }
    }

    return hasHeartBeatMsg;
}

QVariant VermeerFirebaseManager::getTlogs(QVariant data)
{
    QString tLogs{""};
    QString notification(data.toString());
    QJsonObject obj;
    QJsonDocument doc = QJsonDocument::fromJson(notification.toUtf8());
    if(!doc.isNull()){
        if(doc.isObject()){
            obj = doc.object();
            if(obj.contains("messagePayload") && \
                obj.contains("sourceNode") && \
                obj.contains("timeStamp")) {
                QString messagePayload = obj["messagePayload"].toString();
                if(!messagePayload.isEmpty()){
                    QString sourceDevice = obj["sourceNode"].toString();
                    QString timeStamp = obj["timeStamp"].toString();
                    QString msgType = obj["msgType"].toString();
                    tLogs = timeStamp + " : " + msgType + " : " + sourceDevice + " : " + messagePayload;
                }
            } else {
                if(obj.contains("msgType")) {
                   QString msgType  = obj["msgType"].toString();
                   if("heartbeat" == msgType) {
                    tLogs = obj["timeStamp"].toString() + ":" + "herelink recieved heartbeat";
                   } else {
                       QString missingKeys;
                       if(false == obj.contains("messagePayload")){
                           missingKeys += "messagePayload,";
                       }
                       if(false == obj.contains("sourceNode")){
                           missingKeys += "sourceNode,";
                       }
                       if(false == obj.contains("timeStamp")){
                           missingKeys += "timeStamp";
                       }
                       QString msg = "json is missing key: " + missingKeys;
                       emit(sendDebugInformation(msg));
                       qInfo() << msg;
                   }
                } else {
                    qInfo() << QString(Q_FUNC_INFO) << ":" << "does not contain msgType" << notification;
                }
            }
        }
    }
    return tLogs;
}

QVariant VermeerFirebaseManager::getMissionStatus()
{
    return VermeerUser::getMissionStatus();
}

void VermeerFirebaseManager::storeMissionAndNodeStatus(QVariant data)
{
    QString notification(data.toString());
    QJsonObject obj;
    QJsonDocument doc = QJsonDocument::fromJson(notification.toUtf8());
    if(!doc.isNull()){
        if(doc.isObject()){
            obj = doc.object();
            if(obj.contains("msgType")){
                QString msgType = obj["msgType"].toString();
                if("mission"== msgType){
                    QString status =  obj["status"].toString();
                    VermeerUser::setMissionStatus(status);
                } else if("node"== msgType){
                    QString sourceNode = obj["sourceNode"].toString();
                    QString status =  obj["status"].toString();
                    if("bt_master" == sourceNode){
                        VermeerUser::setBtMasterNodeStatus(status);
                    } else if("geolocator_node" == sourceNode) {
                        VermeerUser::setGeolocatorNodeStatus(status);
                    } else if("path_planner" == sourceNode) {
                        VermeerUser::setPathPlannerNodeStatus(status);
                    } else if("perception_data_publisher_node" == sourceNode) {
                        VermeerUser::setDataPublisherNodeStatus(status);
                    } else if("node_manager" == sourceNode){
                        VermeerUser::setNodeManagerNodeStatus(status);
                    } else if("detector_node" == sourceNode) {
                        VermeerUser::setDetectorNodeStatus(status);
                    } else if("image_source_node" == sourceNode) {
                        VermeerUser::setImageSourceNodeNodeStatus(status);
                    }else if("tracker_node" == sourceNode) {
                        VermeerUser::setTrackerNodeStatus(status);
                    }else if("perception_manager" == sourceNode) {
                        VermeerUser::setPerceptionManagerNodeStatus(status);
                    }else if("telemetry" == sourceNode) {
                        VermeerUser::setTelemetryNodeStatus(status);
                    }else if("comm_link" == sourceNode) {
                        VermeerUser::setCommLinkNodeStatus(status);
                    }else if("parameter_distribution" == sourceNode) {
                        VermeerUser::setParameterDistributionNodeStatus(status);
                    }else if("mavros" == sourceNode) {
                        VermeerUser::setMavrosNodeStatus(status);
                    }else if("bot_health_pub" == sourceNode) {
                        VermeerUser::setBotHeathStatus(status);
                    }else {
                        qInfo() << QString(Q_FUNC_INFO) << " : " << notification;
                    }
                }
            } else {
                QString msg = "json does not contain msgType and status key";
                emit(sendDebugInformation(msg));
                qInfo() << msg;
            }
        }
    }
}

QVariant VermeerFirebaseManager::getStatusButtonText()
{
    QString missionStatus = VermeerUser::getMissionStatus();
    if("Search" == missionStatus ||
       "Verify" == missionStatus ||
       "Investigate" == missionStatus){
        missionStatus = "Flying Mission";
    }
    return missionStatus;
}

void VermeerFirebaseManager::setStatusButtonText(QVariant status)
{
    VermeerUser::setMissionStatus(status.toString());
}

QVariant VermeerFirebaseManager::getBtMasterNodeStatus()
{
    return VermeerUser::getBtMasterNodeStatus();
}

QVariant VermeerFirebaseManager::getGeolocatorNodeStatus()
{
    return VermeerUser::getGeolocatorNodeStatus();
}

QVariant VermeerFirebaseManager::getNodeManagerNodeStatus()
{
    return VermeerUser::getNodeManagerNodeStatus();
}

QVariant VermeerFirebaseManager::getPathPlannerNodeStatus()
{
    return VermeerUser::getPathPlannerNodeStatus();
}

QVariant VermeerFirebaseManager::getDataPublisherNodeStatus()
{
    return VermeerUser::getDataPublisherNodeStatus();
}

QVariant VermeerFirebaseManager::getDetectorNodeStatus()
{
    return VermeerUser::getDetectorNodeStatus();
}

QVariant VermeerFirebaseManager::getImageSourceNodeStatus()
{
    return VermeerUser::getImageSourceNodeNodeStatus();
}

QVariant VermeerFirebaseManager::getTrackerNodeStatus()
{
    return VermeerUser::getTrackerNodeStatus();
}

QVariant VermeerFirebaseManager::getMavrosNodeStatus()
{
    return VermeerUser::getMavrosNodeStatus();
}

QVariant VermeerFirebaseManager::getPerceptionManagerNodeStatus()
{
    return VermeerUser::getPerceptionManagerNodeStatus();
}

QVariant VermeerFirebaseManager::getTelemetryNodeStatus()
{
    return VermeerUser::getTelemetryNodeStatus();
}

QVariant VermeerFirebaseManager::getCommLinkNodeStatus()
{
    return VermeerUser::getCommLinkNodeStatus();
}

QVariant VermeerFirebaseManager::getParameterDistributionNodeStatus()
{
    return VermeerUser::getParameterDistributionNodeStatus();
}

QVariant VermeerFirebaseManager::getBotHealthNodeStatus()
{
    return VermeerUser::getBotHeathStatus();
}

void VermeerFirebaseManager::setBtMasterNodeStatus(QVariant status)
{
    VermeerUser::setBtMasterNodeStatus(status.toString());
}

void VermeerFirebaseManager::setGeolocatorNodeStatus(QVariant status)
{
    VermeerUser::setGeolocatorNodeStatus(status.toString());
}

void VermeerFirebaseManager::setNodeManagerNodeStatus(QVariant status)
{
    VermeerUser::setNodeManagerNodeStatus(status.toString());
}

void VermeerFirebaseManager::setPathPlannerNodeStatus(QVariant status)
{
    VermeerUser::setPathPlannerNodeStatus(status.toString());
}

void VermeerFirebaseManager::setDataPublisherNodeStatus(QVariant status)
{
    VermeerUser::setDataPublisherNodeStatus(status.toString());
}

void VermeerFirebaseManager::setDetectorNodeStatus(QVariant status)
{
    VermeerUser::setDetectorNodeStatus(status.toString());
}

void VermeerFirebaseManager::setImageSourceNodeStatus(QVariant status)
{
    VermeerUser::setImageSourceNodeNodeStatus(status.toString());
}

void VermeerFirebaseManager::setTrackerNodeStatus(QVariant status)
{
    VermeerUser::setTrackerNodeStatus(status.toString());
}

void VermeerFirebaseManager::setMavrosNodeStatus(QVariant status)
{
    VermeerUser::setMavrosNodeStatus(status.toString());
}

void VermeerFirebaseManager::setPerceptionManagerNodeStatus(QVariant status)
{
    VermeerUser::setPerceptionManagerNodeStatus(status.toString());
}

void VermeerFirebaseManager::setTelemetryNodeStatus(QVariant status)
{
    VermeerUser::setTelemetryNodeStatus(status.toString());
}

void VermeerFirebaseManager::setCommLinkNodeStatus(QVariant status)
{
    VermeerUser::setCommLinkNodeStatus(status.toString());
}

void VermeerFirebaseManager::setParameterDistributionNodeStatus(QVariant status)
{
    VermeerUser::setParameterDistributionNodeStatus(status.toString());
}

void VermeerFirebaseManager::setBotHealthNodeStatus(QVariant status)
{
    VermeerUser::setBotHeathStatus(status.toString());
}

void VermeerFirebaseManager::_fetchFlightPlans(QString fetchFlightPlansUrl, QString accessToken,QString uID)
{   
    fetchFlightPlansUrl.replace("[ACCESS_TOKEN]",accessToken);
    fetchFlightPlansUrl.replace("[UID]",uID);
    QNetworkRequest fetchFlightPlansRequest((QUrl(fetchFlightPlansUrl)));
    networkReply = networkManager->get(fetchFlightPlansRequest);
    connect(networkReply,&QNetworkReply::finished, this,&VermeerFirebaseManager::fetchFlightPlansReadyRead);
}

QJsonObject VermeerFirebaseManager::_missionToJson(QString missionsJsonString)
{
    QJsonDocument missionsDoc = QJsonDocument::fromJson(missionsJsonString.toUtf8());
    QJsonObject missionsJson;
    if(!missionsDoc.isNull()) {
        if(missionsDoc.isObject()){
            missionsJson = missionsDoc.object();
        }
    }
    else{
        qInfo() << Q_FUNC_INFO <<": firebaseMissionsJson: Invalid Json ";
        // we could potentialy emit a signal to the ui if we use invalid access token??
    }
    return missionsJson;
}

