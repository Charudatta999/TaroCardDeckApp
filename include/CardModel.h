#ifndef CARDMODEL_H
#define CARDMODEL_H

#include "CardData.h"
#include <QAbstractListModel>

class CardModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum CardRoles {
        IdRole = Qt::UserRole + 1,
        CardTypeRole,
        ArcanaRole,
        UprightKeywordsRole,
        ReversedKeywordsRole,
        NameRole,
        NotesRole,
        ImagePathRole,
        IsReversedRole
    };

    explicit CardModel(QObject *parent = nullptr);

    int     rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // JS-friendly accessor: returns the row at `index` as a map of role-name -> value.
    // Returns an empty map if index is out of range.
    Q_INVOKABLE QVariantMap get(int row) const;

    void setCards(const QVector<CardData> &cards);
    void addCard(const CardData &card);
    void clear();

signals:
    void countChanged();

private:
    QVector<CardData> m_cards;
};

#endif // CARDMODEL_H
