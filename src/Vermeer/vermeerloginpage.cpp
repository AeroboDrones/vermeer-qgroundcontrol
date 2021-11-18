#include "vermeerloginpage.h"


#include <QDir>
#include <QFile>
#include <QString>
#include <QByteArray>
#include <QFileInfo>


VermeerLogInPage::VermeerLogInPage(QObject *parent) : QObject(parent)
{   
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
              qInfo() << "VermeerLogInPage::readJsonFile: QJsonDocument::fromJson Failed with: " + jsonError.errorString();
          }
     }

     return document.object();
}

void VermeerLogInPage::sendJson(QVariant filepath)
{
    QString fileName(filepath.toString());
    QFile file(fileName);
    if(!QFileInfo::exists(fileName)){
        qInfo() << filepath.toString() << ": does not exist";
        return;
    }

    if(isConnected)
    {
        QString jsonFilePath = filepath.toString();

        QJsonObject jsonObject = readJsonFile(jsonFilePath);

        QJsonDocument doc(jsonObject);

        QString strJson(doc.toJson(QJsonDocument::Compact));

        qInfo() << strJson;

        QByteArray byteArrayJson = strJson.toUtf8();

        QNetworkDatagram datagram(byteArrayJson,QHostAddress(destinationIp),port);

        socket.writeDatagram(datagram);
    }
    else
    {
         qInfo() << "Connect first";
    }
}

void VermeerLogInPage::connectToCompanionComputer(QVariant sourceIpAddress,QVariant destinationIpAddress)
{
    sourceIp= sourceIpAddress.toString();
    destinationIp = destinationIpAddress.toString();

    if(!socket.bind(QHostAddress(sourceIp), port)) {
        qInfo() << socket.errorString();
        isConnected = false;
        return;
    }

    isConnected = true;

    qInfo() << "Started UDP on" << socket.localAddress() << ":" << socket.localPort();
}

void VermeerLogInPage::disconnectFromCompanionComputer()
{
    socket.close();
    isConnected = false;
    qInfo() << "Socket Disconnected";
}
