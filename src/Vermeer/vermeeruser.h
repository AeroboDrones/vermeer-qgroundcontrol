/*
    Vermeer
    VermeerUser class is a runtime global data storage that is shared accross the main three pages
    Since the 3 main pages are managed through a loader which means that when one page is loaded from another page
    the previous page is destroyed and data is lost. This class helps to store persistent data at runtime
*/

#ifndef VERMEERUSER_H
#define VERMEERUSER_H

#include <QObject>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonValue>
#include <QJsonArray>


class VermeerUser : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int numberOfMissions READ readNumberOfMissionItems)
    Q_PROPERTY(QString missionJsonString READ readMissionJsonSring)
    Q_PROPERTY(QString rtspUrl1 READ readRtspUrl1)
    Q_PROPERTY(QString rtspUrl2 READ readRtspUrl2)
public:
    explicit VermeerUser(QObject *parent = nullptr);

    static const QString &getEmail();
    static void setEmail(const QString &newEmail);

    static const QString &getPassword();
    static void setPassword(const QString &newPassword);

    static const QString &getAccessToken();
    static void setAccessToken(const QString &newAccessToken);

    static const QString &getUid();
    static void setUid(const QString &newUid);

    static const QString &getRefreshToken();
    static void setRefreshToken(const QString &newRefreshToken);

    static int readNumberOfMissionItems();
    static void setNumberOfMission(int numberOfMissionItems);

    static void setMissionJson(QJsonObject missionJson);
    static QString getMissionByKey(QString index);
    static QString readMissionJsonSring();
    static QString getMissionList();

    static const QString &getDestinationIpAddress();
    static void setDestinationIpAddress(const QString &newDestinationIpAddress);

    static int getDestinationPortNumber();
    static void setDestinationPortNumber(int newDestinationPortNumber);

    static int getExpiresIn();
    static void setExpiresIn(int newExpiresIn);

    static bool getSignOutButtonPressed();
    static void setSignOutButtonPressed(bool newSignOutButtonPressed);

    static bool getInternetAccessReaquired();
    static void setInternetAccessReaquired(bool newInternetAccessReaquired);

    static const QString &getRtspLink1();
    static void setRtspLink1(const QString &newRtspLink1);

    static const QString &getRtspLink2();
    static void setRtspLink2(const QString &newRtspLink2);

    static QString readRtspUrl1();
    static QString readRtspUrl2();

private:
    inline static QString email;
    inline static QString password;
    inline static QString accessToken;
    inline static int expiresIn;
    inline static QString uid;
    inline static QString refreshToken;
    inline static int numberOfMissions;
    inline static QJsonObject missionJson;
    inline static QString destinationIpAddress{"192.168.144.100"};
    inline static int destinationPortNumber{14555};
    inline static bool signOutButtonPressed;
    inline static bool isAccessTokenTimeOut;
    inline static bool internetAccessReaquired;
    inline static QString rtspLink1{"rtsp://192.168.1.73:8584/vermeer1"};
    inline static QString rtspLink2{"rtsp://192.168.1.73:8584/vermeer2"};
};

#endif // VERMEERUSER_H
