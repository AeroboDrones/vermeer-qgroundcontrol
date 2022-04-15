#ifndef VERMEERLOGMANAGER_H
#define VERMEERLOGMANAGER_H

#include <QObject>
#include <QFile>
#include <QDir>

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
