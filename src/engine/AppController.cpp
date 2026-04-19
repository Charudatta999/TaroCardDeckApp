#include "AppController.h"
#include "CardManager.h"

AppController::AppController(QObject *parent)
    : QObject(parent)
    , m_readingEngine(new ReadingEngine(this))
    , m_catalogueModel(new CardModel(this))
{
}

ReadingEngine *AppController::readingEngine()  const { return m_readingEngine; }
CardModel     *AppController::catalogueModel() const { return m_catalogueModel; }
QString        AppController::currentScreen()  const { return m_currentScreen; }

void AppController::setCurrentScreen(const QString &screen)
{
    if (m_currentScreen != screen) {
        m_currentScreen = screen;
        emit currentScreenChanged();
    }
}

void AppController::initialize()
{
    // Load JSON via CardManager singleton
    bool ok = CardManager::instance().loadFromJson(QStringLiteral(":/data/cards_data.json"));
    if (!ok) {
        qWarning("AppController: failed to load cards_data.json");
        emit initialized(0);
        return;
    }

    m_fullDeck = CardManager::instance().getDeck();

    // Populate catalogue model with all cards
    m_catalogueModel->setCards(m_fullDeck);

    int count = m_fullDeck.size();
    qWarning("AppController: initialized with %d cards", count);
    emit initialized(count);
}

void AppController::searchCatalogue(const QString &query)
{
    filterCatalogue(query, QStringLiteral("ALL"));
}

void AppController::filterCatalogue(const QString &query, const QString &filter)
{
    const QString q = query.trimmed().toLower();
    const QString f = filter.trimmed().toUpper();

    QVector<CardData> filtered;
    filtered.reserve(m_fullDeck.size());

    for (const CardData &c : m_fullDeck) {
        const QString arcana = c.arcana.toLower();
        const bool matchesQuery = q.isEmpty()
            || c.cardType.toLower().contains(q)
            || c.name.toLower().contains(q)
            || arcana.contains(q)
            || c.uprightKeywords.toLower().contains(q)
            || c.reversedKeywords.toLower().contains(q);

        bool matchesFilter = true;
        if (f == QStringLiteral("MAJOR")) {
            matchesFilter = arcana.contains(QStringLiteral("major"));
        } else if (f != QStringLiteral("ALL") && !f.isEmpty()) {
            matchesFilter = arcana.contains(f.toLower());
        }

        if (matchesQuery && matchesFilter)
            filtered.append(c);
    }

    m_catalogueModel->setCards(filtered);
}

QVariantMap AppController::cardAt(int deckIndex) const
{
    CardData c = CardManager::instance().cardAt(deckIndex);
    return {
        {QStringLiteral("cardId"),          c.id},
        {QStringLiteral("cardType"),         c.cardType},
        {QStringLiteral("arcana"),           c.arcana},
        {QStringLiteral("uprightKeywords"),  c.uprightKeywords},
        {QStringLiteral("reversedKeywords"), c.reversedKeywords},
        {QStringLiteral("name"),             c.name},
        {QStringLiteral("notes"),            c.notes},
        {QStringLiteral("imagePath"),        c.imagePath},
        {QStringLiteral("isReversed"),       c.isReversed}
    };
}

int AppController::deckSize() const
{
    return CardManager::instance().deckSize();
}
