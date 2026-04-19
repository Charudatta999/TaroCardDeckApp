#include "Reading.h"

Reading::Reading(SpreadType type)
    : m_spreadType(type)
{
}

void Reading::addCard(const CardData &card)
{
    if (!isComplete())
        m_cards.append(card);
}

void Reading::clear()
{
    m_cards.clear();
}

Reading::SpreadType Reading::spreadType() const { return m_spreadType; }
const QVector<CardData> &Reading::cards() const { return m_cards; }

int Reading::maxCards() const
{
    switch (m_spreadType) {
    case SingleCard:   return 1;
    case ThreeCard:    return 3;
    case CelticCross:  return 10;
    }
    return 1;
}

bool Reading::isComplete() const
{
    return m_cards.size() >= maxCards();
}
