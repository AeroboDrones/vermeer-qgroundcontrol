# QGroundControl Ground Control Station

[![Releases](https://img.shields.io/github/release/mavlink/QGroundControl.svg)](https://github.com/mavlink/QGroundControl/releases)
[![Travis Build Status](https://travis-ci.org/mavlink/qgroundcontrol.svg?branch=master)](https://travis-ci.org/mavlink/qgroundcontrol)
[![Appveyor Build Status](https://ci.appveyor.com/api/projects/status/crxcm4qayejuvh6c/branch/master?svg=true)](https://ci.appveyor.com/project/mavlink/qgroundcontrol)

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/mavlink/qgroundcontrol?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


*QGroundControl* (QGC) is an intuitive and powerful ground control station (GCS) for UAVs.

The primary goal of QGC is ease of use for both first time and professional users. 
It provides full flight control and mission planning for any MAVLink enabled drone, and vehicle setup for both PX4 and ArduPilot powered UAVs. Instructions for *using QGroundControl* are provided in the [User Manual](https://docs.qgroundcontrol.com/en/) (you may not need them because the UI is very intuitive!)

All the code is open-source, so you can contribute and evolve it as you want. 
The [Developer Guide](https://dev.qgroundcontrol.com/en/) explains how to [build](https://dev.qgroundcontrol.com/en/getting_started/) and extend QGC.


Key Links: 
* [Website](http://qgroundcontrol.com) (qgroundcontrol.com)
* [User Manual](https://docs.qgroundcontrol.com/en/)
* [Developer Guide](https://dev.qgroundcontrol.com/en/)
* [Discussion/Support](https://docs.qgroundcontrol.com/en/Support/Support.html)
* [Contributing](https://dev.qgroundcontrol.com/en/contribute/)
* [License](https://github.com/mavlink/qgroundcontrol/blob/master/COPYING.md)

# Vermeer Context

Vermeer specific features are build on top of the existing herelink-V4.0.8 branch of the [CubePilot/qgroundcontrol-herelink](https://github.com/CubePilot/qgroundcontrol-herelink/commits/herelink-v4.0.8) repository

The Vermer application was developed on top of [this](https://github.com/CubePilot/qgroundcontrol-herelink/tree/5440f933278d01f9974ad5410d31246f865ccbd9) commit 

# Pre-requisites 

Qt Creator Version used is Version 6.0.1

Qt Kit version used is Android Qt 5.12.6 Clang armeabia-v7a

building for android-25

ANDROID_NDK_ROOT set to android-ndk-r20b

JAVA_HOME set to java-8-openjdk-amd64

# Vermeer Top Level Design

There are three main pages 

* Sign In Page - VermeerSignInPage.qml
* Mission Page - VermeerMissionPage.qml
* Settings Page - VermeerSettingsPage.qml

The entry point to the Vermeer pages is through the vermeer button found in the qgc toolbar which is defined in MainToolBar.qml id=vermeerButton
It calls showVermeerSignInPage from MainRootWindow.qml
The three main pages are loaded to a Loader id=vermeerLoader defined in MainRootWindow.qml
All the c++ files and resource files are found in src/Vermeer