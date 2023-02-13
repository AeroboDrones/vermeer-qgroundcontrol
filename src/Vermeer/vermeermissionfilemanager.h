#ifndef VERMEERMISSIONFILEMANAGER_H
#define VERMEERMISSIONFILEMANAGER_H

#include <QObject>
#include <QVariant>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

#include "Vermeer/vermeerlogmanager.h"

class VermeerMissionFileManager : public QObject
{
    Q_OBJECT
public:
    explicit VermeerMissionFileManager(QObject *parent = nullptr);

    QJsonObject filenameToFilePathJson;



signals:

public slots:
    QString getFileNamesJsonArray(QString missionDirectoryPath);
    QVariant getDownloadFilePath();
    QVariant getMissionFilenamesRecursively();
    QString getAbsoluteFilePathFromMisionFilename(QString missionFilename);

private:
    VermeerLogManager vermeerLogManager;

};

#endif // VERMEERMISSIONFILEMANAGER_H
