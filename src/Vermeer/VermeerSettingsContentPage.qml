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

    function showInvalidSettingsPage(){
        invalidSettingsPage.visible = true
        invalidSettingsPage.z = 1
    }

    function showSettingsPage(){
        invalidSettingsPage.visible = false
        invalidSettingsPage.z = 0
        successfulSettingsUpdatePage.visible = false
        successfulSettingsUpdatePage.z = 0
    }

    function showSuccessfulSettingsUpdate(){
        successfulSettingsUpdatePage.visible = true
        successfulSettingsUpdatePage.z = 1
    }

    VermeerFirebaseManager{
        id: vermeerFirebaseManager
        onDisplayMsgToQml: {
            if("InvalidIpAddress" === data){
                showInvalidSettingsPage()
            }

            if("SettingsUpdatedSuccessfuly" === data){
                showSuccessfulSettingsUpdate()
            }
        }
    }

    Component.onCompleted: {
        ipAddressRectangleTextInput.text = vermeerFirebaseManager.getDestinationIpAddress()
        portNumberRectangleTextInput.text = vermeerFirebaseManager.getDestinationPortNumber()
    }

    Rectangle {
        id: invalidSettingsPage
        height: parent.height
        width: parent.width
        color: "#161618"
        anchors.centerIn: parent
        visible: false

        Text {
            id: invalidSettingsPageText
            text: "Invalid Ip Address"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -100
            anchors.bottom: invalidSettingsPageBackButton.top
            color: "white"
            font.pointSize: 25
            font.bold: true
        }

        Rectangle {
            id: invalidSettingsPageBackButton
            width: 250
            height: 60
            anchors.centerIn: parent
            color:"#d7003f"

             Text {
                id: invalidSettingsPageGoBackButtonText
                text: qsTr("Go Back")
                color: "white"
                anchors.centerIn: parent
             }

             MouseArea {
                 id: sucsessfulBackButtonMouseArea
                 anchors.fill: parent
                 onPressed: {
                     invalidSettingsPageGoBackButtonText.color = "#d7003f"
                     invalidSettingsPageBackButton.color = "white"

                 }
                 onReleased: {
                    invalidSettingsPageGoBackButtonText.color = "white"
                    invalidSettingsPageBackButton.color = "#d7003f"
                    showSettingsPage()
                 }
             }
        }
    }

    Rectangle {
        id: successfulSettingsUpdatePage
        height: parent.height
        width: parent.width
        color: "#161618"
        anchors.centerIn: parent
        visible: false

        Text {
            id: successfulSettingsUpdatePageText
            text: "Settings Updated Successfuly"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -100
            anchors.bottom: successfulSettingsUpdatePageBackButton.top
            color: "white"
            font.pointSize: 25
            font.bold: true
        }

        Rectangle {
            id: successfulSettingsUpdatePageBackButton
            width: 250
            height: 60
            anchors.centerIn: parent
            color:"#d7003f"

             Text {
                id: successfulSettingsUpdatePageGoBackButtonText
                text: qsTr("Go Back")
                color: "white"
                anchors.centerIn: parent
             }

             MouseArea {
                 id: successfulSettingsUpdatePageBackButtonMouseArea
                 anchors.fill: parent
                 onPressed: {
                     successfulSettingsUpdatePageGoBackButtonText.color = "#d7003f"
                     successfulSettingsUpdatePageBackButton.color = "white"

                 }
                 onReleased: {
                    successfulSettingsUpdatePageGoBackButtonText.color = "white"
                    successfulSettingsUpdatePageBackButton.color = "#d7003f"
                    showSettingsPage()
                 }
             }
        }
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
                validator: IntValidator {bottom: 0; top: 65353}
                inputMethodHints: Qt.ImhDigitsOnly
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
            onPressed: {
                updateSettingButtonText.color = "#d7003f"
                updateSettingButton.color = "white"
            }
            onReleased: {
                updateSettingButtonText.color = "white"
                updateSettingButton.color = "#d7003f"

                console.log("updating settings")
                vermeerFirebaseManager.updateSetting(ipAddressRectangleTextInput.text,portNumberRectangleTextInput.text)
            }
        }
    }
}
