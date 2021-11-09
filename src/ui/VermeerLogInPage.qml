
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

    property var middleY: height /2
    property var middleX: width / 2


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

        Text {
            id: signIn
            text: qsTr("Sign in")
            color: "white"

            x: vermeerSignIn.width / 2
            y: vermeerSignIn.height / 2
        }
    }


//    QGCButton {

//        height:             100
//        text:               "Sign In"
//        anchors.bottomMargin: 12
//        color: "red"

//        onClicked: {
//            testText.text = "Its a good day today"
//        }

//    }




    // explore whether we should use buttons
//    Button {
//       text: "Sign in"
//       a
//    }


//    property bool _first: true

//    QGCPalette { id: qgcPal }

//    Component.onCompleted: {
//        //-- Default Settings
//        __rightPanel.source = QGroundControl.corePlugin.settingsPages[QGroundControl.corePlugin.defaultSettings].url
//    }

//    QGCFlickable {
//        id:                 buttonList
//        width:              buttonColumn.width
//        anchors.topMargin:  _verticalMargin
//        anchors.top:        parent.top
//        anchors.bottom:     parent.bottom
//        anchors.leftMargin: _horizontalMargin
//        anchors.left:       parent.left
//        contentHeight:      buttonColumn.height + _verticalMargin
//        flickableDirection: Flickable.VerticalFlick
//        clip:               true

//        ColumnLayout {
//            id:         buttonColumn
//            spacing:    _verticalMargin

//            property real _maxButtonWidth: 0

//            Repeater {
//                model:  QGroundControl.corePlugin.settingsPages
//                QGCButton {
//                    height:             _buttonHeight
//                    text:               modelData.title
//                    autoExclusive:      true
//                    Layout.fillWidth:   true

//                    onClicked: {
//                        if (mainWindow.preventViewSwitch()) {
//                            return
//                        }
//                        if (__rightPanel.source !== modelData.url) {
//                            __rightPanel.source = modelData.url
//                        }
//                        checked = true
//                    }

//                    Component.onCompleted: {
//                        if(_first) {
//                            _first = false
//                            checked = true
//                        }
//                    }
//                }
//            }
//        }
//    }

//    Rectangle {
//        id:                     divider
//        anchors.topMargin:      _verticalMargin
//        anchors.bottomMargin:   _verticalMargin
//        anchors.leftMargin:     _horizontalMargin
//        anchors.left:           buttonList.right
//        anchors.top:            parent.top
//        anchors.bottom:         parent.bottom
//        width:                  1
//        color:                  qgcPal.windowShade
//    }

//    //-- Panel Contents
//    Loader {
//        id:                     __rightPanel
//        anchors.leftMargin:     _horizontalMargin
//        anchors.rightMargin:    _horizontalMargin
//        anchors.topMargin:      _verticalMargin
//        anchors.bottomMargin:   _verticalMargin
//        anchors.left:           divider.right
//        anchors.right:          parent.right
//        anchors.top:            parent.top
//        anchors.bottom:         parent.bottom
//    }
}

