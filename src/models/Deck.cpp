#include "Deck.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QRandomGenerator>

bool Deck::loadFromJson(const QString &filePath)
{
    Q_UNUSED(filePath)
    return false;
}

void Deck::shuffle()
{
    m_drawPile = m_cards;
    auto *rng = QRandomGenerator::global();
    for (int i = m_drawPile.size() - 1; i > 0; --i) {
        int j = rng->bounded(i + 1);
        m_drawPile.swapItemsAt(i, j);
    }
}

void Deck::reset()
{
    m_drawPile = m_cards;
}

CardData Deck::drawCard()
{
    if (m_drawPile.isEmpty())
        return CardData();
    return m_drawPile.takeLast();
}

QVector<CardData> Deck::drawCards(int count)
{
    QVector<CardData> drawn;
    for (int i = 0; i < count && !m_drawPile.isEmpty(); ++i)
        drawn.append(drawCard());
    return drawn;
}

int Deck::remainingCards() const { return m_drawPile.size(); }
const QVector<CardData> &Deck::allCards() const { return m_cards; }
