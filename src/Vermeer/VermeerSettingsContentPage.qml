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
    id: vermeerSettingsContentPage

    property string ipAddress: "192.168.1.97"
    property int portNumber: 5555

    VermeerFirebaseManager{
        id: vermeerFirebaseManager
    }

    Component.onCompleted: {
        console.log("getDestinationIpAddress" + vermeerFirebaseManager.getDestinationIpAddress())
        console.log("getDestinationPortNumber" + vermeerFirebaseManager.getDestinationPortNumber())

        ipAddressRectangleTextInput.text = vermeerFirebaseManager.getDestinationIpAddress()
        portNumberRectangleTextInput.text = vermeerFirebaseManager.getDestinationPortNumber()
    }

    Rectangle {
        id: ipAdddressBlock
        height: parent.height * 0.30
        width: parent.width * 0.50
        color: "#161618"
        anchors{
            left: parent.left
            top: parent.top
        }

        Text {
            id: ipAdddressText
            text: qsTr("Destination IP Address")
            color: "white"
            font.pointSize: 15
            anchors{
                left: parent.left
                top: parent.top
                topMargin: 20
                leftMargin: 100
            }
        }

        Rectangle {
            id: ipAddressRectangle
            height: parent.height * 0.40
            width: parent.width * 0.80
            color: "#282828"
            anchors{
                top: ipAdddressText.bottom
                topMargin: 10
                left: parent.left
                leftMargin: 100
            }

            TextInput{
                id: ipAddressRectangleTextInput
                text: ipAddress
                anchors.fill: parent
                font.pointSize: 15
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.topMargin: 25
                color: "white"
            }
        }
    }

    Rectangle {
        id: portNumberBlock
        height: parent.height * 0.30
        width: parent.width * 0.50
        color: "#161618"
        anchors{
            right: parent.right
            top: parent.top
        }

        Text {
            id: portNumberText
            text: qsTr("Destination Port Number")
            color: "white"
            font.pointSize: 15
            anchors{
                left: parent.left
                top: parent.top
                topMargin: 20
            }
        }

        Rectangle {
            id: portNumberRectangle
            height: parent.height * 0.40
            width: parent.width * 0.80
            color: "#282828"
            anchors{
                top: portNumberText.bottom
                topMargin: 10
                left: parent.left
            }

            TextInput{
                id: portNumberRectangleTextInput
                text: portNumber
                anchors.fill: parent
                font.pointSize: 15
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.topMargin: 25
                color: "white"
            }
        }
    }

    Rectangle {
        id: updateSettingButton
        width: parent.width * 0.20
        height: parent.height * 0.10
        anchors.right: parent.right
        anchors.rightMargin: 150
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        color:"#d7003f"

        Text {
            id: updateSettingButtonText
            text: qsTr("UPDATE SETTINGS")
            font.pointSize: 15
            font.bold: true
            color: "white"
            anchors.centerIn: parent
        }

        MouseArea {
            id: updateSettingButtonMouseArea
            anchors.fill: parent
            onClicked: {
                console.log("update settings")
                vermeerFirebaseManager.updateSetting(ipAddressRectangleTextInput.text,portNumberRectangleTextInput.text)
            }
        }
    }
}
