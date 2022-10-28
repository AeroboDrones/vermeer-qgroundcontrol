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
    id: vermeerPageToolbar
    height: parent.height * 0.15
    width: parent.width
    color: "#161618"

    signal showLogPage()
    signal showMissionPage()
    signal showFlightLogPage()
    signal showMissionListPage()
    signal showSettingsPage()

    function enableOnlineWifiIcon() {
        onlineWifiIcon.visible = true
        offlineWifiIcon.visible = false
    }

    function enableOfflineWifiIcon() {
        onlineWifiIcon.visible = false
        offlineWifiIcon.visible = true
    }

    function disableSignOutButton() {
        vermeerSignOutButton.visible = false
        vermeerSignOutDisabledButton.visible = true
    }

    function enableSignOutButton() {
        vermeerSignOutButton.visible = true
        vermeerSignOutDisabledButton.visible = false
    }

    function vermeerShowXavierOnlineIcon(){
        xavierOnlineIcon.visible = true
        xavierOfflineIcon.visible = false
    }

    function vermeerShowXavierOfflineIcon(){
        xavierOnlineIcon.visible = false
        xavierOfflineIcon.visible = true
    }

    function updateMissionStatusToolbar(){
        missionStatus.text = vermeerFirebaseManager.getMissionStatus()
        if("Ready" === missionStatus.text){
            missionStatus.text = "Ready to Fly"
        }
    }

    VermeerLogManager{
        id: vermeerLogManager
    }

    VermeerFirebaseManager {
        id: vermeerFirebaseManager
        onDisplayMsgToQml: {
            if("NoInternet"===data){
                enableOfflineWifiIcon()
                disableSignOutButton()
            }
            else if ("HasInternet"===data) {
                 enableOnlineWifiIcon()
                 enableSignOutButton()
                if(vermeerFirebaseManager.isInternetReacquired()) {
                    console.log("vermeerMssionPageToolBarQml: Internet access Re-Gained signing in with refresh token")
                    vermeerFirebaseManager.setInternetReqacquiaredFlag(false)
                    vermeerFirebaseManager.signInWithRefreshToken()
                }
            }
        }
    }

    Component.onCompleted: {
        if(vermeerFirebaseManager.hasInternetConnection()){
            enableOnlineWifiIcon()
            enableSignOutButton()
        } else {
            enableOfflineWifiIcon()
            disableSignOutButton()
        }
        vermeerLogManager.log("MissionPage: mission page loaded")
    }

    Text {
        id: vermeerTittleToolbarText
        text: qsTr("Missions")
        color: "white"
        font.pointSize: 24
        font.bold: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.05
        anchors.topMargin: parent.width * 0.05
    }

    Rectangle {
        id: devider1
        width: 5
        height: 80
        anchors.verticalCenter: parent.verticalCenter
        anchors.left:vermeerTittleToolbarText.right
        anchors.leftMargin: 15
        color: "white"
    }

    Image {
        id: onlineWifiIcon
        source: "/vermeer/wifiOnlineIcon.svg"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: devider1.right
        anchors.leftMargin: 15
        width: 73.5
        height: 56
        visible: False
    }

    Image {
        id: offlineWifiIcon
        source: "/vermeer/wifiOfflineIcon.svg"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: devider1.right
        anchors.leftMargin: 15
        width: 73.5
        height: 56
        visible: False
    }

    Rectangle {
        id : divider2
        width: 5
        height: 80
        anchors.left: onlineWifiIcon.right
        anchors.leftMargin: 15
        color: "white"
        y : 30
    }

    Rectangle {
        id: xavierOnlineIcon
        anchors.left: divider2.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 15
        width: 30
        height: 30
        radius: width
        color: "green"
        visible: false
    }

    Rectangle {
        id: xavierOfflineIcon
        anchors.left: divider2.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 15
        width: 30
        height: 30
        radius: width
        color: "red"
        visible: true
    }

    Rectangle {
        id : divider3
        width: 5
        height: 80
        anchors.left: xavierOfflineIcon.right
        anchors.leftMargin: 15
        color: "white"
        y : 30
    }

    Text {
        id: missionStatus
        text: qsTr("")
        color: "white"
        font.pointSize: 12
        font.bold: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: divider3.right
        anchors.leftMargin: 15
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

//    Rectangle {
//        id: missionListLogPageToggleButton
//        width: parent.width * 0.15
//        height: parent.height * 0.70
//        anchors.right: vermeerSettingsButton.left
//        anchors.rightMargin: parent.width * 0.001
//        anchors.topMargin: parent.width * 0.05
//        anchors.verticalCenter: parent.verticalCenter
//        color: Qt.rgba(0,0,0,0)

//        Text {
//            id: missionListLogPageToggleButtonText
//            text: qsTr("Logs")
//            font.pointSize: 15
//            font.bold: true
//            color: "white"
//            anchors.centerIn: parent
//        }

//        MouseArea {
//            id:missionListLogPageToggleButtonMouseArea
//            anchors.fill: parent
//            onPressed: {
//                missionListLogPageToggleButton.color = "#d7003f"
//                vermeerLogManager.log("MissionPage: MissionPageToggle pressed")
//            }

//            onReleased: {
//                missionListLogPageToggleButton.color = "#161618"

//                if("Mission List" === missionListLogPageToggleButtonText.text) {
//                    missionListLogPageToggleButtonText.text = "Logs"
//                    vermeerLogManager.log("MissionPage: Switching to mission page")
//                    vermeerMssionPageToolBarQml.showMissionPage()
//                }
//                else if ("Logs" === missionListLogPageToggleButtonText.text) {
//                    missionListLogPageToggleButtonText.text = "Mission List"
//                    vermeerLogManager.log("MissionPage: Switching to log page")
//                    vermeerMssionPageToolBarQml.showLogPage()
//                }
//            }
//        }
//    }

    Rectangle {
        id: vermeerMissionListButton
        width: 200
        height: parent.height * 0.70
        anchors.right: vermeerFlightLogsButton.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 15
        color: Qt.rgba(0,0,0,0)

        Text {
            id: vermeerMissionListButtonText
            text: qsTr("Mission List")
            font.pointSize: 12
            font.bold: true
            color: "white"
            anchors.centerIn: parent
        }

        MouseArea {
            id:vermeerMissionListButtonMouseArea
            anchors.fill: parent
            onClicked: {
                vermeerLogManager.log("MissionPage: mission list button clicked")
                vermeerTittleToolbarText.text = "Missions"
                vermeerPageToolbar.showMissionListPage()
            }
        }
    }

    Rectangle {
        id: vermeerFlightLogsButton
        width: 200
        height: parent.height * 0.70
        anchors.right: vermeerSettingsButton.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 15
        color: Qt.rgba(0,0,0,0)

        Text {
            id: vermeerFlightLogsButtonText
            text: qsTr("Flight Logs")
            font.pointSize: 12
            font.bold: true
            color: "white"
            anchors.centerIn: parent
        }

        MouseArea {
            id:vermeerFlightLogsButtonMouseArea
            anchors.fill: parent
            onClicked: {
                vermeerLogManager.log("MissionPage: flight logs button clicked")
                vermeerTittleToolbarText.text = "Flight Logs"
                vermeerPageToolbar.showFlightLogPage()
            }
        }
    }

    Rectangle {
        id: vermeerSettingsButton
        width: 150
        height: parent.height * 0.70
        anchors.right: vermeerSignOutButton.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 15
        color: Qt.rgba(0,0,0,0)

        Text {
            id: vermeerSettingsButtonText
            text: qsTr("Settings")
            font.pointSize: 12
            font.bold: true
            color: "white"
            anchors.centerIn: parent
        }

        MouseArea {
            id:vermeerSettingsButtonMouseArea
            anchors.fill: parent
            onClicked: {
                vermeerLogManager.log("MissionPage: setting button clicked")
                vermeerTittleToolbarText.text = "Settings"
                vermeerPageToolbar.showSettingsPage()
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
        radius: 20
        color: Qt.rgba(0,0,0,0)

        Text {
            id: vermeerSignOutButtonText
            text: qsTr("Sign Out")
            font.pointSize: 12
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
                vermeerLogManager.log("MissionPage: Sign out button pressed")
                vermeerLoader.source = "VermeerSignInPage.qml"
            }
        }
    }

    Rectangle {
        id: vermeerSignOutDisabledButton
        width: parent.width * 0.15
        height: parent.height * 0.70
        border.width: 5
        anchors.right: parent.right
        anchors.rightMargin: parent.width * 0.05
        anchors.topMargin: parent.width * 0.05
        anchors.verticalCenter: parent.verticalCenter
        color: "gray"
        visible: false

        Text {
            id: vermeerSignOutDisabledButtonText
            text: qsTr("Sign Out")
            font.pointSize: 15
            font.bold: true
            color: "white"
            anchors.centerIn: parent
        }

        MouseArea {
            id: vermeerSignOutDisabledButtonMouseArea
            anchors.fill: parent
            onClicked: {
                vermeerLogManager.log("MissionPage: Disabled Sign Out Button Pressed")
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
