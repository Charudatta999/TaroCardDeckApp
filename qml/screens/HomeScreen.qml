import QtQuick
import QtQuick.Controls

Item {
    id: homeScreen

    Component.onCompleted: console.log("LOG: HomeScreen created OK")

    signal navigateTo(string screen)

    Rectangle {
        anchors.fill: parent
        color: "#000000"

        // Center column
        Column {
            anchors.centerIn: parent
            spacing: 32
            width: 260   // wide enough for all fixed-size children

            // ── Diya ──────────────────────────────────────────────────
            Item {
                id: diyaContainer
                width: 140; height: 140
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.centerIn: parent
                    width: 180; height: 180; radius: 90
                    color: "#FF6000"; opacity: 0.08; z: -1
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.18; duration: 1800; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.06; duration: 1600; easing.type: Easing.InOutSine }
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 110; height: 110; radius: 55
                    color: "#FFD700"; opacity: 0.12; z: -1
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.22; duration: 1200; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.08; duration: 1400; easing.type: Easing.InOutSine }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 70; color: "#1A1A1A"
                    border.color: "#FFD700"; border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "\u0950"; color: "#FFD700"; font.pixelSize: 52
                    }
                }

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.85; duration: 900; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0;  duration: 700; easing.type: Easing.InOutSine }
                }
            }

            // ── Title ─────────────────────────────────────────────────
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "\u0950  T A R O  \u0950"
                color: "#FFD700"; font.pixelSize: 20; font.bold: true
            }

            // ── Card deck stack ───────────────────────────────────────
            Item {
                width: 180; height: 240
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: 5
                    delegate: Rectangle {
                        x: (4 - index) * 3; y: (4 - index) * -2
                        width: 160; height: 230; radius: 8
                        color: "#0D0D0D"; border.color: "#FFD700"; border.width: 1
                        opacity: 0.4 + (index * 0.12)
                        Text {
                            anchors.centerIn: parent
                            text: "\u0950"; color: "#FFD700"; font.pixelSize: 26; opacity: 0.3
                        }
                    }
                }
            }

            // ── Shuffle & Draw ─────────────────────────────────────────
            Rectangle {
                width: 220; height: 52; radius: 26; color: "#FFD700"
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    anchors.centerIn: parent
                    text: "Shuffle & Draw"
                    color: "#000000"; font.pixelSize: 16; font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: homeScreen.navigateTo("draw")
                }
            }
        }
    }
}
