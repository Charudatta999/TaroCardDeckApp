// Card-back visual: dark gradient + gold inner border + 3D-ish Om +
// fixed-position watermark symbols. Seeded per card so each back is unique.
import QtQuick

Item {
    id: root
    property int deckIdx: 0
    property bool active: false
    readonly property var symbols: ["\u0950","\u2638","\u2740","\u534d","\u274b","\u2726","\u2735","\u2731"]
    // Fixed 7 positions (normalised) — centre kept empty.
    readonly property var positions: [
        { x: 0.12, y: 0.14 }, { x: 0.86, y: 0.15 },
        { x: 0.18, y: 0.42 }, { x: 0.80, y: 0.48 },
        { x: 0.15, y: 0.78 }, { x: 0.82, y: 0.82 },
        { x: 0.50, y: 0.08 }
    ]

    // Deterministic PRNG seeded by deckIdx so each card has a stable unique pattern
    function seededRand(seedValue) {
        var x = Math.sin(seedValue * 9301 + 49297) * 233280
        return x - Math.floor(x)
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#1a1614" }
            GradientStop { position: 1.0; color: "#0b0907" }
        }
        border.color: root.active ? "#C9A84C" : "#59C9A84C"
        border.width: root.active ? 2 : 1
    }

    // Inner hairline border (3px inset)
    Rectangle {
        anchors { fill: parent; margins: 6 }
        radius: 7
        color: "transparent"
        border.color: "#47C9A84C"
        border.width: 1
    }

    // Watermark symbols at fixed positions, per-card random selection
    Repeater {
        model: root.positions.length
        delegate: Text {
            property real r1: root.seededRand(root.deckIdx * 17 + index * 7)
            property real r2: root.seededRand(root.deckIdx * 23 + index * 13 + 1)
            property real r3: root.seededRand(root.deckIdx * 31 + index * 19 + 2)
            x: root.width  * root.positions[index].x - width/2
            y: root.height * root.positions[index].y - height/2
            text: root.symbols[Math.floor(r1 * root.symbols.length)]
            color: "#C9A84C"
            font.pixelSize: 8 + Math.floor(r2 * 8)
            opacity: 0.025 + r3 * 0.04
            rotation: Math.floor(r1 * 360)
        }
    }

    // Large 3D-ish Om centered
    Text {
        anchors.centerIn: parent
        text: "\u0950"
        color: "#D4AF37"
        font.pixelSize: Math.min(root.width, root.height) * 0.44
        font.family: "serif"
        style: Text.Raised
        styleColor: "#6e5519"
    }

    // Outer glow when active
    Rectangle {
        visible: root.active
        anchors.fill: parent
        radius: 10
        color: "transparent"
        border.color: "#66D4AF37"
        border.width: 2
        z: -1
    }
}
