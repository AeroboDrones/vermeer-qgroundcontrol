#include "vermeerkeyframe.h"

VermeerKeyFrame::VermeerKeyFrame(QObject *parent)
    : QObject{parent}
{

}

//VermeerKeyFrame::VermeerKeyFrame()
//{

//}

void VermeerKeyFrame::toVermeerKeyFrameFromJson(QJsonObject vermeerKeyFrameJson)
{
    createdAt = vermeerKeyFrameJson["createdAt"].toDouble();
    id = vermeerKeyFrameJson["id"].toString();
    locationName = vermeerKeyFrameJson["locationName"].toString();
    mission3dId = vermeerKeyFrameJson["mission3dId"].toString();
    missionType = vermeerKeyFrameJson["mission3dId"].toInt();
    name = vermeerKeyFrameJson["mission3dId"].toString();
    uid = vermeerKeyFrameJson["uid"].toString();
    vehicleType = vermeerKeyFrameJson["vehicleType"].toInt();

    missionItems = toMissionItems(vermeerKeyFrameJson["missionItems"].toArray());
}

QList<VermeerMissionItem> VermeerKeyFrame::toMissionItems(QJsonArray missionItemsJson)
{
    QList<VermeerMissionItem> localVermeerMissionItems;

//    for (int idx=0; idx < missionItemsJson.count(); idx++) {
//         QJsonObject eachMissionItemJson = missionItemsJson[idx].toObject();

//         VermeerMissionItem missionItem;

//         missionItem.acceptanceRadiusM = eachMissionItemJson["acceptanceRadiusM"].toDouble();
//         missionItem.cameraAction = eachMissionItemJson["cameraAction"].toInt();
//         missionItem.cameraPhotoIntervalS = eachMissionItemJson["cameraPhotoIntervalS"].toInt();
//         missionItem.gimbalPitchDeg = eachMissionItemJson["gimbalPitchDeg"].toDouble();
//         missionItem.gimbalYawDeg = eachMissionItemJson["gimbalYawDeg"].toDouble();
//         missionItem.isFlyThrough = eachMissionItemJson["isFlyThrough"].toBool();
//         missionItem.latitudeDeg = eachMissionItemJson["latitudeDeg"].toDouble();
//         missionItem.loiterTimeS = eachMissionItemJson["loiterTimeS"].toInt();
//         missionItem.longitudeDeg = eachMissionItemJson["longitudeDeg"].toDouble();
//         missionItem.relativeAltitudeM = eachMissionItemJson["relativeAltitudeM"].toDouble();
//         missionItem.speedMs = eachMissionItemJson["speedMs"].toDouble();
//         missionItem.yawDeg = eachMissionItemJson["yawDeg"].toDouble();

//         localVermeerMissionItems.append(missionItem);
//    }


    foreach (const QJsonValue & eachMissionItem, missionItemsJson) {
        QJsonObject eachMissionItemJson = eachMissionItem.toObject();

        VermeerMissionItem missionItem;
        //auto pMissionItem = std::make_unique<VermeerMissionItem>();

        missionItem.acceptanceRadiusM = eachMissionItemJson["acceptanceRadiusM"].toDouble();
        missionItem.cameraAction = eachMissionItemJson["cameraAction"].toInt();
        missionItem.cameraPhotoIntervalS = eachMissionItemJson["cameraPhotoIntervalS"].toInt();
        missionItem.gimbalPitchDeg = eachMissionItemJson["gimbalPitchDeg"].toDouble();
        missionItem.gimbalYawDeg = eachMissionItemJson["gimbalYawDeg"].toDouble();
        missionItem.isFlyThrough = eachMissionItemJson["isFlyThrough"].toBool();
        missionItem.latitudeDeg = eachMissionItemJson["latitudeDeg"].toDouble();
        missionItem.loiterTimeS = eachMissionItemJson["loiterTimeS"].toInt();
        missionItem.longitudeDeg = eachMissionItemJson["longitudeDeg"].toDouble();
        missionItem.relativeAltitudeM = eachMissionItemJson["relativeAltitudeM"].toDouble();
        missionItem.speedMs = eachMissionItemJson["speedMs"].toDouble();
        missionItem.yawDeg = eachMissionItemJson["yawDeg"].toDouble();

        localVermeerMissionItems.append(std::move(missionItem));
    }

    return localVermeerMissionItems;
}

QString VermeerKeyFrame::getMissionItemsJson(QJsonObject vermeerKeyFrameJson)
{
    QJsonArray jsonArray = vermeerKeyFrameJson["missionItems"].toArray();

    QJsonDocument jsondoc;

    jsondoc.setArray(jsonArray);

    QString vermeerMissionItemsJson(jsondoc.toJson());

    return vermeerMissionItemsJson;
}
