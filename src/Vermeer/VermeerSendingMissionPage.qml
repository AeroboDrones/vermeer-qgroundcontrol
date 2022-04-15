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
    id: vermeerSendingMissionPage
    height: parent.height
    width: parent.width
    color: "#161618"

    Rectangle {
        id: vermeerSendingMissionPageRectangle
        height: parent.height * .30
        width: parent.width
        anchors.centerIn: parent
        color: "#161618"
        Text {
            id: vermeerSendingMissionPageText
            text: qsTr("Sending Mission...")
            color: "white"
            font.pointSize: 30
            font.bold: true
            x: parent.width * 0.30
            y: parent.height * 0.85
        }
    }

    Image {
        id: vermeerSendingMissionIcon
        source: "/vermeer/VermeerReloadMissionCircle.png" // should be change to a image for sending a mission
        width: parent.width * 0.08
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent

        RotationAnimation{
            id: imageRotationAnimation
            target: vermeerSendingMissionIcon
            loops: Animation.Infinite
            from: vermeerSendingMissionIcon.rotation
            to: 360
            direction: RotationAnimation.Clockwise
            duration: 3000
            running: true
        }
    }
}
