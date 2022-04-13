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
        vermeerMissionUploadSuccessful.visible = false
        vermeerMissionUploadUnSuccessful.visible = false
        vermeerMissionAlreadyRunning.visible = false
    }

    function disableAllView() {
        vermeerMissionListsView.visible = false
        noMissionAvailablePage.visible = false
        vermeerMissionUploadSuccessful.visible = false
        vermeerMissionUploadUnSuccessful.visible = false
        vermeerMissionAlreadyRunning.visible = false
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

    function showReloadMissionPage(){
        reloadMission.visible = true
        reloadMission.z = 2
    }

    function disableSigningInPage(){
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

    function handleMissionUploadedSuccessfully(){
        console.log("missionUploadedSuccessfuly")
        disableAllView()
        vermeerMissionUploadSuccessful.visible = true
    }

    function handleMissionUploadedUnsuccessfuly(){
        disableAllView()
        vermeerMissionUploadUnSuccessful.visible = true
    }

    function handleMissionAlreadyRunning() {
        disableAllView()
        vermeerMissionAlreadyRunning.visible = true
    }

    VermeerUser {
        id: vermmerUser
    }

    VermeerMIssionReloadPage {
        id: reloadMission
    }

    VermeerFirebaseManager {
        id: vermeerFirebaseManager
        onDisplayMsgToQml: {
            if("numberOfMissionItemsChanged"===data) {
                handleNumberMissionChanged()
                vermeerFirebaseManager.saveMissionListToMissionFile()
                disableSigningInPage()
            }

            if ("invalidAccessToken"===data) {
                console.log("invalid access token")
            }

            if("accessTokenTimedOut"===data){
                if(vermeerFirebaseManager.hasInternetConnection()) {
                    console.log("Access token timedout signing in with refresh token")
                    vermeerFirebaseManager.signInWithRefreshToken()
                } else {
                    console.log("Access token timedout, No Internet, Loading missions from file")
                    vermeerFirebaseManager.loadMissioListsFromMissionFile();
                }
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
    }

    Rectangle {
        id: vermeerMissionUploadSuccessful
        height: parent.height
        width: parent.width
        color: "#161618"
        anchors.centerIn: parent
        visible: false

        Text {
            id: vermeerMissionUploadSuccessfulText
            text: vermeerMissionName + " Uploaded Successfully"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -100
            anchors.bottom: sucsessfulBackButton.top
            color: "white"
            font.pointSize: 25
            font.bold: true
        }

        Rectangle {
            id: sucsessfulBackButton
            width: 250
            height: 60
            anchors.centerIn: parent
            color:"#d7003f"

             Text {
                id: successfulGoBackButtonText
                text: qsTr("Go Back")
                color: "white"
                anchors.centerIn: parent
             }

             MouseArea {
                 id: sucsessfulBackButtonMouseArea
                 anchors.fill: parent
                 onPressed: {
                     successfulGoBackButtonText.color = "#d7003f"
                     sucsessfulBackButton.color = "white"

                 }
                 onReleased: {
                    successfulGoBackButtonText.color = "white"
                    sucsessfulBackButton.color = "#d7003f"
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

        Text {
            id: vermeerMissionUploadUnSuccessfulText
            text: vermeerMissionName + " Failed to Upload"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -100
            anchors.bottom: unsucsessfulBackButton.top
            color: "white"
            font.pointSize: 25
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

        Text {
            id: vermeerMissionAlreadyRunningText
            text: vermeerMissionName + " Mission already running, mission file ignored"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -100
            anchors.bottom: vermeerMissionAlreadyRunningBackButton.top
            color: "white"
            font.pointSize: 25
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

        Text {
            id: vermeerSettingInvalidText
            text: "Settings are invalid check Destination IP address and Port Number"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -100
            anchors.bottom: vermeerMissionAlreadyRunningBackButton.top
            color: "white"
            font.pointSize: 20
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
                        }
                        onReleased: {
                            // do we need a loading screen?
                            uploadButtonText.color = "white"
                            uploadButton.color = "#d7003f"
                            vermeerMissionName = missionName

                            if(isSettingsValid){
                                vermeerFirebaseManager.sendMission(missionKey)
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
                        if(vermeerFirebaseManager.hasInternetConnection()){
                            vermeerFirebaseManager.fetchFlightPlans() // which then send a validSignIn and does a fetchFlightPlans
                        } else {
                            vermeerFirebaseManager.loadMissioListsFromMissionFile()
                        }
                    }
                }
            }
        }
    }

}
