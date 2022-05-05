/*
    Vermeer
    VermeerMissionListManager handles the storage of mission list in internet network denied environment
    VermeerMissionListManager stores missions in a local file while connected to the internet
    When there is no internet connection VermeerMissionListManager is used to load the saved missions localy
    This allows the mission page to function and allows the user to send missions to the GPU/companion
    computer on the drone side when there is no internet connections
*/

#ifndef VERMEERMISSIONLISTMANAGER_H
#define VERMEERMISSIONLISTMANAGER_H

#include <QObject>

class VermeerMissionListManager : public QObject
{
    Q_OBJECT
public:
    explicit VermeerMissionListManager(QObject *parent = nullptr);
    void saveMissionsList(QString filenameByUID,QString missionList);
    QString loadMissionFromFile(QString filenameByUID);
    bool isMissionFileEmpty(QString filenameByUID);
    bool missionFileExistsAndNotEmpty(QString filenameByUID);

signals:

};

#endif // VERMEERMISSIONLISTMANAGER_H
