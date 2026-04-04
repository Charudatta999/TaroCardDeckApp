#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include "ReadingEngine.h"
#include "CardModel.h"
#include <QObject>

class AppController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(ReadingEngine* readingEngine READ readingEngine CONSTANT)
    Q_PROPERTY(CardModel* catalogueModel READ catalogueModel CONSTANT)
    Q_PROPERTY(QString currentScreen READ currentScreen WRITE setCurrentScreen NOTIFY currentScreenChanged)

public:
    explicit AppController(QObject *parent = nullptr);

    ReadingEngine *readingEngine() const;
    CardModel *catalogueModel() const;
    QString currentScreen() const;
    void setCurrentScreen(const QString &screen);

    Q_INVOKABLE void initialize();
    Q_INVOKABLE void searchCatalogue(const QString &query);

signals:
    void currentScreenChanged();
    void initialized();

private:
    ReadingEngine *m_readingEngine = nullptr;
    CardModel *m_catalogueModel = nullptr;
    QString m_currentScreen = QStringLiteral("home");
};

#endif // APPCONTROLLER_H
