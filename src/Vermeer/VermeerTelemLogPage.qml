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
    id: vermeerTelemLogPage

    property date currentDate: new Date()

    Component.onCompleted: {
        vermeerFirebaseManager.bindSocket()
    }

    VermeerFirebaseManager {
        id: vermeerFirebaseManager
        onSendNotificationsToQml: {
            var notificationMsg = currentDate.toLocaleDateString() + ":" + currentDate.toLocaleTimeString() + ":" + data + "\n"
            console.log(notificationMsg)
            telemLogPageTextArea.text += notificationMsg
        }
    }

    VermeerSettingsToolbar {
        id: vermeerSettingsPageToolBarQml
    }

    Rectangle {
        id: telemLogPage
        width: parent.width * 0.85
        height: parent.height
        anchors{
            left: parent.left
            top: vermeerSettingsPageToolBarQml.bottom
            bottom: parent.bottom
        }

        ScrollView{
            id: telemLogPageScrollView
            anchors.fill: parent
            Text{
                id: telemLogPageTextArea
                anchors.fill: parent
                font.pointSize: 10
            }
        }
    }

    Rectangle {
        id: telemLogPageSideBarMenu
        width: parent.width * 0.15
        height: parent.height
        color: "#161618"
        anchors{
            right: parent.right
            top: vermeerSettingsPageToolBarQml.bottom
            left: telemLogPage.right
            bottom: parent.bottom
        }

        Rectangle{
            id: clearLogButton
            width: parent.width
            height: 100
            anchors.top: vermeerSettingsPageToolBarQml.bottom
            color: "#161618"

            Text {
                id: clearLogButtonText
                text: qsTr("CLEAR LOGS")
                font.pointSize: 15
                font.bold: true
                color: "white"
                anchors.centerIn: parent
            }

            MouseArea {
                id: clearLogButtonMouseArea
                anchors.fill: parent
                onPressed: {
                    clearLogButtonText.color = "black"
                    clearLogButton.color = "white"
                }

                onReleased: {
                    clearLogButtonText.color = "white"
                    clearLogButton.color = "#161618"
                    telemLogPageTextArea.text = ""
                }
            }

        }
    }
}
