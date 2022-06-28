/*
    Vermeer
    VermeerFirebaseManager predominently handles the user sign-ins, fetching of missions from vermeer's google firebase,
    and sending missions to the companion computer. It also handles most of higher level abstraction calls to the
    other classes.
*/

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

#include <QTimer>
#include <QDateTime>

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
    void sendNotificationsToQml(QVariant data);
    void missionUdpReply(QVariant data);

public slots:

    void signInWithEmailAndPassword(QVariant emailString, QVariant passwordString);
    void signInWithRefreshToken();
    void signInOffline();
    void setSignOutFlag(bool signOutFlag);
    bool isSignOutButtonPressed();
    void authenticateWithRefreshTokenReadyRead();
    void authenticateWithEmailAndPasswordReadyRead();
    void fetchFlightPlansReadyRead();
    void saveMissionListToMissionFile();
    void loadMissioListsFromMissionFile();
    void udpReadyRead();
    void fetchFlightPlans();
    void sendMission(QVariant missionIndex);
    void updateSetting(QVariant ipAddress, QVariant portNumber);
    void saveRefreshToken();
    bool isRefreshTokenExist();
    bool isSettingValid();
    bool hasInternetConnection();
    void checkInternetConnection();
    void loadExpiresInFromFile();
    void loadUserEmailFromFile();
    bool isInternetReacquired();
    void setInternetReqacquiaredFlag(bool value);
    void showLogPage();
    void showMissionPage();
    void sendSignalSendingMissionTimedOut();
    QVariant getDestinationIpAddress();
    QVariant getDestinationPortNumber();
    QVariant getUserEmailAddress();
    QVariant getUserPassword();

    void accessTokenTimedOut();
    void accessTokenStartTimer();
    void accessTokenStopTimer();
    void bindSocket();
    void deleteRefreshToken();
    void sendingMissionTimeoutStart();
    void sendingMissionTimeoutStop();
    void sendMissionFromFile(QVariant filepath,QVariant ipaddress, QVariant port);

private:

    const QString authenticateUrl = "https://us-central1-vermeer-production.cloudfunctions.net/rest/api/v1/oauth/token";
    const QString authenticateWithRefreshTokenUrl = "https://us-central1-vermeer-production.cloudfunctions.net/rest/api/v1/oauth/refresh";
    const QString checkAuthenticationStatus = "https://us-central1-vermeer-production.cloudfunctions.net/rest/api/v1/oauth/authStatus";
    const QString fetchFlightPlansUrl = "https://vermeer-production.firebaseio.com/FlightPlans/userReadable/[UID]/Astro.json?auth=[ACCESS_TOKEN]";

    QUdpSocket socket;
    quint16 port{14556};

    QString sourceIp{"0.0.0.0"};
    QString destinationIp;

    QNetworkAccessManager * networkManager;
    QNetworkReply * networkReply;

    void _authenticateWithEmailAndPassword(QJsonObject emailAndPasswordJson, QString authenticateURL,
                                           QNetworkAccessManager *networkManager);
    void _authenticateWithRefreshToken(QJsonObject refreshTokenJson, QString authenticateRefreshTokenUrl,
                                       QNetworkAccessManager *networkManager);
    void _fetchFlightPlans(QString fetchFlightPlansUrl,QString accessToken, QString uID);
    QJsonObject _missionToJson(QString missionsJsonString);
    QJsonObject _readJsonFile(QString jsonFilepath);

    QTimer accessTokenTimer;
    QTimer checkInternetConnectionTimer;
    QTimer sendingMissionTimeout;
    int checkInternetConnectionIntervalSeconds{3};
    int sendingMissionTimeoutDelaySeconds{5};
    bool hasNoInternetPreviously{false};
    bool hasInternetPreviously{false};
};

#endif // VERMEERFIREBASEMANAGER_H
