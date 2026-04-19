// 3D flippable reading card.
//   Front  = card-back (FanCardBack)
//   Back   = full-bleed deity image, name block (Devanagari + Roman),
//            and a swipe-up details sheet with upright/reversed/notes.
// Tap the card-back to flip. Swipe up on the image to reveal details.
// Swipe down on the open sheet handle to close it. Tap the image body
// (outside the sheet) to flip back.
import QtQuick
import QtQuick.Controls
import TaroCardDeck 1.0

Flipable {
    id: flip
    Component.onCompleted: console.log("LOG: [ReadingCard] created — deckIdx=" + (cardData && cardData.id !== undefined ? cardData.id : "none") + " name=" + (cardData && cardData.name ? cardData.name : "none"))

    property var cardData: ({})
    property bool revealed: false
    onRevealedChanged: {
        console.log("LOG: [ReadingCard] revealed=" + revealed + " for " + (cardData && cardData.name ? cardData.name : "?"))
        if (!revealed) sheet.open = false   // close details whenever we flip back
    }

    // =======================================================================
    // Devanagari lookup for 67 deities present in cards_data.json.
    // Fallback: Roman name only (when key is not found).
    // =======================================================================
    readonly property var devanagariMap: ({
        "Abhimanyu":        "अभिमन्यु",
        "Agastya":          "अगस्त्य",
        "Agni":             "अग्नि",
        "Anasuya":          "अनसूया",
        "Apsaras":          "अप्सरस्",
        "Arjuna":           "अर्जुन",
        "Atri and Anasuya": "अत्रि-अनसूया",
        "Bhagiratha":       "भगीरथ",
        "Bharata":          "भरत",
        "Bhim":             "भीम",
        "Bhishma":          "भीष्म",
        "Brahma":           "ब्रह्मा",
        "Brihaspati":       "बृहस्पति",
        "Dakshinamurti":    "दक्षिणामूर्ति",
        "Dhritarashtra":    "धृतराष्ट्र",
        "Draupadi":         "द्रौपदी",
        "Ekalavya":         "एकलव्य",
        "Gargi":            "गार्गी",
        "Garuda":           "गरुड",
        "Hanuman":          "हनुमान्",
        "Harishchandra":    "हरिश्चन्द्र",
        "Ikshvaku lineage": "इक्ष्वाकु वंश",
        "Indra":            "इन्द्र",
        "Jada Bharata":     "जड भरत",
        "Kaal Bhairav":     "काल भैरव",
        "Kacha":            "कच",
        "Kamadeva":         "कामदेव",
        "Kamsa":            "कंस",
        "Karna":            "कर्ण",
        "Kartikeya":        "कार्तिकेय",
        "King Janaka":      "जनक",
        "Krishna":          "कृष्ण",
        "Kubera":           "कुबेर",
        "Lav and Kush":     "लव-कुश",
        "MahaKala":         "महाकाल",
        "Maitreyi":         "मैत्रेयी",
        "Mandodari":        "मन्दोदरी",
        "Markandeya":       "मार्कण्डेय",
        "Maya / Yogamaya":  "योगमाया",
        "Nachiketa":        "नचिकेता",
        "Nala and Damayanti":"नल-दमयन्ती",
        "Nandi":            "नन्दी",
        "Narada":           "नारद",
        "Parashurama":      "परशुराम",
        "Parvati":          "पार्वती",
        "Patanjali":        "पतञ्जलि",
        "Radha":            "राधा",
        "Rama":             "राम",
        "Ravana":           "रावण",
        "Shakuni":          "शकुनि",
        "Shani":            "शनि",
        "Shiva-Shakti":     "शिव-शक्ति",
        "Shukracharya":     "शुक्राचार्य",
        "Sita":             "सीता",
        "Soma":             "सोम",
        "Sudama":           "सुदामा",
        "Surya":            "सूर्य",
        "The Ribhus":       "ऋभवः",
        "Tripura Sundari":  "त्रिपुर सुन्दरी",
        "Valmiki":          "वाल्मीकि",
        "Vasistha":         "वसिष्ठ",
        "Vishnu":           "विष्णु",
        "Vishwakarma":      "विश्वकर्मा",
        "Vyasa":            "व्यास",
        "Yajnavalkya":      "याज्ञवल्क्य",
        "Yama":             "यम",
        "Young Krishna":    "बाल कृष्ण",
        "Yudhishthira":     "युधिष्ठिर"
    })

    readonly property string deityDev:   devanagariMap[cardData.name || ""] || ""
    readonly property string deityRoman: cardData.name || ""

    // =======================================================================
    // Public gesture handlers — invoked by SpreadScreen's outer gestureArea
    // =======================================================================
    function tapGesture() {
        console.log("LOG: [ReadingCard] tapGesture revealed=" + revealed + " sheetOpen=" + sheet.open)
        if (!revealed) { revealed = true; return }
        if (sheet.open) { sheet.open = false; return }
        revealed = false
    }

    function swipeUpGesture() {
        console.log("LOG: [ReadingCard] swipeUpGesture revealed=" + revealed)
        if (!revealed) { revealed = true; return }
        sheet.open = true
    }

    function swipeDownGesture() {
        console.log("LOG: [ReadingCard] swipeDownGesture revealed=" + revealed)
        if (revealed && sheet.open) { sheet.open = false; return }
        if (revealed) revealed = false
    }

    // Read-only access to sheet's open state for outer gestureArea
    readonly property bool sheetOpen: sheet.open

    // =======================================================================
    // 3D flip
    // =======================================================================
    transform: Rotation {
        id: rot
        origin.x: flip.width / 2
        origin.y: flip.height / 2
        axis { x: 0; y: 1; z: 0 }
        angle: flip.revealed ? 180 : 0
        Behavior on angle { NumberAnimation { duration: 700; easing.type: Easing.InOutCubic } }
    }

    // =======================================================================
    // FRONT — Card back pattern. Gestures come from SpreadScreen's outer
    // gestureArea; no MouseArea here.
    // =======================================================================
    front: FanCardBack {
        anchors.fill: parent
        deckIdx: flip.cardData && flip.cardData.id !== undefined ? flip.cardData.id : 0
        active: true
    }

    // =======================================================================
    // BACK — Deity image + name + swipe-up details sheet
    // =======================================================================
    back: Item {
        id: backRoot
        anchors.fill: parent

        // Full-bleed deity image via image provider
        Image {
            id: deityImg
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            cache: true
            source: flip.cardData && flip.cardData.id !== undefined
                    ? ("image://cardface/" + flip.cardData.id)
                    : ""
            asynchronous: true
            z: 0
        }

        // Rounded-clip mask (matches Flipable geometry via Rectangle mask)
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: 14
            border.color: "#59C9A84C"
            border.width: 1
            z: 10
        }

        // Top gradient overlay — darkens top for name legibility
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: parent.height * 0.42
            z: 1
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#cc000000" }
                GradientStop { position: 0.55; color: "#66000000" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // Bottom gradient overlay — anchors the sheet handle and
        // keeps the Roman/Dev names readable if the image is bright
        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: parent.height * 0.35
            z: 1
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.55; color: "#66000000" }
                GradientStop { position: 1.0; color: "#d9000000" }
            }
        }

        // ------------------------------------------------------------------
        // Name block (top)
        // ------------------------------------------------------------------
        Column {
            anchors {
                top: parent.top
                topMargin: 24
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width - 40
            spacing: 6
            z: 2

            // cardType · arcana microtype
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: ((flip.cardData.cardType || "") + "  \u00B7  " + (flip.cardData.arcana || "")).toUpperCase()
                color: "#D4AF37"
                font.pixelSize: 9
                font.letterSpacing: 3
                opacity: 0.9
                elide: Text.ElideRight
            }

            // Devanagari name (prominent)
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: flip.deityDev
                visible: flip.deityDev.length > 0
                color: "#FFE89A"
                font.pixelSize: 34
                font.family: "serif"
                style: Text.Raised
                styleColor: "#332200"
                elide: Text.ElideRight
            }

            // Roman name (subtitle)
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: flip.deityRoman
                color: "#D4AF37"
                font.pixelSize: flip.deityDev.length > 0 ? 14 : 24
                font.italic: flip.deityDev.length > 0
                font.letterSpacing: flip.deityDev.length > 0 ? 2 : 3
                opacity: 0.92
                elide: Text.ElideRight
            }
        }

        // Gesture dispatch for the back side is driven by SpreadScreen's
        // outer gestureArea which calls tapGesture() / swipeUpGesture() /
        // swipeDownGesture() on this card. Keeps event routing simple —
        // no competing MouseAreas on top of the sheet's handle.

        // ------------------------------------------------------------------
        // Swipe-up details sheet
        // ------------------------------------------------------------------
        Rectangle {
            id: sheet
            property bool open: false
            readonly property real closedY: backRoot.height - 72   // 72 px peek
            readonly property real openY:   backRoot.height * 0.18  // covers most of card when open

            width: parent.width
            height: parent.height - openY
            radius: 16
            color: "#e60b0907"
            border.color: "#59C9A84C"
            border.width: 1
            z: 4

            // Animate y between closed and open states
            y: open ? openY : closedY
            Behavior on y { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

            // Drop shadow above sheet top (subtle)
            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.top }
                height: 12
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: "#66000000" }
                }
            }

            // Handle bar at top — drag zone + click toggle
            Item {
                id: handle
                width: parent.width
                height: 52

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    width: 44; height: 4; radius: 2
                    color: "#99D4AF37"
                }

                Text {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        bottomMargin: 6
                    }
                    text: sheet.open ? "SWIPE DOWN TO CLOSE" : "SWIPE UP FOR MEANING"
                    color: "#D4AF37"
                    font.pixelSize: 9
                    font.letterSpacing: 3
                }

                MouseArea {
                    id: handleDrag
                    anchors.fill: parent
                    property real pressY: 0
                    property real pressSheetY: 0
                    property bool dragging: false

                    onPressed: function(mouse) {
                        pressY = mouse.y
                        pressSheetY = sheet.y
                        dragging = false
                    }
                    onPositionChanged: function(mouse) {
                        var dy = mouse.y - pressY
                        if (Math.abs(dy) > 4) dragging = true
                        var target = pressSheetY + dy
                        if (target < sheet.openY)   target = sheet.openY
                        if (target > sheet.closedY) target = sheet.closedY
                        sheet.y = target
                    }
                    onReleased: function(mouse) {
                        if (!dragging) {
                            if (typeof haptics !== "undefined") haptics.light()
                            sheet.open = !sheet.open
                            return
                        }
                        var mid = (sheet.openY + sheet.closedY) / 2
                        var wasOpen = sheet.open
                        sheet.open = (sheet.y < mid)
                        if (typeof haptics !== "undefined" && wasOpen !== sheet.open) haptics.medium()
                        // Re-snap via binding
                        sheet.y = Qt.binding(function() { return sheet.open ? sheet.openY : sheet.closedY })
                    }
                }
            }

            // ------------------------------------------------------------------
            // Details content — Flickable so long notes scroll
            // ------------------------------------------------------------------
            Flickable {
                id: content
                anchors {
                    top: handle.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    leftMargin: 18
                    rightMargin: 18
                    topMargin: 6
                    bottomMargin: 14
                }
                contentHeight: detailCol.implicitHeight
                clip: true
                interactive: sheet.open
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: detailCol
                    width: content.width
                    spacing: 10

                    // Mantra / quote (use notes as mantra placeholder)
                    Rectangle {
                        width: parent.width
                        radius: 8
                        color: "#1a140a"
                        border.color: "#26D4AF37"
                        border.width: 1

                        Text {
                            width: parent.width - 24
                            x: 12; y: 10
                            text: "\u201C" + (flip.cardData.notes || "") + "\u201D"
                            color: "#FFE89A"
                            font.pixelSize: 13
                            font.italic: true
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                        // auto-size: parent.height follows text
                        height: Math.max(44, childrenRect.height + 20)
                    }

                    // UPRIGHT
                    Column {
                        width: parent.width
                        spacing: 4
                        Text {
                            text: "UPRIGHT KEYWORDS"
                            color: "#C9A84C"
                            font.pixelSize: 9
                            font.letterSpacing: 3
                        }
                        Text {
                            width: parent.width
                            text: flip.cardData.uprightKeywords || ""
                            color: "#EDD9A3"
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                        }
                    }

                    // REVERSED
                    Column {
                        width: parent.width
                        spacing: 4
                        Text {
                            text: "REVERSED KEYWORDS"
                            color: "#C9A84C"
                            font.pixelSize: 9
                            font.letterSpacing: 3
                        }
                        Text {
                            width: parent.width
                            text: flip.cardData.reversedKeywords || ""
                            color: "#EDD9A3"
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                        }
                    }

                    // NOTES (detailed)
                    Column {
                        width: parent.width
                        spacing: 4
                        Text {
                            text: "INTERPRETIVE NOTES"
                            color: "#C9A84C"
                            font.pixelSize: 9
                            font.letterSpacing: 3
                        }
                        Text {
                            width: parent.width
                            text: flip.cardData.notes || ""
                            color: "#EDD9A3"
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                        }
                    }

                    Item { width: 1; height: 8 } // tail padding
                }
            }
        }
    }
}
