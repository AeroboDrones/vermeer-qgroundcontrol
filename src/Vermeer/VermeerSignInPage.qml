/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick          2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs  1.3
import QtQuick.Layouts  1.11
import QtQuick.Window   2.11

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0

Item {
    id: vermeerSignInQml

    property string invalidCredentialMessage: "Invalid Credentials. Please try again."
    property string invalidRefreshToken: "Invalid Refresh Token. Please sign in."
    property string noNetworkConnectionMessage: "No Network Connection."
    property string cantLogInNoInternetConnection: "Can't Log in. No Internet Connection."

    function showSignInPage() {
        vermeerSignInQml.visible = true
        vermeerSignInQml.z = 2
    }

    function showSigningInPage() {
        vermeerSigningInQml.visible = true
        vermeerSigningInQml.z = 2
    }

    function pushBackSigningInPage() {
        vermeerSigningInQml.visible = false
        vermeerSigningInQml.z = 0
    }

    function showErrorBanner(msg) {
        vermeerSignInPageErrorBanner.visible = true
        vermeerSignInPageErrorBannerText.text = msg
    }

    function loadPage(pageString) {
        vermeerLoader.source = pageString
    }

    VermeerLogManager{
        id: vermeerLogManager
    }

    VermeerFirebaseManager{
        id: vermeerFirebaseManager
        onDisplayMsgToQml: {
            if("validEmailAndPassSignIn" === data) {
                console.log("vermeerSignInQml:" + data)
                console.log("Valid Credentials")
                vermeerFirebaseManager.saveRefreshToken()
                loadPage("VermeerMissionPage.qml")
            }
            else if ("validRefreshTokenSignIn" === data){
                console.log("vermeerSignInQml:" + data)
                console.log("Valid RefreshToken")
                vermeerFirebaseManager.loadUserEmailFromFile()
                vermeerFirebaseManager.saveRefreshToken()
                loadPage("VermeerMissionPage.qml")
            }

            else if("InvalidSignIn" === data) {
                console.log("vermeerSignInPageErrorBanner.visible = true")
                pushBackSigningInPage()
                showErrorBanner(invalidCredentialMessage);
            }
            else if("InvalidRefreshToken" === data) {
                console.log("InvalidRefreshToken")
                pushBackSigningInPage()
                showErrorBanner(invalidRefreshToken);
            }
            else if("ValidOfflineSignIn" === data) {
                loadPage("VermeerMissionPage.qml")
            }
            else if("NoInternetConnection" === data){
                pushBackSigningInPage()
                showSignInPage()
                showErrorBanner(cantLogInNoInternetConnection)
            }
        }
    }

    Component.onCompleted: {

        var hasInternetConnection = vermeerFirebaseManager.hasInternetConnection()

        if (!hasInternetConnection) {
            showErrorBanner(noNetworkConnectionMessage)
        }

        if(!vermeerFirebaseManager.isSignOutButtonPressed()) {
            var isRefreshTokenExist = vermeerFirebaseManager.isRefreshTokenExist()
            console.log("isRefreshTokenExist: " + isRefreshTokenExist)

            if(isRefreshTokenExist) {
                if(hasInternetConnection) {
                    vermeerLogManager.log("SignInPage: refresh token exist and we have internet, signing in with refresh token")
                    vermeerFirebaseManager.signInWithRefreshToken()
                    showSigningInPage()
                } else {
                    vermeerLogManager.log("SignInPage: refresh token exist and we don't have internet, signing in offline")
                    vermeerFirebaseManager.signInOffline()
                    showSigningInPage()
                }
            }
        }

        vermeerFirebaseManager.setSignOutFlag(false)
        vermeerEmailAddressTextInput.text = vermeerFirebaseManager.getUserEmailAddress()
        vermeerPasswordTextInput.text = vermeerFirebaseManager.getUserPassword()
    }

    Rectangle {
        id: vermeerSignInPageErrorBanner
        height: parent.height * .10
        width: parent.width
        color: "#25050b"
        z: 1
        opacity: 0.90
        visible: false

        Text {
            id: vermeerSignInPageErrorBannerText
            text: qsTr("...")
            color: "#8b5862"
            font.pointSize: 15
            anchors.centerIn: parent
        }
    }

    VermeerSigningInPage{
        id: vermeerSigningInQml
    }

    // vermeer logo
    Rectangle {
        id : vermeerLogoSignInPage
        height: parent.height
        width: parent.width/2
        color: "#161618"
        x:0

        Image {
            id: vermeerLogo
            source: "/vermeer/VermeerSignInLogoLeftPng"
            anchors.centerIn: parent
            height: parent.height
            width: parent.width
        }
    }

    // for the sign in
    Rectangle {
        id: vermeerSignIn
        height: parent.height
        width: parent.width / 2
        color: "#161618"
        x: parent.width / 2

        Rectangle {
            id: vermeerSignInText
            color: "#161618"
            height: parent.height * .10
            width: parent.width * .80
            x: parent.width * .10
            y: parent.height * .25

            TextInput {
                id: vermeerSignInTextInput
                text: qsTr("Sign In")
                color: "white"
                font.pointSize: 25
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
            }
        }

        Rectangle {
            id: vermeerEmailAddress
            color: "#282828"
            height: parent.height * .10
            width: parent.width * .80
            x: parent.width * .10
            y: parent.height * .35

            TextInput {
                id: vermeerEmailAddressTextInput
                text: qsTr("czarbalangue@gmail.com")
                color: "#5a5a5a"
                font.pointSize: 15
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.margins: 20
                anchors.fill: parent
            }
        }

        Rectangle {
            id: vermeerPassword
            color: "#282828"
            height: parent.height * .10
            width: parent.width * .80
            x: parent.width * .10
            y: parent.height * .50

            TextInput {
                id: vermeerPasswordTextInput
                text: qsTr("aaaaaa")
                color: "#5a5a5a"
                font.pointSize: 15
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.margins: 20
                anchors.fill: parent
            }
        }

        Rectangle {
            id: vermeerLogInButton
            color: "#d7003f"
            height: parent.height * .10
            width: parent.width * .80
            x: parent.width * .10
            y: parent.height * .65

            Text {
                id: vermeerLogInButtonText
                text: qsTr("Login")
                color: "White"
                font.pointSize: 15
                anchors.centerIn: parent
            }

            MouseArea {
                id: vermeerLogInButtonMouseArea
                anchors.fill: parent
                onPressed: {
                    vermeerLogInButtonText.color = "#d7003f"
                    vermeerLogInButton.color = "white"
                }
                onReleased: {
                    vermeerLogInButtonText.color = "white"
                    vermeerLogInButton.color = "#d7003f"
                    console.log("Loging In Button Released")

                    var logMsg = "SignInPage: Signing is as " + vermeerEmailAddressTextInput.text;
                    vermeerLogManager.log(logMsg)

                    showSigningInPage()
                    vermeerFirebaseManager.signInWithEmailAndPassword(vermeerEmailAddressTextInput.text,vermeerPasswordTextInput.text)
                }
            }
        }
    }
}
