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
    id: vermeerFlightLogsPage

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
    signal heartbeatMsgRecieved()
    signal updateMissionStatus()

    VermeerFirebaseManager {
        id: vermeerFirebaseManager
        onSendNotificationsToQml: {
            var hasHeartBeatMsg = vermeerFirebaseManager.hasHeartBeatMsg(data)
            if(true === hasHeartBeatMsg) {
                vermeerFlightLogsPage.heartbeatMsgRecieved()
            }

            var notificationMsg = ">"+ vermeerFirebaseManager.getTlogs(data)
            tLogsModel.append({"tLogsLineItem":notificationMsg})
            //tLogsListView.positionViewAtEnd()

            vermeerFirebaseManager.storeMissionAndNodeStatus(data)
            missionStatusText.text = vermeerFirebaseManager.getStatusButtonText()

            if(missionStatusText.text === "Ready"){
                startMissionButton.visible = true
                missionStatus.visible = false
            } else {
                startMissionButton.visible = false
                missionStatus.visible = true
            }

            if(missionStatusText.text === "Waiting"){
                missionStatusText.text = "Waiting for Mission"
            }

            if(missionStatusText.text === "Complete"){
                missionStatusText.text = "Mission Complete"
            }

            if(missionStatusText.text === "Error"){
                missionStatusText.color = "#D6003F"
                missionStatus.color = "#25050B"
            }else {
                missionStatusText.color = "white"
                missionStatus.color = "#D6003F"
            }

            vermeerFlightLogsPage.updateMissionStatus()
        }

        // we are doing it here instead of the VermeerMissionList because the onMissionUdpReply signal seems to come here idk why yet...
        // so we receive a sigal from c++ then we send a signal up to the parent which is VermeerMissionPage
        // then on VermeerMissionPage the VermeerTelemLogMissionPage instance calls the slots on the VermeerMissionList

        onMissionUdpReply: {
            if("receivedMissionJson"===data){
                console.log("vermeerTelemLogMissionPage: emit missionUploadedSuccessfully signal")
                vermeerFlightLogsPage.receivedMissionJson()
            }

            if("missionAlreadyRunning"===data){
                console.log("vermeerTelemLogMissionPage: emit missionAlreadyRunning signal")
                vermeerFlightLogsPage.missionAlreadyRunning()
            }

            if("missionCompleted"===data){
                console.log("vermeerTelemLogMissionPage: emit missionCompleted signal")
                vermeerFlightLogsPage.missionCompleted()
            }

            if("missionCurrupted"===data){
                console.log("vermeerTelemLogMissionPage: emit missionCurrupted signal")
                vermeerFlightLogsPage.missionCurrupted()
            }

            if("homePositionReceived"===data){
                console.log("vermeerTelemLogMissionPage: emit homePositionReceived signal")
                vermeerFlightLogsPage.homePositionReceived()
            }
        }

        onSendDebugInformation: {
            var notificationMsg = ">" +data + "\n"
            tLogsModel.append({"tLogsLineItem":notificationMsg})
            //tLogsListView.positionViewAtEnd()
        }
    }

    VermeerLogManager{
        id: vermeerLogManager
    }

    function showTelemLogPage() {
        telemLogMissionPage.visible = true
        ulogPage.visible = false
        nodeStatusPage.visible = false
    }

    function showUlogPage() {
        telemLogMissionPage.visible = false
        ulogPage.visible = true
        nodeStatusPage.visible = false
        ulogPageTextArea.text = vermeerLogManager.readAllUlogs()
    }

    function showNodeStatusPage() {
        nodeStatusPage.visible = true
        ulogPage.visible = false
        telemLogMissionPage.visible = false
    }

    function clearTelemLogPage(){
        tLogsModel.clear()
    }

    function deleteUlogs(){
        vermeerLogManager.deleteFileFromStorage()
        ulogPageTextArea.text = ""
    }

    function clearNodeStatuses(){
        btMasterValue.text = ""
        geolocatorValue.text = ""
        nodeManagerValue.text = ""
        pathPlannerValue.text = ""
        dataPublisherValue.text = ""
        detectorValue.text = ""
        imageSourceNodeValue.text = ""
        trackerValue.text = ""
        perceptionManagerValue.text = ""
        telemetryValue.text = ""
        commLinkValue.text = ""
        parameterDistributionValue.text = ""
        mavrosValue.text = ""
    }

    function clearLogsPage(){
        if(telemLogMissionPage.visible === true) {
            vermeerFlightLogsPage.clearTelemLogPage()
        }

        if(ulogPage.visible === true) {
            vermeerFlightLogsPage.deleteUlogs()
        }

        if(nodeStatusPage.visible === true){
            vermeerFlightLogsPage.clearNodeStatuses()
        }
    }

    Rectangle {
        id: controlPannel
        width: parent.width
        height: parent.height * 0.25
        color: "#161618"

        Rectangle {
            id: startMissionButton
            width: 315
            height: 99
            color: "#D6003F"
            radius: 12
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 100
            anchors.topMargin: 50
            visible: false

            Text {
                id: startMissionButtonText
                text: qsTr("Start")
                anchors.centerIn: parent
                color: "white"
                font.pointSize: 12
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    startMissionButtonText.color = "#D6003F"
                    startMissionButton.color = "white"
                }
                onReleased: {
                    startMissionButtonText.color = "white"
                    startMissionButton.color = "#D6003F"
                    //vermeerFirebaseManager.sendStartMissionCmd()
                }
            }
        }

        Rectangle {
            id: missionStatus
            width: 315
            height: 99
            color: "#8B5862"
            radius: 12
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 100
            anchors.topMargin: 50
            visible: true

            Text {
                id: missionStatusText
                text: qsTr("Initialising")
                anchors.centerIn: parent
                color: "white"
                font.pointSize: 12
                font.bold: true
            }
        }

        Rectangle {
            id: clearButton
            width: 204
            height: 99
            radius: 12
            anchors.right: tlogsButton.left
            anchors.top: parent.top
            anchors.rightMargin: 30
            anchors.topMargin: 50
            color: "#161618"
            border.color: "white"

            Text {
                id: clearButtonText
                text: qsTr("Clear")
                anchors.centerIn: parent
                color: "white"
                font.pointSize: 12
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    clearButtonText.color = "#161618"
                    clearButton.color = "white"
                }
                onReleased: {
                    clearButtonText.color = "white"
                    clearButton.color = "#161618"
                    vermeerFlightLogsPage.clearLogsPage()
                }
            }
        }

        Rectangle {
            id: tlogsButton
            width: 204
            height: 99
            radius: 12
            anchors.right: ulogsButton.left
            anchors.top: parent.top
            anchors.rightMargin: 0
            anchors.topMargin: 50
            color: "#FFFFFF"

            Text {
                id: tlogsButtonText
                text: qsTr("TLogs")
                anchors.centerIn: parent
                color: "#161618"
                font.pointSize: 12
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    tlogsButtonText.color = "#161618"
                    tlogsButton.color = "white"
                    ulogsButtonText.color = "white"
                    ulogsButton.color = "#36363C"
                    nodeStatusButtonText.color = "white"
                    nodeStatusButton.color = "#36363C"
                    vermeerFlightLogsPage.showTelemLogPage()
                }
            }
        }

        Rectangle {
            id: ulogsButton
            width: 204
            height: 99
            radius: 12
            anchors.right: nodeStatusButton.left
            anchors.top: parent.top
            anchors.topMargin: 50
            color: "#36363C"

            Text {
                id: ulogsButtonText
                text: qsTr("ULogs")
                anchors.centerIn: parent
                color: "white"
                font.pointSize: 12
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    tlogsButtonText.color = "white"
                    tlogsButton.color = "#36363C"
                    ulogsButtonText.color = "#161618"
                    ulogsButton.color = "white"
                    nodeStatusButtonText.color = "white"
                    nodeStatusButton.color = "#36363C"
                    vermeerFlightLogsPage.showUlogPage()
                }
            }
        }

        Rectangle {
            id: nodeStatusButton
            width: 300
            height: 99
            radius: 12
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 100
            anchors.topMargin: 50
            color: "#36363C"

            Text {
                id: nodeStatusButtonText
                text: qsTr("Node Status")
                anchors.centerIn: parent
                color: "white"
                font.pointSize: 12
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    tlogsButtonText.color = "white"
                    tlogsButton.color = "#36363C"
                    ulogsButtonText.color = "white"
                    ulogsButton.color = "#36363C"
                    nodeStatusButtonText.color = "#161618"
                    nodeStatusButton.color = "white"
                    vermeerFlightLogsPage.showNodeStatusPage()
                }
            }
        }
    }

    Rectangle {
        id: telemLogMissionPage
        width: parent.width
        height: parent.height
        visible: true
        anchors.top: controlPannel.bottom
        color: "#282828"
        radius: 20

        ListModel {
            id: tLogsModel
        }

        Component{
            id: tLogsDeligate
            Text {
                text: qsTr(tLogsLineItem)
                font.pointSize: 12
                color: "white"
                font.bold: true
            }
        }

        ScrollView {
            id: telemLogMissionPageScrollView
            anchors.fill: parent
            ListView {
                id: tLogsListView
                width: parent.width
                model: tLogsModel
                delegate: tLogsDeligate
                clip: true
                ScrollBar.horizontal: ScrollBar {}
                flickableDirection: Flickable.HorizontalAndVerticalFlick
                contentWidth:  contentItem.childrenRect.width
            }
        }
    }

    Rectangle {
        id: ulogPage
        width: parent.width
        height: parent.height
        anchors.top: controlPannel.bottom
        color: "#282828"
        visible: false
        z:-1

        ScrollView{
            id: ulogPageScrollView
            anchors.fill: parent
            Text{
                id: ulogPageTextArea
                font.pointSize: 12
                color: "white"
                font.bold: true
            }
        }
    }

    Rectangle {
        id: nodeStatusPage
        width: parent.width
        height: parent.height
        visible: false
        anchors.top: controlPannel.bottom
        color: "#282828"
        radius: 20
        z: -1
    }

//    Rectangle {
//        id: telemLogPageSideBarMenu
//        width: parent.width * 0.15
//        height: parent.height
//        color: "#161618"
//        anchors{
//            right: parent.right
//            top: parent.top
//            left: telemLogMissionPage.right
//            bottom: parent.bottom
//        }

//        Rectangle{
//            id: telemLogButton
//            width: parent.width
//            height: 200
//            anchors.top: parent.top
//            color: "#161618"

//            Text {
//                id: telemLogButtonText
//                text: qsTr("Show TLogs")
//                font.pointSize: 15
//                font.bold: true
//                color: "white"
//                anchors.centerIn: parent
//            }

//            MouseArea {
//                id: telemLogButtonMouseArea
//                anchors.fill: parent
//                onPressed: {
//                    telemLogButtonText.color = "black"
//                    telemLogButton.color = "white"
//                }

//                onReleased: {
//                    telemLogButtonText.color = "white"
//                    telemLogButton.color = "#161618"
//                    showTelemLogPage()
//                }
//            }
//        }

//        Rectangle {
//            id: clearLogButton
//            width: parent.width
//            height: 200
//            anchors.top: telemLogButton.bottom
//            color: "#161618"

//            Text {
//                id: clearLogButtonText
//                text: qsTr("Clear TLogs")
//                font.pointSize: 14
//                font.bold: true
//                color: "white"
//                anchors.centerIn: parent
//            }

//            MouseArea {
//                id: clearLogButtonMouseArea
//                anchors.fill: parent
//                onPressed: {
//                    clearLogButtonText.color = "black"
//                    clearLogButton.color = "white"
//                }

//                onReleased: {
//                    clearLogButtonText.color = "white"
//                    clearLogButton.color = "#161618"
//                    clearTelemLogPage()
//                }
//            }
//        }

//        Rectangle {
//            id: userLogsButton
//            width: parent.width
//            height: 200
//            anchors.top: clearLogButton.bottom
//            color: "#161618"

//            Text {
//                id: userLogsButtonText
//                text: qsTr("Show ULogs")
//                font.pointSize: 15
//                font.bold: true
//                color: "white"
//                anchors.centerIn: parent
//            }

//            MouseArea {
//                id: userLogsButtonMouseArea
//                anchors.fill: parent
//                onPressed: {
//                    userLogsButtonText.color = "black"
//                    userLogsButton.color = "white"
//                }

//                onReleased: {
//                    userLogsButtonText.color = "white"
//                    userLogsButton.color = "#161618"
//                    showUlogPage()
//                }
//            }
//        }

//        Rectangle {
//            id: userLogDeleteButton
//            width: parent.width
//            height: 200
//            anchors.top: userLogsButton.bottom
//            color: "#161618"

//            Text {
//                id: userLogDeleteButtonText
//                text: qsTr("Delete ULogs")
//                font.pointSize: 15
//                font.bold: true
//                color: "white"
//                anchors.centerIn: parent
//            }

//            MouseArea {
//                id: userLogDeleteButtonMouseArea
//                anchors.fill: parent
//                onPressed: {
//                    userLogDeleteButtonText.color = "black"
//                    userLogDeleteButton.color = "white"
//                }

//                onReleased: {
//                    userLogDeleteButtonText.color = "white"
//                    userLogDeleteButton.color = "#161618"
//                    deleteUlogs()
//                }
//            }
//        }
//    }
}
