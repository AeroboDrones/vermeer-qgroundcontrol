#ifndef VERMEERLOGINPAGE_H
#define VERMEERLOGINPAGE_H

#include <QObject>
#include <QDebug>

#include <QJsonDocument>
#include <QJsonParseError>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>

class VermeerLogInPage : public QObject
{
    Q_OBJECT
public:
    explicit VermeerLogInPage(QObject *parent = nullptr);

    QJsonObject readJsonFile(QString jsonFilePath);

signals:

public slots:

    bool sendJson(QString filePath);

};

#endif // VERMEERLOGINPAGE_H
