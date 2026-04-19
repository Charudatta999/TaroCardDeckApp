// Reading view — 3D flip cards with swipe navigation.
// Ported from prototype/JyotishTaro_CardSelection.html.
import QtQuick
import QtQuick.Controls
import TaroCardDeck 1.0

Item {
    id: spreadScreen
    Component.onCompleted: {
        console.log("LOG: [SpreadScreen] >>> created OK, size=" + width + "x" + height)
        console.log("LOG: [SpreadScreen] selectedIndices=" + JSON.stringify(selectedIndices) + " (length=" + selectedIndices.length + ")")
    }

    property int spreadType: 0
    property var selectedIndices: []
    onSelectedIndicesChanged: console.log("LOG: [SpreadScreen] selectedIndices changed: " + JSON.stringify(selectedIndices))

    property int currentIndex: 0
    onCurrentIndexChanged: console.log("LOG: [SpreadScreen] currentIndex=" + currentIndex)

    function cardAt(i) {
        if (i < 0 || i >= selectedIndices.length) {
            console.log("LOG: [SpreadScreen] cardAt(" + i + ") out of range — returning empty")
            return ({})
        }
        var data = appController.cardAt(selectedIndices[i])
        console.log("LOG: [SpreadScreen] cardAt(" + i + ") deckIdx=" + selectedIndices[i] + " name=" + (data ? data.name : "null"))
        return data
    }

    Rectangle { anchors.fill: parent; color: "#050305" }
    WatermarkBackground { anchors.fill: parent; z: 0 }

    // --- Header -------------------------------------------------------------
    Text {
        id: header
        anchors { top: parent.top; topMargin: 14; horizontalCenter: parent.horizontalCenter }
        text: "THREE  CARD  SPREAD"
        color: "#C9A84C"; font.pixelSize: 10; font.letterSpacing: 3
        z: 5
    }

    // --- Card stage ---------------------------------------------------------
    Item {
        id: stage
        anchors {
            top: header.bottom; topMargin: 10
            left: parent.left; right: parent.right
            bottom: dots.top; bottomMargin: 14
        }
        z: 2
        clip: false

        // Gesture dispatcher — one MouseArea at stage level classifies
        // tap / horizontal swipe / vertical swipe and delegates to the
        // current ReadingCard's public gesture handlers.
        //
        // Listed BEFORE the Repeater so the ReadingCards are rendered ON
        // TOP (later siblings are drawn on top). MouseAreas inside the
        // cards (e.g. sheet's handle drag) will therefore intercept
        // events in their bounds; everywhere else, events fall through
        // to this gestureArea.
        MouseArea {
            id: gestureArea
            anchors.fill: parent
            property real sx: 0
            property real sy: 0

            onPressed: function(mouse) { sx = mouse.x; sy = mouse.y }
            onReleased: function(mouse) {
                var dx = mouse.x - sx
                var dy = mouse.y - sy
                var adx = Math.abs(dx)
                var ady = Math.abs(dy)
                var target = cardRep.itemAt(spreadScreen.currentIndex)
                console.log("LOG: [SpreadScreen] gesture dx=" + dx.toFixed(0) + " dy=" + dy.toFixed(0))

                // Tap (minimal motion)
                if (adx < 10 && ady < 10) {
                    if (typeof haptics !== "undefined") haptics.light()
                    if (target && target.tapGesture) target.tapGesture()
                    return
                }

                // Horizontal navigation dominates vertical
                if (adx > ady && adx > 60) {
                    if (dx < 0 && spreadScreen.currentIndex < spreadScreen.selectedIndices.length - 1) {
                        if (typeof haptics !== "undefined") haptics.selection()
                        spreadScreen.currentIndex++
                    } else if (dx > 0 && spreadScreen.currentIndex > 0) {
                        if (typeof haptics !== "undefined") haptics.selection()
                        spreadScreen.currentIndex--
                    } else {
                        if (typeof haptics !== "undefined") haptics.warning()
                    }
                    return
                }

                // Vertical → swipe up / down on current card
                if (ady > adx && ady > 40) {
                    if (typeof haptics !== "undefined") haptics.medium()
                    if (dy < 0 && target && target.swipeUpGesture) target.swipeUpGesture()
                    else if (dy > 0 && target && target.swipeDownGesture) target.swipeDownGesture()
                    return
                }
            }
        }

        Repeater {
            id: cardRep
            model: spreadScreen.selectedIndices.length
            delegate: ReadingCard {
                id: rcard
                width: Math.min(stage.width * 0.86, 420)
                height: Math.min(stage.height * 0.96, 680)
                cardData: spreadScreen.cardAt(index)
                y: (stage.height - height) / 2

                property real offsetX: (index - spreadScreen.currentIndex) * (stage.width + 20)
                x: (stage.width - width) / 2 + offsetX
                Behavior on x { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }

                visible: Math.abs(index - spreadScreen.currentIndex) <= 1
            }
        }
    }

    // --- Dots indicator -----------------------------------------------------
    Row {
        id: dots
        anchors { bottom: parent.bottom; bottomMargin: 16; horizontalCenter: parent.horizontalCenter }
        spacing: 10
        z: 5
        Repeater {
            model: spreadScreen.selectedIndices.length
            delegate: Rectangle {
                width: 8; height: 8; radius: 4
                color: index === spreadScreen.currentIndex ? "#D4AF37" : "#40C9A84C"
                scale: index === spreadScreen.currentIndex ? 1.3 : 1.0
                Behavior on scale { NumberAnimation { duration: 200 } }
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
    }

    // --- Hint ---------------------------------------------------------------
    Text {
        anchors { bottom: dots.top; bottomMargin: 6; horizontalCenter: parent.horizontalCenter }
        text: "TAP TO FLIP  \u00B7  SWIPE UP FOR MEANING  \u00B7  SWIPE SIDE FOR NEXT"
        color: "#7a6c47"; font.pixelSize: 8; font.letterSpacing: 3
        opacity: 0.7; z: 5
    }
}
