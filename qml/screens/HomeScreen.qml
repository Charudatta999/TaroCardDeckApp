// Splash / Home screen — matches HTML prototype
import QtQuick
import QtQuick.Controls

Item {
    id: homeScreen
    Component.onCompleted: console.log("LOG: HomeScreen created OK")

    signal navigateTo(string screen)

    // Deep purple-black radial gradient bg
    Rectangle {
        anchors.fill: parent
        color: "#050305"
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#331a0a02" }
            GradientStop { position: 0.5; color: "#00000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    // ── Rising golden particles ──────────────────────────────────────
    Repeater {
        model: 12
        delegate: Rectangle {
            property real tx: (Math.random() - 0.5) * 60
            property real startX: 80 + Math.random() * 200
            property real startY: 300 + Math.random() * 150
            property real dur: 3000 + Math.random() * 3000
            property real del: Math.random() * 4000

            x: startX; y: startY
            width: 2 + Math.random() * 3
            height: width; radius: width
            color: "#FFD700"
            opacity: 0

            SequentialAnimation on y {
                loops: Animation.Infinite
                PauseAnimation { duration: del }
                NumberAnimation { to: startY - 260; duration: dur; easing.type: Easing.OutCubic }
                PauseAnimation { duration: 200 }
                PropertyAction { value: startY }
            }
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                PauseAnimation { duration: del }
                NumberAnimation { to: 0.7; duration: 300 }
                NumberAnimation { to: 0; duration: dur - 300; easing.type: Easing.InCubic }
            }
        }
    }

    // ── Om stage — center of screen ───────────────────────────────────
    Item {
        id: omStage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -60
        width: 220; height: 220

        // 4 breathing halos
        Repeater {
            model: [
                { sz: 100, delay: 0,    borderColor: "#33E8630A" },
                { sz: 145, delay: 600,  borderColor: "#29E8630A" },
                { sz: 190, delay: 1200, borderColor: "#1aD4AF37" },
                { sz: 220, delay: 1800, borderColor: "#0fD4AF37" }
            ]
            delegate: Rectangle {
                anchors.centerIn: parent
                width: modelData.sz; height: modelData.sz
                radius: modelData.sz / 2
                color: "transparent"
                border.color: modelData.borderColor
                border.width: 1

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    PauseAnimation { duration: modelData.delay }
                    NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.4; duration: 1500; easing.type: Easing.InOutSine }
                }
                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    PauseAnimation { duration: modelData.delay }
                    NumberAnimation { to: 1.03; duration: 1500; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0;  duration: 1500; easing.type: Easing.InOutSine }
                }
            }
        }

        // Saffron core glow
        Rectangle {
            anchors.centerIn: parent
            width: 110; height: 110; radius: 55
            color: "transparent"
            opacity: 0.8

            Rectangle {
                anchors.centerIn: parent
                width: 110; height: 110; radius: 55
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: "#80E8630A" }
                    GradientStop { position: 0.45; color: "#33D4AF37" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.15; duration: 2500; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0;  duration: 2500; easing.type: Easing.InOutSine }
                }
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.0; duration: 2500; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.8; duration: 2500; easing.type: Easing.InOutSine }
                }
            }
        }

        // Om glyph
        Text {
            anchors.centerIn: parent
            text: "\u0950"
            font.pixelSize: 96
            color: "#FFD700"
            style: Text.Normal
            z: 2

            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: -10; duration: 4000; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0;   duration: 4000; easing.type: Easing.InOutSine }
            }
        }
    }

    // ── Wordmark ─────────────────────────────────────────────────────
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: omStage.bottom
        anchors.topMargin: 20
        spacing: 6

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "J Y O T I S H   T A R O"
            color: "#D4AF37"
            font.pixelSize: 16
            font.letterSpacing: 6
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "H I N D U   M Y T H I C   O R A C L E"
            color: "#E8630A"
            font.pixelSize: 9
            font.letterSpacing: 5
            opacity: 0.9
        }
    }

    // ── BEGIN READING button ─────────────────────────────────────────
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 48
        width: 200; height: 48
        color: "transparent"
        border.color: "#80D4AF37"
        border.width: 1

        // Subtle inner gradient on hover (always on for mobile)
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#26E8630A" }
                GradientStop { position: 1.0; color: "#1aD4AF37" }
            }
        }

        Text {
            anchors.centerIn: parent
            text: "B E G I N   R E A D I N G"
            color: "#D4AF37"
            font.pixelSize: 10
            font.letterSpacing: 4
        }

        MouseArea {
            anchors.fill: parent
            onClicked: homeScreen.navigateTo("draw")
        }
    }
}
