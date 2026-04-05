// Reading / Spread screen
import QtQuick
import QtQuick.Controls

Item {
    id: spreadScreen
    Component.onCompleted: console.log("LOG: SpreadScreen created OK")

    property int spreadType: 0  // 0=ThreeCard, 1=CelticCross

    Rectangle { anchors.fill: parent; color: "#050305" }

    // Scrollable body
    Flickable {
        anchors.fill: parent
        contentHeight: bodyCol.height + 20
        clip: true

        Column {
            id: bodyCol
            width: spreadScreen.width
            spacing: 0
            topPadding: 14

            // ── Spread layout ────────────────────────────────────────
            Item {
                width: parent.width; height: 160

                Row {
                    anchors.centerIn: parent
                    spacing: 10

                    Repeater {
                        model: spreadType === 0 ? 3 : 5
                        delegate: Column {
                            spacing: 6

                            // Position label above
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: spreadType === 0
                                    ? ["PAST","PRESENT","FUTURE"][index]
                                    : ["SELF","CROSS","BASE","PAST","POTENTIAL"][index]
                                color: "#4dEDD9A3"; font.pixelSize: 7; font.letterSpacing: 2
                            }

                            // Mini card
                            Rectangle {
                                width: 72; height: 115; radius: 7
                                color: "#1a141a"
                                border.color: "#4dD4AF37"; border.width: 1

                                // Saffron corner glow
                                Rectangle {
                                    anchors.fill: parent; radius: 7
                                    gradient: Gradient {
                                        orientation: Gradient.Vertical
                                        GradientStop { position: 0.0; color: "#1aE8630A" }
                                        GradientStop { position: 1.0; color: "transparent" }
                                    }
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 3

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "\u0950"
                                        color: "#D4AF37"; font.pixelSize: 20; opacity: 0.5
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "TAP"
                                        color: "#33EDD9A3"; font.pixelSize: 7; font.letterSpacing: 2
                                    }
                                }

                                // Card number badge
                                Text {
                                    anchors { top: parent.top; right: parent.right; topMargin: 3; rightMargin: 4 }
                                    text: String(index + 1)
                                    color: "#4dEDD9A3"; font.pixelSize: 7
                                }
                            }
                        }
                    }
                }
            }

            // ── Section divider ──────────────────────────────────────
            Item {
                width: parent.width; height: 1
                Rectangle {
                    anchors { left: parent.left; right: parent.right; leftMargin: 14; rightMargin: 14; verticalCenter: parent.verticalCenter }
                    height: 1; color: "#22D4AF37"
                }
            }

            // ── Card detail blocks ───────────────────────────────────
            Repeater {
                model: spreadType === 0 ? 3 : 5
                delegate: Rectangle {
                    width: spreadScreen.width - 28; height: 140
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#110d10"
                    border.color: "#1fD4AF37"; border.width: 1
                    radius: 14

                    // Position label
                    Text {
                        anchors { top: parent.top; left: parent.left; topMargin: 10; leftMargin: 14 }
                        text: spreadType === 0
                            ? ["PAST","PRESENT","FUTURE"][index]
                            : ["SELF","CROSS","BASE","PAST","POTENTIAL"][index]
                        color: "#E8630A"; font.pixelSize: 8; font.letterSpacing: 3
                    }

                    // Card name placeholder
                    Text {
                        anchors { top: parent.top; topMargin: 28; left: parent.left; leftMargin: 14 }
                        text: "— draw a card —"
                        color: "#D4AF37"; font.pixelSize: 14
                    }

                    // Deity placeholder
                    Text {
                        anchors { top: parent.top; topMargin: 52; left: parent.left; leftMargin: 14 }
                        text: "tap a card in the deck to select"
                        color: "#4dEDD9A3"; font.pixelSize: 11
                    }

                    // Gold divider
                    Rectangle {
                        anchors { left: parent.left; right: parent.right; top: parent.top; leftMargin: 14; rightMargin: 14; topMargin: 76 }
                        height: 1; color: "#1aD4AF37"
                    }

                    // Deity block
                    Rectangle {
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 10 }
                        height: 44; radius: 8
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#4d4A0E0E" }
                            GradientStop { position: 1.0; color: "#401a141a" }
                        }
                        border.color: "#33E8630A"; border.width: 1

                        Row {
                            anchors { left: parent.left; right: parent.right; leftMargin: 12; rightMargin: 12; verticalCenter: parent.verticalCenter }
                            spacing: 10
                            Text { text: "\u0950"; color: "#D4AF37"; font.pixelSize: 22; opacity: 0.4 }
                            Column {
                                spacing: 2
                                Text { text: "DEITY"; color: "#4dE8630A"; font.pixelSize: 7; font.letterSpacing: 3 }
                                Text { text: "Select a card"; color: "#80EDD9A3"; font.pixelSize: 11 }
                            }
                        }
                    }
                }
            }

            // Bottom padding
            Item { width: 1; height: 20 }
        }
    }
}
