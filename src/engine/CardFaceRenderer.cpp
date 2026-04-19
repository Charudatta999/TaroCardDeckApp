#include "CardFaceRenderer.h"
#include <QFont>
#include <QFontDatabase>
#include <QFile>
#include <QLinearGradient>
#include <QPainter>
#include <QPainterPath>
#include <QPen>

namespace {
QPixmap loadCardArt(const QString& imagePath)
{
    if (imagePath.isEmpty())
        return {};

    const QString normalized = imagePath.startsWith('/') ? imagePath.mid(1) : imagePath;
    const QStringList candidates = {
        QStringLiteral(":/") + normalized,
        QStringLiteral(":/assets/") + normalized,
        normalized,
        QStringLiteral("assets/") + normalized
    };

    for (const QString& candidate : candidates) {
        if (QFile::exists(candidate)) {
            QPixmap art(candidate);
            if (!art.isNull())
                return art;
        }
    }

    return {};
}
}

// -----------------------------------------------------------------
// Public entry points
// -----------------------------------------------------------------

QPixmap CardFaceRenderer::renderCardFace(const CardData& card, QSize size)
{
    QPixmap result(size);
    result.fill(Qt::transparent);
    QPainter p(&result);
    p.setRenderHint(QPainter::Antialiasing);
    p.setRenderHint(QPainter::SmoothPixmapTransform);

    QRect rect(0, 0, size.width(), size.height());

    // Layer 1 — deity artwork (or Om placeholder if missing)
    QPixmap art = loadCardArt(card.imagePath);
    if (art.isNull())
        drawOmPlaceholder(p, rect);
    else
        drawDeityImage(p, art, rect);

    // Layer 2 — gradient overlays (legibility)
    drawGradientOverlays(p, rect);

    // Layer 3 — gold border + ornaments
    drawGoldBorder(p, rect);
    drawCornerOrnaments(p, rect);

    // Layer 4 — card type text (top)
    drawTopText(p, card.cardType.toUpper(), rect);

    // Layer 5 — deity name + mantra (bottom)
    drawBottomText(p, card.name, card.notes, rect);

    return result;
}

QPixmap CardFaceRenderer::renderCardBack(QSize size)
{
    QPixmap result(size);
    result.fill(QColor(0x0d, 0x08, 0x0d));
    QPainter p(&result);
    p.setRenderHint(QPainter::Antialiasing);

    QRect rect(0, 0, size.width(), size.height());

    // Inner border
    QPen borderPen(QColor(212, 175, 55, 40), 1);
    p.setPen(borderPen);
    p.drawRoundedRect(rect.adjusted(8, 8, -8, -8), 10, 10);

    // Symbol watermark
    SymbolWatermarkRenderer sr;
    sr.initialize(QSizeF(size));
    sr.render(p, QRectF(rect));

    // Om glyph centre
    QFont f;
    f.setPixelSize(size.width() / 3);
    p.setFont(f);
    p.setPen(QColor(212, 175, 55, 31));   // ~12% opacity gold
    p.drawText(rect, Qt::AlignCenter, QString("\u0950"));

    return result;
}

// -----------------------------------------------------------------
// Private helpers
// -----------------------------------------------------------------

void CardFaceRenderer::drawDeityImage(QPainter& p, const QPixmap& art, QRect rect)
{
    // Scale to fill, centre-crop
    QPixmap scaled = art.scaled(rect.size(), Qt::KeepAspectRatioByExpanding,
                                 Qt::SmoothTransformation);
    int dx = (scaled.width()  - rect.width())  / 2;
    int dy = (scaled.height() - rect.height()) / 2;
    p.drawPixmap(rect, scaled, QRect(dx, dy, rect.width(), rect.height()));
}

void CardFaceRenderer::drawGradientOverlays(QPainter& p, QRect rect)
{
    // Top fade — card type legibility
    QLinearGradient topFade(0, 0, 0, rect.height() * 0.22);
    topFade.setColorAt(0.0, QColor(0, 0, 0, 200));
    topFade.setColorAt(1.0, QColor(0, 0, 0, 0));
    p.fillRect(rect, topFade);

    // Bottom fade — deity name + mantra legibility
    QLinearGradient botFade(0, rect.height() * 0.60, 0, rect.height());
    botFade.setColorAt(0.0, QColor(0, 0, 0, 0));
    botFade.setColorAt(1.0, QColor(0, 0, 0, 230));
    p.fillRect(rect, botFade);
}

void CardFaceRenderer::drawGoldBorder(QPainter& p, QRect rect)
{
    int margin = static_cast<int>(rect.width() * 0.04);
    QRect borderRect = rect.adjusted(margin, margin, -margin, -margin);

    // Outer line
    p.setPen(QPen(QColor(201, 168, 76, 180), 1.2));
    p.setBrush(Qt::NoBrush);
    p.drawRoundedRect(borderRect, 8, 8);

    // Inner line
    QRect innerRect = borderRect.adjusted(3, 3, -3, -3);
    p.setPen(QPen(QColor(201, 168, 76, 120), 0.7));
    p.drawRoundedRect(innerRect, 6, 6);
}

void CardFaceRenderer::drawCornerOrnaments(QPainter& p, QRect rect)
{
    int margin = static_cast<int>(rect.width() * 0.04);
    p.setPen(Qt::NoPen);
    p.setBrush(QColor(201, 168, 76, 200));

    auto drawDiamond = [&](QPointF centre, float size) {
        QPainterPath path;
        path.moveTo(centre.x(),        centre.y() - size);
        path.lineTo(centre.x() + size, centre.y());
        path.lineTo(centre.x(),        centre.y() + size);
        path.lineTo(centre.x() - size, centre.y());
        path.closeSubpath();
        p.drawPath(path);
    };

    float d = 4.0f;
    float m = static_cast<float>(margin);
    float w = static_cast<float>(rect.width());
    float h = static_cast<float>(rect.height());
    drawDiamond({m,     m},     d);
    drawDiamond({w - m, m},     d);
    drawDiamond({m,     h - m}, d);
    drawDiamond({w - m, h - m}, d);
}

void CardFaceRenderer::drawTopText(QPainter& p, const QString& cardType, QRect rect)
{
    // Try Cinzel first, fall back to Liberation Serif
    QFont font(QStringLiteral("Cinzel"));
    if (!QFontDatabase::families().contains(QStringLiteral("Cinzel")))
        font = QFont(QStringLiteral("Liberation Serif"));

    font.setPixelSize(static_cast<int>(rect.width() * 0.055));
    font.setLetterSpacing(QFont::AbsoluteSpacing, 4.0);
    p.setFont(font);
    p.setPen(QColor(201, 168, 76, 230));

    QString display = QString("\u00B7 %1 \u00B7").arg(cardType);
    QRect textRect(0, static_cast<int>(rect.height() * 0.04),
                   rect.width(), static_cast<int>(rect.height() * 0.12));
    p.drawText(textRect, Qt::AlignHCenter | Qt::AlignVCenter, display);
}

void CardFaceRenderer::drawBottomText(QPainter& p, const QString& deityName,
                                       const QString& mantra, QRect rect)
{
    // Deity name
    QFont nameFont(QStringLiteral("Lora"));
    if (!QFontDatabase::families().contains(QStringLiteral("Lora")))
        nameFont = QFont(QStringLiteral("Liberation Serif"));
    nameFont.setPixelSize(static_cast<int>(rect.width() * 0.072));
    nameFont.setItalic(true);
    p.setFont(nameFont);
    p.setPen(QColor(215, 185, 100, 240));

    QRect nameRect(0, static_cast<int>(rect.height() * 0.76),
                   rect.width(), static_cast<int>(rect.height() * 0.12));
    p.drawText(nameRect, Qt::AlignHCenter | Qt::AlignVCenter, deityName);

    // Ornamental divider
    int cx   = rect.width() / 2;
    int divY = static_cast<int>(rect.height() * 0.875);
    p.setPen(QPen(QColor(201, 168, 76, 150), 0.8));
    p.drawLine(cx - 40, divY, cx + 40, divY);

    // Mantra
    QFont mantraFont(QStringLiteral("Lora"));
    if (!QFontDatabase::families().contains(QStringLiteral("Lora")))
        mantraFont = QFont(QStringLiteral("Liberation Serif"));
    mantraFont.setPixelSize(static_cast<int>(rect.width() * 0.042));
    mantraFont.setItalic(true);
    p.setFont(mantraFont);
    p.setPen(QColor(190, 155, 80, 200));

    QRect mantraRect(static_cast<int>(rect.width() * 0.1),
                     static_cast<int>(rect.height() * 0.88),
                     static_cast<int>(rect.width() * 0.8),
                     static_cast<int>(rect.height() * 0.10));
    p.drawText(mantraRect, Qt::AlignHCenter | Qt::AlignVCenter, mantra);
}

void CardFaceRenderer::drawOmPlaceholder(QPainter& p, QRect rect)
{
    // Card-back style placeholder: dark bg + Om glyph
    p.fillRect(rect, QColor(0x11, 0x0d, 0x10));

    // Inner border
    p.setPen(QPen(QColor(212, 175, 55, 40), 1));
    p.setBrush(Qt::NoBrush);
    p.drawRoundedRect(rect.adjusted(6, 6, -6, -6), 8, 8);

    // Om
    QFont f;
    f.setPixelSize(rect.width() / 4);
    p.setFont(f);
    p.setPen(QColor(212, 175, 55, 60));
    p.drawText(rect, Qt::AlignCenter, QString("\u0950"));
}
