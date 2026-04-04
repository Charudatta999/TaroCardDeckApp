#include "ReadingEngine.h"

ReadingEngine::ReadingEngine(QObject *parent)
    : QObject(parent)
    , m_deckModel(new CardModel(this))
    , m_readingModel(new CardModel(this))
{
}

CardModel *ReadingEngine::deckModel() const { return m_deckModel; }
CardModel *ReadingEngine::readingModel() const { return m_readingModel; }
bool ReadingEngine::isShuffled() const { return m_isShuffled; }

int ReadingEngine::spreadType() const { return static_cast<int>(m_reading.spreadType()); }

void ReadingEngine::setSpreadType(int type)
{
    m_reading = Reading(static_cast<Reading::SpreadType>(type));
    emit spreadTypeChanged();
}

void ReadingEngine::loadDeck(const QString &jsonPath)
{
    // TODO: implement
    Q_UNUSED(jsonPath)
}

void ReadingEngine::shuffle()
{
    m_deck.shuffle();
    m_isShuffled = true;
    m_deckModel->setCards(m_deck.allCards());
    emit shuffledChanged();
}

void ReadingEngine::selectCard(int index)
{
    // TODO: implement card selection logic
    Q_UNUSED(index)
}

void ReadingEngine::resetReading()
{
    m_reading.clear();
    m_readingModel->clear();
    m_deck.reset();
    m_isShuffled = false;
    m_deckModel->setCards(m_deck.allCards());
    emit shuffledChanged();
}
