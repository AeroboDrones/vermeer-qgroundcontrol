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
