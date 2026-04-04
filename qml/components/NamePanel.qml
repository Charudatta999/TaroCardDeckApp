import QtQuick
import QtQuick.Controls

Rectangle {
    id: panel
    color: "#111111"
    radius: 12
    border.color: "#FFD700"
    border.width: 1

    property string beingName: ""
    property string description: ""
    property string mantra: ""

    Column {
        anchors { fill: parent; margins: 16 }
        spacing: 12

        Text {
            text: panel.beingName
            color: "#FFD700"; font.pixelSize: 20; font.bold: true
            width: parent.width
        }

        Rectangle {
            width: parent.width; height: 1
            color: "#FFD700"; opacity: 0.3
        }

        Text {
            text: panel.description
            color: "#FFFDD0"; font.pixelSize: 14
            wrapMode: Text.WordWrap
            width: parent.width
        }

        Text {
            visible: panel.mantra.length > 0
            text: "Mantra: " + panel.mantra
            color: "#FF4500"; font.pixelSize: 14; font.italic: true
            wrapMode: Text.WordWrap
            width: parent.width
        }
    }
}
