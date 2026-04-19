#pragma once
#include <QQuickImageProvider>

// Registered as "cardface" — QML uses:
//   image://cardface/<id>          → card front face
//   image://cardback/any           → card back
//
// Example:
//   Image { source: "image://cardface/13" }
class CardImageProvider : public QQuickImageProvider
{
public:
    CardImageProvider();

    QPixmap requestPixmap(const QString& id,
                          QSize* size,
                          const QSize& requestedSize) override;
};
