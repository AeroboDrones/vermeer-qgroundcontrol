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

void VermeerMissionFileManager::saveMissionFilePath(QVariant missionFilePath)
{
    QFile missionFilePathFile(QDir::currentPath() + QDir::separator() + missionFilePathFilename);
    if(missionFilePathFile.open(QFile::WriteOnly)){
        QTextStream logStream(&missionFilePathFile);
        logStream << missionFilePath.toString();
    }
    missionFilePathFile.close();
}

QVariant VermeerMissionFileManager::getMissionFilePath()
{
    QFile missionFilePathFile(QDir::currentPath() + QDir::separator() + missionFilePathFilename);
    QString missionFilePathString{"replace with mission file path"};
    if(missionFilePathFile.exists()) {
        if(missionFilePathFile.open(QIODevice::ReadOnly)) {
            missionFilePathString = missionFilePathFile.readAll();
        }
    } else {
        qInfo() << Q_FUNC_INFO << ": " << missionFilePathFilename << " does not exist";
    }
    return missionFilePathString;
}
