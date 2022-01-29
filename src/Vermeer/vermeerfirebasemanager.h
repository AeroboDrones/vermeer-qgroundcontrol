#ifndef VERMEERFIREBASEMANAGER_H
#define VERMEERFIREBASEMANAGER_H

#include "vermeeruser.h"

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>


class VermeerFirebaseManager : public QObject
{
    Q_OBJECT
public:
    explicit VermeerFirebaseManager(QObject *parent = nullptr);
    ~VermeerFirebaseManager();

signals:
    void displayMsgToQml(QVariant data);

public slots:

    void signIn(QVariant emailString, QVariant passwordString);
    void networkReplyReadyRead();
    void fetchFlightPlans();

private:

    const QString authenticateUrl = "https://us-central1-vermeer-production.cloudfunctions.net/rest/api/v1/oauth/token";
    const QString authenticateWithRefreshTokenUrl = "https://us-central1-vermeer-production.cloudfunctions.net/rest/api/v1/oauth/refresh";
    const QString checkAuthenticationStatus = "https://us-central1-vermeer-production.cloudfunctions.net/rest/api/v1/oauth/authStatus";
    const QString fetchFlightPlansUrl = "https://vermeer-production.firebaseio.com/FlightPlans/userReadable/[UID]/Astro.json?auth=[ACCESS_TOKEN]";

    QNetworkAccessManager * networkManager;
    QNetworkReply * networkReply;

    VermeerUser vermeerUser;

    void _authenticateWithEmailAndPassword(QJsonObject emailAndPasswordJson, QString authenticateURL, QNetworkAccessManager *networkManager);
    //bool isRefreshTokenExist();
    bool _storeRefreshTokenToFile();
    void _fetchFlightPlans(QString fetchFlightPlansUrl,QString accessToken, QString uID);

};

#endif // VERMEERFIREBASEMANAGER_H
