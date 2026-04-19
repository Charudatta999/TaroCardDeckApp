#include "CardManager.h"
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRandomGenerator>

CardManager& CardManager::instance()
{
    static CardManager inst;
    return inst;
}

CardManager::CardManager(QObject* parent) : QObject(parent) {}

bool CardManager::loadFromJson(const QString& path)
{
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly)) {
        qWarning("CardManager: cannot open '%s'", qPrintable(path));
        return false;
    }

    QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    if (!doc.isArray()) {
        qWarning("CardManager: JSON root is not an array");
        return false;
    }

    m_deck.clear();
    m_selectedIndices.clear();

    for (const QJsonValue& val : doc.array()) {
        QJsonObject obj = val.toObject();
        CardData c;
        c.id               = obj[QStringLiteral("id")].toInt();
        c.cardType         = obj[QStringLiteral("cardType")].toString();
        c.arcana           = obj[QStringLiteral("arcana")].toString();
        c.uprightKeywords  = obj[QStringLiteral("uprightKeywords")].toString();
        c.reversedKeywords = obj[QStringLiteral("reversedKeywords")].toString();
        c.name             = obj[QStringLiteral("name")].toString();
        c.notes            = obj[QStringLiteral("notes")].toString();
        c.imagePath        = obj[QStringLiteral("imagePath")].toString();
        m_deck.append(c);
    }

    qWarning("CardManager: loaded %lld cards from %s", static_cast<long long>(m_deck.size()), qPrintable(path));
    emit deckLoaded(m_deck.size());
    return true;
}

QVector<CardData> CardManager::getDeck() const
{
    return m_deck;
}

int CardManager::deckSize() const
{
    return m_deck.size();
}

CardData CardManager::cardAt(int index) const
{
    if (index < 0 || index >= m_deck.size()) return {};
    return m_deck.at(index);
}

void CardManager::shuffle()
{
    // Fisher-Yates
    for (int i = m_deck.size() - 1; i > 0; --i) {
        int j = static_cast<int>(QRandomGenerator::global()->bounded(i + 1));
        m_deck.swapItemsAt(i, j);
    }
    clearSelection();
}

bool CardManager::selectCard(int deckIndex)
{
    if (deckIndex < 0 || deckIndex >= m_deck.size()) return false;
    if (m_selectedIndices.size() >= 3) return false;
    if (m_selectedIndices.contains(deckIndex)) return false;

    m_selectedIndices.append(deckIndex);
    int slotIndex = m_selectedIndices.size() - 1;
    emit cardSelected(slotIndex, m_deck.at(deckIndex));
    emit selectionChanged();
    if (m_selectedIndices.size() == 3) emit selectionComplete();
    return true;
}

void CardManager::deselectCard(int deckIndex)
{
    if (!m_selectedIndices.removeOne(deckIndex)) return;
    emit cardDeselected(deckIndex);
    emit selectionChanged();
}

bool CardManager::isSelected(int deckIndex) const
{
    return m_selectedIndices.contains(deckIndex);
}

QVector<CardData> CardManager::getSelectedCards() const
{
    QVector<CardData> result;
    result.reserve(m_selectedIndices.size());
    for (int idx : m_selectedIndices)
        result.append(m_deck.at(idx));
    return result;
}

QVector<int> CardManager::getSelectedIndices() const
{
    return m_selectedIndices;
}

void CardManager::clearSelection()
{
    m_selectedIndices.clear();
    emit selectionChanged();
}
