/*
    Vermeer
    VermeerLogManager handles the telemetry loogging(TLogs) and User Logs (ULogs)
    UserLogs are stored in a file and displayed on the Ulogs page because it is expected to be less frequent than TLogs
    TLogs are stored in memory and displayed on TLogs page because the Companion Computer/GPU on the drone is expected
    to flood the Tlogs
    Small Cavient: with Tlogs, as soon as the user navigates away from the mission page the the memory which TLogs are
    stored are cleared. However, ULogs can be displayed to the Ulogs page because the ULogs are being stored in a file
*/


#ifndef VERMEERLOGMANAGER_H
#define VERMEERLOGMANAGER_H

#include <QObject>
#include <QFile>
#include <QDir>
#include <QTimer>

class VermeerLogManager : public QObject
{
    Q_OBJECT
public:
    explicit VermeerLogManager(QObject *parent = nullptr);

signals:

public slots:
    void deleteFileFromStorage();
    void log(QString logMessage);
    QString readAllUlogs();
    bool isFileExist();

private:
    QString filename{"VermeerUserLogs.txt"};
};

#endif // VERMEERLOGMANAGER_H
