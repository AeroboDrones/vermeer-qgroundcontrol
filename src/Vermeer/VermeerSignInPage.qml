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

/// @brief Native QML top level window
/// All properties defined here are visible to all QML pages.
ApplicationWindow {
    id:             mainWindow
    minimumWidth:   ScreenTools.isMobile ? Screen.width  : Math.min(ScreenTools.defaultFontPixelWidth * 100, Screen.width)
    minimumHeight:  ScreenTools.isMobile ? Screen.height : Math.min(ScreenTools.defaultFontPixelWidth * 50, Screen.height)
    visible:        true

    Component.onCompleted: {
        //-- Full screen on mobile or tiny screens
        if(ScreenTools.isMobile || Screen.height / ScreenTools.realPixelDensity < 120) {
            mainWindow.showFullScreen()
        } else {
            width   = ScreenTools.isMobile ? Screen.width  : Math.min(250 * Screen.pixelDensity, Screen.width)
            height  = ScreenTools.isMobile ? Screen.height : Math.min(150 * Screen.pixelDensity, Screen.height)
        }
    }

    VermeerFirebaseManager{
        id: vermeerFirebaseManager
        onDisplayMsgToQml: {
            console.log("onDisplayMsgToQml:")
            console.log(data)

            if("fetchFlightPlans" === data){
                console.log("fetching flight plans")
                vermeerFirebaseManager.fetchFlightPlans();
            }
            else if("InvalidSignIn") {
                vermeerInvalidCredentials.visible = true
            }
            else if("validSignIn") {
                // call a function that loads the MainRootWindow in C++
            }
        }
    }


    // error banner
    Rectangle {
        id: vermeerInvalidCredentials
        height: parent.height * .10
        width: parent.width
        color: "#d7003f"
        z: 1
        opacity: 0.90
        visible: false

        Text {
            id: vermeerInvalidCredentialsText
            text: qsTr("Invalid Credentials. Please try again.")
            color: "white"

            font.pointSize: 15
            anchors.centerIn: parent
        }
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
                text: qsTr("Email Address")
                color: "#5a5a5a"
                font.pointSize: 15
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.margins: 20
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
                text: qsTr("Password")
                color: "#5a5a5a"
                font.pointSize: 15
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.margins: 20
            }
        }

        Rectangle {
            id: vermeerLogInButton
            color: "#d7003f"
            height: parent.height * .10
            width: parent.width * .80
            x: parent.width * .10
            y: parent.height * .65

            MouseArea {
                id: vermeerLogInButtonMouseArea
                anchors.fill: parent

                onClicked: {
                    console.log("Press Loging In")
                    vermeerFirebaseManager.signIn(vermeerEmailAddressTextInput.text,vermeerPasswordTextInput.text)
                }
            }

            Text {
                id: vermeerLogInButtonText
                text: qsTr("Login")
                color: "White"
                font.pointSize: 15
                anchors.centerIn: parent
            }
        }
    }
}
