#include <QDir>
#include <QTextStream>
#include <QDebug>
#include <QDateTime>

#include "vermeerlogmanager.h"

VermeerLogManager::VermeerLogManager(QObject *parent)
    : QObject{parent}
{
}

void VermeerLogManager::deleteFileFromStorage()
{
    QFile vermeerUserLogs(QDir::currentPath() + QDir::separator() + filename);
    if(isFileExist()) {
        vermeerUserLogs.remove();
        qInfo() << Q_FUNC_INFO << " : " << filename << " deleted";
    }
}

void VermeerLogManager::log(QString logMessage)
{
    QDateTime dateTime = dateTime.currentDateTime();
    QFile vermeerUserLogs(QDir::currentPath() + QDir::separator() + filename);
    if(vermeerUserLogs.open(QFile::Append)){
        QTextStream logStream(&vermeerUserLogs);
        logStream << dateTime.toString("yyyy-MM-dd HH:mm:ss")<< ": " << logMessage << endl;
    }
    qInfo() << Q_FUNC_INFO << " : " << logMessage;
    vermeerUserLogs.close();
}

QString VermeerLogManager::readAllUlogs()
{
    QFile vermeerUserLogs(QDir::currentPath() + QDir::separator() + filename);
    QString logContent;
    if(isFileExist()){
        if(vermeerUserLogs.open(QIODevice::ReadOnly)){
            logContent = vermeerUserLogs.readAll();
        }
    } else {
        logContent = logContent + " does not exist";
        qInfo() << Q_FUNC_INFO << ": " << filename << " does not exist";
    }

    return logContent;
}

bool VermeerLogManager::isFileExist()
{
    QFile vermeerUserLogs(QDir::currentPath() + QDir::separator() + filename);
    return vermeerUserLogs.exists();
}
