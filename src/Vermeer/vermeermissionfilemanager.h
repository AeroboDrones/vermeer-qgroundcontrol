#ifndef VERMEERMISSIONFILEMANAGER_H
#define VERMEERMISSIONFILEMANAGER_H

#include <QObject>

class VermeerMissionFileManager : public QObject
{
    Q_OBJECT
public:
    explicit VermeerMissionFileManager(QObject *parent = nullptr);

signals:

public slots:
    QVariant getFileNamesJsonArray(QVariant missionDirectoryPath);


};

#endif // VERMEERMISSIONFILEMANAGER_H
