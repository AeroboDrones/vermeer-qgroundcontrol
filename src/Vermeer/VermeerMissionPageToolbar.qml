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

Rectangle {
    id: vermeerMssionPageToolBarQml
    height: parent.height * 0.15
    width: parent.width
    color: "#161618"

    VermeerFirebaseManager{
        id: vermeerFirebaseManager
        onDisplayMsgToQml: {
            console.log("vermeerMssionPageToolBarQml:" + data)
            if("NoInternet"===data){
                onlineStatusCircle.color = "red"
            }
            else if ("HasInternet"===data) {
                 onlineStatusCircle.color = "green"
            }
        }
    }

    Component.onCompleted: {
        console.log("vermeerMssionPageToolBarQml: Component.onCompleted:")
        loggedInUser.text = vermeerFirebaseManager.getUserEmailAddress()
    }

    Text {
        id: vermeerMissionText
        text: qsTr("MISSIONS")
        color: "white"
        font.pointSize: 30
        font.bold: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.05
        anchors.topMargin: parent.width * 0.05
    }

    Rectangle {
        id: onlineStatusCircle
        width: 100
        height: 100
        anchors.left: vermeerMissionText.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 50
        border.color: "green"
        border.width: 5
        color: "green"
        radius: width

    }

    Text {
        id: loggedInUser
        color: "white"
        font.pointSize: 15
        font.bold: true
        anchors.centerIn: parent
    }
    // testing refresh token
    Rectangle {
        id: vermerDeleteRttest
        visible: false // set to true for testing refresh token
        width: parent.width * 0.15
        height: parent.height * 0.70
        anchors.right: vermeerSettingsButton.left
        anchors.rightMargin: parent.width * 0.001
        anchors.topMargin: parent.width * 0.05
        anchors.verticalCenter: parent.verticalCenter
        border.width: 5
        border.color: "white"
        color: Qt.rgba(0,0,0,0)

        Text {
            id: vermerDeleteRttestText
            text: qsTr("Delete RT")
            font.pointSize: 15
            font.bold: true
            color: "white"
            anchors.centerIn: parent
        }

        MouseArea {
            id:vermerDeleteRttestMouseArea
            anchors.fill: parent
            onClicked: {
                //vermeerFirebaseManager.deleteRefreshToken()
                //vermeerFirebaseManager.socketDisconnect()
            }
        }
    }

    Rectangle {
        id: vermeerMakeRefreshTokenInvalid
        visible: false // set to true for testing refresh token
        width: parent.width * 0.15
        height: parent.height * 0.70
        anchors.right: vermerDeleteRttest.left
        anchors.rightMargin: parent.width * 0.001
        anchors.topMargin: parent.width * 0.05
        anchors.verticalCenter: parent.verticalCenter
        border.width: 5
        border.color: "white"
        color: Qt.rgba(0,0,0,0)

        Text {
            id: vermeerMakeRefreshTokenInvalidText
            text: qsTr("make RT Invalid")
            font.pointSize: 15
            font.bold: true
            color: "white"
            anchors.centerIn: parent
        }

        MouseArea {
            id:vermeerMakeRefreshTokenInvalidMouseArea
            anchors.fill: parent
            onClicked: {
                vermeerFirebaseManager.makeRtInvalid()
                //vermeerFirebaseManager.socketConnect()
            }
        }
    }
    // end for testing refresh token

    Rectangle {
        id: vermeerSettingsButton
        width: parent.width * 0.15
        height: parent.height * 0.70
        anchors.right: vermeerSignOutButton.left
        anchors.rightMargin: parent.width * 0.001
        anchors.topMargin: parent.width * 0.05
        anchors.verticalCenter: parent.verticalCenter
        color: Qt.rgba(0,0,0,0)

        Text {
            id: vermeerSettingsButtonText
            text: qsTr("Settings")
            font.pointSize: 15
            font.bold: true
            color: "white"
            anchors.centerIn: parent
        }

        MouseArea {
            id:vermeerSettingsButtonMouseArea
            anchors.fill: parent
            onClicked: {
                vermeerLoader.source = "VermeerSettingsPage.qml"
            }
        }
    }

    Rectangle {
        id: vermeerSignOutButton
        width: parent.width * 0.15
        height: parent.height * 0.70
        border.color: "white"
        border.width: 5
        anchors.right: parent.right
        anchors.rightMargin: parent.width * 0.05
        anchors.topMargin: parent.width * 0.05
        anchors.verticalCenter: parent.verticalCenter
        color: Qt.rgba(0,0,0,0)

        Text {
            id: vermeerSignOutButtonText
            text: qsTr("Sign Out")
            font.pointSize: 15
            font.bold: true
            color: "white"
            anchors.centerIn: parent
        }

        MouseArea {
            id:vermeerSignOutButtonMouseArea
            anchors.fill: parent           
            onPressed: {
                vermeerSignOutButtonText.color = "black"
                vermeerSignOutButton.color = "white"
            }
            onReleased: {
                vermeerSignOutButtonText.color = "white"
                vermeerSignOutButton.color = "black"
                vermeerFirebaseManager.setSignOutFlag(true)
                vermeerFirebaseManager.deleteRefreshToken()
                vermeerLoader.source = "VermeerSignInPage.qml"
            }
        }
    }

    Rectangle {
        id: line
        width: parent.width
        height: 5
        anchors.bottom: parent.bottom
        color:"#262626"
    }
}
