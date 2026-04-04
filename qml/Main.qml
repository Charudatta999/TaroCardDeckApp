import QtQuick
import QtQuick.Controls
import TaroCardDeck 1.0   // 🔥 REQUIRED for your custom components

ApplicationWindow {
    id: root
    visible: true
    width: 360
    height: 640
    title: "Taro"
    color: "#000000"

    Component.onCompleted: console.log("LOG: Main.qml ApplicationWindow created OK")

    // ── Top bar ──────────────────────────────────────────────────────────
    Rectangle {
        id: topBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 56
        color: "#0D0D0D"
        z: 2

        Item {
            id: menuButton
            anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
            width: 40; height: 40

            Column {
                anchors.centerIn: parent
                spacing: 6
                Repeater {
                    model: 3
                    Rectangle { width: 22; height: 2; color: "#FFD700"; radius: 1 }
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: drawer.open()
            }
        }

        Text {
            anchors.centerIn: parent
            text: "\u2736  Taro  \u2736"
            color: "#FFD700"
            font.pixelSize: 20
            font.bold: true
        }

        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 1; color: "#FFD700"; opacity: 0.4
        }
    }

    // ── StackView ────────────────────────────────────────────────────────
    StackView {
        id: stackView
        Component.onCompleted: console.log("LOG: StackView created OK")
        anchors {
            top: topBar.bottom
            left: parent.left; right: parent.right; bottom: parent.bottom
        }
        initialItem: homeComp

        pushEnter:  Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 220 } }
        pushExit:   Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 220 } }
        popEnter:   Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 220 } }
        popExit:    Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 220 } }
    }

    // ── Drawer ───────────────────────────────────────────────────────────
    Drawer {
        id: drawer
        Component.onCompleted: console.log("LOG: Drawer created OK")
        width: 260
        height: root.height

        background: Rectangle {
            color: "#0D0D0D"
            Rectangle {
                anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                width: 1; color: "#FFD700"; opacity: 0.3
            }
        }

        Rectangle {
            id: drawerHeader
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 110
            color: "#111111"

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\u0950"
                    color: "#FFD700"
                    font.pixelSize: 40
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "T A R O"
                    color: "#FFD700"
                    font.pixelSize: 14
                }
            }

            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: 1; color: "#FFD700"; opacity: 0.3
            }
        }

        Column {
            anchors {
                top: drawerHeader.bottom; topMargin: 8
                left: parent.left; right: parent.right; bottom: parent.bottom
            }

            Text {
                width: parent.width
                leftPadding: 20
                topPadding: 12; bottomPadding: 4
                text: "DIVINATION"
                color: "#666666"
                font.pixelSize: 10
            }

            Rectangle {
                width: parent.width; height: 52
                color: drawArea.pressed ? "#1A1A1A" : "transparent"
                Row {
                    anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                    spacing: 14
                    Text { text: "\u2666"; color: "#FFD700"; font.pixelSize: 18 }
                    Text { text: "Draw a Card"; color: "#FFFDD0"; font.pixelSize: 15 }
                }
                MouseArea {
                    id: drawArea; anchors.fill: parent
                    onClicked: { drawer.close(); stackView.replace(drawComp) }
                }
            }

            Rectangle {
                width: parent.width; height: 52
                color: threeArea.pressed ? "#1A1A1A" : "transparent"
                Row {
                    anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                    spacing: 14
                    Text { text: "\u2663"; color: "#FFD700"; font.pixelSize: 18 }
                    Text { text: "Three Card Spread"; color: "#FFFDD0"; font.pixelSize: 15 }
                }
                MouseArea {
                    id: threeArea; anchors.fill: parent
                    onClicked: { drawer.close(); stackView.replace(spreadComp, {"spreadType": 0}) }
                }
            }

            Rectangle {
                width: parent.width; height: 52
                color: celticArea.pressed ? "#1A1A1A" : "transparent"
                Row {
                    anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                    spacing: 14
                    Text { text: "\u2665"; color: "#FFD700"; font.pixelSize: 18 }
                    Text { text: "Celtic Cross"; color: "#FFFDD0"; font.pixelSize: 15 }
                }
                MouseArea {
                    id: celticArea; anchors.fill: parent
                    onClicked: { drawer.close(); stackView.replace(spreadComp, {"spreadType": 1}) }
                }
            }

            Rectangle {
                width: parent.width - 40; height: 1
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#FFD700"; opacity: 0.2
            }

            Text {
                width: parent.width
                leftPadding: 20
                topPadding: 12; bottomPadding: 4
                text: "CATALOGUE"
                color: "#666666"
                font.pixelSize: 10
            }

            Rectangle {
                width: parent.width; height: 52
                color: catArea.pressed ? "#1A1A1A" : "transparent"
                Row {
                    anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                    spacing: 14
                    Text { text: "\u2736"; color: "#FFD700"; font.pixelSize: 18 }
                    Text { text: "All 78 Cards"; color: "#FFFDD0"; font.pixelSize: 15 }
                }
                MouseArea {
                    id: catArea; anchors.fill: parent
                    onClicked: { drawer.close(); stackView.replace(catalogueComp) }
                }
            }

            Item { width: 1; height: 1 }

            Rectangle {
                width: parent.width - 40; height: 1
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#FFD700"; opacity: 0.15
            }

            Rectangle {
                width: parent.width; height: 52
                color: homeArea.pressed ? "#1A1A1A" : "transparent"
                Row {
                    anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                    spacing: 14
                    Text { text: "\u0950"; color: "#FFD700"; font.pixelSize: 18 }
                    Text { text: "Home"; color: "#FFFDD0"; font.pixelSize: 15 }
                }
                MouseArea {
                    id: homeArea; anchors.fill: parent
                    onClicked: { drawer.close(); stackView.replace(homeComp) }
                }
            }
        }
    }

    Component {
        id: homeComp
        HomeScreen {
            onNavigateTo: function(screen) {
                if      (screen === "draw")      stackView.replace(drawComp)
                else if (screen === "three")     stackView.replace(spreadComp, {"spreadType": 0})
                else if (screen === "celtic")    stackView.replace(spreadComp, {"spreadType": 1})
                else if (screen === "catalogue") stackView.replace(catalogueComp)
            }
        }
    }

    Component { id: drawComp;      DrawScreen      {} }
    Component { id: spreadComp;    SpreadScreen    {} }
    Component { id: catalogueComp; CatalogueScreen {} }
}