#ifndef VERMEERKEYFRAME_H
#define VERMEERKEYFRAME_H

#include "vermeermissionitem.h"

#include <QObject>

class VermeerKeyFrame : public QObject
{
    Q_OBJECT
    //Q_PROPERTY(double createdAt READ getCreatedAt)
public:
    //explicit VermeerKeyFrame(QObject *parent = nullptr);
    VermeerKeyFrame(QObject *parent = nullptr);

    void toVermeerKeyFrameFromJson(QJsonObject vermeerKeyFrameJson);
    QList<VermeerMissionItem> toMissionItems(QJsonArray missionItemsJson);

    QString getMissionItemsJson(QJsonObject vermeerKeyFrameJson);

//    QList<QVariant> getKeyFrameMissionItemList();

    // maybe make its const
    double createdAt;
    QString id;
    QString locationName;
    QString mission3dId;
    int missionType;
    QString name;
    QString uid;
    int vehicleType;

    QList<VermeerMissionItem> missionItems;

signals:


private:


};

#endif // VERMEERKEYFRAME_H
