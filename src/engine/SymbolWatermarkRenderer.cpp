#include "SymbolWatermarkRenderer.h"
#include <QFont>
#include <QRandomGenerator>
#include <QTransform>
#include <cmath>

// -----------------------------------------------------------------
// Unicode glyphs — BMP only, safe on Android
// -----------------------------------------------------------------
QString SymbolWatermarkRenderer::glyphForSymbol(Symbol s)
{
    switch (s) {
    case Om:        return QString("\u0950");  // ॐ
    case Trishul:   return QString("\u2638");  // ☸ dharma wheel
    case Lotus:     return QString("\u273F");  // ✿
    case Chakra:    return QString("\u2726");  // ✦
    case Vajra:     return QString("\u2724");  // ✤
    case SriYantra: return QString("\u2733");  // ✳
    case Shankha:   return QString("\u274B");  // ❋
    case Damaru:    return QString("\u2735");  // ✵
    default:        return QString("\u2736");  // ✶ fallback
    }
}

// Complex symbols get lower opacity so they don't distract
float SymbolWatermarkRenderer::opacityForSymbol(Symbol s)
{
    switch (s) {
    case SriYantra: return 0.025f;
    case Chakra:    return 0.030f;
    case Om:        return 0.055f;
    case Lotus:     return 0.060f;
    default:        return 0.045f;
    }
}

int SymbolWatermarkRenderer::fontSizeForSymbol(Symbol /*s*/, float scale, float rectWidth)
{
    return static_cast<int>(rectWidth * 0.18f * scale);
}

// -----------------------------------------------------------------
// Six fixed relative positions: corners + mid-edges
// Center 40% is intentionally left empty.
// -----------------------------------------------------------------
QVector<QPointF> SymbolWatermarkRenderer::fixedPositions()
{
    return {
        {0.08f, 0.08f},   // top-left corner
        {0.92f, 0.08f},   // top-right corner
        {0.08f, 0.92f},   // bottom-left corner
        {0.92f, 0.92f},   // bottom-right corner
        {0.50f, 0.05f},   // top mid-edge
        {0.50f, 0.95f},   // bottom mid-edge
    };
}

// Assign symbols without consecutive duplicates
QVector<SymbolWatermarkRenderer::Symbol>
SymbolWatermarkRenderer::assignSymbols(int count)
{
    QVector<Symbol> all;
    for (int i = 0; i < SymbolCount; ++i)
        all.append(static_cast<Symbol>(i));

    QVector<Symbol> result;
    result.reserve(count);
    Symbol last = SymbolCount;  // sentinel "none"

    for (int i = 0; i < count; ++i) {
        QVector<Symbol> pool;
        for (Symbol s : all)
            if (s != last) pool.append(s);
        int pick = static_cast<int>(QRandomGenerator::global()->bounded(pool.size()));
        last = pool[pick];
        result.append(last);
    }
    return result;
}

// -----------------------------------------------------------------
SymbolWatermarkRenderer::SymbolWatermarkRenderer() = default;

void SymbolWatermarkRenderer::initialize(QSizeF /*bounds*/)
{
    m_placements.clear();

    QVector<QPointF>  positions = fixedPositions();
    QVector<Symbol>   symbols   = assignSymbols(NUM_POSITIONS);

    for (int i = 0; i < NUM_POSITIONS; ++i) {
        SymbolPlacement p;
        p.relativePos  = positions[i];
        p.symbol       = symbols[i];
        p.rotation     = static_cast<float>(QRandomGenerator::global()->bounded(360));
        p.scale        = 0.7f + static_cast<float>(QRandomGenerator::global()->bounded(80)) / 100.0f;
        p.opacity      = opacityForSymbol(p.symbol);
        p.isNearLayer  = (i % 2 == 0);   // alternate near/far layers
        m_placements.append(p);
    }
    m_initialized = true;
}

void SymbolWatermarkRenderer::render(QPainter& painter, const QRectF& targetRect) const
{
    if (!m_initialized || m_placements.isEmpty()) return;

    painter.save();

    for (const SymbolPlacement& pl : m_placements) {
        // Absolute position inside targetRect
        float ax = static_cast<float>(targetRect.x() + pl.relativePos.x() * targetRect.width());
        float ay = static_cast<float>(targetRect.y() + pl.relativePos.y() * targetRect.height());

        int px = static_cast<int>(static_cast<float>(targetRect.width()) * 0.18f * pl.scale);
        if (pl.isNearLayer)
            px = static_cast<int>(px * 0.75f);

        QFont font;
        font.setPixelSize(qMax(8, px));
        painter.setFont(font);

        QColor color(201, 168, 76);   // gold
        color.setAlphaF(static_cast<double>(pl.opacity));
        painter.setPen(color);

        // Rotate around the glyph centre
        painter.save();
        painter.translate(ax, ay);
        painter.rotate(static_cast<double>(pl.rotation));
        painter.translate(-px / 2, px / 2);  // crude centering
        painter.drawText(0, 0, glyphForSymbol(pl.symbol));
        painter.restore();
    }

    painter.restore();
}
