import QtQuick
import QtQuick.Controls

Item {
    id: drawScreen
    Component.onCompleted: console.log("LOG: DrawScreen created OK")

    Rectangle {
        anchors.fill: parent
        color: "#000000"

        Column {
            anchors.centerIn: parent
            spacing: 24
            width: 240

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Draw a Card"
                color: "#FFD700"; font.pixelSize: 22; font.bold: true
            }

            Rectangle {
                width: 180; height: 270; radius: 10
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#1A1A1A"; border.color: "#FFD700"; border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: "\u0950"; color: "#FFD700"; font.pixelSize: 48; opacity: 0.4
                }

                Text {
                    anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 16 }
                    text: "Tap to reveal"
                    color: "#FFFDD0"; font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: console.log("LOG: Card tapped")
                }
            }
        }
    }
}
