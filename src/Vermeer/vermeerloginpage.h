#ifndef VERMEERLOGINPAGE_H
#define VERMEERLOGINPAGE_H

#include "vermeerkeyframe.h"

#include <QObject>
#include <QDebug>

#include <QVariant>

#include <QJsonDocument>
#include <QJsonParseError>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>

#include <QUdpSocket>
#include <QNetworkDatagram>

#include <QHostAddress>
#include <QNetworkInterface>
#include <QAbstractSocket>

#include <QList>

class VermeerLogInPage : public QObject
{
    Q_OBJECT

    Q_PROPERTY(VermeerKeyFrame* vermeerKeyFrame READ getVermeerKeyFrame)
    Q_PROPERTY(int testInt READ readTestInt)

public:
    explicit VermeerLogInPage(QObject *parent = nullptr);
    QJsonObject readJsonFile(QString jsonFilePath);

    VermeerKeyFrame* getVermeerKeyFrame();
    int readTestInt();

    // need qproperty

    // need accesor

signals:
    void displayNotification(QVariant data);

public slots:

    void sendJson(QVariant filePath);
    // How to set it on on c++ so QML can access data instead of a function returning data?

    void connectToCompanionComputer(QVariant sourceIpAddress,QVariant destinationIpAddress);
    void disconnectFromCompanionComputer();
    void readyRead();
    QVariant getKeyFrameMissionItems(QVariant keyframeJsonFilePath);

private:
    QUdpSocket socket;
    quint16 port{14555};
    bool isConnected = false;
    QString sourceIp;
    QString destinationIp;
    QString notificationData;

    VermeerKeyFrame vermeerKeyFrame;

    int _testInt = 0;


};

#endif // VERMEERLOGINPAGE_H
