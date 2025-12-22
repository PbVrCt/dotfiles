// Desktop widget that displays the time, date, battery, cpu usage and whether notifications are in hidden mode

// Requires:
//   quickshell
//   upower
//   makoctl

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

ShellRoot {
    property string currentTime: ""
    property string currentDate: ""
    property int batteryPct: -1
    property int cpuPct: -1
    property bool makoHidden: false
    property color defaultColor: "#a8a8a8"
    property color warningColor: "#ffaa00"
    property color criticalColor: "#ff4444"
    property string defaultFont: "monospace"
    
    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: {
            var now = new Date()
            currentTime = Qt.formatTime(now, "hh:mm")
            currentDate = Qt.formatDate(now, "dd ddd")
            if (UPower.displayDevice.ready && UPower.displayDevice.percentage >= 0) {
                batteryPct = Math.round(UPower.displayDevice.percentage * 100)
            }
            cpuProcess.running = true
            makoProcess.running = true
        }
    }
    
    Process {
        id: cpuProcess
        command: ["sh", "-c", "top -bn1 | awk '/^%Cpu\\(s\\):/{ print int($2) }'"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                var usage = parseInt(data.trim())
                if (!isNaN(usage)) cpuPct = usage
            }
        }
    }

    Process {
        id: makoProcess
        command: ["makoctl", "mode"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                var mode = data.trim()
                makoHidden = (mode === "hidden")
            }
        }
    }
    
    PanelWindow {
        screen: Quickshell.screens[0]
        anchors { right: true; bottom: true }
        margins { right: 2; bottom: 2 }
        implicitWidth: content.implicitWidth + 8
        implicitHeight: content.implicitHeight + 8
        color: "transparent"
        mask: Region {}
        
        RowLayout {
            id: content
            spacing: 12
            Column {
                visible: makoHidden
                Text {
                    text: "H"
                    color: warningColor
                    font { pointSize: 12; family: defaultFont }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            // Column {
            //     Text {
            //         text: currentTime
            //         color: defaultColor
            //         font { pointSize: 12; family: defaultFont }
            //         anchors.horizontalCenter: parent.horizontalCenter
            //     }
            //     Text {
            //         text: currentDate
            //         color: defaultColor
            //         font { pointSize: 9; family: defaultFont }
            //         anchors.horizontalCenter: parent.horizontalCenter
            //     }
            // }
            Column {
                Text {
                    text: "CPU"
                    color: defaultColor
                    font { pointSize: 9; family: defaultFont }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: cpuPct >= 0 ? cpuPct : "--"
                    color: cpuPct < 0 ? defaultColor :
                           cpuPct > 70 ? criticalColor :
                           cpuPct > 20 ? warningColor : defaultColor
                    font { pointSize: 11; family: defaultFont }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            Column {
                Text {
                    text: "BAT"
                    color: defaultColor
                    font { pointSize: 9; family: defaultFont }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: batteryPct >= 0 ? batteryPct : "--"
                    color: batteryPct < 0 ? defaultColor :
                           batteryPct < 20 ? criticalColor :
                           batteryPct < 50 ? warningColor : defaultColor
                    font { pointSize: 11; family: defaultFont }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
    
    Component.onCompleted: {
        var now = new Date()
        currentTime = Qt.formatTime(now, "hh:mm")
        currentDate = Qt.formatDate(now, "dd ddd")
        if (UPower.displayDevice.ready && UPower.displayDevice.percentage >= 0) {
            batteryPct = Math.round(UPower.displayDevice.percentage * 100)
        }
        cpuProcess.running = true
        makoProcess.running = true
    }
}
