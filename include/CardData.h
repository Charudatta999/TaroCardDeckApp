#pragma once
#include <QString>

struct CardData {
    int     id               = -1;
    QString cardType;         // e.g. "13. Death", "Ace of Swords"
    QString arcana;           // "Major Arcana", "Cups (Water)", etc.
    QString uprightKeywords;
    QString reversedKeywords;
    QString name;             // Hindu deity name
    QString notes;            // mantra / description
    QString imagePath;        // "cards/major/13_death.png" — empty = Om placeholder
    bool    isReversed        = false;
};
