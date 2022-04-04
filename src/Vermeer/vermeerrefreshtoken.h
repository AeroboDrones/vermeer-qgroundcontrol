#ifndef VERMEERREFRESHTOKEN_H
#define VERMEERREFRESHTOKEN_H

#include <QObject>

class VermeerRefreshToken : public QObject
{
    Q_OBJECT
public:
    explicit VermeerRefreshToken(QObject *parent = nullptr);
    bool exists() const;
    QString getRefreshToken();
    int getExpiresIn();
    QString getUserEmail();
    std::tuple<bool,QString> save(QString const refreshToken,QString UID,int expiresIn,QString userEmail);
    QString getUIDFromRefreshToken();
    bool deleteRefreshToken();

signals:

private:
    QString _getFileContent();

    const QString refreshTokenFileName{"refreshTokenFile.txt"};

};

#endif // VERMEERREFRESHTOKEN_H
