/*
 * Serial Studio - https://serial-studio.github.io/
 *
 * Copyright (C) 2020-2025 Alex Spataru <https://aspatru.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls

import SerialStudio
import "../../Widgets" as Widgets

Rectangle {
  id: root
  implicitWidth: (layout.implicitWidth + 32)

  //
  // Custom signals
  //
  signal setupClicked()
  signal consoleClicked()
  signal dashboardClicked()
  signal structureClicked()
  signal projectEditorClicked()

  //
  // Aliases to button check status
  //
  property alias setupChecked: setupBt.checked
  property alias consoleChecked: consoleBt.checked
  property alias dashboardChecked: dashboardBt.checked
  property alias structureChecked: structureBt.checked

  //
  // Calculate offset based on platform
  //
  property int titlebarHeight: Cpp_NativeWindow.titlebarHeight(mainWindow)
  Connections {
    target: mainWindow
    function onVisibilityChanged() {
      root.titlebarHeight = Cpp_NativeWindow.titlebarHeight(mainWindow)
    }
  }

  //
  // Set toolbar height
  //
  Layout.minimumHeight: titlebarHeight + 64 + 16
  Layout.maximumHeight: titlebarHeight + 64 + 16

  //
  // Titlebar text
  //
  Label {
    text: mainWindow.title
    visible: root.titlebarHeight > 0
    color: Cpp_ThemeManager.colors["titlebar_text"]
    font: Cpp_Misc_CommonFonts.customUiFont(1.07, true)

    anchors {
      topMargin: 6
      top: parent.top
      horizontalCenter: parent.horizontalCenter
    }
  }

  //
  // Toolbar background
  //
  gradient: Gradient {
    GradientStop {
      position: 0
      color: Cpp_ThemeManager.colors["toolbar_top"]
    }

    GradientStop {
      position: 1
      color: Cpp_ThemeManager.colors["toolbar_bottom"]
    }
  }

  //
  // Toolbar border
  //
  Rectangle {
    height: 1
    color: Cpp_ThemeManager.colors["toolbar_border"]

    anchors {
      left: parent.left
      right: parent.right
      bottom: parent.bottom
    }
  }

  //
  // Drag main window with the toolbar
  //
  DragHandler {
    target: null
    onActiveChanged: {
      if (active)
        mainWindow.startSystemMove()
    }
  }

  //
  // Toolbar controls
  //
  RowLayout {
    id: layout
    spacing: 4

    anchors {
      margins: 2
      left: parent.left
      right: parent.right
      verticalCenter: parent.verticalCenter
      verticalCenterOffset: root.titlebarHeight / 2
    }

    //
    // Horizontal spacer
    //
    Item {
      implicitWidth: 1
    }

    //
    // Project Editor
    //
    Widgets.BigButton {
      text: qsTr("Project Editor")
      Layout.alignment: Qt.AlignVCenter
      onClicked: app.showProjectEditor()
      icon.source: "qrc:/rcc/icons/toolbar/project-setup.svg"
      enabled: Cpp_JSON_FrameBuilder.operationMode == SerialStudio.ProjectFile
    }

    //
    // CSV Player
    //
    Widgets.BigButton {
      text: qsTr("CSV Player")
      Layout.alignment: Qt.AlignVCenter
      onClicked: Cpp_CSV_Player.openFile()
      icon.source: "qrc:/rcc/icons/toolbar/csv.svg"
      enabled: !Cpp_CSV_Player.isOpen && !Cpp_IO_Manager.isConnected
    }

    //
    // Separator
    //
    Rectangle {
      implicitWidth: 1
      Layout.fillHeight: true
      Layout.maximumHeight: 64
      Layout.alignment: Qt.AlignVCenter
      color: Cpp_ThemeManager.colors["toolbar_separator"]
    }

    //
    // Setup
    //
    Widgets.BigButton {
      id: setupBt
      text: qsTr("Setup")
      onClicked: root.setupClicked()
      Layout.alignment: Qt.AlignVCenter
      icon.source: "qrc:/rcc/icons/toolbar/device-setup.svg"
    }

    //
    // Console
    //
    Widgets.BigButton {
      id: consoleBt
      opacity: 1
      text: qsTr("Console")
      enabled: dashboardBt.enabled
      onClicked: root.consoleClicked()
      Layout.alignment: Qt.AlignVCenter
      icon.source: "qrc:/rcc/icons/toolbar/console.svg"
    }

    //
    // Separator
    //
    Rectangle {
      implicitWidth: 1
      Layout.fillHeight: true
      Layout.maximumHeight: 64
      Layout.alignment: Qt.AlignVCenter
      color: Cpp_ThemeManager.colors["toolbar_separator"]
    }

    //
    // Dashboard Structure
    //
    Widgets.BigButton {
      id: structureBt
      text: qsTr("Widgets")
      enabled: dashboardBt.checked
      Layout.alignment: Qt.AlignVCenter
      onClicked: root.structureClicked()
      icon.source: "qrc:/rcc/icons/toolbar/structure.svg"
    }

    //
    // Dashboard
    //
    Widgets.BigButton {
      id: dashboardBt
      text: qsTr("Dashboard")
      onClicked: root.dashboardClicked()
      Layout.alignment: Qt.AlignVCenter
      enabled: Cpp_UI_Dashboard.available
      icon.source: "qrc:/rcc/icons/toolbar/dashboard.svg"
    }

    //
    // Separator
    //
    Rectangle {
      implicitWidth: 1
      Layout.fillHeight: true
      Layout.maximumHeight: 64
      Layout.alignment: Qt.AlignVCenter
      visible: Cpp_QtCommercial_Available
      color: Cpp_ThemeManager.colors["toolbar_separator"]
    }

    //
    // MQTT Setup
    //
    Loader {
      active: Cpp_QtCommercial_Available
      sourceComponent: Component {
        Widgets.BigButton {
          text: qsTr("MQTT")
          onClicked: app.showMqttConfiguration()
          icon.source: Cpp_MQTT_Client.isConnected ?
                         (Cpp_MQTT_Client.isSubscriber ?
                            "qrc:/rcc/icons/toolbar/mqtt-subscriber.svg" :
                            "qrc:/rcc/icons/toolbar/mqtt-publisher.svg") :
                         "qrc:/rcc/icons/toolbar/mqtt.svg"
        }
      }
    }

    //
    // Separator
    //
    Rectangle {
      implicitWidth: 1
      Layout.fillHeight: true
      Layout.maximumHeight: 64
      Layout.alignment: Qt.AlignVCenter
      color: Cpp_ThemeManager.colors["toolbar_separator"]
    }

    //
    // Examples
    //
    Widgets.BigButton {
      text: qsTr("Examples")
      Layout.alignment: Qt.AlignVCenter
      icon.source: "qrc:/rcc/icons/toolbar/examples.svg"
      onClicked: Qt.openUrlExternally("https://github.com/Serial-Studio/Serial-Studio/tree/master/examples")
    }

    //
    // Help
    //
    Widgets.BigButton {
      text: qsTr("Help")
      Layout.alignment: Qt.AlignVCenter
      icon.source: "qrc:/rcc/icons/toolbar/help.svg"
      onClicked: Qt.openUrlExternally("https://github.com/Serial-Studio/Serial-Studio/wiki")
    }

    //
    // About
    //
    Widgets.BigButton {
      text: qsTr("About")
      onClicked: app.showAboutDialog()
      Layout.alignment: Qt.AlignVCenter
      icon.source: "qrc:/rcc/icons/toolbar/about.svg"
    }

    //
    // Horizontal spacer
    //
    Item {
      implicitWidth: 1
      Layout.fillWidth: true
    }

    //
    // Connect/Disconnect button
    //
    Widgets.BigButton {
      id: _connectButton
      Layout.alignment: Qt.AlignVCenter
      implicitWidth: metrics.width + 16
      font: Cpp_Misc_CommonFonts.boldUiFont
      Layout.minimumWidth: metrics.width + 16
      Layout.maximumWidth: metrics.width + 16
      checked: Cpp_IO_Manager.isConnected || mqttSubscriber
      text: checked ? qsTr("Disconnect") : qsTr("Connect")
      icon.source: checked ? "qrc:/rcc/icons/toolbar/connect.svg" :
                             "qrc:/rcc/icons/toolbar/disconnect.svg"

      //
      // Get MQTT status
      //
      readonly property bool mqttSubscriber: Cpp_QtCommercial_Available ? (Cpp_MQTT_Client.isConnected && Cpp_MQTT_Client.isSubscriber) : false

      //
      // Enable/disable the connect button
      //
      enabled: (Cpp_IO_Manager.configurationOk && !Cpp_CSV_Player.isOpen) || mqttSubscriber

      //
      // Connect/disconnect device when button is clicked
      //
      onClicked: {
        if (mqttSubscriber)
          Cpp_MQTT_Client.toggleConnection()
        else
          Cpp_IO_Manager.toggleConnection()
      }

      //
      // Obtain maximum width of the button
      //
      TextMetrics {
        id: metrics
        font: Cpp_Misc_CommonFonts.boldUiFont
        text: " " + qsTr("Disconnect") + " "
      }
    }

    //
    // Horizontal spacer
    //
    Item {
      implicitWidth: 1
    }
  }
}
