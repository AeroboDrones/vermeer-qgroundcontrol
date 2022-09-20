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
    id: vermeerMissionPageQml

    Rectangle {
        id: vermeerMissionPageBackground
        height: parent.height
        width: parent.width
        color: "#161618"
    }

    VermeerFirebaseManager {
        id: vermeerFirebaseManager
        onDisplayMsgToQml: {
            console.log(data)
            if ("xavier_disconnected" === data) {
                console.log("xavier_disconnected")
                vermeerMssionPageToolBarQml.vermeerShowXavierOfflineIcon()
                vermeerFirebaseManager.sendHeartbeatMsg()
            }
        }
    }

    // Mission Page Tool Bar
    VermeerMissionPageToolbar {
        id: vermeerMssionPageToolBarQml
        z: 1 // this is so that the upload button do not overlap on the tool bar
        onShowLogPage: {
            console.log("vermeerMissionPageQml: onShowLogPage ")
            vermeerMissionList.visible = false;
            vermeerTelemLogMissionPage.visible = true
        }

        onShowMissionPage: {
            console.log("vermeerMissionPageQml: onShowMissionPage ")
            vermeerMissionList.visible = true;
            vermeerTelemLogMissionPage.visible = false
        }
    }

    VermeerMissionList {
        id: vermeerMissionList
        anchors{
            right: parent.right
            top: vermeerMssionPageToolBarQml.bottom
            left: parent.left
            bottom: parent.bottom
        }
    }

    VermeerTelemLogMissionPage {
        id: vermeerTelemLogMissionPage
        visible: false
        anchors{
            right: parent.right
            top: vermeerMssionPageToolBarQml.bottom
            left: parent.left
            bottom: parent.bottom
        }

        onReceivedMissionJson: {
            vermeerMissionList.handleReceivedMissionJson()
        }

        onMissionAlreadyRunning: {
            vermeerMissionList.handleMissionAlreadyRunning()
        }

        onMissionCompleted: {
            vermeerMissionList.handleMissionCompleted()
        }

        onMissionCurrupted: {
            vermeerMissionList.handleMissionCorrupted()
        }

        onHomePositionReceived: {
            vermeerMissionList.handleHomePositionReceived()
        }

        onHeartbeatMsgRecieved: {
            vermeerFirebaseManager.heartbeatRestartTimer()
            vermeerFirebaseManager.sendHeartbeatMsg()
            vermeerMssionPageToolBarQml.vermeerShowXavierOnlineIcon()
        }
    }
}
