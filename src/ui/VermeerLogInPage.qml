
import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

Rectangle {
    id:     vermeerLogInPage
    color:  "black"
    z:      QGroundControl.zOrderTopMost

    readonly property real _defaultTextHeight:  ScreenTools.defaultFontPixelHeight
    readonly property real _defaultTextWidth:   ScreenTools.defaultFontPixelWidth
    readonly property real _horizontalMargin:   _defaultTextWidth / 2
    readonly property real _verticalMargin:     _defaultTextHeight / 2
    readonly property real _buttonHeight:       ScreenTools.isTinyScreen ? ScreenTools.defaultFontPixelHeight * 3 : ScreenTools.defaultFontPixelHeight * 2

    property int middleY: height /2
    property int middleX: width / 2

    VermeerLogInPage{
        id: vermeerLogInPageClass
    }

    // vermeer logo
    Rectangle {
        id : vermeerLogoLogInPage
        height: parent.height
        width: parent.width / 2
        color: "black"
        x:0

        Image {
            id: vermeerLogo
            source: "/vermeer/vermeerLogoBlackPng"
            anchors.centerIn: parent

            height: parent.height / 2
            width: parent.width / 2

            x: vermeerLogoLogInPage.width / 2
            y: vermeerLogoLogInPage.height / 2
        }
    }

    // for the sign in
    Rectangle {
        id: vermeerSignIn
        height: parent.height
        width: parent.width / 2
        color: "black"
        x: parent.width / 2

        Rectangle {
            id: vermeerSendJsonButton
            color: "white"
            height: parent.height / 16
            width: parent.width / 4
            x: parent.width / 2
            y: parent.height / 8

            MouseArea {
                id: signInMouseArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton

                onClicked: {

                    if(mouse.button === Qt.LeftButton)
                    {
                        console.log("sending json")
                        vermeerLogInPageClass.sendJson(jsonfilePathTextInputField.text)
                    }
                }
            }

            Text {
                id: vermeerSignInText
                text: qsTr("Send Json")
                color: "black"
                font.pointSize: 35
                anchors.centerIn: parent
            }
        }

        Rectangle {
            id: vermeerConnectButton
            color: "white"
            height: parent.height / 16
            width: parent.width / 4
            x: parent.width / 2
            y: parent.height / 4

            MouseArea {
                id: vermmerConnectMouseArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton

                onClicked: {
                    if(mouse.button === Qt.LeftButton)
                    {
                        console.log("connecting to companion computer")
                        vermeerLogInPageClass.connectToCompanionComputer(ipAddressSource.text,ipAddressDestination.text);
                    }
                }
            }

            Text {
                id: vermeerConnectButtonText
                text: qsTr("Connect to Jetson")
                color: "black"
                font.pointSize: 20
                anchors.centerIn: parent
            }

        }

        Rectangle {
            id: vermeerDisconnectButton
            color: "white"
            height: parent.height / 16
            width: parent.width / 4
            x: parent.width / 8
            y: parent.height / 4

            MouseArea {
                id: vermmerDisconnectMouseArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton

                onClicked: {
                    if(mouse.button === Qt.LeftButton)
                    {
                        console.log("disconnecting to companion computer")
                        vermeerLogInPageClass.disconnectFromCompanionComputer()
                    }
                }
            }

            Text {
                id: vermeerDisconnectButtonText
                text: qsTr("Disconnect from Jetson")
                color: "black"
                font.pointSize: 20
                anchors.centerIn: parent
            }

        }

        Rectangle {
            id: vermeerTextInputForJsonFilePath
            width: parent.width
            height: parent.height / 64
            border.color: "gray"
            border.width: 1

            TextInput {
                id: jsonfilePathTextInputField
                anchors.fill: parent
            }
        }

        Rectangle {
            id: vermeerTextInputForSourceIpAddress
            width: parent.width/2
            height: parent.height / 64
            border.color: "red"
            border.width: 1
            y: parent.height / 10

            TextInput {
                id: ipAddressSource
                anchors.fill: parent
            }
        }

        Rectangle {
            id: vermeerTextInputForDestinationIpAddress
            width: parent.width/2
            height: parent.height / 64
            border.color: "green"
            border.width: 1
            y: parent.height / 10
            x: parent.width / 2

            TextInput {
                id: ipAddressDestination
                anchors.fill: parent
            }
        }
    }
}

