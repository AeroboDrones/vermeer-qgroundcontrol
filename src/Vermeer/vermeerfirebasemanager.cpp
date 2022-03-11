#include "vermeerfirebasemanager.h"

#include <QNetworkRequest>
#include <QDebug>
#include <QPointF>
#include <QQmlEngine>
#include <QDir>
#include <QFileInfo>
#include <QFile>
#include <QByteArray>

VermeerFirebaseManager::VermeerFirebaseManager(QObject *parent)
    : QObject{parent}
{
    connect(&accessTokenTimer,&QTimer::timeout,this,&VermeerFirebaseManager::accessTokenTimedOut);
    connect(&socket,&QUdpSocket::readyRead,this,&VermeerFirebaseManager::udpReadyRead);

    networkManager = new QNetworkAccessManager( this );
}

VermeerFirebaseManager::~VermeerFirebaseManager()
{
    networkManager->deleteLater();
}

void VermeerFirebaseManager::signIn(QVariant emailString, QVariant passwordString)
{
    VermeerUser::setEmail(emailString.toString());
    VermeerUser::setPassword(passwordString.toString());

    QJsonObject emailAndPasswordJson;

    emailAndPasswordJson["email"] = VermeerUser::getEmail();
    emailAndPasswordJson["password"] = VermeerUser::getPassword();

    _authenticateWithEmailAndPassword(emailAndPasswordJson, authenticateUrl,networkManager);
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

    QJsonObject missionJson = _missionToJson(firebaseMissionsJsonReply);

    _setVermeerUserMissionArray(missionJson);
    VermeerUser::setNumberOfMission(missionJson.count());
    emit(displayMsgToQml("numberOfMissionItemsChanged"));
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

        if("Mission already running, mission file ignored" == messagePayload) {
                msg  = "missionAlreadyRunning";
        }
        else if("Received Keyframe Mission" == messagePayload) {
                msg = "missionUploadedSuccessfuly";
        }
        else if("Received AoI Mission" == messagePayload) {
                msg = "missionUploadedSuccessfuly";
        }
        else if("Mission Completed" == messagePayload) {
               // not sure what to display just yet
        }
        qInfo() << msg;
        emit(displayMsgToQml(msg));
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
    QFile refreshTokenFile(QDir::currentPath() + QDir::separator() + refreshTokenFileName);

    if(!refreshTokenFile.open(QIODevice::WriteOnly)){
        qWarning() << refreshTokenFile.errorString();
        return;
    }

    if (!VermeerUser::getRefreshToken().isEmpty()) {
        refreshTokenFile.write(VermeerUser::getRefreshToken().toUtf8());
        refreshTokenFile.close();
    }else{
        qWarning() << "VermeerFirebaseManager: unable to save VermeerUser::getRefreshToken() is empty";
    }
}

bool VermeerFirebaseManager::isRefreshTokenExist()
{
    QFile refreshTokenFile(QDir::currentPath() + QDir::separator() + refreshTokenFileName);

    if(!refreshTokenFile.exists()) {
        qInfo() << "VermeerFirebaseManager: refresh token file does not exist";
        return false;
    }else{
        qInfo() << "VermeerFirebaseManager: refreshTokenFile exist";
        qInfo() << refreshTokenFile;
    }

    return true;
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

    if(!ipAddress.isEmpty()){
        isIPAddressValid = true;
    }
    return (isPortNumberValid && isIPAddressValid);
}

void VermeerFirebaseManager::signInWithRefreshToken()
{
    QFile refreshTokenFile(QDir::currentPath() + QDir::separator() + refreshTokenFileName);
    if(refreshTokenFile.open(QIODevice::ReadOnly)) {
        auto refreshToken = refreshTokenFile.readAll();
        VermeerUser::setRefreshToken(refreshToken);
        refreshTokenFile.close();
    }

    QJsonObject refreshTokenJson;

    refreshTokenJson["refreshToken"] = VermeerUser::getRefreshToken();

    _authenticateWithRefreshToken(refreshTokenJson,authenticateWithRefreshTokenUrl,networkManager);
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
    return QVariant(VermeerUser::getEmail());
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

    qInfo() << "emailAndPasswordJsonDoc: "<< emailAndPasswordJsonDoc.toJson(QJsonDocument::Compact);

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

            QVariant msg = "validSignIn";
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

            qInfo() << "authenticateWithEmailAndPasswordReadyRead";
            QVariant msg = "validSignIn";
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
    QFile refreshTokenFile(QDir::currentPath() + QDir::separator() + refreshTokenFileName);

    qInfo() << "deleteRefreshToken";
    qInfo() << refreshTokenFile;

    if(refreshTokenFile.remove()){
        qInfo() << "File successfuly removed";
    }
}

void VermeerFirebaseManager::makeRtInvalid()
{
     QFile refreshTokenFile(QDir::currentPath() + QDir::separator() + refreshTokenFileName);

     if(!refreshTokenFile.open(QIODevice::WriteOnly)){
         qWarning() << refreshTokenFile.errorString();
         return;
     }

     qInfo() << "makeRtInvalid";

     refreshTokenFile.write("Invalid Refresh Token");
     refreshTokenFile.close();
}

void VermeerFirebaseManager::bindSocket()
{
    qInfo() << "closing the socket";
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
    qInfo() << "accessTokenTimedOut";
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

void VermeerFirebaseManager::_fetchFlightPlans(QString fetchFlightPlansUrl, QString accessToken,QString uID)
{   
    fetchFlightPlansUrl.replace("[ACCESS_TOKEN]",accessToken);
    fetchFlightPlansUrl.replace("[UID]",uID);

    QNetworkRequest fetchFlightPlansRequest((QUrl(fetchFlightPlansUrl)));

    networkReply = networkManager->get(fetchFlightPlansRequest);

    connect(networkReply,&QNetworkReply::finished, this,&VermeerFirebaseManager::fetchFlightPlansReadyRead);
}

QJsonObject VermeerFirebaseManager::_missionToJson(QString firebaseMissionsJsonString)
{
    QJsonDocument firebaseMissionsDoc = QJsonDocument::fromJson(firebaseMissionsJsonString.toUtf8());
    QJsonObject firebaseMissionsJson;

    if(!firebaseMissionsDoc.isNull()) {
        if(firebaseMissionsDoc.isObject()){
            firebaseMissionsJson = firebaseMissionsDoc.object();
        }
    }
    else{
        qInfo() << "VermeerFirebaseManager::missionToJson: ";
        qInfo() << "firebaseMissionsJson: Invalid Json ";
    }

    return firebaseMissionsJson;
}

void VermeerFirebaseManager::_setVermeerUserMissionArray(QJsonObject missionsJson)
{
    VermeerUser::setMissionJson(missionsJson);
}

