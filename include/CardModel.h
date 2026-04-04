#ifndef CARDMODEL_H
#define CARDMODEL_H

#include "Card.h"
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

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setCards(const QVector<Card> &cards);
    void addCard(const Card &card);
    void clear();

signals:
    void countChanged();

private:
    QVector<Card> m_cards;
};

#endif // CARDMODEL_H
