// Full-screen canvas watermark — edge-biased scatter of Hindu symbols
// matching the HTML prototype (prototype/JyotishTaro_CardSelection.html).
import QtQuick

Canvas {
    id: root
    anchors.fill: parent
    antialiasing: true

    // Symbols pool — BMP-safe
    readonly property var symbols: ["\u0950","\u2638","\u2740","\u534d","\u274b","\u2726","\u2735","\u2731"]
    property int seed: 1

    onPaint: {
        var ctx = getContext("2d")
        var W = width, H = height
        ctx.clearRect(0,0,W,H)
        ctx.fillStyle = "#0a0a0a"
        ctx.fillRect(0,0,W,H)

        var count = Math.max(36, Math.round(W * H / 9000))
        for (var i = 0; i < count; i++) {
            // edge-biased position: prefer outside the central 35% box
            var x, y, a = 0
            do {
                x = Math.random() * W
                y = Math.random() * H
                var cx = Math.abs(x - W/2) / (W/2)
                var cy = Math.abs(y - H/2) / (H/2)
                if (cx > 0.35 || cy > 0.35) break
                a++
            } while (a < 5)

            var sym = symbols[Math.floor(Math.random() * symbols.length)]
            var size = 22 + Math.random() * 68
            var rot  = Math.random() * Math.PI * 2
            var op   = 0.02 + Math.random() * 0.025
            if (sym === "\u2735" || sym === "\u2726") op *= 0.7

            ctx.save()
            ctx.translate(x, y)
            ctx.rotate(rot)
            ctx.globalAlpha = op
            ctx.fillStyle = "#C9A84C"
            ctx.font = size + "px serif"
            ctx.textAlign = "center"
            ctx.textBaseline = "middle"
            ctx.fillText(sym, 0, 0)
            ctx.restore()
        }
    }

    onWidthChanged:  requestPaint()
    onHeightChanged: requestPaint()
    Component.onCompleted: requestPaint()
}
