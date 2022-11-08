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
    property int nodeStatusRectWidth: 364
    property int spacingBetweenTheNodeStausBox: 15
    property string emptyNodeStatus: "No Response"
    property string noResponseBackgroundColour: "#101010"
    property string noResponseTextColour: "#FFFFFF"
    property string initialisingBackgroundColour: "#616116"
    property string initialisingTextColour: "#F2CC60"
    property string standbyBackgroundColour: "#273750"
    property string standbyTextColour: "#518EEF"
    property string normalBackgroundColour: "#1C4620"
    property string normalTextColour: "#56D663"
    property string errorBackgroundColour: "#25050B"
    property string errorTextColour: "#D6003F"

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

            var notificationMsg = vermeerFirebaseManager.getTlogs(data)

            if("" === notificationMsg) {
                // do nothing
            } else {
                var tlogLine =  ">" + vermeerFirebaseManager.getTlogs(data)
                tLogsModel.append({"tLogsLineItem":tlogLine})
                //tLogsListView.positionViewAtEnd()
            }

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
                missionStatus.color = "#8B5862"
            }

            vermeerFlightLogsPage.updateMissionStatus()
            vermeerFlightLogsPage.updateNodeStatus()
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
            var notificationMsg = ">" + data
            tLogsModel.append({"tLogsLineItem":notificationMsg})
            //tLogsListView.positionViewAtEnd()
        }
    }

    VermeerLogManager{
        id: vermeerLogManager
    }

    function showTelemLogPage() {
        clearButtonText.text = "Clear"
        telemLogMissionPage.visible = true
        ulogPage.visible = false
        nodeStatusPage.visible = false
    }

    function showUlogPage() {
        clearButtonText.text = "Clear"
        telemLogMissionPage.visible = false
        ulogPage.visible = true
        nodeStatusPage.visible = false
        ulogPageTextArea.text = vermeerLogManager.readAllUlogs()
    }

    function showNodeStatusPage() {
        clearButtonText.text = "Refresh"
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

    function clearNodeStatuses() {
        btMasterNodeStatusText.text = emptyNodeStatus
        geolocatorNodeStatusText.text = emptyNodeStatus
        nodeManagerNodeStatusText.text = emptyNodeStatus
        pathPlannerNodeStatusText.text = emptyNodeStatus
        dataPublisherNodeStatusText.text = emptyNodeStatus
        detectorNodeStatusText.text = emptyNodeStatus
        imageSourceNodeNodeStatusText.text = emptyNodeStatus
        trackerNodeStatusText.text = emptyNodeStatus
        perceptionManagerNodeStatusText.text = emptyNodeStatus
        mavrosNodeStatusText.text = emptyNodeStatus
        telemetryNodeStatusText.text = emptyNodeStatus
        commLinkNodeStatusText.text = emptyNodeStatus
        parameterDistributionNodeStatusText.text = emptyNodeStatus
        botHealthNodeStatusText.text = emptyNodeStatus

        vermeerFirebaseManager.setStatusButtonText("")
        vermeerFlightLogsPage.updateMissionStatus()
        missionStatusText.text = ""

        setNodeStatusEmptyNodeStatus()
        updateNodeStatus()
    }

    function setNodeStatusEmptyNodeStatus(){
        vermeerFirebaseManager.setBtMasterNodeStatus(emptyNodeStatus)
        vermeerFirebaseManager.setGeolocatorNodeStatus(emptyNodeStatus)
        vermeerFirebaseManager.setNodeManagerNodeStatus(emptyNodeStatus)
        vermeerFirebaseManager.setPathPlannerNodeStatus(emptyNodeStatus)
        vermeerFirebaseManager.setDataPublisherNodeStatus(emptyNodeStatus)
        vermeerFirebaseManager.setDetectorNodeStatus(emptyNodeStatus)
        vermeerFirebaseManager.setImageSourceNodeStatus(emptyNodeStatus)
        vermeerFirebaseManager.setTrackerNodeStatus(emptyNodeStatus)
        vermeerFirebaseManager.setPerceptionManagerNodeStatus(emptyNodeStatus)
        vermeerFirebaseManager.setMavrosNodeStatus(emptyNodeStatus)
        vermeerFirebaseManager.setTelemetryNodeStatus(emptyNodeStatus)
        vermeerFirebaseManager.setCommLinkNodeStatus(emptyNodeStatus)
        vermeerFirebaseManager.setParameterDistributionNodeStatus(emptyNodeStatus)
        vermeerFirebaseManager.setBotHealthNodeStatus(emptyNodeStatus)
    }

    function updateNodeStatus() {
        updateBtMaster()
        updateGeolocator()
        updateNodeManager()
        updatePathPlanner()
        updateDataPublisher()
        updateDetector()
        updateImageSourceNode()
        updateTracker()
        updateMavros()
        updatePerceptionManager()
        updateTelemetry()
        updateCommLink()
        updateParameterDistribtion()
        updateBotHealth()
    }

    function getNodeTextColour(status){
        if("Initializing" === status){
            return initialisingTextColour
        }else if("Standby" === status){
            return standbyTextColour
        }else if("Normal"=== status){
            return normalTextColour
        }else if("Error" === status){
            return errorTextColour
        }else{
            return noResponseTextColour
        }
    }

    function getNodeBackgroundColour(status) {
        if("Initializing" === status){
            return initialisingBackgroundColour
        }else if("Standby" === status){
            return standbyBackgroundColour
        }else if("Normal"=== status){
            return normalBackgroundColour
        }else if("Error" === status){
            return errorBackgroundColour
        }else{
            return noResponseBackgroundColour
        }
    }

    function updateBtMaster() {
        var status = vermeerFirebaseManager.getBtMasterNodeStatus()
        btMasterNodeStatusText.text = status
        btMasterNodeStatus.color = getNodeBackgroundColour(status)
        btMasterNodeStatusText.color = getNodeTextColour(status)
    }

    function updateGeolocator() {
        var status = vermeerFirebaseManager.getGeolocatorNodeStatus()
        geolocatorNodeStatusText.text = status
        geolocatorNodeStatus.color = getNodeBackgroundColour(status)
        geolocatorNodeStatusText.color = getNodeTextColour(status)
    }

    function updateNodeManager() {
        var status = vermeerFirebaseManager.getNodeManagerNodeStatus()
        nodeManagerNodeStatusText.text = status
        nodeManagerNodeStatus.color = getNodeBackgroundColour(status)
        nodeManagerNodeStatusText.color = getNodeTextColour(status)
    }

    function updatePathPlanner() {
        var status = vermeerFirebaseManager.getPathPlannerNodeStatus()
        pathPlannerNodeStatusText.text = status
        pathPlannerNodeStatus.color = getNodeBackgroundColour(status)
        pathPlannerNodeStatusText.color = getNodeTextColour(status)
    }

    function updateDataPublisher() {
        var status = vermeerFirebaseManager.getDataPublisherNodeStatus()
        dataPublisherNodeStatusText.text = status
        dataPublisherNodeStatus.color = getNodeBackgroundColour(status)
        dataPublisherNodeStatusText.color = getNodeTextColour(status)
    }

    function updateDetector() {
        var status = vermeerFirebaseManager.getDetectorNodeStatus()
        detectorNodeStatusText.text = status
        detectorNodeStatus.color = getNodeBackgroundColour(status)
        detectorNodeStatusText.color = getNodeTextColour(status)
    }

    function updateImageSourceNode() {
        var status = vermeerFirebaseManager.getImageSourceNodeStatus()
        imageSourceNodeNodeStatusText.text = status
        imageSourceNodeNodeStatus.color = getNodeBackgroundColour(status)
        imageSourceNodeNodeStatusText.color = getNodeTextColour(status)
    }

    function updateTracker() {
        var status = vermeerFirebaseManager.getTrackerNodeStatus()
        trackerNodeStatusText.text = status
        trackerNodeStatus.color = getNodeBackgroundColour(status)
        trackerNodeStatusText.color = getNodeTextColour(status)
    }

    function updateMavros() {
        var status = vermeerFirebaseManager.getMavrosNodeStatus()
        mavrosNodeStatusText.text = status
        mavrosNodeStatus.color = getNodeBackgroundColour(status)
        mavrosNodeStatusText.color = getNodeTextColour(status)
    }

    function updatePerceptionManager() {
        var status = vermeerFirebaseManager.getPerceptionManagerNodeStatus()
        perceptionManagerNodeStatusText.text = status
        perceptionManagerNodeStatus.color = getNodeBackgroundColour(status)
        perceptionManagerNodeStatusText.color = getNodeTextColour(status)
    }

    function updateTelemetry() {
        var status = vermeerFirebaseManager.getTelemetryNodeStatus()
        telemetryNodeStatusText.text = status
        telemetryNodeStatus.color = getNodeBackgroundColour(status)
        telemetryNodeStatusText.color = getNodeTextColour(status)
    }

    function updateCommLink() {
        var status = vermeerFirebaseManager.getCommLinkNodeStatus()
        commLinkNodeStatusText.text = status
        commLinkNodeStatus.color = getNodeBackgroundColour(status)
        commLinkNodeStatusText.color = getNodeTextColour(status)
    }

    function updateParameterDistribtion() {
        var status = vermeerFirebaseManager.getParameterDistributionNodeStatus()
        parameterDistributionNodeStatusText.text = status
        parameterDistributionNodeStatus.color = getNodeBackgroundColour(status)
        parameterDistributionNodeStatusText.color = getNodeTextColour(status)
    }

    function updateBotHealth() {
        var status = vermeerFirebaseManager.getBotHealthNodeStatus()
        botHealthNodeStatusText.text = status
        botHealthNodeStatus.color = getNodeBackgroundColour(status)
        botHealthNodeStatusText.color = getNodeTextColour(status)
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
                text: qsTr("")
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
        height: parent.height * 0.75
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

        Rectangle {
            id: btMasterNodeStatus
            width: nodeStatusRectWidth
            height: 153
            color: "#25050B"
            radius: 12
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 48
            anchors.leftMargin: 12

            Text {
                id: btMasterNodeStatusText
                text: qsTr("Error")
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                font.pointSize: 10
                font.bold: true
                color: "#D6003F"
            }

            Text {
                id: btMasterNodeTitle
                text: qsTr("BT Master")
                anchors.top: btMasterNodeStatusText.bottom
                anchors.left: parent.left
                anchors.topMargin: 12
                anchors.leftMargin: 24
                font.pointSize: 12
                font.bold: true
                color: "white"
            }
        }

        Rectangle {
            id: geolocatorNodeStatus
            width: nodeStatusRectWidth
            height: 153
            color: "#25050B"
            radius: 12
            anchors.top: btMasterNodeStatus.bottom
            anchors.left: parent.left
            anchors.topMargin: 32
            anchors.leftMargin: 12

            Text {
                id: geolocatorNodeStatusText
                text: qsTr("Error")
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                font.pointSize: 10
                font.bold: true
                color: "#D6003F"

            }

            Text {
                id: geolocatorNodeTitle
                text: qsTr("Geolocator")
                anchors.top: geolocatorNodeStatusText.bottom
                anchors.left: parent.left
                anchors.topMargin: 12
                anchors.leftMargin: 24
                font.pointSize: 12
                font.bold: true
                color: "white"
            }
        }

        Rectangle {
            id: nodeManagerNodeStatus
            width: nodeStatusRectWidth
            height: 153
            color: "#25050B"
            radius: 12
            anchors.top: geolocatorNodeStatus.bottom
            anchors.left: parent.left
            anchors.topMargin: 32
            anchors.leftMargin: 12

            Text {
                id: nodeManagerNodeStatusText
                text: qsTr("Error")
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                font.pointSize: 10
                font.bold: true
                color: "#D6003F"
            }

            Text {
                id: nodeManagerNodeTitle
                text: qsTr("Node Manager")
                anchors.top: nodeManagerNodeStatusText.bottom
                anchors.left: parent.left
                anchors.topMargin: 12
                anchors.leftMargin: 24
                font.pointSize: 12
                font.bold: true
                color: "white"
            }
        }

        Rectangle {
            id: pathPlannerNodeStatus
            width: nodeStatusRectWidth
            height: 153
            color: "#25050B"
            radius: 12
            anchors.top: parent.top
            anchors.left: btMasterNodeStatus.right
            anchors.topMargin: 48
            anchors.leftMargin: spacingBetweenTheNodeStausBox

            Text {
                id: pathPlannerNodeStatusText
                text: qsTr("Error")
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                font.pointSize: 10
                font.bold: true
                color: "#D6003F"

            }

            Text {
                id: pathPlannerNodeTitle
                text: qsTr("Path Planner")
                anchors.top: pathPlannerNodeStatusText.bottom
                anchors.left: parent.left
                anchors.topMargin: 12
                anchors.leftMargin: 24
                font.pointSize: 12
                font.bold: true
                color: "white"
            }
        }

        Rectangle {
            id: dataPublisherNodeStatus
            width: nodeStatusRectWidth
            height: 153
            color: "#25050B"
            radius: 12
            anchors.top: pathPlannerNodeStatus.bottom
            anchors.left: geolocatorNodeStatus.right
            anchors.topMargin: 32
            anchors.leftMargin: spacingBetweenTheNodeStausBox

            Text {
                id: dataPublisherNodeStatusText
                text: qsTr("Error")
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                font.pointSize: 10
                font.bold: true
                color: "#D6003F"

            }

            Text {
                id: dataPublisherNodeTitle
                text: qsTr("Data Publisher")
                anchors.top: dataPublisherNodeStatusText.bottom
                anchors.left: parent.left
                anchors.topMargin: 12
                anchors.leftMargin: 24
                font.pointSize: 12
                font.bold: true
                color: "white"
            }
        }

        Rectangle {
            id: detectorNodeStatus
            width: nodeStatusRectWidth
            height: 153
            color: "#25050B"
            radius: 12
            anchors.top: dataPublisherNodeStatus.bottom
            anchors.left: nodeManagerNodeStatus.right
            anchors.topMargin: 32
            anchors.leftMargin: spacingBetweenTheNodeStausBox

            Text {
                id: detectorNodeStatusText
                text: qsTr("Error")
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                font.pointSize: 10
                font.bold: true
                color: "#D6003F"
            }

            Text {
                id: detectorNodeTitle
                text: qsTr("Detector")
                anchors.top: detectorNodeStatusText.bottom
                anchors.left: parent.left
                anchors.topMargin: 12
                anchors.leftMargin: 24
                font.pointSize: 12
                font.bold: true
                color: "white"
            }
        }

        Rectangle {
            id: imageSourceNodeNodeStatus
            width: nodeStatusRectWidth
            height: 153
            color: "#25050B"
            radius: 12
            anchors.top: parent.top
            anchors.left: pathPlannerNodeStatus.right
            anchors.topMargin: 48
            anchors.leftMargin: spacingBetweenTheNodeStausBox

            Text {
                id: imageSourceNodeNodeStatusText
                text: qsTr("Error")
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                font.pointSize: 10
                font.bold: true
                color: "#D6003F"

            }

            Text {
                id: imageSourceNodeNodeTitle
                text: qsTr("Image Source")
                anchors.top: imageSourceNodeNodeStatusText.bottom
                anchors.left: parent.left
                anchors.topMargin: 12
                anchors.leftMargin: 24
                font.pointSize: 12
                font.bold: true
                color: "white"
            }
        }

        Rectangle {
            id: trackerNodeStatus
            width: nodeStatusRectWidth
            height: 153
            color: "#25050B"
            radius: 12
            anchors.top: imageSourceNodeNodeStatus.bottom
            anchors.left: dataPublisherNodeStatus.right
            anchors.topMargin: 32
            anchors.leftMargin: spacingBetweenTheNodeStausBox

            Text {
                id: trackerNodeStatusText
                text: qsTr("Error")
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                font.pointSize: 10
                font.bold: true
                color: "#D6003F"

            }

            Text {
                id: trackerNodeTitle
                text: qsTr("Tracker")
                anchors.top: trackerNodeStatusText.bottom
                anchors.left: parent.left
                anchors.topMargin: 12
                anchors.leftMargin: 24
                font.pointSize: 12
                font.bold: true
                color: "white"
            }
        }

        Rectangle {
            id: mavrosNodeStatus
            width: nodeStatusRectWidth
            height: 153
            color: "#25050B"
            radius: 12
            anchors.top: trackerNodeStatus.bottom
            anchors.left: detectorNodeStatus.right
            anchors.topMargin: 32
            anchors.leftMargin: spacingBetweenTheNodeStausBox

            Text {
                id: mavrosNodeStatusText
                text: qsTr("Error")
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                font.pointSize: 10
                font.bold: true
                color: "#D6003F"
            }

            Text {
                id: mavrosNodeTitle
                text: qsTr("Mavros")
                anchors.top: mavrosNodeStatusText.bottom
                anchors.left: parent.left
                anchors.topMargin: 12
                anchors.leftMargin: 24
                font.pointSize: 12
                font.bold: true
                color: "white"
            }
        }

        Rectangle {
            id: perceptionManagerNodeStatus
            width: nodeStatusRectWidth
            height: 153
            color: "#25050B"
            radius: 12
            anchors.top: parent.top
            anchors.left: imageSourceNodeNodeStatus.right
            anchors.topMargin: 48
            anchors.leftMargin: spacingBetweenTheNodeStausBox

            Text {
                id: perceptionManagerNodeStatusText
                text: qsTr("Error")
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                font.pointSize: 10
                font.bold: true
                color: "#D6003F"
            }

            Text {
                id: perceptionManagerNodeTitle
                text: qsTr("Perception Manager")
                anchors.top: perceptionManagerNodeStatusText.bottom
                anchors.left: parent.left
                anchors.topMargin: 12
                anchors.leftMargin: 24
                font.pointSize: 12
                font.bold: true
                color: "white"
            }
        }

        Rectangle {
            id: telemetryNodeStatus
            width: nodeStatusRectWidth
            height: 153
            color: "#25050B"
            radius: 12
            anchors.top: perceptionManagerNodeStatus.bottom
            anchors.left: trackerNodeStatus.right
            anchors.topMargin: 32
            anchors.leftMargin: spacingBetweenTheNodeStausBox

            Text {
                id: telemetryNodeStatusText
                text: qsTr("Error")
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                font.pointSize: 10
                font.bold: true
                color: "#D6003F"

            }

            Text {
                id: telemetryNodeTitle
                text: qsTr("Telemetry")
                anchors.top: telemetryNodeStatusText.bottom
                anchors.left: parent.left
                anchors.topMargin: 12
                anchors.leftMargin: 24
                font.pointSize: 12
                font.bold: true
                color: "white"
            }
        }

        Rectangle {
            id: botHealthNodeStatus
            width: nodeStatusRectWidth
            height: 153
            color: "#25050B"
            radius: 12
            anchors.top: telemetryNodeStatus.bottom
            anchors.left: mavrosNodeStatus.right
            anchors.topMargin: 32
            anchors.leftMargin: spacingBetweenTheNodeStausBox

            Text {
                id: botHealthNodeStatusText
                text: qsTr("Error")
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                font.pointSize: 10
                font.bold: true
                color: "#D6003F"
            }

            Text {
                id: botHealthNodeNodeTitle
                text: qsTr("Bot Health")
                anchors.top: botHealthNodeStatusText.bottom
                anchors.left: parent.left
                anchors.topMargin: 12
                anchors.leftMargin: 24
                font.pointSize: 12
                font.bold: true
                color: "white"
            }
        }

        Rectangle {
            id: commLinkNodeStatus
            width: nodeStatusRectWidth
            height: 153
            color: "#25050B"
            radius: 12
            anchors.top: parent.top
            anchors.left: telemetryNodeStatus.right
            anchors.topMargin: 48
            anchors.leftMargin: spacingBetweenTheNodeStausBox

            Text {
                id: commLinkNodeStatusText
                text: qsTr("Error")
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                font.pointSize: 10
                font.bold: true
                color: "#D6003F"
            }

            Text {
                id: commLinkNodeTitle
                text: qsTr("Comm Link")
                anchors.top: commLinkNodeStatusText.bottom
                anchors.left: parent.left
                anchors.topMargin: 12
                anchors.leftMargin: 24
                font.pointSize: 12
                font.bold: true
                color: "white"
            }
        }

        Rectangle {
            id: parameterDistributionNodeStatus
            width: nodeStatusRectWidth
            height: 153
            color: "#25050B"
            radius: 12
            anchors.top: perceptionManagerNodeStatus.bottom
            anchors.left: telemetryNodeStatus.right
            anchors.topMargin: 32
            anchors.leftMargin: spacingBetweenTheNodeStausBox

            Text {
                id: parameterDistributionNodeStatusText
                text: qsTr("Error")
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                font.pointSize: 10
                font.bold: true
                color: "#D6003F"
            }

            Text {
                id: parameterDistributionNodeTitle
                text: qsTr("Parameter Distribution")
                anchors.top: parameterDistributionNodeStatusText.bottom
                anchors.left: parent.left
                anchors.topMargin: 12
                anchors.leftMargin: 24
                font.pointSize: 12
                font.bold: true
                color: "white"
            }
        }
    }
}
