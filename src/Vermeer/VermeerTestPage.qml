
import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

Rectangle {
    id:     vermeerTestPage
    color:  "black"
    z:      QGroundControl.zOrderTopMost

    readonly property real _defaultTextHeight:  ScreenTools.defaultFontPixelHeight
    readonly property real _defaultTextWidth:   ScreenTools.defaultFontPixelWidth
    readonly property real _horizontalMargin:   _defaultTextWidth / 2
    readonly property real _verticalMargin:     _defaultTextHeight / 2
    readonly property real _buttonHeight:       ScreenTools.isTinyScreen ? ScreenTools.defaultFontPixelHeight * 3 : ScreenTools.defaultFontPixelHeight * 2

    property int middleY: height /2
    property int middleX: width / 2

    property date currentDate: new Date()

    VermeerFirebaseManager{
        id: vermeerFirebaseManager
        onDisplayMsgToQml: {
            console.log("onDisplayMsgToQml:")
            console.log(data)

            if("fetchFlightPlans" === data){
                console.log("fetching flight plans")
                vermeerFirebaseManager.fetchFlightPlans();
            }
        }
    }


    Rectangle {
        id : testAuthenticateButton
        height: parent.height / 8
        width: parent.width / 8
        color: "white"
        x: middleX
        y: middleY

        MouseArea {
            id: testAuthenticateButtonMouseArea
            anchors.fill: parent

            onClicked: {
                console.log("sending auth request")

                var userEmail = "czarbalangue@gmail.com"
                var userPassword = "aaaaaa"
                vermeerFirebaseManager.signIn(userEmail,userPassword)
            }
        }

        Text {
            id: vermeerSignInText
            text: qsTr("Authenticate Test Button")
            color: "black"
            font.pointSize: 10
            anchors.centerIn: parent
        }
    }
    /*
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
                text: qsTr("Send Mission File")
                color: "black"
                font.pointSize: 10
                anchors.centerIn: parent
            }
        }


        Rectangle {
            id: vermeerSendKeyFrameMission
            color: "white"
            height: parent.height / 16
            width: parent.width / 4
            x: parent.width / 8
            y: parent.height * .40

            MouseArea {
                id: vermeerSendKeyFrameMouseArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton

                onClicked: {
                    if(mouse.button === Qt.LeftButton)
                    {
                        console.log("sending keyframe mission")
                        //vermeerLogInPageClass.sendJson(jsonfilePathTextInputField.text)
                    }
                }
            }

            Text {
                id: vermeerSendKeyFrameMissionText
                text: qsTr("Send Keyframe Mission")
                color: "black"
                font.pointSize: 10
                anchors.centerIn: parent
            }
        }

        Rectangle {
            id: vermeerExecuteKeyFrameMission
            color: "white"
            height: parent.height / 16
            width: parent.width / 4
            x: parent.width * 0.50
            y: parent.height * .40

            MouseArea {
                id: vermeerExecuteKeyFrameMouseArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton

                onClicked: {
                    if(mouse.button === Qt.LeftButton)
                    {
                        console.log("Execute keyframe mission")
                        //vermeerLogInPageClass.sendJson(jsonfilePathTextInputField.text)
                    }
                }
            }

            Text {
                id: vermeerExecuteKeyFrameMissionText
                text: qsTr("Execute Keyframe Mission")
                color: "black"
                font.pointSize: 10
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
                font.pointSize: 10
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
                        console.log("disconnecting to companion computer\n")
                        vermeerLogInPageClass.disconnectFromCompanionComputer()
                    }
                }
            }

            Text {
                id: vermeerDisconnectButtonText
                text: qsTr("Disconnect from Jetson")
                color: "black"
                font.pointSize: 10
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
            width: parent.width / 2
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

        Rectangle {
            id: vermeerNotificationRectangle
            width: parent.width
            height: parent.height / 4
            border.color: "red"
            border.width: 3
            y: parent.height / 2
            x: 0

            TextArea {
                id: vermeerNotificationTextInput
                anchors.fill: parent
            }
        }
    }

    */
}

