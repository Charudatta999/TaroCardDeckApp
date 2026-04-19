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

    const CardData &c = m_cards.at(index.row());
    switch (role) {
    case IdRole:               return c.id;
    case CardTypeRole:         return c.cardType;
    case ArcanaRole:           return c.arcana;
    case UprightKeywordsRole:  return c.uprightKeywords;
    case ReversedKeywordsRole: return c.reversedKeywords;
    case NameRole:             return c.name;
    case NotesRole:            return c.notes;
    case ImagePathRole:        return c.imagePath;
    case IsReversedRole:       return c.isReversed;
    default: break;
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

QVariantMap CardModel::get(int row) const
{
    QVariantMap map;
    if (row < 0 || row >= m_cards.size())
        return map;

    const CardData &c = m_cards.at(row);
    map.insert("cardId",           c.id);
    map.insert("cardType",         c.cardType);
    map.insert("arcana",           c.arcana);
    map.insert("uprightKeywords",  c.uprightKeywords);
    map.insert("reversedKeywords", c.reversedKeywords);
    map.insert("name",             c.name);
    map.insert("notes",            c.notes);
    map.insert("imagePath",        c.imagePath);
    map.insert("isReversed",       c.isReversed);
    return map;
}

void CardModel::setCards(const QVector<CardData> &cards)
{
    beginResetModel();
    m_cards = cards;
    endResetModel();
    emit countChanged();
}

void CardModel::addCard(const CardData &card)
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
