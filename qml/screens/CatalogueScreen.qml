import QtQuick
import QtQuick.Controls
import QtMultimedia
import TaroCardDeck 1.0

Item {
    id: catalogueScreen
    Component.onCompleted: {
        console.log("LOG: [CatalogueScreen] >>> created OK, size=" + width + "x" + height)
        console.log("LOG: [CatalogueScreen] catalogueModel count=" + (appController && appController.catalogueModel ? appController.catalogueModel.count : "N/A"))
    }

    property string activeFilter: "ALL"
    property var selectedCard: null
    property int selectedIndex: -1   // row in the filtered catalogueModel
    onActiveFilterChanged: console.log("LOG: [CatalogueScreen] activeFilter=" + activeFilter)

    // Build selectedCard from the filtered model at `row`. Used by tap + swipe nav.
    function openCardAt(row) {
        if (!appController || !appController.catalogueModel) return
        var n = appController.catalogueModel.count
        if (n <= 0) { selectedCard = null; selectedIndex = -1; return }
        if (row < 0) row = 0
        if (row >= n) row = n - 1
        var data = appController.catalogueModel.get(row)
        if (!data || data.cardId === undefined) {
            console.log("LOG: [CatalogueScreen] openCardAt(" + row + ") — no data")
            return
        }
        selectedIndex = row
        selectedCard = data
        console.log("LOG: [CatalogueScreen] openCardAt row=" + row + " cardId=" + data.cardId + " name=" + data.name)
    }

    function applyFilters() {
        console.log("LOG: [CatalogueScreen] applyFilters — query='" + searchField.text + "' filter='" + activeFilter + "'")
        appController.filterCatalogue(searchField.text, activeFilter)
    }

    // Revolver-cylinder SFX — paired with per-row tick haptic so
    // the scroll rattle matches the physical feedback.
    //
    // NOT looped — we want the sound to be bounded by actual scroll
    // motion rather than play continuously. Start on the first row
    // crossing of a motion burst, stop the instant motion ends, and
    // if the sample finishes before motion does it simply goes silent
    // (the haptic ticks continue regardless).
    SoundEffect {
        id: scrollSfx
        source: "qrc:/assets/sounds/mixkit-revolver-chamber-spin-1674.wav"
        volume: 0.75
    }

    Rectangle { anchors.fill: parent; color: "#050305" }

    Rectangle {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 12
        }
        height: 118
        radius: 18
        color: "#110d10"
        border.color: "#1fD4AF37"
        border.width: 1

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#1fE8630A" }
                GradientStop { position: 0.5; color: "#0e110d10" }
                GradientStop { position: 1.0; color: "#1a110d10" }
            }
            opacity: 0.55
        }

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Row {
                width: parent.width

                Column {
                    width: parent.width - 70
                    spacing: 2

                    Text {
                        text: "Browse The Deck"
                        color: "#D4AF37"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Text {
                        text: appController.catalogueModel.count + " cards visible"
                        color: "#7FEDD9A3"
                        font.pixelSize: 10
                    }
                }

                Rectangle {
                    width: 58
                    height: 28
                    radius: 14
                    color: "#181a141a"
                    border.color: "#26D4AF37"
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: activeFilter
                        color: "#EDD9A3"
                        font.pixelSize: 9
                        font.letterSpacing: 1
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 40
                radius: 20
                color: "#1a141a"
                border.color: "#2eD4AF37"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    Text {
                        text: "\u2315"
                        color: "#80D4AF37"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: searchField
                        width: parent.width - 36
                        anchors.verticalCenter: parent.verticalCenter
                        placeholderText: "Search cards, deities, meanings..."
                        placeholderTextColor: "#4dEDD9A3"
                        color: "#EDD9A3"
                        font.pixelSize: 13
                        background: Item {}
                        onTextChanged: catalogueScreen.applyFilters()
                    }
                }
            }

            ListView {
                id: filterList
                width: parent.width
                height: 28
                orientation: ListView.Horizontal
                spacing: 6
                clip: true
                model: ["ALL", "MAJOR", "CUPS", "SWORDS", "PENTACLES", "WANDS"]

                delegate: Rectangle {
                    width: filterText.width + 24
                    height: 28
                    radius: 14
                    color: catalogueScreen.activeFilter === modelData ? "#1fD4AF37" : "transparent"
                    border.color: catalogueScreen.activeFilter === modelData ? "#D4AF37" : "#33D4AF37"
                    border.width: 1

                    Text {
                        id: filterText
                        anchors.centerIn: parent
                        text: modelData
                        color: catalogueScreen.activeFilter === modelData ? "#D4AF37" : "#80EDD9A3"
                        font.pixelSize: 9
                        font.letterSpacing: 1
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (typeof haptics !== "undefined") haptics.light()
                            catalogueScreen.activeFilter = modelData
                            catalogueScreen.applyFilters()
                        }
                    }
                }
            }
        }
    }

    ListView {
        id: cardList
        anchors {
            top: parent.top
            topMargin: 142
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 12
        }
        clip: true
        spacing: 10
        model: appController.catalogueModel

        // Row-tick haptic — fire a short tick each time the list
        // scrolls past one row height (card 94 + spacing 10 = 104 px).
        // Keeps the same mechanical "detent per card" feel the fan
        // uses on DrawScreen so the app speaks one haptic language.
        property real _lastTickY: 0
        readonly property real _tickStride: 104

        onContentYChanged: {
            if (!moving && !flicking && !dragging) {
                // Programmatic / binding-driven changes (filter resets
                // the list) shouldn't tick — only user motion does.
                _lastTickY = contentY
                return
            }
            if (Math.abs(contentY - _lastTickY) >= _tickStride) {
                _lastTickY = contentY
                if (typeof haptics !== "undefined") haptics.tick()

                // SFX must be DRIVEN by the ticks so audio tempo
                // follows scroll speed rather than the sample's own
                // fixed pacing. Restart the revolver sample on every
                // row crossing:
                //   Fast flick → rapid restarts → quick rattle
                //   Slow drag  → one click per row → slow rattle
                //   < 1 row    → never fires → silent
                scrollSfx.stop()
                scrollSfx.play()
            }
        }

        onMovementStarted: _lastTickY = contentY
        onMovementEnded: {
            // Covers both drag-release and flick decay — kill the
            // rattle the instant motion stops.
            if (scrollSfx.playing) scrollSfx.stop()
        }
        onFlickEnded: {
            if (scrollSfx.playing) scrollSfx.stop()
            if (typeof haptics !== "undefined") haptics.light()
        }

        delegate: Rectangle {
            width: cardList.width
            height: 94
            radius: 18
            color: cardTapArea.pressed ? "#1b171a" : "#110d10"
            border.color: "#1fD4AF37"
            border.width: 1

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#16000000" }
                    GradientStop { position: 0.35; color: "#161a141a" }
                    GradientStop { position: 1.0; color: "#0b000000" }
                }
                opacity: 0.7
            }

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12

                Rectangle {
                    width: 52
                    height: 74
                    radius: 10
                    color: "#1a141a"
                    border.color: "#33D4AF37"
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        anchors.fill: parent
                        anchors.margins: 3
                        fillMode: Image.PreserveAspectCrop
                        source: "image://cardface/" + model.cardId
                        cache: false
                    }
                }

                Column {
                    width: parent.width - 128
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        width: parent.width
                        text: model.cardType || ""
                        color: "#D4AF37"
                        font.pixelSize: 13
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: (model.name || "") + "  |  " + (model.arcana || "")
                        color: "#E8630A"
                        font.pixelSize: 11
                        font.italic: true
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: model.uprightKeywords || ""
                        color: "#7FEDD9A3"
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }
                }

                Column {
                    width: 42
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Rectangle {
                        width: 42
                        height: 22
                        radius: 11
                        color: "#0dD4AF37"
                        border.color: "#2eD4AF37"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: (model.arcana || "").indexOf("Major") !== -1 ? "MAJ" : "MIN"
                            color: "#80EDD9A3"
                            font.pixelSize: 7
                            font.letterSpacing: 1
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: ">"
                        color: "#BFD4AF37"
                        font.pixelSize: 16
                    }
                }
            }

            MouseArea {
                id: cardTapArea
                anchors.fill: parent
                onClicked: {
                    console.log("LOG: [CatalogueScreen] row tapped index=" + index + " cardId=" + model.cardId + " name=" + model.name)
                    if (typeof haptics !== "undefined") haptics.medium()
                    catalogueScreen.openCardAt(index)
                }
            }
        }

        ScrollIndicator.vertical: ScrollIndicator {}

        Text {
            anchors.centerIn: parent
            visible: cardList.count === 0
            text: "No cards match this search"
            color: "#55EDD9A3"
            font.pixelSize: 14
        }
    }

    // =======================================================================
    // Detail overlay — reuses ReadingCard for identical UX to SpreadScreen.
    // Opens pre-flipped (revealed=true) so the image + Devanagari name
    // show immediately; swipe-up opens the details sheet.
    // =======================================================================
    Item {
        id: detailOverlay
        anchors.fill: parent
        visible: catalogueScreen.selectedCard !== null
        z: 100

        // Dimmed backdrop — tap to dismiss
        Rectangle {
            anchors.fill: parent
            color: "#c0000000"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("LOG: [CatalogueScreen] backdrop tap — closing detail")
                    if (typeof haptics !== "undefined") haptics.light()
                    catalogueScreen.selectedCard = null
                    catalogueScreen.selectedIndex = -1
                    detailCard.revealed = true   // reset for next open
                }
            }
        }

        // Stage for the ReadingCard + its gestureArea
        Item {
            id: detailStage
            width: Math.min(parent.width - 24, 430)
            height: Math.min(parent.height - 60, 720)
            anchors.centerIn: parent

            // Gesture dispatcher — same pattern as SpreadScreen
            MouseArea {
                id: catGestureArea
                anchors.fill: parent
                property real sx: 0
                property real sy: 0

                onPressed: function(mouse) { sx = mouse.x; sy = mouse.y }
                onReleased: function(mouse) {
                    var dx = mouse.x - sx
                    var dy = mouse.y - sy
                    var adx = Math.abs(dx)
                    var ady = Math.abs(dy)

                    if (adx < 10 && ady < 10) {
                        if (typeof haptics !== "undefined") haptics.light()
                        if (detailCard.tapGesture) detailCard.tapGesture()
                        return
                    }
                    // Horizontal dominant swipe — navigate prev/next within the
                    // filtered catalogueModel. Matches SpreadScreen behaviour.
                    if (adx > ady && adx > 60) {
                        var n = (appController && appController.catalogueModel)
                                ? appController.catalogueModel.count : 0
                        if (n <= 1) return
                        if (dx < 0 && catalogueScreen.selectedIndex < n - 1) {
                            // swipe left → next
                            if (typeof haptics !== "undefined") haptics.selection()
                            detailCard.revealed = true
                            catalogueScreen.openCardAt(catalogueScreen.selectedIndex + 1)
                        } else if (dx > 0 && catalogueScreen.selectedIndex > 0) {
                            // swipe right → previous
                            if (typeof haptics !== "undefined") haptics.selection()
                            detailCard.revealed = true
                            catalogueScreen.openCardAt(catalogueScreen.selectedIndex - 1)
                        } else {
                            if (typeof haptics !== "undefined") haptics.warning()
                        }
                        return
                    }
                    if (ady > adx && ady > 40) {
                        if (typeof haptics !== "undefined") haptics.medium()
                        if (dy < 0 && detailCard.swipeUpGesture) detailCard.swipeUpGesture()
                        else if (dy > 0 && detailCard.swipeDownGesture) detailCard.swipeDownGesture()
                    }
                }
            }

            ReadingCard {
                id: detailCard
                anchors.fill: parent
                revealed: true   // open straight to the image + name
                cardData: catalogueScreen.selectedCard
                         ? ({
                                "id":               catalogueScreen.selectedCard.cardId,
                                "cardType":         catalogueScreen.selectedCard.cardType,
                                "arcana":           catalogueScreen.selectedCard.arcana,
                                "uprightKeywords":  catalogueScreen.selectedCard.uprightKeywords,
                                "reversedKeywords": catalogueScreen.selectedCard.reversedKeywords,
                                "name":             catalogueScreen.selectedCard.name,
                                "notes":            catalogueScreen.selectedCard.notes,
                                "imagePath":        catalogueScreen.selectedCard.imagePath
                           })
                         : ({})
            }

            // Close button (X) — top-right over the card
            Rectangle {
                width: 34; height: 34; radius: 17
                anchors { top: parent.top; right: parent.right; topMargin: -6; rightMargin: -6 }
                color: "#110d10"
                border.color: "#99D4AF37"
                border.width: 1
                z: 200

                Text {
                    anchors.centerIn: parent
                    text: "\u00D7"
                    color: "#EDD9A3"
                    font.pixelSize: 18
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("LOG: [CatalogueScreen] close button tap")
                        if (typeof haptics !== "undefined") haptics.light()
                        catalogueScreen.selectedCard = null
                        catalogueScreen.selectedIndex = -1
                        detailCard.revealed = true
                    }
                }
            }
        }
    }

}
