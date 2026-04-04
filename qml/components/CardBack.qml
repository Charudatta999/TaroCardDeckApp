import QtQuick

Rectangle {
    id: cardBack
    Component.onCompleted: console.log("LOG: CardBack created OK")
    radius: 8
    color: "#0D0D0D"
    border.color: "#FFD700"
    border.width: 1

    // Gold Om symbol centered on velvet-black card back
    Label {
        anchors.centerIn: parent
        text: "\u0950"  // Om symbol (Devanagari)
        color: "#FFD700"
        font.pixelSize: 48
        font.bold: true
    }

    // Subtle border pattern
    Rectangle {
        anchors.fill: parent
        anchors.margins: 8
        radius: 6
        color: "transparent"
        border.color: "#FFD700"
        border.width: 0.5
        opacity: 0.3
    }
}
