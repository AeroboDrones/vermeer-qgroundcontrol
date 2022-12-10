#ifndef VERMEERMISSIONFILEMANAGER_H
#define VERMEERMISSIONFILEMANAGER_H

#include <QObject>
#include <QVariant>

class VermeerMissionFileManager : public QObject
{
    Q_OBJECT
public:
    explicit VermeerMissionFileManager(QObject *parent = nullptr);

signals:

public slots:
    QString getFileNamesJsonArray(QString missionDirectoryPath);
    QVariant getDownloadFilePath();
    void saveMissionFilePath(QVariant missionFilePath);
    QVariant getMissionFilePath();

private:
    QString missionFilePathFilename{"missionFilePath.txt"};
};

#endif // VERMEERMISSIONFILEMANAGER_H
