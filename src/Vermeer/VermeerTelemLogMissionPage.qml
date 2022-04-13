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
    id: vermeerTelemLogMissionPage

    property date currentDate: new Date()

    Component.onCompleted: {
        console.log("vermeerTelemLogMissionPage: bindSocket()")
        vermeerFirebaseManager.bindSocket()
    }

    signal missionUploadedSuccessfully()
    signal missionUploadedUnsuccessfully()
    signal missionAlreadyRunning()

    VermeerFirebaseManager {
        id: vermeerFirebaseManager
        onSendNotificationsToQml: {
            var notificationMsg = currentDate.toLocaleDateString() + ":" + currentDate.toLocaleTimeString() + ":" + data + "\n"
            telemLogMissionPageTextArea.text += notificationMsg
        }

        onMissionUdpReply: {
            console.log("onMissionUdpReply:" + data)
            if("missionUploadedSuccessfuly"===data){
                console.log("vermeerTelemLogMissionPage: emit missionUploadedSuccessfully signal")
                vermeerTelemLogMissionPage.missionUploadedSuccessfully()

                // we need to clear the log page
                telemLogMissionPageTextArea.text = ""
            }

            if("missionUploadedUnsuccessfuly"===data){
                console.log("vermeerTelemLogMissionPage: emit missionUploadedUnsuccessfully signal")
                vermeerTelemLogMissionPage.missionUploadedUnsuccessfully()
            }

            if("missionAlreadyRunning"===data){
                console.log("vermeerTelemLogMissionPage: emit missionAlreadyRunning signal")
                vermeerTelemLogMissionPage.missionAlreadyRunning()
            }
        }
    }

    Rectangle {
        id: telemLogMissionPage
        width: parent.width * 0.85
        height: parent.height

        ScrollView{
            id: telemLogMissionPageScrollView
            anchors.fill: parent
            Text{
                id: telemLogMissionPageTextArea
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
            top: parent.top
            left: telemLogMissionPage.right
            bottom: parent.bottom
        }

        Rectangle{
            id: clearLogButton
            width: parent.width
            height: 100
            anchors.top: parent.top
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
                    telemLogMissionPageTextArea.text = ""
                }
            }
        }
    }
}
