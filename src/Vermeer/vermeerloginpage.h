#ifndef VERMEERLOGINPAGE_H
#define VERMEERLOGINPAGE_H

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

class VermeerLogInPage : public QObject
{
    Q_OBJECT
public:
    explicit VermeerLogInPage(QObject *parent = nullptr);
    QJsonObject readJsonFile(QString jsonFilePath);

signals:
    void displayNotification(QVariant data);

public slots:

    void sendJson(QVariant filePath);
    void connectToCompanionComputer(QVariant sourceIpAddress,QVariant destinationIpAddress);
    void disconnectFromCompanionComputer();
    void readyRead();

private:
    QUdpSocket socket;
    quint16 port{14555};
    bool isConnected = false;
    QString sourceIp;
    QString destinationIp;
    QString notificationData;

};

#endif // VERMEERLOGINPAGE_H
