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

    signal receivedMissionJson()
    signal missionAlreadyRunning()
    signal missionCompleted()
    signal missionCurrupted()
    signal homePositionReceived()

    VermeerFirebaseManager {
        id: vermeerFirebaseManager
        onSendNotificationsToQml: {
            var notificationMsg = currentDate.toLocaleDateString() + ":" + currentDate.toLocaleTimeString() + ":" + data + "\n"
            telemLogMissionPageTextArea.text += notificationMsg
        }

        // we are doing it here instead of the VermeerMissionList because the onMissionUdpReply signal seems to come here idk why yet...
        // so we receive a sigal from c++ then we send a signal up to the parent which is VermeerMissionPage
        // then on VermeerMissionPage the VermeerTelemLogMissionPage instance calls the slots on the VermeerMissionList

        onMissionUdpReply: {
            if("receivedMissionJson"===data){
                console.log("vermeerTelemLogMissionPage: emit missionUploadedSuccessfully signal")
                vermeerTelemLogMissionPage.receivedMissionJson()
            }

            if("missionAlreadyRunning"===data){
                console.log("vermeerTelemLogMissionPage: emit missionAlreadyRunning signal")
                vermeerTelemLogMissionPage.missionAlreadyRunning()
            }

            if("missionCompleted"===data){
                console.log("vermeerTelemLogMissionPage: emit missionCompleted signal")
                vermeerTelemLogMissionPage.missionCompleted()
            }

            if("missionCurrupted"===data){
                console.log("vermeerTelemLogMissionPage: emit missionCurrupted signal")
                vermeerTelemLogMissionPage.missionCurrupted()
            }

            if("homePositionReceived"===data){
                console.log("vermeerTelemLogMissionPage: emit homePositionReceived signal")
                vermeerTelemLogMissionPage.homePositionReceived()
            }
        }
    }

    VermeerLogManager{
        id: vermeerLogManager
    }


    function showTelemLogPage() {
        telemLogMissionPage.visible = true
        ulogPage.visible = false
    }

    function showUlogPage() {
        telemLogMissionPage.visible = false
        ulogPage.visible = true

        ulogPageTextArea.text = vermeerLogManager.readAllUlogs()
    }

    function clearTelemLogPage(){
        telemLogMissionPageTextArea.text = ""
    }

    function deleteUlogs(){
        vermeerLogManager.deleteFileFromStorage()
        ulogPageTextArea.text = ""
    }

    Rectangle {
        id: telemLogMissionPage
        width: parent.width * 0.85
        height: parent.height
        visible: true

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
        id: ulogPage
        width: parent.width * 0.85
        height: parent.height
        visible: false

        ScrollView{
            id: ulogPageScrollView
            anchors.fill: parent
            Text{
                id: ulogPageTextArea
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
            id: telemLogButton
            width: parent.width
            height: 200
            anchors.top: parent.top
            color: "#161618"

            Text {
                id: telemLogButtonText
                text: qsTr("Show TLogs")
                font.pointSize: 15
                font.bold: true
                color: "white"
                anchors.centerIn: parent
            }

            MouseArea {
                id: telemLogButtonMouseArea
                anchors.fill: parent
                onPressed: {
                    telemLogButtonText.color = "black"
                    telemLogButton.color = "white"
                }

                onReleased: {
                    telemLogButtonText.color = "white"
                    telemLogButton.color = "#161618"
                    showTelemLogPage()
                }
            }
        }

        Rectangle {
            id: clearLogButton
            width: parent.width
            height: 200
            anchors.top: telemLogButton.bottom
            color: "#161618"

            Text {
                id: clearLogButtonText
                text: qsTr("Clear TLogs")
                font.pointSize: 14
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
                    clearTelemLogPage()
                }
            }
        }

        Rectangle {
            id: userLogsButton
            width: parent.width
            height: 200
            anchors.top: clearLogButton.bottom
            color: "#161618"

            Text {
                id: userLogsButtonText
                text: qsTr("Show ULogs")
                font.pointSize: 15
                font.bold: true
                color: "white"
                anchors.centerIn: parent
            }

            MouseArea {
                id: userLogsButtonMouseArea
                anchors.fill: parent
                onPressed: {
                    userLogsButtonText.color = "black"
                    userLogsButton.color = "white"
                }

                onReleased: {
                    userLogsButtonText.color = "white"
                    userLogsButton.color = "#161618"
                    showUlogPage()
                }
            }
        }

        Rectangle {
            id: userLogDeleteButton
            width: parent.width
            height: 200
            anchors.top: userLogsButton.bottom
            color: "#161618"

            Text {
                id: userLogDeleteButtonText
                text: qsTr("Delete ULogs")
                font.pointSize: 15
                font.bold: true
                color: "white"
                anchors.centerIn: parent
            }

            MouseArea {
                id: userLogDeleteButtonMouseArea
                anchors.fill: parent
                onPressed: {
                    userLogDeleteButtonText.color = "black"
                    userLogDeleteButton.color = "white"
                }

                onReleased: {
                    userLogDeleteButtonText.color = "white"
                    userLogDeleteButton.color = "#161618"
                    deleteUlogs()
                }
            }
        }
    }
}
