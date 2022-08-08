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
    id: vermeerSettingsPageToolBarQml
    height: parent.height * 0.15
    width: parent.width
    color: "#161618"

    VermeerFirebaseManager{
        id: vermeerFirebaseManager
    }

    VermeerLogManager {
        id: vermeerLogManager
    }

    Text {
        id: vermeerMissionText
        text: qsTr("SETTINGS")
        color: "white"
        font.pointSize: 30
        font.bold: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.05
        anchors.topMargin: parent.width * 0.05
    }

    Text {
        id: loggedInUser
        color: "white"
        font.pointSize: 15
        font.bold: true
        anchors.centerIn: parent
        visible: true
    }

    Component.onCompleted: {
        loggedInUser.text = vermeerFirebaseManager.getUserEmailAddress()
    }

    Rectangle {
        id: vermeerGoBackButton
        width: parent.width * 0.15
        height: parent.height * 0.70
        anchors.right: parent.right
        anchors.rightMargin: parent.width * 0.05
        anchors.topMargin: parent.width * 0.05
        anchors.verticalCenter: parent.verticalCenter
        color: Qt.rgba(0,0,0,0)

        Text {
            id: vermeerGoBackButtonText
            text: qsTr("GO BACK")
            font.pointSize: 15
            font.bold: true
            color: "white"
            anchors.centerIn: parent
        }

        MouseArea {
            id: vermeerGoBackButtonMouseArea
            anchors.fill: parent           
            onPressed: {
                vermeerGoBackButtonText.color = "black"
                vermeerGoBackButton.color = "white"
            }

            onReleased: {
                vermeerGoBackButtonText.color = "white"
                vermeerGoBackButton.color = "black"
                vermeerLogManager.log("SettingsPage: GoBack Button Pressed ")
                vermeerLoader.source = "VermeerMissionPage.qml"
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