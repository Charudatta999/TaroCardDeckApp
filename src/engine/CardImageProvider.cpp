#include "CardImageProvider.h"
#include "CardFaceRenderer.h"
#include "CardManager.h"

CardImageProvider::CardImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Pixmap)
{
}

QPixmap CardImageProvider::requestPixmap(const QString& id,
                                          QSize* size,
                                          const QSize& requestedSize)
{
    QSize targetSize = requestedSize.isValid() ? requestedSize : QSize(420, 680);

    // "back" → card back design
    if (id == QStringLiteral("back")) {
        QPixmap px = CardFaceRenderer::renderCardBack(targetSize);
        if (size) *size = px.size();
        return px;
    }

    // numeric string → card id
    bool ok = false;
    int cardId = id.toInt(&ok);
    if (!ok) {
        // Unknown id — return a blank card back
        QPixmap px = CardFaceRenderer::renderCardBack(targetSize);
        if (size) *size = px.size();
        return px;
    }

    // Find card in manager
    const QVector<CardData> deck = CardManager::instance().getDeck();
    CardData card;
    bool found = false;
    for (const CardData& c : deck) {
        if (c.id == cardId) { card = c; found = true; break; }
    }

    QPixmap px = found
        ? CardFaceRenderer::renderCardFace(card, targetSize)
        : CardFaceRenderer::renderCardBack(targetSize);

    if (size) *size = px.size();
    return px;
}
