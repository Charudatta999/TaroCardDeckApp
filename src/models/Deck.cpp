#include "Deck.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QRandomGenerator>
#include <algorithm>

bool Deck::loadFromJson(const QString &filePath)
{
    // TODO: implement JSON loading
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

Card Deck::drawCard()
{
    if (m_drawPile.isEmpty())
        return Card();
    return m_drawPile.takeLast();
}

QVector<Card> Deck::drawCards(int count)
{
    QVector<Card> drawn;
    for (int i = 0; i < count && !m_drawPile.isEmpty(); ++i)
        drawn.append(drawCard());
    return drawn;
}

int Deck::remainingCards() const { return m_drawPile.size(); }
const QVector<Card> &Deck::allCards() const { return m_cards; }
