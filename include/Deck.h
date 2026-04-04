#ifndef DECK_H
#define DECK_H

#include "Card.h"
#include <QVector>

class Deck
{
public:
    Deck() = default;

    bool loadFromJson(const QString &filePath);
    void shuffle();
    void reset();
    Card drawCard();
    QVector<Card> drawCards(int count);
    int remainingCards() const;
    const QVector<Card> &allCards() const;

private:
    QVector<Card> m_cards;
    QVector<Card> m_drawPile;
};

#endif // DECK_H
