#!/usr/bin/env -S quickshell -p

// Displays a widget that shows current keypresses.

// Requires:
//   showmethekey-cli
//   quickshell

// Built with ai.

// NOTE:
// I just tried quickshell for the first time.
// Claude-code got this right in one prompt:
// > Read through the quickshell examples and @docs/ and build a widget that shows keypresses that i'm  pressing, like the @showmethekey.py I have built. Test it with quickshell -p ~/.config/quickshell/shell.qml    Ultrathink

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root
    
    // Properties to track current state
    property var pressedKeys: ({})
    property string displayText: ""
    
    // Process to run showmethekey-cli
    Process {
        id: keyProcess
        command: ["showmethekey-cli"]
        running: true
        
        stdout: SplitParser {
            onRead: data => {
                // Parse JSON events from showmethekey-cli
                root.parseKeyEvents(data)
            }
        }
        
        onStarted: console.log("showmethekey-cli started")
        onExited: (code, status) => {
            console.log("showmethekey-cli exited with code:", code)
            if (code !== 0) {
                console.log("Restarting showmethekey-cli in 2 seconds...")
                restartTimer.start()
            }
        }
    }
    
    // Timer to restart the process if it fails
    Timer {
        id: restartTimer
        interval: 2000
        onTriggered: keyProcess.running = true
    }
    
    // Function to format key names
    function formatKeyName(rawName) {
        if (rawName.startsWith("KEY_")) {
            return rawName.substring(4).toLowerCase()
        }
        return rawName.toLowerCase()
    }
    
    // Function to parse key events
    function parseKeyEvents(data) {
        try {
            // Split data by lines and process each JSON object
            var lines = data.split('\n')
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim()
                if (line.length === 0) continue
                
                // Try to find JSON objects in the line
                var startIdx = line.indexOf('{')
                var endIdx = line.lastIndexOf('}')
                if (startIdx !== -1 && endIdx !== -1 && endIdx > startIdx) {
                    var jsonStr = line.substring(startIdx, endIdx + 1)
                    var event = JSON.parse(jsonStr)
                    
                    var keyName = event.key_name
                    var stateName = event.state_name
                    
                    if (keyName && stateName) {
                        if (stateName === "PRESSED") {
                            root.pressedKeys[keyName] = true
                        } else if (stateName === "RELEASED") {
                            delete root.pressedKeys[keyName]
                        }
                        
                        // Update display text
                        root.updateDisplayText()
                    }
                }
            }
        } catch (e) {
            console.log("Error parsing key event:", e)
        }
    }
    
    // Function to update display text
    function updateDisplayText() {
        var keys = Object.keys(root.pressedKeys)
        if (keys.length === 0) {
            root.displayText = "[        ]"
        } else {
            var formattedKeys = keys.map(key => root.formatKeyName(key)).sort()
            root.displayText = "[ " + formattedKeys.join(" + ") + " ]"
        }
    }
    
    // Create window on primary screen
    PanelWindow {
        screen: Quickshell.screens[0] // Use primary screen
        
        anchors {
            right: true
            bottom: true
        }
        
        margins {
            right: 30
            bottom: 70
        }
        
        implicitWidth: Math.max(200, displayContent.implicitWidth + 40)
        implicitHeight: displayContent.implicitHeight + 20
        
        color: "#80000000"  // Semi-transparent black background
        
        // Give the window an empty click mask so clicks pass through
        mask: Region {}
        
        ColumnLayout {
            id: displayContent
            anchors.centerIn: parent
            
            Text {
                text: "Keypresses:"
                color: "#ffffff"
                font.pointSize: 10
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: root.displayText || "[        ]"
                color: "#ffffff"
                font.pointSize: 14
                font.family: "monospace"
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
    
    // Initialize display text
    Component.onCompleted: {
        root.updateDisplayText()
    }
}
