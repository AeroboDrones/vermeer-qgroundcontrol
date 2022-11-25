#include <QJsonObject>
#include <QJsonArray>
#include <QString>
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QJsonObject>
#include <QJsonDocument>
#include <QStandardPaths>

#include "vermeermissionfilemanager.h"

VermeerMissionFileManager::VermeerMissionFileManager(QObject *parent)
    : QObject{parent}
{

}

QString VermeerMissionFileManager::getFileNamesJsonArray(QString missionDirectoryPath)
{
    QString directoryPath(missionDirectoryPath);
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
     return missionFilenamesJsonString;
}

QVariant VermeerMissionFileManager::getDownloadFilePath()
{
    QString downloadsFolder = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    return QVariant(downloadsFolder);
}
