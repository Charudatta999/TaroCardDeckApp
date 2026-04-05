// Card back face — dark purple with gold Om watermark
import QtQuick

Rectangle {
    id: cardBack
    radius: 9
    color: "#0d080d"
    Component.onCompleted: console.log("LOG: CardBack created OK")

    // Inner border
    Rectangle {
        anchors { fill: parent; margins: 5 }
        radius: 6; color: "transparent"
        border.color: "#1aD4AF37"; border.width: 1
    }

    // Diagonal subtle pattern (simulated with opacity)
    Rectangle {
        anchors.fill: parent; radius: 9
        opacity: 0.04
        color: "#D4AF37"
    }

    // Om watermark
    Text {
        anchors.centerIn: parent
        text: "\u0950"
        font.pixelSize: 38
        color: "#1fD4AF37"
    }
}
