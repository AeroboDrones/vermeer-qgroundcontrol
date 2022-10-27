#include <QDebug>

#include "vermeeruser.h"
#include <QJsonValue>

VermeerUser::VermeerUser(QObject *parent)
    : QObject{parent}
{
}

const QString &VermeerUser::getEmail()
{
    return VermeerUser::email;
}

void VermeerUser::setEmail(const QString &newEmail)
{
    VermeerUser::email = newEmail;
}

const QString &VermeerUser::getPassword()
{
    return VermeerUser::password;
}

void VermeerUser::setPassword(const QString &newPassword)
{
    VermeerUser::password = newPassword;
}

const QString &VermeerUser::getAccessToken()
{
    return VermeerUser::accessToken;
}

void VermeerUser::setAccessToken(const QString &newAccessToken)
{
    VermeerUser::accessToken = newAccessToken;
}

const QString &VermeerUser::getUid()
{
    return VermeerUser::uid;
}

void VermeerUser::setUid(const QString &newUid)
{
    VermeerUser::uid = newUid;
}

const QString &VermeerUser::getRefreshToken()
{
    return VermeerUser::refreshToken;
}

void VermeerUser::setRefreshToken(const QString &newRefreshToken)
{
    VermeerUser::refreshToken = newRefreshToken;
}

int VermeerUser::readNumberOfMissionItems()
{
    return VermeerUser::numberOfMissions;
}

void VermeerUser::setNumberOfMission(int numberOfMissionItems)
{
    VermeerUser::numberOfMissions = numberOfMissionItems;
}

void VermeerUser::setMissionJson(QJsonObject missionJson)
{
    VermeerUser::missionJson = missionJson;
}

QString VermeerUser::getMissionByKey(QString key)
{
    QJsonObject missionJson = VermeerUser::missionJson.value(key).toObject();
    QJsonDocument doc(missionJson);
    QString missionString(doc.toJson(QJsonDocument::Compact));
    return missionString;
}

QString VermeerUser::readMissionJsonSring()
{
    QJsonDocument doc(VermeerUser::missionJson);
    QString missionJsonString(doc.toJson(QJsonDocument::Compact));
    return missionJsonString;
}

QString VermeerUser::getMissionList()
{
    QJsonDocument doc(VermeerUser::missionJson);
    QString missionJsonString(doc.toJson(QJsonDocument::Compact));
    return missionJsonString;
}

const QString &VermeerUser::getDestinationIpAddress()
{
    return VermeerUser::destinationIpAddress;
}

void VermeerUser::setDestinationIpAddress(const QString &newDestinationIpAddress)
{
    VermeerUser::destinationIpAddress = newDestinationIpAddress;
}

int VermeerUser::getDestinationPortNumber()
{
    return VermeerUser::destinationPortNumber;
}

void VermeerUser::setDestinationPortNumber(int newDestinationPortNumber)
{
    VermeerUser::destinationPortNumber = newDestinationPortNumber;
}

int VermeerUser::getExpiresIn()
{
    return expiresIn;
}

void VermeerUser::setExpiresIn(int newExpiresIn)
{
    expiresIn = newExpiresIn;
}

bool VermeerUser::getSignOutButtonPressed()
{
    return signOutButtonPressed;
}

void VermeerUser::setSignOutButtonPressed(bool newSignOutButtonPressed)
{
    signOutButtonPressed = newSignOutButtonPressed;
}

bool VermeerUser::getInternetAccessReaquired()
{
    return internetAccessReaquired;
}

void VermeerUser::setInternetAccessReaquired(bool newInternetAccessReaquired)
{
    internetAccessReaquired = newInternetAccessReaquired;
}

const QString &VermeerUser::getMissionStatus()
{
    return missionStatus;
}

void VermeerUser::setMissionStatus(const QString &newMissionStatus)
{
    missionStatus = newMissionStatus;
}

const QString &VermeerUser::getNodeStatus()
{
    return nodeStatus;
}

void VermeerUser::setNodeStatus(const QString &newNodeStatus)
{
    nodeStatus = newNodeStatus;
}
