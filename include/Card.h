#ifndef CARD_H
#define CARD_H

#include <QString>
#include <QObject>

class Card
{
    Q_GADGET
    Q_PROPERTY(int id MEMBER m_id)
    Q_PROPERTY(QString cardType MEMBER m_cardType)
    Q_PROPERTY(QString arcana MEMBER m_arcana)
    Q_PROPERTY(QString uprightKeywords MEMBER m_uprightKeywords)
    Q_PROPERTY(QString reversedKeywords MEMBER m_reversedKeywords)
    Q_PROPERTY(QString name MEMBER m_name)
    Q_PROPERTY(QString notes MEMBER m_notes)
    Q_PROPERTY(QString imagePath MEMBER m_imagePath)
    Q_PROPERTY(bool reversed MEMBER m_reversed)

public:
    Card() = default;
    Card(int id, const QString &cardType, const QString &arcana,
         const QString &uprightKeywords, const QString &reversedKeywords,
         const QString &name, const QString &notes,
         const QString &imagePath);

    int id() const;
    QString cardType() const;
    QString arcana() const;
    QString uprightKeywords() const;
    QString reversedKeywords() const;
    QString name() const;
    QString notes() const;
    QString imagePath() const;
    bool isReversed() const;
    void setReversed(bool reversed);

private:
    int m_id = -1;
    QString m_cardType;
    QString m_arcana;
    QString m_uprightKeywords;
    QString m_reversedKeywords;
    QString m_name;
    QString m_notes;
    QString m_imagePath;
    bool m_reversed = false;
};

Q_DECLARE_METATYPE(Card)

#endif // CARD_H
