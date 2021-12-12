#ifndef VERMEERMISSIONITEM_H
#define VERMEERMISSIONITEM_H

class VermeerMissionItem : public QObject
{

public:
    VermeerMissionItem();
//    void fromJson(QJsonObject missionItemJson);

    double acceptanceRadiusM;
    int cameraAction;
    int cameraPhotoIntervalS;
    double gimbalPitchDeg;
    double gimbalYawDeg;
    bool isFlyThrough;
    double latitudeDeg;
    int loiterTimeS;
    double longitudeDeg;
    double relativeAltitudeM;
    double speedMs;
    double yawDeg;

private:



};

#endif // VERMEERMISSIONITEM_H
