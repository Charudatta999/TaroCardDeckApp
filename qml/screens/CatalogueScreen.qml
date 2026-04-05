// Catalogue screen — search + filter pills + card list
import QtQuick
import QtQuick.Controls

Item {
    id: catalogueScreen
    Component.onCompleted: console.log("LOG: CatalogueScreen created OK")

    property string activeFilter: "ALL"

    Rectangle { anchors.fill: parent; color: "#050305" }

    Column {
        anchors.fill: parent
        spacing: 0

        // ── Search bar ───────────────────────────────────────────────
        Item {
            width: parent.width; height: 52

            Rectangle {
                anchors { fill: parent; leftMargin: 14; rightMargin: 14; topMargin: 8; bottomMargin: 8 }
                color: "#1a141a"
                border.color: "#2eD4AF37"; border.width: 1
                radius: 20

                Row {
                    anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                    spacing: 10

                    Text {
                        text: "\u2315"  // loupe-like
                        color: "#80D4AF37"; font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: searchField
                        width: parent.width - 36
                        anchors.verticalCenter: parent.verticalCenter
                        placeholderText: "Search cards or deities\u2026"
                        color: "#EDD9A3"; font.pixelSize: 13
                        background: Item {}
                        placeholderTextColor: "#4dEDD9A3"
                        onTextChanged: appController.searchCatalogue(text)
                    }
                }
            }
        }

        // ── Filter pills ─────────────────────────────────────────────
        Item {
            width: parent.width; height: 38

            ListView {
                anchors { fill: parent; leftMargin: 14; rightMargin: 14; topMargin: 4; bottomMargin: 4 }
                orientation: ListView.Horizontal
                spacing: 6
                clip: true
                model: ["ALL", "MAJOR", "CUPS", "SWORDS", "PENTACLES", "WANDS"]

                delegate: Rectangle {
                    property bool isActive: catalogueScreen.activeFilter === modelData
                    height: 28; width: pillText.width + 24
                    radius: 14
                    color: isActive ? "#1aD4AF37" : "transparent"
                    border.color: isActive ? "#D4AF37" : "#33D4AF37"; border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: pillText
                        anchors.centerIn: parent
                        text: modelData
                        color: isActive ? "#D4AF37" : "#80EDD9A3"
                        font.pixelSize: 8; font.letterSpacing: 2
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: catalogueScreen.activeFilter = modelData
                    }
                }
            }
        }

        // ── Card list ────────────────────────────────────────────────
        ListView {
            id: cardList
            width: parent.width
            height: parent.height - 52 - 38
            clip: true
            leftMargin: 14; rightMargin: 14
            topMargin: 4; bottomMargin: 4
            spacing: 7
            model: appController.catalogueModel

            delegate: Rectangle {
                width: cardList.width - 28
                anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                height: 68
                color: "#110d10"
                border.color: "#1aD4AF37"; border.width: 1
                radius: 10

                Row {
                    anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                    spacing: 12

                    // Mini card thumbnail
                    Rectangle {
                        width: 36; height: 54; radius: 5
                        color: "#1a141a"; border.color: "#2eD4AF37"; border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "\u0950"; color: "#D4AF37"; font.pixelSize: 16; opacity: 0.4
                        }
                    }

                    // Card info
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3
                        width: parent.width - 36 - 12 - 44 - 12

                        Text {
                            width: parent.width
                            text: model.cardType || ""
                            color: "#D4AF37"; font.pixelSize: 12; font.bold: true
                            elide: Text.ElideRight
                        }
                        Text {
                            width: parent.width
                            text: (model.name || "") + "  \u00B7  " + (model.arcana || "")
                            color: "#E8630A"; font.pixelSize: 11; font.italic: true
                            elide: Text.ElideRight
                        }
                        Text {
                            width: parent.width
                            text: model.uprightKeywords || ""
                            color: "#59EDD9A3"; font.pixelSize: 10
                            elide: Text.ElideRight
                        }
                    }

                    // Arcana badge
                    Rectangle {
                        width: 44; height: 24; radius: 8
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#0dD4AF37"
                        border.color: "#33D4AF37"; border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: (model.arcana || "").indexOf("Major") !== -1 ? "MAJ" : "MIN"
                            color: "#80EDD9A3"; font.pixelSize: 7; font.letterSpacing: 1
                        }
                    }
                }

                // Pressed state
                MouseArea {
                    anchors.fill: parent
                    onPressed: parent.color = "#221a141a"
                    onReleased: parent.color = "#110d10"
                    onClicked: console.log("LOG: Catalogue card tapped:", model.cardType)
                }
            }

            // Empty state
            Text {
                anchors.centerIn: parent
                text: "No cards found"
                color: "#33EDD9A3"; font.pixelSize: 14
                visible: cardList.count === 0
            }
        }
    }
}
