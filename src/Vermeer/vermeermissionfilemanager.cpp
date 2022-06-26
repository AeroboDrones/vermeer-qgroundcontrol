#include <QJsonObject>
#include <QJsonArray>
#include <QString>
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QJsonObject>
#include <QJsonDocument>

#include "vermeermissionfilemanager.h"

VermeerMissionFileManager::VermeerMissionFileManager(QObject *parent)
    : QObject{parent}
{

}

QVariant VermeerMissionFileManager::getFileNamesJsonArray(QVariant missionDirectoryPath)
{
    QString directoryPath(missionDirectoryPath.toString());
    QDir directory(directoryPath);

    QJsonArray missionFileNames;
    QJsonDocument doc;

     QStringList missionFilenameList = directory.entryList(QStringList() << "*.json",QDir::Files);
     foreach(QString missionFileName, missionFilenameList) {
         QJsonObject missionFilenameJson;
         missionFilenameJson.insert("filename",QJsonValue(missionFileName));
         missionFileNames.push_back(QJsonValue(missionFilenameJson));
     }
     doc.setArray(missionFileNames);
     QString missionFilenamesJsonString = doc.toJson();

     return QVariant(missionFilenamesJsonString);
}
