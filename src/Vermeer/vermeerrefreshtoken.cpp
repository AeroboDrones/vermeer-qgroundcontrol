#include <QFile>
#include <QDir>
#include <QDebug>
#include <QJsonObject>
#include <QJsonDocument>

#include "vermeerrefreshtoken.h"

VermeerRefreshToken::VermeerRefreshToken(QObject *parent)
    : QObject{parent}
{
}

bool VermeerRefreshToken::exists() const
{
    QFile refreshTokenFile(QDir::currentPath() + QDir::separator() + refreshTokenFileName);
    return refreshTokenFile.exists();
}

QString VermeerRefreshToken::getRefreshToken()
{
    QString refreshToken;
    auto fileContent = _getFileContent();
    QJsonDocument doc = QJsonDocument::fromJson(fileContent.toUtf8());
    QJsonObject json = doc.object();

    if(json.contains("refresh_token")){
        refreshToken = json["refresh_token"].toString();
    }
    else{
       qInfo() << Q_FUNC_INFO << ": refresh file does not contain refresh_token key";
    }

    return refreshToken;
}

int VermeerRefreshToken::getExpiresIn()
{
    int expiresIn{0};
    auto fileContent = _getFileContent();
    QJsonDocument doc = QJsonDocument::fromJson(fileContent.toUtf8());
    QJsonObject json = doc.object();

    if(json.contains("expires_in")){
        expiresIn = json["expires_in"].toInt();
    }
    else{
       qInfo() << Q_FUNC_INFO << ": refresh file does not contain expires_in key";
    }

    return expiresIn;
}

QString VermeerRefreshToken::getUserEmail()
{
    QString userEmail;
    auto fileContent = _getFileContent();
    QJsonDocument doc = QJsonDocument::fromJson(fileContent.toUtf8());
    QJsonObject json = doc.object();

    if(json.contains("user_email")){
        userEmail = json["user_email"].toString();
    }
    else{
       qInfo() << Q_FUNC_INFO << ": refresh file does not contain user_email key";
    }
    return userEmail;
}

std::tuple<bool,QString>VermeerRefreshToken::save(QString refreshToken,QString UID, int expiresIn, QString userEmail)
{
    qInfo() << Q_FUNC_INFO << ": UID: " << UID;
    QFile refreshTokenFile(QDir::currentPath() + QDir::separator() + refreshTokenFileName);
    if(!refreshTokenFile.open(QIODevice::WriteOnly)) {
        qInfo() << refreshTokenFile.errorString();
        return std::make_tuple(false,"Unable to open file:  " + refreshTokenFile.errorString());
    }

    QJsonObject refreshTokenJson;
    refreshTokenJson["refresh_token"] = refreshToken;
    refreshTokenJson["UID"] = UID;
    refreshTokenJson["expires_in"] = expiresIn;
    refreshTokenJson["user_email"] = userEmail;
    QJsonDocument doc(refreshTokenJson);
    QString refreshTokenString(doc.toJson(QJsonDocument::Compact));
    qInfo() << Q_FUNC_INFO << ": " << refreshTokenString;
    refreshTokenFile.write(refreshTokenString.toUtf8());
    refreshTokenFile.close();
    return std::make_tuple(true,"save successfully");
}

QString VermeerRefreshToken::getUIDFromRefreshToken()
{
    QString uid;
    auto fileContent = _getFileContent();
    QJsonDocument doc = QJsonDocument::fromJson(fileContent.toUtf8());
    QJsonObject json = doc.object();

    if(json.contains("UID")){
        uid = json["UID"].toString();
    }
    else{
       qInfo() << Q_FUNC_INFO << ": refresh file does not contain UID key";
    }
    return uid;
}

bool VermeerRefreshToken::deleteRefreshToken()
{
    QFile refreshTokenFile(QDir::currentPath() + QDir::separator() + refreshTokenFileName);
    return refreshTokenFile.remove();
}

QString VermeerRefreshToken::_getFileContent()
{
    QString refreshTokenFileContent;
    QFile refreshTokenFile(QDir::currentPath() + QDir::separator() + refreshTokenFileName);
    if(refreshTokenFile.open(QIODevice::ReadOnly)) {
        refreshTokenFileContent = refreshTokenFile.readAll();
        refreshTokenFile.close();
    }
    return refreshTokenFileContent;
}
