#include "vermeeruser.h"

VermeerUser::VermeerUser(QObject *parent)
    : QObject{parent}
{

}

const QString &VermeerUser::getEmail() const
{
    return email;
}

void VermeerUser::setEmail(const QString &newEmail)
{
    email = newEmail;
}

const QString &VermeerUser::getPassword() const
{
    return password;
}

void VermeerUser::setPassword(const QString &newPassword)
{
    password = newPassword;
}

const QString &VermeerUser::getAccessToken() const
{
    return accessToken;
}

void VermeerUser::setAccessToken(const QString &newAccessToken)
{
    accessToken = newAccessToken;
}

const QString &VermeerUser::getUid() const
{
    return uid;
}

void VermeerUser::setUid(const QString &newUid)
{
    uid = newUid;
}

const QString &VermeerUser::getRefreshToken() const
{
    return refreshToken;
}

void VermeerUser::setRefreshToken(const QString &newRefreshToken)
{
    refreshToken = newRefreshToken;
}
