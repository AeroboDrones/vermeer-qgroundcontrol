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

    VermeerFirebaseManager{
        id: vermeerFirebaseManager
        onDisplayMsgToQml: {
            console.log("onDisplayMsgToQml:")
            console.log(data)

            if("validSignIn" === data){
                console.log("Valid Credentials")
                vermeerLoader.source = "VermeerMissionPage.qml"
            }
            else if("InvalidSignIn" === data) {
                console.log("vermeerInvalidCredentials.visible = true")
                vermeerSigningInQml.z = 0
                vermeerInvalidCredentials.visible = true
            }
        }
    }

    Component.onCompleted: {
        vermeerEmailAddressTextInput.text = vermeerFirebaseManager.getUserEmailAddress()
        vermeerPasswordTextInput.text = vermeerFirebaseManager.getUserPassword()
    }

    // error banner
    Rectangle {
        id: vermeerInvalidCredentials
        height: parent.height * .10
        width: parent.width
        color: "#25050b"
        z: 1
        opacity: 0.90
        visible: false

        Text {
            id: vermeerInvalidCredentialsText
            text: qsTr("Invalid Credentials. Please try again.")
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

            MouseArea {
                id: vermeerLogInButtonMouseArea
                anchors.fill: parent

                onClicked: {
                    console.log("Press Loging In")
                    vermeerFirebaseManager.signIn(vermeerEmailAddressTextInput.text,vermeerPasswordTextInput.text)
                    vermeerSigningInQml.z = 2
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
