#include "vermeerfirebasemanager.h"

#include <QNetworkRequest>
#include <QDebug>
#include <QPointF>
#include <QQmlEngine>

VermeerFirebaseManager::VermeerFirebaseManager(QObject *parent)
    : QObject{parent}
{
    networkManager = new QNetworkAccessManager( this );

    if (VermeerFirebaseManager::isConnected == false)
    {
        if(!socket.bind(QHostAddress(sourceIp), port)) {
            QString msg = socket.errorString();
            qInfo() << "Not Connected" + msg;
            VermeerFirebaseManager::isConnected = false;
        }
        else {
            VermeerFirebaseManager::isConnected = true;
            qInfo() << "bound to: " + sourceIp + ":" + QString::number(port);
        }
    }
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

void VermeerFirebaseManager::fetchFlightPlansReadyRead()
{
    QString firebaseMissionsJsonReply = networkReply->readAll();
    QJsonObject missionJson = _missionToJson(firebaseMissionsJsonReply);

    _setVermeerUserMissionArray(missionJson);
    VermeerUser::setNumberOfMission(missionJson.count());
    emit(displayMsgToQml("numberOfMissionItemsChanged"));
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

    qInfo() << "sending: ";
    qInfo() << missionContent;
    qInfo() << "VermeerUser::getDestinationAddress("
               ")" + VermeerUser::getDestinationIpAddress();
    qInfo() << "VermeerUser::getDestinationPortNumber()";
    qInfo() << VermeerUser::getDestinationPortNumber();

    socket.writeDatagram(datagram);
}

void VermeerFirebaseManager::updateSetting(QVariant ipAddress, QVariant portNumber)
{
    // need to handle possible error here - make sure ipaddress if a string and portnumber is a number
    VermeerUser::setDestinationIpAddress(ipAddress.toString());
    VermeerUser::setDestinationPortNumber(portNumber.toInt());
}

QVariant VermeerFirebaseManager::getDestinationIpAddress()
{
    return QVariant(VermeerUser::getDestinationIpAddress());
}

QVariant VermeerFirebaseManager::getDestinationPortNumber()
{
    return QVariant(VermeerUser::getDestinationPortNumber());
}

void VermeerFirebaseManager::_authenticateWithEmailAndPassword(QJsonObject emailAndPasswordJson, QString authenticateURL, QNetworkAccessManager *networkManager)
{
    bool returnValue = false;
    QNetworkRequest authRequest((QUrl(authenticateURL)));
    authRequest.setHeader(QNetworkRequest::ContentTypeHeader, QString("application/json"));

    QJsonDocument emailAndPasswordJsonDoc(emailAndPasswordJson);

    qInfo() << "emailAndPasswordJsonDoc: "<< emailAndPasswordJsonDoc.toJson(QJsonDocument::Compact);

    QNetworkReply *netReply = networkManager->post(authRequest,emailAndPasswordJsonDoc.toJson());

    connect(netReply, &QNetworkReply::finished, [=]() {

        if(netReply->error() == QNetworkReply::NoError) {
            QString replyString = netReply->readAll();
            QJsonDocument doc = QJsonDocument::fromJson(replyString.toUtf8());
            QJsonObject replyJsonObj = doc.object();

            bool isAuthenticationValid = replyJsonObj.contains("access_token") && replyJsonObj.contains("uid") && replyJsonObj.contains("refresh_token");

            if(isAuthenticationValid){
                VermeerUser::setAccessToken(replyJsonObj["access_token"].toString());
                VermeerUser::setUid(replyJsonObj["uid"].toString());
                VermeerUser::setRefreshToken(replyJsonObj["refresh_token"].toString());

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
            QString err = netReply->errorString();
            emit(displayMsgToQml("InvalidSignIn"));
            qInfo() << err;
        }
    });
}

bool VermeerFirebaseManager::_storeRefreshTokenToFile()
{
    qInfo() << "calling storeRefreshTokenToFile";

    return true;
}

void VermeerFirebaseManager::_fetchFlightPlans(QString fetchFlightPlansUrl, QString accessToken,QString uID)
{   
    fetchFlightPlansUrl.replace("[ACCESS_TOKEN]",accessToken);
    fetchFlightPlansUrl.replace("[UID]",uID);

    QNetworkRequest fetchFlightPlansRequest((QUrl(fetchFlightPlansUrl)));

    networkReply = networkManager->get(fetchFlightPlansRequest);

    // might change
    connect(networkReply,&QNetworkReply::readyRead, this,&VermeerFirebaseManager::fetchFlightPlansReadyRead);
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

