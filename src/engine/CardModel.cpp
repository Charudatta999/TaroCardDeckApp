#include "CardModel.h"

CardModel::CardModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int CardModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_cards.size();
}

QVariant CardModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_cards.size())
        return QVariant();

    const Card &card = m_cards.at(index.row());
    switch (role) {
    case IdRole:               return card.id();
    case CardTypeRole:         return card.cardType();
    case ArcanaRole:           return card.arcana();
    case UprightKeywordsRole:  return card.uprightKeywords();
    case ReversedKeywordsRole: return card.reversedKeywords();
    case NameRole:             return card.name();
    case NotesRole:            return card.notes();
    case ImagePathRole:        return card.imagePath();
    case IsReversedRole:       return card.isReversed();
    }
    return QVariant();
}

QHash<int, QByteArray> CardModel::roleNames() const
{
    return {
        {IdRole,               "cardId"},
        {CardTypeRole,         "cardType"},
        {ArcanaRole,           "arcana"},
        {UprightKeywordsRole,  "uprightKeywords"},
        {ReversedKeywordsRole, "reversedKeywords"},
        {NameRole,             "name"},
        {NotesRole,            "notes"},
        {ImagePathRole,        "imagePath"},
        {IsReversedRole,       "isReversed"}
    };
}

void CardModel::setCards(const QVector<Card> &cards)
{
    beginResetModel();
    m_cards = cards;
    endResetModel();
    emit countChanged();
}

void CardModel::addCard(const Card &card)
{
    beginInsertRows(QModelIndex(), m_cards.size(), m_cards.size());
    m_cards.append(card);
    endInsertRows();
    emit countChanged();
}

void CardModel::clear()
{
    beginResetModel();
    m_cards.clear();
    endResetModel();
    emit countChanged();
}
