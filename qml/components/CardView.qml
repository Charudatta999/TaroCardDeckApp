import QtQuick
import QtQuick.Controls

Item {
    id: cardView
    width: 160
    height: 240

    property bool flipped: false
    property bool reversed: false
    property string cardImage: ""
    property string cardName: ""

    Flipable {
        id: flipable
        anchors.fill: parent

        property bool flipped: cardView.flipped

        front: CardBack {
            anchors.fill: parent
        }

        back: Rectangle {
            anchors.fill: parent
            radius: 8
            color: "#1A1A1A"
            border.color: "#FFD700"
            border.width: 1

            rotation: cardView.reversed ? 180 : 0

            // Card front image with placeholder when art is missing
            Image {
                id: cardImg
                anchors.fill: parent
                anchors.margins: 4
                source: cardView.cardImage
                fillMode: Image.PreserveAspectFit
                visible: status === Image.Ready
            }

            // Placeholder shown when image has not loaded
            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                radius: 6
                color: "#1A0A2E"
                visible: cardImg.status !== Image.Ready

                Label {
                    anchors.centerIn: parent
                    text: "\u0950"
                    color: "#FFD700"
                    font.pixelSize: 36
                    opacity: 0.4
                }
            }

            Label {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 8
                text: cardView.cardName
                color: "#FFD700"
                font.pixelSize: 12
                font.bold: true
            }
        }

        transform: Rotation {
            id: rotation
            origin.x: flipable.width / 2
            origin.y: flipable.height / 2
            axis.x: 0; axis.y: 1; axis.z: 0
            angle: 0
        }

        states: State {
            name: "back"
            when: flipable.flipped
            PropertyChanges { target: rotation; angle: 180 }
        }

        transitions: Transition {
            NumberAnimation {
                target: rotation
                property: "angle"
                duration: 400
                easing.type: Easing.InOutQuad
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: cardView.flipped = !cardView.flipped
    }
}
