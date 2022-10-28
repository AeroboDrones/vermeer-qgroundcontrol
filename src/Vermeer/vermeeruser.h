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

    static const QString &getMissionStatus();
    static void setMissionStatus(const QString &newMissionStatus);

    static const QString &getBtMasterNodeStatus();
    static void setBtMasterNodeStatus(const QString &newBtMasterNodeStatus);

    static const QString &getGeolocatorNodeStatus();
    static void setGeolocatorNodeStatus(const QString &newGeolocatorNodeStatus);

    static const QString &getNodeManagerNodeStatus();
    static void setNodeManagerNodeStatus(const QString &newNodeManagerNodeStatus);

    static const QString &getPathPlannerNodeStatus();
    static void setPathPlannerNodeStatus(const QString &newPathPlannerNodeStatus);

    static const QString &getDataPublisherNodeStatus();
    static void setDataPublisherNodeStatus(const QString &newDataPublisherNodeStatus);

    static const QString &getDetectorNodeStatus();
    static void setDetectorNodeStatus(const QString &newDetectorNodeStatus);

    static const QString &getImageSourceNodeNodeStatus();
    static void setImageSourceNodeNodeStatus(const QString &newImageSourceNodeNodeStatus);

    static const QString &getTrackerNodeStatus();
    static void setTrackerNodeStatus(const QString &newTrackerNodeStatus);

    static const QString &getPerceptionManagerNodeStatus();
    static void setPerceptionManagerNodeStatus(const QString &newPerceptionManagerNodeStatus);

    static const QString &getTelemetryNodeStatus();
    static void setTelemetryNodeStatus(const QString &newTelemetryNodeStatus);

    static const QString &getCommLinkNodeStatus();
    static void setCommLinkNodeStatus(const QString &newCommLinkNodeStatus);

    static const QString &getParameterDistributionNodeStatus();
    static void setParameterDistributionNodeStatus(const QString &newParameterDistributionNodeStatus);

    static const QString &getMavrosNodeStatus();
    static void setMavrosNodeStatus(const QString &newMavrosNodeStatus);

private:
    inline static QString email;
    inline static QString password;
    inline static QString accessToken;
    inline static int expiresIn;
    inline static QString uid;
    inline static QString refreshToken;
    inline static int numberOfMissions;
    inline static QJsonObject missionJson;
    //inline static QString destinationIpAddress{"192.168.144.100"};
    inline static QString destinationIpAddress{"192.168.1.73"};

    inline static int destinationPortNumber{14555};
    inline static bool signOutButtonPressed;
    inline static bool isAccessTokenTimeOut;
    inline static bool internetAccessReaquired;

    inline static QString missionStatus{""};

    inline static QString btMasterNodeStatus{""};
    inline static QString geolocatorNodeStatus{""};
    inline static QString nodeManagerNodeStatus{""};
    inline static QString pathPlannerNodeStatus{""};
    inline static QString dataPublisherNodeStatus{""};
    inline static QString detectorNodeStatus{""};
    inline static QString imageSourceNodeNodeStatus{""};
    inline static QString trackerNodeStatus{""};
    inline static QString perceptionManagerNodeStatus{""};
    inline static QString telemetryNodeStatus{""};
    inline static QString commLinkNodeStatus{""};
    inline static QString parameterDistributionNodeStatus{""};
    inline static QString mavrosNodeStatus{""};


};

#endif // VERMEERUSER_H
