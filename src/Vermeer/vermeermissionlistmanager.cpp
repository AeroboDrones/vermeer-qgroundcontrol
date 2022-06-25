#include <QFile>
#include <QDir>
#include <QDebug>

#include "vermeermissionlistmanager.h"

VermeerMissionListManager::VermeerMissionListManager(QObject *parent)
    : QObject{parent}
{

}

void VermeerMissionListManager::saveMissionsList(QString filenameByUID,QString missionList)
{
    QFile missionListFile(QDir::currentPath() + QDir::separator() + filenameByUID);
    if(!missionListFile.open(QIODevice::WriteOnly)) {
        qInfo() << missionListFile.errorString();
    }
    missionListFile.write(missionList.toUtf8());
    missionListFile.close();
}

QString VermeerMissionListManager::loadMissionFromFile(QString filenameByUID)
{
    QString missionFileContent;
    QFile missionListFile(QDir::currentPath() + QDir::separator() + filenameByUID);
    if(missionListFile.open(QIODevice::ReadOnly)) {
        missionFileContent = missionListFile.readAll();
        missionListFile.close();
    }
    return missionFileContent;
}

bool VermeerMissionListManager::missionFileExistsAndNotEmpty(QString filenameByUID)
{
    QFile missionListFile(QDir::currentPath() + QDir::separator() + filenameByUID);
    bool isFileNotEmpty{false};
    if(missionListFile.exists()) {
        qInfo() << Q_FUNC_INFO << ": missionListFile.exists(): " << missionListFile.exists();
        if(missionListFile.open(QIODevice::ReadOnly)) {
            isFileNotEmpty = !missionListFile.readAll().isEmpty();
            missionListFile.close();
            qInfo() << Q_FUNC_INFO <<  ": isFileNotEmpty: " << isFileNotEmpty;
            return isFileNotEmpty;
        }
    }
    return false;
}
