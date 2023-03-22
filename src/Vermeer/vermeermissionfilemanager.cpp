#include <QJsonObject>
#include <QJsonArray>
#include <QString>
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QJsonObject>
#include <QJsonDocument>
#include <QStandardPaths>
#include <QDirIterator>

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

QVariant VermeerMissionFileManager::getMissionFilenamesRecursively()
{
    QString userFilePath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    userFilePath += "/com.Vermeer.Augnav/files/database/flightPlans";

    try {
        QJsonArray missionFileNames;
        QJsonDocument doc;
        QStringList missionFilenameList;
        QDirIterator directories(userFilePath, QStringList() << "*.json",QDir::Files, QDirIterator::Subdirectories);
        while(directories.hasNext()){
               directories.next();

               QString missionJsonString;
               QFile file(directories.filePath());
               if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
                   QTextStream in(&file);
                   missionJsonString = in.readAll();
                   file.close();
               }

               QJsonDocument missionJsonDocument = QJsonDocument::fromJson(missionJsonString.toUtf8());
               QJsonObject missionJsonObject = missionJsonDocument.object();
               QString missionName = missionJsonObject.value("name").toString();

               filenameToFilePathJson[missionName] = directories.filePath();
               missionFilenameList.push_back(missionName);
        }

        foreach(QString missionFileName, missionFilenameList) {
            QJsonObject missionFilenameJson;
            missionFilenameJson.insert("filename",QJsonValue(missionFileName));
            missionFileNames.push_back(QJsonValue(missionFilenameJson));
        }

        doc.setArray(missionFileNames);
        QString missionFilenamesJsonString = doc.toJson();
        return missionFilenamesJsonString;
    } catch (const char* exception) {
        qInfo() << "Error: " << exception;
        return exception;
    }
}

QString VermeerMissionFileManager::getAbsoluteFilePathFromMisionFilename(QString missionFilename)
{
    return filenameToFilePathJson[missionFilename].toString();
}
