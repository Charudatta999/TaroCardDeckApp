#ifndef READING_H
#define READING_H

#include "Card.h"
#include <QVector>
#include <QString>

class Reading
{
public:
    enum SpreadType {
        SingleCard,
        ThreeCard,
        CelticCross
    };

    Reading() = default;
    Reading(SpreadType type);

    void addCard(const Card &card);
    void clear();
    SpreadType spreadType() const;
    const QVector<Card> &cards() const;
    int maxCards() const;
    bool isComplete() const;

private:
    SpreadType m_spreadType = SingleCard;
    QVector<Card> m_cards;
};

#endif // READING_H
