import QtQuick
import QtQuick.Controls

Item {
    id: catalogueScreen
    Component.onCompleted: console.log("LOG: CatalogueScreen created OK")

    Rectangle {
        anchors.fill: parent
        color: "#000000"

        // ── Search bar ────────────────────────────────────────────────
        Rectangle {
            id: searchBar
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 52; color: "#111111"

            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: 1; color: "#FFD700"; opacity: 0.25
            }

            Row {
                anchors { left: parent.left; right: parent.right; leftMargin: 16; rightMargin: 16; verticalCenter: parent.verticalCenter }
                spacing: 10

                Text {
                    text: "\u2315"   // search-like symbol
                    color: "#FFD700"; font.pixelSize: 18; opacity: 0.6
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextField {
                    id: searchField
                    width: parent.width - 40
                    placeholderText: "Search cards or deities\u2026"
                    color: "#FFFDD0"; font.pixelSize: 14
                    background: Item {}
                    placeholderTextColor: "#555555"
                    onTextChanged: appController.searchCatalogue(text)
                }
            }
        }

        // ── Card list ─────────────────────────────────────────────────
        ListView {
            id: cardList
            anchors { top: searchBar.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
            clip: true; spacing: 1
            model: appController.catalogueModel

            delegate: Rectangle {
                width: cardList.width; height: 72
                color: index % 2 === 0 ? "#0A0A0A" : "#111111"

                // Badge
                Rectangle {
                    id: badge
                    x: 16; anchors.verticalCenter: parent.verticalCenter
                    width: 40; height: 40; radius: 4
                    color: "#1A1A1A"; border.color: "#FFD700"; border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: model.cardId !== undefined ? String(model.cardId) : ""
                        color: "#FFD700"; font.pixelSize: 12; font.bold: true
                    }
                }

                // Arcana dot
                Rectangle {
                    id: arcDot
                    anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                    width: 8; height: 8; radius: 4
                    color: (model.arcana || "").indexOf("Major") !== -1 ? "#FFD700" : "#FF4500"
                    opacity: 0.8
                }

                // Card info
                Column {
                    anchors {
                        left: badge.right; leftMargin: 14
                        right: arcDot.left; rightMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 2

                    Text {
                        width: parent.width
                        text: model.cardType || ""
                        color: "#FFFDD0"; font.pixelSize: 14; font.bold: true
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        text: (model.name || "") + "  \u00B7  " + (model.arcana || "")
                        color: "#888888"; font.pixelSize: 12
                        elide: Text.ElideRight
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "No cards found"
                color: "#444444"; font.pixelSize: 16
                visible: cardList.count === 0
            }
        }
    }
}
