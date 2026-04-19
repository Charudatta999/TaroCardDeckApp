#pragma once
#include "CardData.h"
#include "SymbolWatermarkRenderer.h"
#include <QPixmap>
#include <QSize>

class CardFaceRenderer
{
public:
    // Produce a fully composited card-face pixmap.
    // If the deity image is missing, renders the Om placeholder card back.
    static QPixmap renderCardFace(const CardData& card,
                                  QSize size = {420, 680});

    // Render the card back (Om + symbol watermark, no text)
    static QPixmap renderCardBack(QSize size = {420, 680});

private:
    static void drawDeityImage       (QPainter& p, const QPixmap& art, QRect rect);
    static void drawGradientOverlays (QPainter& p, QRect rect);
    static void drawGoldBorder       (QPainter& p, QRect rect);
    static void drawCornerOrnaments  (QPainter& p, QRect rect);
    static void drawTopText          (QPainter& p, const QString& cardType, QRect rect);
    static void drawBottomText       (QPainter& p, const QString& deityName,
                                      const QString& mantra, QRect rect);
    static void drawOmPlaceholder    (QPainter& p, QRect rect);
};
