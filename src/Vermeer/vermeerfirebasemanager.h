#ifndef VERMEERFIREBASEMANAGER_H
#define VERMEERFIREBASEMANAGER_H

#include "vermeeruser.h"

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonObject>
#include <QJsonDocument>

#include <QUdpSocket>
#include <QNetworkDatagram>
#include <QHostAddress>
#include <QNetworkInterface>
#include <QAbstractSocket>


class VermeerFirebaseManager : public QObject
{
    Q_OBJECT
public:
    explicit VermeerFirebaseManager(QObject *parent = nullptr);
    ~VermeerFirebaseManager();

public:
    inline static bool isConnected;

signals:
    void displayMsgToQml(QVariant data);

public slots:

    void signIn(QVariant emailString, QVariant passwordString);
    void fetchFlightPlansReadyRead();
    void fetchFlightPlans();
    void sendMission(QVariant missionIndex);
    void updateSetting(QVariant ipAddress, QVariant portNumber);
    QVariant getDestinationIpAddress();
    QVariant getDestinationPortNumber();


private:

    const QString authenticateUrl = "https://us-central1-vermeer-production.cloudfunctions.net/rest/api/v1/oauth/token";
    const QString authenticateWithRefreshTokenUrl = "https://us-central1-vermeer-production.cloudfunctions.net/rest/api/v1/oauth/refresh";
    const QString checkAuthenticationStatus = "https://us-central1-vermeer-production.cloudfunctions.net/rest/api/v1/oauth/authStatus";
    const QString fetchFlightPlansUrl = "https://vermeer-production.firebaseio.com/FlightPlans/userReadable/[UID]/Astro.json?auth=[ACCESS_TOKEN]";

    QUdpSocket socket;
    quint16 port{5555};

    QString sourceIp{"0.0.0.0"};
    QString destinationIp;

    QNetworkAccessManager * networkManager;
    QNetworkReply * networkReply;

    void _authenticateWithEmailAndPassword(QJsonObject emailAndPasswordJson, QString authenticateURL, QNetworkAccessManager *networkManager);
    //bool isRefreshTokenExist();
    bool _storeRefreshTokenToFile();

    void _fetchFlightPlans(QString fetchFlightPlansUrl,QString accessToken, QString uID);
    QJsonObject _missionToJson(QString firebaseMissionsJsonString);
    void _setVermeerUserMissionArray(QJsonObject firebaseMissionsJson);

};

#endif // VERMEERFIREBASEMANAGER_H
