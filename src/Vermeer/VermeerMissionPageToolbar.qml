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

    signal showLogPage()
    signal showMissionPage()

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
        console.log("vermeerShowXavierOnlineIcon")
        xavierOnlineIcon.visible = true
        xavierOfflineIcon.visible = false
    }

    function vermeerShowXavierOfflineIcon(){
        xavierOnlineIcon.visible = false
        xavierOfflineIcon.visible = true
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
        id: onlineWifiIcon
        width: 100
        height: 75
        anchors.left: vermeerMissionText.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 50
        color: "#161618"

        Image {
            id: onlineWifiIconImage
            source: "/vermeer/VermeerOnlineWifiIcon.png"
            anchors.centerIn: parent
            height: parent.height
            width: parent.width
        }
    }

    Rectangle {
        id: offlineWifiIcon
        width: 100
        height: 75
        anchors.left: vermeerMissionText.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 50
        color: "#161618"
        visible: false

        Image {
            id: offlineWifiIconImage
            source: "/vermeer/VermeerOfflineWifiIcon.png"
            anchors.centerIn: parent
            height: parent.height
            width: parent.width
        }
    }

    Rectangle {
        id: xavierOnlineIcon
        width: 100
        height: 75
        anchors.left: offlineWifiIcon.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 50
        color: "#161618"
        visible: false

        Rectangle {
            id: xavierOnlineIconCircle
            anchors.centerIn: parent
            width: 100
            height: 100
            radius: width
            color: "green"
        }
    }

    Rectangle {
        id: xavierOfflineIcon
        width: 100
        height: 75
        anchors.left: offlineWifiIcon.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 50
        color: "#161618"
        visible: true

        Rectangle {
            id: xavierOfflineIconCircle
            anchors.centerIn: parent
            width: 100
            height: 100
            radius: width
            color: "red"
        }
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
        id: missionListLogPageToggleButton
        width: parent.width * 0.15
        height: parent.height * 0.70
        anchors.right: vermeerSettingsButton.left
        anchors.rightMargin: parent.width * 0.001
        anchors.topMargin: parent.width * 0.05
        anchors.verticalCenter: parent.verticalCenter
        color: Qt.rgba(0,0,0,0)

        Text {
            id: missionListLogPageToggleButtonText
            text: qsTr("Logs")
            font.pointSize: 15
            font.bold: true
            color: "white"
            anchors.centerIn: parent
        }

        MouseArea {
            id:missionListLogPageToggleButtonMouseArea
            anchors.fill: parent
            onPressed: {
                missionListLogPageToggleButton.color = "#d7003f"
                vermeerLogManager.log("MissionPage: MissionPageToggle pressed")
            }

            onReleased: {
                missionListLogPageToggleButton.color = "#161618"

                if("Mission List" === missionListLogPageToggleButtonText.text) {
                    missionListLogPageToggleButtonText.text = "Logs"
                    vermeerLogManager.log("MissionPage: Switching to mission page")
                    vermeerMssionPageToolBarQml.showMissionPage()
                }
                else if ("Logs" === missionListLogPageToggleButtonText.text) {
                    missionListLogPageToggleButtonText.text = "Mission List"
                    vermeerLogManager.log("MissionPage: Switching to log page")
                    vermeerMssionPageToolBarQml.showLogPage()
                }
            }
        }
    }


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
                vermeerLogManager.log("MissionPage: setting button clicked")
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
