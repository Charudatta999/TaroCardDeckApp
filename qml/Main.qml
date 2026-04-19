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

    property string activeScreen: "home"

    function screenTitle(screen) {
        if (screen === "draw")
            return "DRAW THE CARDS"
        if (screen === "spread")
            return "READING"
        if (screen === "catalogue")
            return "CARD CATALOGUE"
        return "JYOTISH TARO"
    }

    function screenSubtitle(screen) {
        if (screen === "draw")
            return "Select the three cards that call to you"
        if (screen === "spread")
            return "Flip each card and move through the spread"
        if (screen === "catalogue")
            return "Browse the deck, deities, and meanings"
        return "Hindu mythic oracle"
    }

    function openScreen(screen, properties) {
        console.log("LOG: [Main] openScreen(" + screen + ", " + JSON.stringify(properties || {}) + ")")
        activeScreen = screen
        if (screen === "home") {
            console.log("LOG: [Main] replacing with homeComp")
            stackView.replace(homeComp)
        } else if (screen === "draw") {
            console.log("LOG: [Main] replacing with drawComp")
            stackView.replace(drawComp)
        } else if (screen === "spread") {
            console.log("LOG: [Main] replacing with spreadComp, props=" + JSON.stringify(properties || {}))
            stackView.replace(spreadComp, properties || {})
        } else if (screen === "catalogue") {
            console.log("LOG: [Main] replacing with catalogueComp")
            stackView.replace(catalogueComp)
        } else {
            console.log("LOG: [Main] ERROR — unknown screen: " + screen)
        }
    }

    Component.onCompleted: {
        console.log("LOG: ============================================")
        console.log("LOG: [Main] ApplicationWindow created OK")
        console.log("LOG: [Main] size=" + width + "x" + height)
        console.log("LOG: [Main] appController available=" + (typeof appController !== "undefined"))
        console.log("LOG: [Main] calling appController.initialize()...")
        if (typeof appController !== "undefined" && appController) {
            appController.initialize()
            console.log("LOG: [Main] appController.initialize() returned")
        } else {
            console.log("LOG: [Main] ERROR — appController is undefined!")
        }
        console.log("LOG: [Main] activeScreen=" + activeScreen)
        console.log("LOG: ============================================")
    }

    onActiveScreenChanged: console.log("LOG: [Main] activeScreen changed to " + activeScreen)

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#09050a" }
            GradientStop { position: 0.45; color: "#050305" }
            GradientStop { position: 1.0; color: "#0b080c" }
        }
    }

    Rectangle {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 140
        opacity: 0.55
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#33E8630A" }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    Rectangle {
        id: topBar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 10
        }
        height: 64
        radius: 18
        color: "#120d10"
        border.color: "#26D4AF37"
        border.width: 1
        z: 20

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#1aE8630A" }
                GradientStop { position: 0.35; color: "#0d110d10" }
                GradientStop { position: 1.0; color: "#140c080c" }
            }
            opacity: 0.45
        }

        Rectangle {
            id: menuButton
            width: 40
            height: 40
            radius: 20
            color: menuArea.pressed ? "#241a141a" : "#1a141a"
            border.color: "#33D4AF37"
            border.width: 1
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }

            Column {
                anchors.centerIn: parent
                spacing: 4
                Repeater {
                    model: 3
                    Rectangle {
                        width: 16
                        height: 2
                        radius: 1
                        color: "#D4AF37"
                    }
                }
            }

            MouseArea {
                id: menuArea
                anchors.fill: parent
                onClicked: {
                    if (typeof haptics !== "undefined") haptics.light()
                    drawer.open()
                }
            }
        }

        Column {
            anchors {
                left: menuButton.right
                leftMargin: 12
                right: screenGlyph.left
                rightMargin: 12
                verticalCenter: parent.verticalCenter
            }
            spacing: 2

            Text {
                width: parent.width
                text: screenTitle(root.activeScreen)
                color: "#D4AF37"
                font.pixelSize: 13
                font.letterSpacing: 3
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: screenSubtitle(root.activeScreen)
                color: "#88EDD9A3"
                font.pixelSize: 10
                elide: Text.ElideRight
            }
        }

        Rectangle {
            id: screenGlyph
            width: 40
            height: 40
            radius: 20
            color: "#14000000"
            border.color: "#22E8630A"
            border.width: 1
            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }

            Text {
                anchors.centerIn: parent
                text: root.activeScreen === "draw"
                    ? "\u2666"
                    : root.activeScreen === "spread"
                        ? "\u2665"
                        : root.activeScreen === "catalogue"
                            ? "\u2736"
                            : "\u0950"
                color: "#FFD700"
                font.pixelSize: 18
            }
        }
    }

    StackView {
        id: stackView
        Component.onCompleted: console.log("LOG: StackView created OK")
        anchors {
            top: topBar.bottom
            topMargin: 8
            left: parent.left
            right: parent.right
            bottom: navBar.top
            bottomMargin: 10
        }
        initialItem: homeComp

        replaceEnter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 260 } }
        replaceExit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 160 } }
        pushEnter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 260 } }
        pushExit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 160 } }
        popEnter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 260 } }
        popExit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 160 } }
    }

    Rectangle {
        id: navBar
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 10
        }
        height: 60
        radius: 20
        color: "#120d10"
        border.color: "#26D4AF37"
        border.width: 1
        z: 20

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#1f1a141a" }
                GradientStop { position: 1.0; color: "#14090709" }
            }
        }

        Row {
            anchors.fill: parent
            anchors.margins: 6

            Repeater {
                model: [
                    { sym: "\u0950", lbl: "HOME", screen: "home" },
                    { sym: "\u2666", lbl: "DRAW", screen: "draw" },
                    { sym: "\u2665", lbl: "READ", screen: "spread" },
                    { sym: "\u2736", lbl: "CARDS", screen: "catalogue" }
                ]

                delegate: Rectangle {
                    width: (navBar.width - 12) / 4
                    height: navBar.height - 12
                    radius: 16
                    color: root.activeScreen === modelData.screen ? "#211f1a14" : "transparent"
                    border.color: root.activeScreen === modelData.screen ? "#44D4AF37" : "transparent"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.sym
                            font.pixelSize: 18
                            color: root.activeScreen === modelData.screen ? "#FFD700" : "#66EDD9A3"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.lbl
                            font.pixelSize: 8
                            font.letterSpacing: 2
                            color: root.activeScreen === modelData.screen ? "#D4AF37" : "#55EDD9A3"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (typeof haptics !== "undefined") haptics.light()
                            root.openScreen(modelData.screen)
                        }
                    }
                }
            }
        }
    }

    Drawer {
        id: drawer
        Component.onCompleted: console.log("LOG: Drawer created OK")
        width: 268
        height: root.height
        edge: Qt.LeftEdge

        background: Rectangle {
            color: "#0C080C"
            Rectangle {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                }
                width: 1
                color: "#33D4AF37"
            }
        }

        Rectangle {
            id: dHeader
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: 136
            color: "#110d10"

            Column {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\u0950"
                    color: "#FFD700"
                    font.pixelSize: 44
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "J Y O T I S H"
                    color: "#D4AF37"
                    font.pixelSize: 10
                    font.letterSpacing: 4
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Oracle navigation"
                    color: "#77EDD9A3"
                    font.pixelSize: 10
                }
            }
        }

        Column {
            anchors {
                top: dHeader.bottom
                left: parent.left
                right: parent.right
                margins: 14
            }
            spacing: 10

            Text {
                text: "D I V I N A T I O N"
                color: "#66EDD9A3"
                font.pixelSize: 9
                font.letterSpacing: 3
            }

            Repeater {
                model: [
                    { sym: "\u2666", lbl: "Draw Three Cards", screen: "draw" },
                    { sym: "\u2665", lbl: "Open Reading", screen: "spread" },
                    { sym: "\u2736", lbl: "Browse Catalogue", screen: "catalogue" },
                    { sym: "\u0950", lbl: "Return Home", screen: "home" }
                ]

                delegate: Rectangle {
                    width: parent.width
                    height: 52
                    radius: 14
                    color: drawerItemArea.pressed ? "#1aD4AF37" : "#140f1110"
                    border.color: "#1fD4AF37"
                    border.width: 1

                    Row {
                        anchors {
                            left: parent.left
                            leftMargin: 16
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 12

                        Text {
                            text: modelData.sym
                            color: "#D4AF37"
                            font.pixelSize: 16
                        }

                        Text {
                            text: modelData.lbl
                            color: "#EDD9A3"
                            font.pixelSize: 14
                        }
                    }

                    MouseArea {
                        id: drawerItemArea
                        anchors.fill: parent
                        onClicked: {
                            if (typeof haptics !== "undefined") haptics.medium()
                            drawer.close()
                            root.openScreen(modelData.screen)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: homeComp
        HomeScreen {
            Component.onCompleted: console.log("LOG: [Main] homeComp instantiated HomeScreen")
            onNavigateTo: function(screen) {
                console.log("LOG: [Main] homeComp onNavigateTo(" + screen + ")")
                root.openScreen(screen)
            }
        }
    }

    Component {
        id: drawComp
        DrawScreen {
            Component.onCompleted: console.log("LOG: [Main] drawComp instantiated DrawScreen")
            onReadCards: function(indices) {
                console.log("LOG: [Main] drawComp onReadCards — " + indices.length + " cards: " + JSON.stringify(indices))
                root.openScreen("spread", {"selectedIndices": indices})
            }
        }
    }

    Component {
        id: spreadComp
        SpreadScreen {
            Component.onCompleted: console.log("LOG: [Main] spreadComp instantiated SpreadScreen with " + selectedIndices.length + " indices")
        }
    }

    Component {
        id: catalogueComp
        CatalogueScreen {
            Component.onCompleted: console.log("LOG: [Main] catalogueComp instantiated CatalogueScreen")
        }
    }
}
