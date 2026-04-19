#ifndef DECK_H
#define DECK_H

#include "CardData.h"
#include <QVector>

class Deck
{
public:
    Deck() = default;

    bool loadFromJson(const QString &filePath);
    void shuffle();
    void reset();
    CardData drawCard();
    QVector<CardData> drawCards(int count);
    int remainingCards() const;
    const QVector<CardData> &allCards() const;

private:
    QVector<CardData> m_cards;
    QVector<CardData> m_drawPile;
};

#endif // DECK_H
