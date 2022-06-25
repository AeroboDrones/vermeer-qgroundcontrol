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
    id: vermeerSettingsPageQml

    Rectangle{
        id: vermeerSettingsPageQmlBackground
        height: parent.height
        width: parent.width
        color: "#161618"
    }

    VermeerSettingsToolbar {
        id: vermeerSettingsPageToolBarQml
    }

    // this is the ipAddress page
    VermeerSettingsContentPage {
        id: vermeerSettingsContentPage
        anchors{
            right: parent.right
            top: vermeerSettingsPageToolBarQml.bottom
            left: parent.left
            bottom: parent.bottom
        }
    }
}
