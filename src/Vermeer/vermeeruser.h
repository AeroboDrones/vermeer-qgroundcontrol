#ifndef VERMEERUSER_H
#define VERMEERUSER_H

#include <QObject>

class VermeerUser : public QObject
{
    Q_OBJECT
public:
    explicit VermeerUser(QObject *parent = nullptr);

    const QString &getEmail() const;
    void setEmail(const QString &newEmail);

    const QString &getPassword() const;
    void setPassword(const QString &newPassword);

    const QString &getAccessToken() const;
    void setAccessToken(const QString &newAccessToken);

    const QString &getUid() const;
    void setUid(const QString &newUid);

    const QString &getRefreshToken() const;
    void setRefreshToken(const QString &newRefreshToken);

signals:

private:
    QString email;
    QString password;
    QString accessToken;
    QString uid;
    QString refreshToken;
};

#endif // VERMEERUSER_H
