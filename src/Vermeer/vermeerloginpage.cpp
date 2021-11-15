#include "vermeerloginpage.h"


#include <QDir>
#include <QFile>
#include <QString>
#include <QByteArray>

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

bool VermeerLogInPage::sendJson(QString filepath)
{





    return true;
}
