#pragma once
#include "CardData.h"
#include <QObject>
#include <QVector>

class CardManager : public QObject
{
    Q_OBJECT
public:
    static CardManager& instance();

    bool              loadFromJson(const QString& path);
    QVector<CardData> getDeck()          const;
    int               deckSize()         const;
    CardData          cardAt(int index)  const;

    void              shuffle();
    bool              selectCard(int deckIndex);   // returns false if already 3 selected
    void              deselectCard(int deckIndex);
    bool              isSelected(int deckIndex)    const;
    QVector<CardData> getSelectedCards()           const;
    QVector<int>      getSelectedIndices()         const;
    void              clearSelection();

signals:
    void deckLoaded(int count);
    void cardSelected(int slotIndex, const CardData& card);
    void cardDeselected(int deckIndex);
    void selectionComplete();           // emitted when 3rd card selected
    void selectionChanged();

private:
    explicit CardManager(QObject* parent = nullptr);

    QVector<CardData> m_deck;
    QVector<int>      m_selectedIndices;  // up to 3 deckIndex values
};
