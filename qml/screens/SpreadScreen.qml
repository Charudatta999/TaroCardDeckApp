import QtQuick
import QtQuick.Controls

Item {
    id: spreadScreen
    Component.onCompleted: console.log("LOG: SpreadScreen created OK")

    property int spreadType: 0  // 0=ThreeCard, 1=CelticCross

    Rectangle {
        anchors.fill: parent
        color: "#000000"

        Column {
            anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: 24 }
            spacing: 20

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: spreadType === 0 ? "Three Card Spread" : "Celtic Cross"
                color: "#FFD700"; font.pixelSize: 20; font.bold: true
            }

            // Three-card row
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16
                visible: spreadType === 0

                Repeater {
                    model: 3
                    delegate: Column {
                        spacing: 8
                        Rectangle {
                            width: 90; height: 140; radius: 8
                            color: "#1A1A1A"; border.color: "#FFD700"; border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: "\u0950"; color: "#FFD700"; font.pixelSize: 24; opacity: 0.3
                            }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: ["Past","Present","Future"][index]
                            color: "#888888"; font.pixelSize: 11
                        }
                    }
                }
            }

            // Celtic Cross placeholder
            Item {
                visible: spreadType === 1
                width: parent.width; height: 200
                Text {
                    anchors.centerIn: parent
                    text: "Celtic Cross\n(coming soon)"
                    color: "#FFD700"; font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
