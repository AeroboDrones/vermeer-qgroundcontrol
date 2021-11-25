#include "vermeerloginpage.h"


#include <QDir>
#include <QFile>
#include <QString>
#include <QByteArray>
#include <QFileInfo>


VermeerLogInPage::VermeerLogInPage(QObject *parent) : QObject(parent)
{
    connect(&socket,&QUdpSocket::readyRead,this,&VermeerLogInPage::readyRead);
}

QJsonObject VermeerLogInPage::readJsonFile(QString jsonFilePath)
{
     QFile jsonFile(jsonFilePath);
     QJsonDocument document;

     if(jsonFile.open(QIODevice::ReadOnly)) {

         QByteArray bytes = jsonFile.readAll();
          jsonFile.close();

          QJsonParseError jsonError;
          document = QJsonDocument::fromJson( bytes, &jsonError );

          if (jsonError.error != QJsonParseError::NoError) {
              QString msg = "VermeerLogInPage::readJsonFile: QJsonDocument::fromJson Failed with: " + jsonError.errorString();
              qInfo() << msg;
              emit(displayNotification(msg));
          }
     }

     return document.object();
}

void VermeerLogInPage::sendJson(QVariant filepath)
{
    QString fileName(filepath.toString());
    QFile file(fileName);
    if(!QFileInfo::exists(fileName)){
        QString msg = filepath.toString() +  ": does not exist";
        qInfo() << msg;
        emit(displayNotification(msg));
        return;
    }

    if(isConnected)
    {
        QString jsonFilePath = filepath.toString();

        QJsonObject jsonObject = readJsonFile(jsonFilePath);

        QJsonDocument doc(jsonObject);

        QString strJson(doc.toJson(QJsonDocument::Compact));

        QByteArray byteArrayJson = strJson.toUtf8();

        QNetworkDatagram datagram(byteArrayJson,QHostAddress(destinationIp),port);

        socket.writeDatagram(datagram);
    }
    else
    {
        QString msg = "Connect first";
        qInfo() << msg;
        emit(displayNotification(msg));
    }
}

void VermeerLogInPage::connectToCompanionComputer(QVariant sourceIpAddress,QVariant destinationIpAddress)
{
    sourceIp= sourceIpAddress.toString();
    destinationIp = destinationIpAddress.toString();

    if(!socket.bind(QHostAddress(sourceIp), port)) {
        QString msg = socket.errorString();
        qInfo() << msg;
        emit(displayNotification(msg));
        isConnected = false;
        return;
    }

    isConnected = true;
    QString msg =  "Started UDP on" + socket.localAddress().toString() + ":" + QString::number(socket.localPort());
    qInfo() << msg;
    emit(displayNotification(msg));
}

void VermeerLogInPage::disconnectFromCompanionComputer()
{
    socket.close();
    isConnected = false;
    QString msg =  "Socket Disconnected";
    qInfo() << msg;
    emit(displayNotification(msg));
}

void VermeerLogInPage::readyRead()
{
    while(socket.hasPendingDatagrams())
    {
        QNetworkDatagram datagram = socket.receiveDatagram();
        qInfo() << "Read: " << datagram.data();

        notificationData = datagram.data();
        emit(displayNotification(notificationData));
    }
}
