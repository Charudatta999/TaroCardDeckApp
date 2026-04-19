// Divination screen — semicircular fan carousel + 3 holder slots + flight animation.
// Ported from prototype/JyotishTaro_CardSelection.html.
import QtQuick
import QtQuick.Controls
import QtMultimedia
import TaroCardDeck 1.0

Item {
    id: drawScreen
    Component.onCompleted: {
        console.log("LOG: [DrawScreen] >>> created OK, width=" + width + " height=" + height)
        console.log("LOG: [DrawScreen] deckSize=" + deckSize + " fanCenter=" + fanCenter)
    }

    // =======================================================================
    // Signals + state
    // =======================================================================
    signal readCards(var indices)

    // Revolver-cylinder SFX — paired with the per-step tick haptic so
    // the audio rattle syncs with the physical detents.
    //
    // Deliberately NOT looped: we want one natural spin-sample to play
    // during a drag and go silent afterwards rather than a continuous
    // rattle that plays even after the finger lifts.
    SoundEffect {
        id: revolverSfx
        source: "qrc:/assets/sounds/mixkit-revolver-chamber-spin-1674.wav"
        volume: 0.85
    }

    property int deckSize: 78
    property var selectedCards: []               // deck indices chosen so far (max 3)
    onSelectedCardsChanged: console.log("LOG: [DrawScreen] selectedCards=" + JSON.stringify(selectedCards))

    property int fanCenter: 0                    // integer — which deck card is at angle 0
    property real angularOffset: 0.0             // continuous drag offset (in steps)

    // Fan math (matches HTML prototype)
    readonly property int visibleSpan: 15
    readonly property int halfSpan: 7
    readonly property real arcDeg: 110
    readonly property int stepPx: 48             // pixels per 1-card rotation

    // Returns shortest-path signed distance from fanCenter for deck card d.
    function relOf(d) {
        var n = deckSize
        var rel = d - fanCenter
        if (rel >  n / 2) rel -= n
        if (rel < -n / 2) rel += n
        return rel
    }

    function advanceCenterPastSelected() {
        var tries = 0
        do {
            fanCenter = (fanCenter + 1) % deckSize
            tries++
        } while (drawScreen.selectedCards.indexOf(fanCenter) >= 0 && tries < deckSize)
        angularOffset = 0
    }

    function doShuffle() {
        console.log("LOG: [DrawScreen] shuffle")
        drawScreen.selectedCards = []
        fanCenter = Math.floor(Math.random() * deckSize)
        angularOffset = 0
    }

    // =======================================================================
    // Background
    // =======================================================================
    Rectangle { anchors.fill: parent; color: "#050305" }
    WatermarkBackground { anchors.fill: parent; z: 0 }

    // =======================================================================
    // Status strip
    // =======================================================================
    Rectangle {
        id: statusStrip
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 10
        }
        height: 44
        radius: 16
        color: "#110d10"
        border.color: "#1fD4AF37"
        border.width: 1
        z: 5

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            Column {
                width: parent.width - 92
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: "Center a card and tap to claim it"
                    color: "#D4AF37"
                    font.pixelSize: 11
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    text: "Drag the fan, then read when all three slots are filled"
                    color: "#7FEDD9A3"
                    font.pixelSize: 9
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                width: 58
                height: 26
                radius: 13
                color: "#1a141a"
                border.color: "#26D4AF37"
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: drawScreen.selectedCards.length + "/3"
                    color: "#EDD9A3"
                    font.pixelSize: 11
                    font.bold: true
                }
            }
        }
    }

    // =======================================================================
    // Holder slots — gold border, Om placeholder, glow-pulse when filled
    // =======================================================================
    Row {
        id: holders
        anchors { top: statusStrip.bottom; topMargin: 10; horizontalCenter: parent.horizontalCenter }
        spacing: 10
        z: 5

        Repeater {
            model: 3
            delegate: Item {
                id: holder
                width: 54
                height: 76
                property bool filled: index < drawScreen.selectedCards.length
                property bool pulsing: false

                // Pulse timer — fires when a card lands
                Timer {
                    id: pulseTimer
                    interval: 900
                    onTriggered: holder.pulsing = false
                }

                function pulseGlow() {
                    holder.pulsing = true
                    pulseTimer.restart()
                }

                // Slot background
                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: holder.filled ? "#1a141a" : "transparent"
                    border.color: holder.pulsing
                                  ? "#FFD700"
                                  : (holder.filled ? "#C9A84C" : "#44D4AF37")
                    border.width: holder.pulsing ? 2 : 1
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                }

                // Glow ring when pulsing
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -3
                    radius: 10
                    color: "transparent"
                    border.color: "#66FFD700"
                    border.width: 2
                    visible: holder.pulsing
                    opacity: holder.pulsing ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 400 } }
                }

                // Placeholder Om (shows when slot is filled — stands in for the chosen card)
                Text {
                    anchors.centerIn: parent
                    text: holder.filled ? "\u0950" : "+"
                    color: holder.filled ? "#D4AF37" : "#4dD4AF37"
                    font.pixelSize: holder.filled ? 26 : 20
                }

                // Slot index label
                Text {
                    anchors { top: parent.bottom; horizontalCenter: parent.horizontalCenter; topMargin: 2 }
                    text: ["PAST", "PRESENT", "FUTURE"][index]
                    color: holder.filled ? "#C9A84C" : "#55C9A84C"
                    font.pixelSize: 7
                    font.letterSpacing: 2
                }

                Component.onCompleted: {
                    drawScreen.registerHolder(index, holder)
                }
            }
        }
    }

    // Map slot index → holder Item so the flyer can call pulseGlow()
    property var holderRefs: [null, null, null]
    function registerHolder(i, item) {
        var refs = holderRefs.slice()
        refs[i] = item
        holderRefs = refs
    }

    // =======================================================================
    // Flight area — contains the fan carousel + flyer
    // =======================================================================
    Item {
        id: flightArea
        anchors {
            top: holders.bottom
            topMargin: 28
            left: parent.left
            right: parent.right
            bottom: actionBar.top
            bottomMargin: 0
        }
        clip: false
        z: 2

        // ------------------------------------------------------------------
        // Fan Repeater — one persistent delegate per deck card
        // ------------------------------------------------------------------
        Repeater {
            id: fanRep
            model: drawScreen.deckSize

            delegate: Item {
                id: fanCard
                width: 120
                height: 184

                // Per-card computed slot (shortest-path) relative to visible center
                property int deckIdx: index
                property real slot: drawScreen.relOf(index) - drawScreen.angularOffset
                property real frac: slot / drawScreen.halfSpan
                property real dist: Math.min(1.0, Math.abs(frac))
                property real angleDeg: frac * (drawScreen.arcDeg / 2)
                property real yOff: dist * dist * 70
                property real scl: 1.0 - dist * 0.38
                property bool isSelected: drawScreen.selectedCards.indexOf(index) >= 0
                property bool offScreen: Math.abs(slot) > drawScreen.halfSpan + 1.5

                // Anchor: bottom-centered in flightArea
                x: (flightArea.width - width) / 2
                y: flightArea.height - height - 30

                visible: !isSelected && !offScreen
                opacity: dist > 1.0 ? Math.max(0, 1.0 - (dist - 1.0) * 2) : 1.0
                z: 200 - Math.round(Math.abs(slot) * 10)

                // Rotation pivot raised 114px below card bottom (flattens arc, sweeps outward)
                transform: [
                    Rotation {
                        origin.x: fanCard.width / 2
                        origin.y: fanCard.height + 114
                        angle: fanCard.angleDeg
                    },
                    Translate { y: fanCard.yOff },
                    Scale {
                        origin.x: fanCard.width / 2
                        origin.y: fanCard.height / 2
                        xScale: fanCard.scl
                        yScale: fanCard.scl
                    }
                ]

                // Smooth only when not dragging (drag sets angularOffset continuously)
                Behavior on angleDeg { enabled: !drag.pressed; NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
                Behavior on yOff    { enabled: !drag.pressed; NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
                Behavior on scl     { enabled: !drag.pressed; NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }

                FanCardBack {
                    anchors.fill: parent
                    deckIdx: fanCard.deckIdx
                    active: Math.abs(fanCard.slot) < 0.5
                }
            }
        }

        // ------------------------------------------------------------------
        // Outer drag/tap MouseArea — single handler drives angularOffset and
        // tap-to-select. Hit-tests the tap so only the center card launches.
        // ------------------------------------------------------------------
        MouseArea {
            id: drag
            anchors.fill: parent
            property real startX: 0
            property real startOffset: 0
            property real maxDelta: 0
            property bool didDrag: false
            // Last integer detent the fan was "on" — used to emit a
            // revolver-cylinder click each time we cross to a new card.
            property int lastTickStep: 0

            onPressed: function(mouse) {
                startX = mouse.x
                startOffset = drawScreen.angularOffset
                maxDelta = 0
                didDrag = false
                lastTickStep = Math.round(drawScreen.angularOffset)
            }

            onPositionChanged: function(mouse) {
                var dx = mouse.x - startX
                if (Math.abs(dx) > maxDelta) maxDelta = Math.abs(dx)
                if (maxDelta > 8) didDrag = true
                drawScreen.angularOffset = startOffset - dx / drawScreen.stepPx

                // Revolver-cylinder haptic: tick every time the rounded
                // step changes. Each tick = one "chamber" clicking into
                // the detent. Kept deliberately sharp+short so rapid
                // flicks give a distinct rattle, not a continuous buzz.
                var step = Math.round(drawScreen.angularOffset)
                if (step !== lastTickStep) {
                    lastTickStep = step
                    if (typeof haptics !== "undefined") haptics.tick()

                    // SFX gate: the sound must be DRIVEN by the ticks so
                    // that audio tempo == scroll speed. Each step change
                    // restarts the revolver sample from the beginning.
                    //   Fast flick   → many rapid restarts → rattle
                    //   Slow drag    → one click per tick  → slower rattle
                    //   Pure tap     → no step changes     → silent
                    // We still require real drag distance (maxDelta >
                    // stepPx) before the first play() so tap jitter
                    // that happens to flip one step stays silent.
                    if (maxDelta > drawScreen.stepPx) {
                        revolverSfx.stop()
                        revolverSfx.play()
                    }
                }
            }

            onReleased: function(mouse) {
                // Always stop the rattle when the finger lifts so the
                // sample tail doesn't keep rolling after the snap.
                if (revolverSfx.playing) revolverSfx.stop()

                if (didDrag) {
                    // Snap to nearest integer step
                    var steps = Math.round(drawScreen.angularOffset)
                    if (steps !== 0) {
                        drawScreen.fanCenter = (drawScreen.fanCenter + steps + drawScreen.deckSize) % drawScreen.deckSize
                        // Final "seated" click as the cylinder locks
                        if (typeof haptics !== "undefined") haptics.light()
                    }
                    drawScreen.angularOffset = 0
                    return
                }

                // Tap — only accept taps near the bottom-center card area
                if (drawScreen.selectedCards.length >= 3) return
                var cx = width / 2
                var cy = height - 120
                if (Math.abs(mouse.x - cx) > 70) return
                if (Math.abs(mouse.y - cy) > 110) return

                var centerIdx = drawScreen.fanCenter
                if (drawScreen.selectedCards.indexOf(centerIdx) >= 0) return

                if (typeof haptics !== "undefined") haptics.medium()
                flyer.launch(centerIdx)
            }
        }

        // ------------------------------------------------------------------
        // Flyer — hidden card that animates center → target holder
        // ------------------------------------------------------------------
        Item {
            id: flyer
            width: 120
            height: 184
            visible: false
            z: 1000

            property real startX: 0
            property real startY: 0
            property real endX: 0
            property real endY: 0
            property real endScale: 0.35
            property real t: 0
            property string style: "kite"
            property int flyingDeckIdx: -1
            property int targetSlot: 0

            FanCardBack {
                id: flyerBack
                anchors.fill: parent
                deckIdx: flyer.flyingDeckIdx >= 0 ? flyer.flyingDeckIdx : 0
                active: false
            }

            function ease(u) { return u < 0.5 ? 2 * u * u : 1 - Math.pow(-2 * u + 2, 2) / 2 }

            function launch(deckIdx) {
                console.log("LOG: [DrawScreen] launching flight for deckIdx=" + deckIdx)
                flyingDeckIdx = deckIdx
                targetSlot = drawScreen.selectedCards.length

                // Source: center card rest position in flightArea coords
                startX = (flightArea.width - width) / 2
                startY = flightArea.height - height - 30

                // Destination: target holder mapped to flightArea coords
                var target = drawScreen.holderRefs[targetSlot]
                if (target) {
                    var pt = target.mapToItem(flightArea, 0, 0)
                    endX = pt.x + (target.width - width * endScale) / 2
                    endY = pt.y + (target.height - height * endScale) / 2
                } else {
                    endX = flightArea.width / 2 - (width * endScale) / 2
                    endY = 0
                }

                var styles = ["kite", "shuriken", "flutter"]
                style = styles[Math.floor(Math.random() * styles.length)]

                visible = true
                t = 0
                flightAnim.duration = (style === "shuriken") ? 750 : 950
                flightAnim.restart()
            }

            onTChanged: {
                var e = ease(t)
                var x = startX + (endX - startX) * e
                var y = startY + (endY - startY) * e
                var rot = 0
                var sc = 1 + (endScale - 1) * e

                if (style === "kite") {
                    var arcH = Math.min(220, Math.abs(startY - endY) * 0.6)
                    y -= Math.sin(Math.PI * e) * arcH
                    x += Math.sin(e * Math.PI * 2) * 22
                    rot = Math.sin(e * Math.PI * 2) * 10
                } else if (style === "shuriken") {
                    rot = e * 720
                    if (e > 0.85) sc *= 1 + (1 - e) * 0.3
                } else {
                    x += Math.sin(e * Math.PI * 4) * 28
                    y -= Math.sin(Math.PI * e) * 80
                    rot = Math.sin(e * Math.PI * 4) * 14
                }

                flyer.x = x
                flyer.y = y
                flyer.rotation = rot
                flyer.scale = sc
            }

            NumberAnimation {
                id: flightAnim
                target: flyer
                property: "t"
                from: 0
                to: 1
                duration: 950
                easing.type: Easing.Linear
                onStopped: {
                    // Commit selection
                    var arr = drawScreen.selectedCards.slice()
                    arr.push(flyer.flyingDeckIdx)
                    drawScreen.selectedCards = arr

                    // Pulse the holder that just got filled
                    var target = drawScreen.holderRefs[flyer.targetSlot]
                    if (target && target.pulseGlow) target.pulseGlow()
                    if (typeof haptics !== "undefined") {
                        if (drawScreen.selectedCards.length >= 3) haptics.success()
                        else haptics.light()
                    }

                    // Advance center past the now-selected card
                    drawScreen.advanceCenterPastSelected()

                    flyer.visible = false
                    flyer.scale = 1
                    flyer.rotation = 0
                    console.log("LOG: [DrawScreen] flight done — selected=" + JSON.stringify(drawScreen.selectedCards))
                }
            }
        }

        // Backdrop gradient at bottom so card spillover is masked
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 24
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: "#050305" }
            }
            z: 50
        }
    }

    // =======================================================================
    // Action bar — SHUFFLE + READ
    // =======================================================================
    Rectangle {
        id: actionBar
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 10 }
        height: 54
        color: "#f5050305"
        border.color: "#14D4AF37"
        border.width: 0
        z: 10

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1; color: "#14D4AF37"
        }

        Row {
            anchors { fill: parent; leftMargin: 4; rightMargin: 4; topMargin: 6; bottomMargin: 6 }
            spacing: 10

            // SHUFFLE
            Rectangle {
                width: (parent.width - 10) / 2
                height: parent.height
                radius: 6
                color: "transparent"
                border.color: "#66D4AF37"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "S H U F F L E"
                    color: "#D4AF37"
                    font.pixelSize: 10
                    font.letterSpacing: 3
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (typeof haptics !== "undefined") haptics.heavy()
                        drawScreen.doShuffle()
                    }
                }
            }

            // READ
            Rectangle {
                id: readBtn
                width: (parent.width - 10) / 2
                height: parent.height
                radius: 6
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#40E8630A" }
                    GradientStop { position: 1.0; color: "#26D4AF37" }
                }
                border.color: ready ? pulseColor : "#D4AF37"
                border.width: ready ? 2 : 1
                property bool ready: drawScreen.selectedCards.length === 3
                property color pulseColor: "#D4AF37"
                opacity: drawScreen.selectedCards.length > 0 ? 1.0 : 0.4

                SequentialAnimation on pulseColor {
                    running: readBtn.ready
                    loops: Animation.Infinite
                    ColorAnimation { to: "#FFD700"; duration: 600 }
                    ColorAnimation { to: "#D4AF37"; duration: 600 }
                }

                Text {
                    anchors.centerIn: parent
                    text: "R E A D"
                    color: "#D4AF37"
                    font.pixelSize: 10
                    font.letterSpacing: 3
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: drawScreen.selectedCards.length > 0
                    onClicked: {
                        console.log("LOG: [DrawScreen] READ clicked — emitting readCards with " + drawScreen.selectedCards.length + " indices: " + JSON.stringify(drawScreen.selectedCards))
                        if (typeof haptics !== "undefined") haptics.success()
                        drawScreen.readCards(drawScreen.selectedCards.slice())
                    }
                }
            }
        }
    }
}
