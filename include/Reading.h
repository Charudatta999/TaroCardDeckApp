#ifndef READING_H
#define READING_H

#include "CardData.h"
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

    void addCard(const CardData &card);
    void clear();
    SpreadType spreadType() const;
    const QVector<CardData> &cards() const;
    int maxCards() const;
    bool isComplete() const;

private:
    SpreadType m_spreadType = SingleCard;
    QVector<CardData> m_cards;
};

#endif // READING_H
