// Desktop widget that displays the time, date, battery and cpu usage

// Requires:
//   quickshell
//   upower

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
    property color defaultColor: "#a8a8a8"
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
                Text {
                    text: currentTime
                    color: defaultColor
                    font { pointSize: 12; family: defaultFont }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: currentDate
                    color: defaultColor
                    font { pointSize: 9; family: defaultFont }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
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
                           cpuPct > 70 ? "#ff4444" :
                           cpuPct > 20 ? "#ffaa00" : defaultColor
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
                           batteryPct < 20 ? "#ff4444" :
                           batteryPct < 50 ? "#ffaa00" : defaultColor
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
    }
}
