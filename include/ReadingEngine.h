#ifndef READINGENGINE_H
#define READINGENGINE_H

#include "Deck.h"
#include "Reading.h"
#include "CardModel.h"
#include <QObject>

class ReadingEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(CardModel* deckModel READ deckModel CONSTANT)
    Q_PROPERTY(CardModel* readingModel READ readingModel CONSTANT)
    Q_PROPERTY(bool isShuffled READ isShuffled NOTIFY shuffledChanged)
    Q_PROPERTY(int spreadType READ spreadType WRITE setSpreadType NOTIFY spreadTypeChanged)

public:
    explicit ReadingEngine(QObject *parent = nullptr);

    CardModel *deckModel() const;
    CardModel *readingModel() const;
    bool isShuffled() const;
    int spreadType() const;
    void setSpreadType(int type);

    Q_INVOKABLE void loadDeck(const QString &jsonPath);
    Q_INVOKABLE void shuffle();
    Q_INVOKABLE void selectCard(int index);
    Q_INVOKABLE void resetReading();

signals:
    void shuffledChanged();
    void spreadTypeChanged();
    void readingComplete();
    void cardSelected(int index);

private:
    Deck m_deck;
    Reading m_reading;
    CardModel *m_deckModel = nullptr;
    CardModel *m_readingModel = nullptr;
    bool m_isShuffled = false;
};

#endif // READINGENGINE_H
