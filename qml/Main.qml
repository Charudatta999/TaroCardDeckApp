import QtQuick
import QtQuick.Controls
import TaroCardDeck 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 360
    height: 640
    title: "Taro"
    color: "#050305"

    Component.onCompleted: console.log("LOG: Main.qml ApplicationWindow created OK")

    // ── Top bar ──────────────────────────────────────────────────────────
    Rectangle {
        id: topBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 54
        z: 10

        // Dark gradient bg
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#fa050305" }
            GradientStop { position: 1.0; color: "#d8050305" }
        }

        // Hamburger
        Item {
            anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
            width: 36; height: 36
            Column {
                anchors.centerIn: parent
                spacing: 5
                Repeater {
                    model: 3
                    Rectangle { width: 20; height: 2; color: "#D4AF37"; radius: 1; opacity: 0.85 }
                }
            }
            MouseArea { anchors.fill: parent; onClicked: drawer.open() }
        }

        // Title
        Text {
            anchors.centerIn: parent
            text: "J Y O T I S H   T A R O"
            color: "#D4AF37"
            font.pixelSize: 11
            font.bold: false
            font.letterSpacing: 5
        }

        // Bottom border with saffron center glow
        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 1; color: "#1fD4AF37"
        }
        Rectangle {
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            width: parent.width * 0.6; height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: "#66E8630A" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    // ── Main StackView ───────────────────────────────────────────────────
    StackView {
        id: stackView
        Component.onCompleted: console.log("LOG: StackView created OK")
        anchors {
            top: topBar.bottom
            left: parent.left; right: parent.right
            bottom: navBar.top
        }
        initialItem: homeComp

        replaceEnter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 350 } }
        replaceExit:  Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 } }
        pushEnter:    Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 350 } }
        pushExit:     Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 } }
        popEnter:     Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 350 } }
        popExit:      Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 } }
    }

    // ── Bottom Nav Bar ───────────────────────────────────────────────────
    Rectangle {
        id: navBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: 54
        color: "#0C080C"
        z: 10

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1; color: "#1aD4AF37"
        }

        Row {
            anchors.fill: parent

            Repeater {
                model: [
                    { sym: "\u2666", lbl: "DIVINE",    screen: "home" },
                    { sym: "\u2663", lbl: "SPREAD",    screen: "spread" },
                    { sym: "\u2736", lbl: "CARDS",     screen: "catalogue" },
                    { sym: "\u2665", lbl: "READING",   screen: "draw" }
                ]

                delegate: Item {
                    width: navBar.width / 4
                    height: navBar.height

                    property bool isActive: {
                        var cur = stackView.currentItem
                        if (!cur) return modelData.screen === "home"
                        var t = cur.toString()
                        if (modelData.screen === "home")      return t.indexOf("HomeScreen") !== -1
                        if (modelData.screen === "spread")    return t.indexOf("SpreadScreen") !== -1
                        if (modelData.screen === "catalogue") return t.indexOf("CatalogueScreen") !== -1
                        if (modelData.screen === "draw")      return t.indexOf("DrawScreen") !== -1
                        return false
                    }

                    // Active top line
                    Rectangle {
                        anchors { top: parent.top; left: parent.left; right: parent.right }
                        height: 2; visible: isActive
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.5; color: "#E8630A" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 3
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.sym
                            font.pixelSize: 18
                            color: isActive ? "#FFD700" : "#4dEDD9A3"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.lbl
                            font.pixelSize: 7
                            font.letterSpacing: 2
                            color: isActive ? "#D4AF37" : "#33EDD9A3"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var s = modelData.screen
                            if      (s === "home")      stackView.replace(homeComp)
                            else if (s === "draw")      stackView.replace(drawComp)
                            else if (s === "spread")    stackView.replace(spreadComp)
                            else if (s === "catalogue") stackView.replace(catalogueComp)
                        }
                    }
                }
            }
        }
    }

    // ── Side Drawer ───────────────────────────────────────────────────────
    Drawer {
        id: drawer
        Component.onCompleted: console.log("LOG: Drawer created OK")
        width: 260; height: root.height
        edge: Qt.LeftEdge

        background: Rectangle {
            color: "#0C080C"
            Rectangle {
                anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                width: 1; color: "#33D4AF37"
            }
        }

        // Header
        Rectangle {
            id: dHeader
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 120
            color: "#110d10"

            Column {
                anchors.centerIn: parent
                spacing: 6
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\u0950"
                    color: "#FFD700"
                    font.pixelSize: 44
                    style: Text.Normal
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "J Y O T I S H"
                    color: "#D4AF37"
                    font.pixelSize: 10
                    font.letterSpacing: 4
                }
            }
            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: 1; color: "#33D4AF37"
            }
        }

        // Menu items
        Column {
            anchors { top: dHeader.bottom; left: parent.left; right: parent.right; topMargin: 12 }

            // Section
            Text {
                width: parent.width; leftPadding: 20; topPadding: 8; bottomPadding: 6
                text: "D I V I N A T I O N"
                color: "#4dEDD9A3"; font.pixelSize: 9; font.letterSpacing: 3
            }

            Repeater {
                model: [
                    { sym: "\u2666", lbl: "Draw a Card",       action: "draw" },
                    { sym: "\u2663", lbl: "Three Card Spread",  action: "three" },
                    { sym: "\u2665", lbl: "Celtic Cross",       action: "celtic" }
                ]
                delegate: Rectangle {
                    width: parent.width; height: 52
                    color: ma.pressed ? "#1aD4AF37" : "transparent"
                    Row {
                        anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                        spacing: 14
                        Text { text: modelData.sym; color: "#D4AF37"; font.pixelSize: 16 }
                        Text { text: modelData.lbl; color: "#EDD9A3"; font.pixelSize: 14 }
                    }
                    MouseArea {
                        id: ma; anchors.fill: parent
                        onClicked: {
                            drawer.close()
                            if      (modelData.action === "draw")   stackView.replace(drawComp)
                            else if (modelData.action === "three")  stackView.replace(spreadComp, {"spreadType": 0})
                            else if (modelData.action === "celtic") stackView.replace(spreadComp, {"spreadType": 1})
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width - 40; height: 1
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#1aD4AF37"
            }

            Text {
                width: parent.width; leftPadding: 20; topPadding: 8; bottomPadding: 6
                text: "C A T A L O G U E"
                color: "#4dEDD9A3"; font.pixelSize: 9; font.letterSpacing: 3
            }

            Rectangle {
                width: parent.width; height: 52
                color: catMa.pressed ? "#1aD4AF37" : "transparent"
                Row {
                    anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                    spacing: 14
                    Text { text: "\u2736"; color: "#D4AF37"; font.pixelSize: 16 }
                    Text { text: "All 78 Cards"; color: "#EDD9A3"; font.pixelSize: 14 }
                }
                MouseArea {
                    id: catMa; anchors.fill: parent
                    onClicked: { drawer.close(); stackView.replace(catalogueComp) }
                }
            }
        }
    }

    // ── Screen components ─────────────────────────────────────────────────
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
