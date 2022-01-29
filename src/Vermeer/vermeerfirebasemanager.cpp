#include "vermeerfirebasemanager.h"

#include <QNetworkRequest>
#include <QDebug>

#include <QJsonObject>
#include <QJsonDocument>

VermeerFirebaseManager::VermeerFirebaseManager(QObject *parent)
    : QObject{parent}
{
    networkManager = new QNetworkAccessManager( this );
}

VermeerFirebaseManager::~VermeerFirebaseManager()
{
    networkManager->deleteLater();
}

void VermeerFirebaseManager::signIn(QVariant emailString, QVariant passwordString)
{
    vermeerUser.setEmail(emailString.toString());
    vermeerUser.setPassword(passwordString.toString());

    QJsonObject emailAndPasswordJson;

    emailAndPasswordJson["email"] = vermeerUser.getEmail();
    emailAndPasswordJson["password"] = vermeerUser.getPassword();

    _authenticateWithEmailAndPassword(emailAndPasswordJson, authenticateUrl,networkManager);
}

void VermeerFirebaseManager::networkReplyReadyRead()
{
    emit(displayMsgToQml("reply 1"));
    qInfo() << "Getting here";

    QString reply = networkReply->readAll();

    qInfo() << "reply: " + reply;

    qInfo() << networkReply->readAll();

    emit(displayMsgToQml("reply"));
}

void VermeerFirebaseManager::fetchFlightPlans()
{
    qInfo() << "fetching flight plans";

    qInfo() << "fetchFlightPlansUrl";
    qInfo() << fetchFlightPlansUrl;
    qInfo() << "vermeerUser.getAccessToken()";
    qInfo() << vermeerUser.getAccessToken();

    _fetchFlightPlans(fetchFlightPlansUrl,vermeerUser.getAccessToken(),vermeerUser.getUid());
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
                vermeerUser.setAccessToken(replyJsonObj["access_token"].toString());
                vermeerUser.setUid(replyJsonObj["uid"].toString());
                vermeerUser.setRefreshToken(replyJsonObj["refresh_token"].toString());

                QVariant msg = "fetchFlightPlans";
                emit(displayMsgToQml(msg));
            } else {
                QVariant errorMsg = replyJsonObj["message"].toVariant();
                emit(displayMsgToQml(errorMsg));
                qInfo() << errorMsg;
            }
        }
        else {
            QString err = netReply->errorString();
            emit(displayMsgToQml(err));
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

    qInfo() << "fetchFlightPlansUrl: ";
    qInfo() << fetchFlightPlansUrl;

    QNetworkRequest fetchFlightPlansRequest((QUrl(fetchFlightPlansUrl)));

    networkReply = networkManager->get(fetchFlightPlansRequest);

    // might change
    connect(networkReply,&QNetworkReply::readyRead, this,&VermeerFirebaseManager::networkReplyReadyRead);
}
