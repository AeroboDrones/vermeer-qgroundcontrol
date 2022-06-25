/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick          2.12
import QtQuick.Controls 2.5
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
    id: vermeerMissionList

    property string vermeerMissionName: ""
    property bool isSettingsValid: false

    function goBackButtonView() {
        vermeerMissionListsView.visible = true

        noMissionAvailablePage.visible = false
        vermeerReceivedMissionJson.visible = false
        vermeerMissionUploadUnSuccessful.visible = false // not sure what to do yet
        vermeerMissionAlreadyRunning.visible = false
        vermeerHomePositionReceived.visible = false
        vermeerMissionCompleted.visible = false
        vermeerMissionCurrupted.visible = false
    }

    function disableAllView() {
        vermeerMissionListsView.visible = false
        noMissionAvailablePage.visible = false
        vermeerReceivedMissionJson.visible = false
        vermeerMissionUploadUnSuccessful.visible = false // not sure what to do yet
        vermeerMissionAlreadyRunning.visible = false
        vermeerHomePositionReceived.visible = false
        vermeerMissionCompleted.visible = false
        vermeerMissionCurrupted.visible = false
        disableSendingMissionPage()
    }

    function handleNumberMissionChanged() {
        if(vermmerUser.numberOfMissions > 0) {
            noMissionAvailablePage.visible = false
            vermeerMissionListsView.visible = true
            var missionJson = JSON.parse(vermmerUser.missionJsonString)
            missionModel.clear()
            for (var missionKey in missionJson){
                missionModel.append({"missionName":missionJson[missionKey]["name"],
                                    "missionKey":missionKey})
            }
        }
        else{
            noMissionAvailablePageText.visible = true
            noMissionAvailablePage.visible = true
            vermeerMissionListsView.visible = false
        }
    }

    function handleLogIn() {
        if(vermeerFirebaseManager.hasInternetConnection()) {
            vermeerFirebaseManager.signInWithRefreshToken()
        } else {
            vermeerFirebaseManager.loadMissioListsFromMissionFile();
        }
    }

    function showSendingMissionPage() {
        vermeerSendingMissionPage.visible = true
        vermeerSendingMissionPage.z = 2
    }

    function disableSendingMissionPage() {
        vermeerSendingMissionPage.visible = false
        vermeerSendingMissionPage.z = 0
    }

    function showReloadMissionPage(){
        vermeerLogManager.log("showReloadMissionPage")
        reloadMission.visible = true
        reloadMission.z = 2
    }

    function disableReloadPage(){
        reloadMission.visible = false
        reloadMission.z = 0
    }

    function handleMissionLists(){
        if(vermeerFirebaseManager.hasInternetConnection()){
            vermeerFirebaseManager.loadUserEmailFromFile()
            console.log("vermeerMissionList: noMissionAvailablePage: fetchFlightPlans")
            vermeerFirebaseManager.fetchFlightPlans()
        } else {
            console.log("vermeerMissionList: noMissionAvailablePage: load mission list from file:")
            vermeerFirebaseManager.loadMissioListsFromMissionFile()
        }
    }

    function handleReceivedMissionJson(){
        console.log("receivedMissionJson")
        disableAllView()
        vermeerFirebaseManager.sendingMissionTimeoutStop()
        vermeerReceivedMissionJson.visible = true
    }

    function handleMissionUploadedUnsuccessfuly(){
        disableAllView()
        vermeerFirebaseManager.sendingMissionTimeoutStop()
        vermeerMissionUploadUnSuccessful.visible = true
    }

    function handleMissionAlreadyRunning() {
        disableAllView()
        vermeerFirebaseManager.sendingMissionTimeoutStop()
        vermeerMissionAlreadyRunning.visible = true
    }

    function handleMissionCompleted() {
        disableAllView()
        vermeerMissionCompleted.visible = true
    }

    function handleMissionCorrupted() {
        disableAllView()
        vermeerFirebaseManager.sendingMissionTimeoutStop()
        vermeerMissionCurrupted.visible = true
    }

    function handleHomePositionReceived() {
        disableAllView()
        vermeerHomePositionReceived.visible = true
    }

    VermeerUser {
        id: vermmerUser
    }

    VermeerLogManager{
        id: vermeerLogManager
    }

    VermeerMissionReloadPage {
        id: reloadMission
    }

    VermeerSendingMissionPage{
        id: vermeerSendingMissionPage
    }

    VermeerFirebaseManager {
        id: vermeerFirebaseManager
        onDisplayMsgToQml: {
            if("numberOfMissionItemsChanged"===data) {
                handleNumberMissionChanged()
                vermeerFirebaseManager.saveMissionListToMissionFile()
                disableReloadPage()
            }

            if ("invalidAccessToken"===data) {
                console.log("invalid access token")
            }

            if("accessTokenTimedOut"===data) {
                if(vermeerFirebaseManager.hasInternetConnection()) {
                    console.log("Access token timedout signing in with refresh token")
                    vermeerFirebaseManager.signInWithRefreshToken()
                } else {
                    console.log("Access token timedout, No Internet, Loading missions from file")
                    vermeerFirebaseManager.loadMissioListsFromMissionFile();
                }
            }

            if ("sendingMissionTimedOut" === data){
                console.log("vermeerMissionList: sendingMissionTimedOut")
                handleMissionUploadedUnsuccessfuly();
            }
        }
    }

    Component.onCompleted: {
        if(vermeerFirebaseManager.hasInternetConnection()) {
            console.log("Starting the access token timer")
            vermeerFirebaseManager.accessTokenStartTimer();
        }
        else {
            console.log("Setting Expires in from file")
            vermeerFirebaseManager.loadExpiresInFromFile() // Not sure what to do when the timer for refresh token expires
            console.log("Starting the access token timer")
            vermeerFirebaseManager.accessTokenStartTimer();
        }

        isSettingsValid = vermeerFirebaseManager.isSettingValid()
        console.log("is seting valid: " + isSettingsValid)
    }

    Rectangle {
        id: noMissionAvailablePage
        height: parent.height
        width: parent.width
        color: "#161618"
        anchors.centerIn: parent
        anchors.bottom: parent.bottom
        visible: true

        Component.onCompleted: {
            handleMissionLists()
        }

        Text {
            id: noMissionAvailablePageText
            text: qsTr("No Mission Available")
            anchors.centerIn: parent
            color: "white"
            font.pointSize: 20
            font.bold: true
            visible: false
        }

        Rectangle {
            id: noMissionAvailablePageReloadButton
            width: 250
            height: 60
            anchors.centerIn: parent
            color:"#d7003f"

             Text {
                id: noMissionAvailablePageReloadButtonText
                text: qsTr("Reload Mission")
                color: "white"
                anchors.centerIn: parent
             }

             MouseArea {
                 id: noMissionAvailablePageReloadButtonMouseArea
                 anchors.fill: parent
                 onPressed: {
                     noMissionAvailablePageReloadButtonText.color = "#d7003f"
                     noMissionAvailablePageReloadButton.color = "white"
                     vermeerLogManager.log("noMissionAvailablePageReloadButton pressed")

                 }
                 onReleased: {
                    noMissionAvailablePageReloadButtonText.color = "white"
                    noMissionAvailablePageReloadButton.color = "#d7003f"
                    handleMissionLists()
                 }
             }
        }
    }

    Rectangle {
        id: vermeerHomePositionReceived
        height: parent.height
        width: parent.width
        color: "#161618"
        anchors.centerIn: parent
        visible: false


        TextMetrics {
            id: vermeerHomePositionReceivedTextMetrics
            font.pixelSize: 50
            text: vermeerMissionName + " Home Position received. Ready to upload mission"
        }

        Text {
            id: vermeerHomePositionReceivedText
            text: vermeerHomePositionReceivedTextMetrics.text
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -100
            anchors.bottom: vermeerHomePositionReceivedBackButton.top
            color: "white"
            font.bold: true
        }

        Rectangle {
            id: vermeerHomePositionReceivedBackButton
            width: 250
            height: 60
            anchors.centerIn: parent
            color:"#d7003f"

             Text {
                id: vermeerHomePositionReceivedBackButtonText
                text: qsTr("Go Back")
                color: "white"
                anchors.centerIn: parent
             }

             MouseArea {
                 id: vermeerHomePositionReceivedBackButtonMouseArea
                 anchors.fill: parent
                 onPressed: {
                     vermeerHomePositionReceivedBackButtonText.color = "#d7003f"
                     vermeerHomePositionReceivedBackButton.color = "white"
                     vermeerLogManager.log("vermeerHomePositionReceivedBackButton pressed")

                 }
                 onReleased: {
                    vermeerHomePositionReceivedBackButtonText.color = "white"
                    vermeerHomePositionReceivedBackButton.color = "#d7003f"
                    goBackButtonView()
                 }
             }
        }
    }

    Rectangle {
        id: vermeerMissionCurrupted
        height: parent.height
        width: parent.width
        color: "#161618"
        anchors.centerIn: parent
        visible: false

        TextMetrics {
            id: vermeerMissionCurruptedTextMetrics
            font.pixelSize: 50
            text: vermeerMissionName + "Mission Currupted"
        }

        Text {
            id: vermeerMissionCurruptedText
            text: vermeerMissionCurruptedTextMetrics.text
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -100
            anchors.bottom: vermeerMissionCurruptedBackButton.top
            color: "white"
            font.bold: true
        }

        Rectangle {
            id: vermeerMissionCurruptedBackButton
            width: 250
            height: 60
            anchors.centerIn: parent
            color:"#d7003f"

             Text {
                id: vermeerMissionCurruptedBackButtonText
                text: qsTr("Go Back")
                color: "white"
                anchors.centerIn: parent
             }

             MouseArea {
                 id: vermeerMissionCurruptedBackButtonMouseArea
                 anchors.fill: parent
                 onPressed: {
                     vermeerMissionCurruptedBackButtonText.color = "#d7003f"
                     vermeerMissionCurruptedBackButton.color = "white"
                     vermeerLogManager.log("vermeerMissionCurruptedBackButton pressed")

                 }
                 onReleased: {
                    vermeerMissionCurruptedBackButtonText.color = "white"
                    vermeerMissionCurruptedBackButton.color = "#d7003f"
                    goBackButtonView()
                 }
             }
        }
    }

    Rectangle {
        id: vermeerMissionCompleted
        height: parent.height
        width: parent.width
        color: "#161618"
        anchors.centerIn: parent
        visible: false

        TextMetrics {
            id: vermeerMissionCompletedTextMetrics
            font.pixelSize: 50
            text: vermeerMissionName + "Mission Completed"
        }

        Text {
            id: vermeerMissionCompletedText
            text: vermeerMissionCompletedTextMetrics.text
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -100
            anchors.bottom: vermeerMissionCompletedBackButton.top
            color: "white"
            font.bold: true
        }

        Rectangle {
            id: vermeerMissionCompletedBackButton
            width: 250
            height: 60
            anchors.centerIn: parent
            color:"#d7003f"

             Text {
                id: vermeerMissionCompletedBackButtonText
                text: qsTr("Go Back")
                color: "white"
                anchors.centerIn: parent
             }

             MouseArea {
                 id: vermeerMissionCompletedBackButtonMouseArea
                 anchors.fill: parent
                 onPressed: {
                     vermeerMissionCompletedBackButtonText.color = "#d7003f"
                     vermeerMissionCompletedBackButton.color = "white"
                     vermeerLogManager.log("vermeerMissionCompletedBackButton pressed")

                 }
                 onReleased: {
                    vermeerMissionCompletedBackButtonText.color = "white"
                    vermeerMissionCompletedBackButton.color = "#d7003f"
                    goBackButtonView()
                 }
             }
        }
    }

    Rectangle {
        id: vermeerReceivedMissionJson
        height: parent.height
        width: parent.width
        color: "#161618"
        anchors.centerIn: parent
        visible: false

        TextMetrics {
            id: vermeerReceivedMissionJsonTextMetrics
            font.pixelSize: 50
            text: vermeerMissionName + " Received Mission JSON"
        }

        Text {
            id: vermeerReceivedMissionJsonText
            text: vermeerReceivedMissionJsonTextMetrics.text
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -100
            anchors.bottom: vermeerReceivedMissionJsonBackButton.top
            color: "white"
            font.bold: true
        }

        Rectangle {
            id: vermeerReceivedMissionJsonBackButton
            width: 250
            height: 60
            anchors.centerIn: parent
            color:"#d7003f"

             Text {
                id: vermeerReceivedMissionJsonBackButtonText
                text: qsTr("Go Back")
                color: "white"
                anchors.centerIn: parent
             }

             MouseArea {
                 id: vermeerReceivedMissionJsonBackButtonMouseArea
                 anchors.fill: parent
                 onPressed: {
                     vermeerReceivedMissionJsonBackButtonText.color = "#d7003f"
                     vermeerReceivedMissionJsonBackButton.color = "white"
                     vermeerLogManager.log("vermeerReceivedMissionJsonBackButton pressed")

                 }
                 onReleased: {
                    vermeerReceivedMissionJsonBackButtonText.color = "white"
                    vermeerReceivedMissionJsonBackButton.color = "#d7003f"
                    goBackButtonView()
                 }
             }
        }
    }

    Rectangle {
        id: vermeerMissionUploadUnSuccessful
        height: parent.height
        width: parent.width
        color: "#161618"
        anchors.centerIn: parent
        visible: false

        TextMetrics {
            id: vermeerMissionUploadUnSuccessfulTextMetrics
            font.pixelSize: 50
            text: vermeerMissionName + " Mission upload failed"
        }

        Text {
            id: vermeerMissionUploadUnSuccessfulText
            text: vermeerMissionUploadUnSuccessfulTextMetrics.text
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -100
            anchors.bottom: unsucsessfulBackButton.top
            color: "white"
            font.bold: true
        }

        Rectangle {
            id: unsucsessfulBackButton
            width: 250
            height: 60
            anchors.centerIn: parent
            color:"#d7003f"

             Text {
                id: unsuccessfulGoBackButtonText
                text: qsTr("Go Back")
                color: "white"
                anchors.centerIn: parent
             }

             MouseArea {
                 id: unsucsessfulBackButtonMouseArea
                 anchors.fill: parent
                 onPressed: {
                    unsuccessfulGoBackButtonText.color = "#d7003f"
                    unsucsessfulBackButton.color = "white"
                    vermeerLogManager.log("unsucsessfulBackButton pressed")
                 }
                 onReleased: {
                    unsuccessfulGoBackButtonText.color = "white"
                    unsucsessfulBackButton.color = "#d7003f"
                    goBackButtonView()
                 }
             }
        }
    }

    Rectangle {
        id: vermeerMissionAlreadyRunning
        height: parent.height
        width: parent.width
        color: "#161618"
        anchors.centerIn: parent
        visible: false

        TextMetrics {
            id: vermeerMissionAlreadyRunningTextMetrics
            font.pixelSize: 50
            text: vermeerMissionName + " Mission already running, mission file ignored"
        }

        Text {
            id: vermeerMissionAlreadyRunningText
            width: vermeerMissionAlreadyRunningTextMetrics.width
            height: vermeerMissionAlreadyRunningTextMetrics.height
            text: vermeerMissionAlreadyRunningTextMetrics.text
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -100
            anchors.bottom: vermeerMissionAlreadyRunningBackButton.top
            color: "white"
            font.bold: true
        }

        Rectangle {
            id: vermeerMissionAlreadyRunningBackButton
            width: 250
            height: 60
            anchors.centerIn: parent
            color:"#d7003f"

             Text {
                id: vermeerMissionAlreadyRunningGoBackButtonText
                text: qsTr("Go Back")
                color: "white"
                anchors.centerIn: parent
             }

             MouseArea {
                 id: vermeerMissionAlreadyRunningBackButtonMouseArea
                 anchors.fill: parent
                 onPressed: {
                     vermeerMissionAlreadyRunningGoBackButtonText.color = "#d7003f"
                     vermeerMissionAlreadyRunningBackButton.color = "white"
                     vermeerLogManager.log("vermeerMissionAlreadyRunningBackButton pressed")
                 }
                 onReleased: {
                    vermeerMissionAlreadyRunningGoBackButtonText.color = "white"
                    vermeerMissionAlreadyRunningBackButton.color = "#d7003f"
                    goBackButtonView()
                 }
             }
        }
    }

    Rectangle {
        id: vermeerSettingInvalid
        height: parent.height
        width: parent.width
        color: "#161618"
        anchors.centerIn: parent
        visible: false

        TextMetrics {
            id: vermeerSettingInvalidTextMetrics
            font.pixelSize: 50
            text: "Settings are invalid check Destination IP address and Port Number"
        }

        Text {
            id: vermeerSettingInvalidText
            text: vermeerSettingInvalidTextMetrics.text
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -100
            anchors.bottom: vermeerSettingInvalidGoBackButton.top
            color: "white"
            font.bold: true
        }

        Rectangle {
            id: vermeerSettingInvalidGoBackButton
            width: 250
            height: 60
            anchors.centerIn: parent
            color:"#d7003f"

             Text {
                id: vermeerSettingInvalidGoBackButtonText
                text: qsTr("Go Back")
                color: "white"
                anchors.centerIn: parent
             }

             MouseArea {
                 id: vermeerSettingInvalidGoBackButtonMouseArea
                 anchors.fill: parent
                 onPressed: {
                     vermeerSettingInvalidGoBackButtonText.color = "#d7003f"
                     vermeerSettingInvalidGoBackButton.color = "white"
                     vermeerLogManager.log("vermeerSettingInvalidGoBackButton pressed")
                 }
                 onReleased: {
                    vermeerSettingInvalidGoBackButtonText.color = "white"
                    vermeerSettingInvalidGoBackButton.color = "#d7003f"
                    goBackButtonView()
                 }
             }
        }
    }

    Rectangle {
        id: vermeerMissionListsView
        height: parent.height
        width: parent.width
        anchors.centerIn: parent
        color: "#161618"

        ListModel{
            id: missionModel
        }

        Component {
            id: missionItemDelegate
            Item {
                id: missionItemBlock
                width: parent.width
                height: 200
                Rectangle {
                    id: missionItemRectangle
                    width: parent.width * 0.50
                    height: parent.height
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 100
                    anchors.topMargin:70
                    color: Qt.rgba(0,0,0,0)

                    Text {
                        id: missionItemDelegateText
                        font.pointSize: 20
                        font.bold: true
                        color: "white"
                        text: qsTr(missionName)
                    }
                }

                Rectangle {
                    id: uploadButton
                    width: 200
                    height: 50
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    color:"#d7003f"
                    anchors.rightMargin: 100
                    anchors.topMargin: 50
                    anchors.bottomMargin: 50

                    Text {
                        id: uploadButtonText
                        text: qsTr("Upload")
                        font.pointSize: 15
                        anchors.centerIn: parent
                        color: "white"
                        font.bold: true
                    }

                    MouseArea {
                        id: uploadButtonMouseArea
                        anchors.fill: parent
                        onPressed: {
                            uploadButtonText.color = "#d7003f"
                            uploadButton.color = "white"

                            // I am binding to the broadcast everytime I send a mission
                            // I get weird behavior when I bind on the constructor
                            // So I explicitly disconnect then bind
                            // binding to local host allows us to recieve the notification
                            // from the drone side
                            vermeerFirebaseManager.bindSocket()

                            var logMsg = missionName + " upload button pressed"
                            vermeerLogManager.log(logMsg)
                        }
                        onReleased: {
                            // do we need a loading screen?
                            uploadButtonText.color = "white"
                            uploadButton.color = "#d7003f"
                            vermeerMissionName = missionName

                            if(isSettingsValid){
                                console.log("vermeerSendingMissionPage")
                                showSendingMissionPage()
                                vermeerFirebaseManager.sendingMissionTimeoutStart()
                                vermeerFirebaseManager.sendMission(missionKey)

                                var logMsg = missionName + " upload button released"
                                vermeerLogManager.log(logMsg)
                            }
                            else {
                                disableAllView()
                                vermeerSettingInvalid.visible = true
                            }
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
        }

        ScrollView {
            anchors.fill: parent
            ListView {
                id: missionItemListView
                width: parent.width
                model: missionModel
                delegate: missionItemDelegate
                onFlickStarted: {
                    if(atYBeginning){
                        showReloadMissionPage()
                        if(vermeerFirebaseManager.hasInternetConnection()) {
                            vermeerLogManager.log("we have internet connection, fetching flight plans")
                            vermeerFirebaseManager.fetchFlightPlans() // which then send a validSignIn and does a fetchFlightPlans
                        } else {
                            vermeerLogManager.log("No internet connection, loading mission from file")
                            vermeerFirebaseManager.loadMissioListsFromMissionFile()
                        }
                    }
                }
            }
        }
    }

}
