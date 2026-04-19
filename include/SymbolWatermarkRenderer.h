#pragma once
#include <QPainter>
#include <QRectF>
#include <QSizeF>
#include <QVector>

class SymbolWatermarkRenderer
{
public:
    enum Symbol {
        Om,        // ॐ
        Trishul,   // ☸  (dharma wheel)
        Lotus,     // ✿
        Chakra,    // ✦
        Vajra,     // ✤
        SriYantra, // ✳
        Shankha,   // ❋
        Damaru,    // ✵
        SymbolCount
    };

    struct SymbolPlacement {
        QPointF relativePos;   // normalized 0.0–1.0
        Symbol  symbol;
        float   rotation;      // degrees
        float   scale;         // 0.6–1.4
        float   opacity;       // 0.02–0.08
        bool    isNearLayer;   // true = sharper/smaller, false = larger/blurred
    };

    SymbolWatermarkRenderer();

    // Call once with the card/widget bounds to fix symbol positions
    void initialize(QSizeF bounds);

    // Render all placements into the given targetRect
    void render(QPainter& painter, const QRectF& targetRect) const;

private:
    static constexpr int NUM_POSITIONS = 6;

    QVector<SymbolPlacement> m_placements;
    bool m_initialized = false;

    static QString glyphForSymbol(Symbol s);
    static float   opacityForSymbol(Symbol s);
    static int     fontSizeForSymbol(Symbol s, float scale, float rectWidth);

    // Generate non-repeating symbol list for positions
    static QVector<Symbol> assignSymbols(int count);

    // Fixed relative positions: corners + mid-edges
    static QVector<QPointF> fixedPositions();
};
