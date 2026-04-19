#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include "ReadingEngine.h"
#include "CardModel.h"
#include <QObject>
#include <QVariantList>

class AppController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(ReadingEngine* readingEngine   READ readingEngine   CONSTANT)
    Q_PROPERTY(CardModel*     catalogueModel  READ catalogueModel  CONSTANT)
    Q_PROPERTY(QString currentScreen READ currentScreen WRITE setCurrentScreen NOTIFY currentScreenChanged)

public:
    explicit AppController(QObject *parent = nullptr);

    ReadingEngine *readingEngine()  const;
    CardModel     *catalogueModel() const;
    QString        currentScreen()  const;
    void           setCurrentScreen(const QString &screen);

    // Called from QML on app start
    Q_INVOKABLE void initialize();

    // Search/filter catalogue
    Q_INVOKABLE void searchCatalogue(const QString &query);
    Q_INVOKABLE void filterCatalogue(const QString &query, const QString &filter);

    // Get card data by deck index — returns a JS object to QML
    Q_INVOKABLE QVariantMap cardAt(int deckIndex) const;

    // Total cards loaded
    Q_INVOKABLE int deckSize() const;

signals:
    void currentScreenChanged();
    void initialized(int cardCount);

private:
    ReadingEngine *m_readingEngine   = nullptr;
    CardModel     *m_catalogueModel  = nullptr;
    QString        m_currentScreen   = QStringLiteral("home");

    // Full deck copy for searching (catalogue model may be filtered)
    QVector<CardData> m_fullDeck;
};

#endif // APPCONTROLLER_H
