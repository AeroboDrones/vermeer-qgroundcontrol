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

    VermeerFirebaseManager {
        id: vermeerFirebaseManager
        onDisplayMsgToQml: {
            console.log("onDisplayMsgToQml:" + data)

            if("numberOfMissionItemsChanged"===data){

                if(vermmerUser.numberOfMissions > 0){
                    noMissionAvailablePage.visible = false
                    vermeerMissionListsView.visible = true

                    var missionJson = JSON.parse(vermmerUser.missionJsonString)
                    for (var missionKey in missionJson){
                        missionModel.append({"mission":missionKey})
                    }
                }
                else{
                    noMissionAvailablePageText.visible = true
                    noMissionAvailablePage.visible = true
                    vermeerMissionListsView.visible = false
                }
            }
        }
    }

    VermeerUser {
        id: vermmerUser
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
            console.log("fetchFlightPlans:")
            vermeerFirebaseManager.fetchFlightPlans();
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
        id: vermeerMissionListsView
        height: parent.height
        width: parent.width
        anchors.centerIn: parent
        color: "#161618"
        visible: false

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
                        text: qsTr("Mission#" + mission)
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
                        onClicked: {
                            vermeerFirebaseManager.sendMission(mission)
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
            }
        }
    }

}
