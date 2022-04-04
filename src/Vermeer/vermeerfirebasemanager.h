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

public slots:

    void signIn(QVariant emailString, QVariant passwordString);
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
    QVariant getDestinationIpAddress();
    QVariant getDestinationPortNumber();
    QVariant getUserEmailAddress();
    QVariant getUserPassword();

    void accessTokenTimedOut();
    void accessTokenStartTimer();
    void accessTokenStopTimer();
    void bindSocket();
    void deleteRefreshToken();

    // only used for testing
    void makeRtInvalid();


private:

    const QString authenticateUrl = "https://us-central1-vermeer-production.cloudfunctions.net/rest/api/v1/oauth/token";
    const QString authenticateWithRefreshTokenUrl = "https://us-central1-vermeer-production.cloudfunctions.net/rest/api/v1/oauth/refresh";
    const QString checkAuthenticationStatus = "https://us-central1-vermeer-production.cloudfunctions.net/rest/api/v1/oauth/authStatus";
    const QString fetchFlightPlansUrl = "https://vermeer-production.firebaseio.com/FlightPlans/userReadable/[UID]/Astro.json?auth=[ACCESS_TOKEN]";
    const QString refreshTokenFileName = "refreshTokenFile.txt"; // to be deleted

    QUdpSocket socket;
    quint16 port{5656};

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

    QTimer accessTokenTimer;
    QTimer checkInternetConnectionTimer;
    int checkInternetConnectionIntervalSeconds{3};
};

#endif // VERMEERFIREBASEMANAGER_H
