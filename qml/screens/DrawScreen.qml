// Divination screen — horizontal scrollable deck + selection tray
import QtQuick
import QtQuick.Controls

Item {
    id: drawScreen
    Component.onCompleted: console.log("LOG: DrawScreen created OK")

    // Track selected card indices (max 3)
    property var selectedCards: []

    Rectangle {
        anchors.fill: parent
        color: "#050305"
    }

    Column {
        anchors.fill: parent
        spacing: 0
        // Heights: tray 86 + divider 20 + hint 28 + actionbar 58 = 192 → deck fills rest

        // ── Selection Tray ───────────────────────────────────────────
        Item {
            width: parent.width
            height: 86

            Rectangle {
                anchors.fill: parent
                color: "transparent"
            }

            // Tray header
            Row {
                id: trayHeader
                anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: 10; leftMargin: 14; rightMargin: 14 }
                height: 18

                Text {
                    text: "SELECTED"
                    color: "#4dEDD9A3"; font.pixelSize: 8; font.letterSpacing: 4
                    anchors.verticalCenter: parent.verticalCenter
                }
                Item { width: 1; height: 1 } // spacer handled by anchors

                Text {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    text: drawScreen.selectedCards.length + " / 3"
                    color: "#E8630A"; font.pixelSize: 8; font.letterSpacing: 2
                }
            }

            // Snake tray box
            Rectangle {
                anchors { top: trayHeader.bottom; left: parent.left; right: parent.right; topMargin: 6; leftMargin: 14; rightMargin: 14; bottom: parent.bottom; bottomMargin: 6 }
                color: "#0d110d10"
                border.color: "#22D4AF37"
                border.width: 1
                radius: 6

                // Snake glyphs on sides
                Text {
                    anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
                    text: "\u1F40D"  // fallback: use Om if snake not available
                    font.pixelSize: 16; color: "#59D4AF37"
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.6; duration: 1500; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.3; duration: 1500; easing.type: Easing.InOutSine }
                    }
                }

                // Three tray slots
                Row {
                    anchors.centerIn: parent
                    spacing: 10

                    Repeater {
                        model: 3
                        delegate: Rectangle {
                            width: 40; height: 58; radius: 5
                            color: index < drawScreen.selectedCards.length ? "#1a141a" : "transparent"
                            border.color: index < drawScreen.selectedCards.length ? "#80D4AF37" : "#33D4AF37"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: index < drawScreen.selectedCards.length ? "\u0950" : "+"
                                color: index < drawScreen.selectedCards.length ? "#D4AF37" : "#4dEDD9A3"
                                font.pixelSize: index < drawScreen.selectedCards.length ? 18 : 16
                            }
                        }
                    }
                }
            }
        }

        // ── Ornament divider ─────────────────────────────────────────
        Item {
            width: parent.width; height: 20
            Row {
                anchors.centerIn: parent
                spacing: 8
                Rectangle { width: 80; height: 1; color: "transparent"
                    gradient: Gradient { orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 1.0; color: "#26D4AF37" } }
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text { text: "\u2736 \u2736 \u2736"; color: "#33D4AF37"; font.pixelSize: 9; font.letterSpacing: 4 }
                Rectangle { width: 80; height: 1; color: "transparent"
                    gradient: Gradient { orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#26D4AF37" }
                        GradientStop { position: 1.0; color: "transparent" } }
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // ── Deck hint ────────────────────────────────────────────────
        Text {
            width: parent.width
            text: "SCROLL  \u00B7  TAP CORNER DOT TO SELECT"
            color: "#33EDD9A3"; font.pixelSize: 8; font.letterSpacing: 3
            horizontalAlignment: Text.AlignHCenter
            bottomPadding: 8
        }

        // ── Horizontal scrollable deck ───────────────────────────────
        Item {
            width: parent.width
            height: drawScreen.height - 86 - 20 - 28 - 58
            clip: true

            // Subtle maroon glow behind deck
            Rectangle {
                anchors.centerIn: parent
                width: parent.width; height: 160
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: "#1f4A0E0E" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            ListView {
                id: deckList
                anchors { fill: parent; topMargin: 10; bottomMargin: 10 }
                orientation: ListView.Horizontal
                spacing: 12
                leftMargin: 24; rightMargin: 24
                clip: true
                model: 78  // All 78 cards

                delegate: Item {
                    width: 108; height: deckList.height
                    property bool isSelected: {
                        for (var i = 0; i < drawScreen.selectedCards.length; i++)
                            if (drawScreen.selectedCards[i] === index) return true
                        return false
                    }

                    // Card container
                    Rectangle {
                        id: cardRect
                        anchors.verticalCenter: parent.verticalCenter
                        width: 108; height: 172
                        radius: 10
                        color: "#110d10"
                        border.color: isSelected ? "#D4AF37" : "#38D4AF37"
                        border.width: isSelected ? 1.5 : 1

                        // Subtle hover lift
                        y: isSelected ? -8 : 0
                        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

                        // Card back pattern
                        Rectangle {
                            anchors { fill: parent; margins: 5 }
                            radius: 6; color: "transparent"
                            border.color: "#19D4AF37"; border.width: 1
                        }

                        // Om watermark
                        Text {
                            anchors.centerIn: parent
                            text: "\u0950"
                            font.pixelSize: 38
                            color: "#1fD4AF37"
                        }

                        // Card number
                        Text {
                            anchors { top: parent.top; topMargin: 8; horizontalCenter: parent.horizontalCenter }
                            text: String(index + 1)
                            font.pixelSize: 7; font.letterSpacing: 2
                            color: "#33D4AF37"
                        }

                        // Selected checkmark
                        Text {
                            anchors { top: parent.top; topMargin: 5; right: parent.right; rightMargin: 6 }
                            text: "\u2713"
                            font.pixelSize: 9; color: "#D4AF37"
                            visible: isSelected
                        }

                        // Corner dot — tap to select
                        Rectangle {
                            anchors { bottom: parent.bottom; right: parent.right }
                            width: 38; height: 38; color: "transparent"

                            Rectangle {
                                anchors { bottom: parent.bottom; right: parent.right; margins: 7 }
                                width: 9; height: 9; radius: 5
                                color: isSelected ? "#D4AF37" : "#E8630A"
                                opacity: isSelected ? 1.0 : 0.45

                                SequentialAnimation on opacity {
                                    running: !isSelected
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.7; duration: 1200; easing.type: Easing.InOutSine }
                                    NumberAnimation { to: 0.3; duration: 1200; easing.type: Easing.InOutSine }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var arr = drawScreen.selectedCards.slice()
                                    var pos = arr.indexOf(index)
                                    if (pos !== -1) {
                                        arr.splice(pos, 1)
                                    } else if (arr.length < 3) {
                                        arr.push(index)
                                    }
                                    drawScreen.selectedCards = arr
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Action bar ───────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: 58
            color: "#f5050305"
            border.color: "#14D4AF37"; border.width: 0

            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 1; color: "#14D4AF37"
            }

            Row {
                anchors { fill: parent; leftMargin: 14; rightMargin: 14; topMargin: 8; bottomMargin: 8 }
                spacing: 10

                // SHUFFLE
                Rectangle {
                    width: (parent.width - 10) / 2; height: parent.height
                    color: "transparent"
                    border.color: "#4dD4AF37"; border.width: 1
                    radius: 4
                    Text {
                        anchors.centerIn: parent
                        text: "S H U F F L E"
                        color: "#D4AF37"; font.pixelSize: 10; font.letterSpacing: 3
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            drawScreen.selectedCards = []
                            deckList.positionViewAtIndex(0, ListView.Beginning)
                        }
                    }
                }

                // READ
                Rectangle {
                    width: (parent.width - 10) / 2; height: parent.height
                    radius: 4
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#40E8630A" }
                        GradientStop { position: 1.0; color: "#26D4AF37" }
                    }
                    border.color: "#D4AF37"; border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "R E A D"
                        color: "#D4AF37"; font.pixelSize: 10; font.letterSpacing: 3
                    }
                    opacity: drawScreen.selectedCards.length > 0 ? 1.0 : 0.4
                    MouseArea {
                        anchors.fill: parent
                        enabled: drawScreen.selectedCards.length > 0
                        onClicked: console.log("LOG: Read clicked with", drawScreen.selectedCards.length, "cards")
                    }
                }
            }
        }
    }
}
