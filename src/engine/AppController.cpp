#include "AppController.h"

AppController::AppController(QObject *parent)
    : QObject(parent)
    , m_readingEngine(new ReadingEngine(this))
    , m_catalogueModel(new CardModel(this))
{
}

ReadingEngine *AppController::readingEngine() const { return m_readingEngine; }
CardModel *AppController::catalogueModel() const { return m_catalogueModel; }
QString AppController::currentScreen() const { return m_currentScreen; }

void AppController::setCurrentScreen(const QString &screen)
{
    if (m_currentScreen != screen) {
        m_currentScreen = screen;
        emit currentScreenChanged();
    }
}

void AppController::initialize()
{
    // TODO: load deck from JSON, populate catalogue
    emit initialized();
}

void AppController::searchCatalogue(const QString &query)
{
    // TODO: filter catalogue model by query
    Q_UNUSED(query)
}
