#include "Card.h"

Card::Card(int id, const QString &cardType, const QString &arcana,
           const QString &uprightKeywords, const QString &reversedKeywords,
           const QString &name, const QString &notes,
           const QString &imagePath)
    : m_id(id)
    , m_cardType(cardType)
    , m_arcana(arcana)
    , m_uprightKeywords(uprightKeywords)
    , m_reversedKeywords(reversedKeywords)
    , m_name(name)
    , m_notes(notes)
    , m_imagePath(imagePath)
{
}

int Card::id() const { return m_id; }
QString Card::cardType() const { return m_cardType; }
QString Card::arcana() const { return m_arcana; }
QString Card::uprightKeywords() const { return m_uprightKeywords; }
QString Card::reversedKeywords() const { return m_reversedKeywords; }
QString Card::name() const { return m_name; }
QString Card::notes() const { return m_notes; }
QString Card::imagePath() const { return m_imagePath; }
bool Card::isReversed() const { return m_reversed; }
void Card::setReversed(bool reversed) { m_reversed = reversed; }
