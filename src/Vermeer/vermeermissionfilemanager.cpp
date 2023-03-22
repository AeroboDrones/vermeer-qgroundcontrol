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

QString VermeerMissionFileManager::getMissionJsonRecursively()
{
    //QString userFilePath = "\\This PC\\Galaxy Tab Active3\\Internal storage\\Android\\data\\com.Vermeer.Augnav\files\\database\flightPlans";

    QString userFilePath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    userFilePath += "/Android/data/org.mavlink.qgroundcontrol/files/database/flightPlans/";

    QDir directory(userFilePath);
    QJsonArray missionFileNames;
    QJsonDocument doc;

    QStringList missionFilenameList;

    QDirIterator directories(userFilePath, QStringList() << "*.json",QDir::Files, QDirIterator::Subdirectories);
    while(directories.hasNext()){
           directories.next();
           missionFilenameList.push_back(directories.filePath());
    }

    foreach(QString missionFileName, missionFilenameList) {

        qInfo() << missionFileName;
        QJsonObject missionFilenameJson;
        missionFilenameJson.insert("filename",QJsonValue(missionFileName));
        missionFileNames.push_back(QJsonValue(missionFilenameJson));
    }

    doc.setArray(missionFileNames);
    QString missionFilenamesJsonString = doc.toJson();
    return missionFilenamesJsonString;
}

QVariant VermeerMissionFileManager::getThisFilePath()
{
    QString downloadsFolder = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    return QVariant(downloadsFolder);
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
