#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCoreApplication>
#include <QDebug>
#include <QFontDatabase>
#include <QQmlError>

#include "AppController.h"
#include "CardImageProvider.h"
#include "Haptics.h"

int main(int argc, char *argv[])
{
    qWarning() << "TaroApp: ============================================";
    qWarning() << "TaroApp: [main] entering main()";
    qWarning() << "TaroApp: ============================================";

    QGuiApplication app(argc, argv);
    qWarning() << "TaroApp: [main] QGuiApplication constructed";

    QCoreApplication::setApplicationName("TaroCardDeckApp");
    QCoreApplication::setOrganizationName("cjadhav");

    // ---- Load custom fonts (bundled in assets) ----
    int fId1 = QFontDatabase::addApplicationFont(":/assets/fonts/Cinzel-Regular.ttf");
    int fId2 = QFontDatabase::addApplicationFont(":/assets/fonts/Lora-Italic.ttf");
    qWarning() << "TaroApp: [main] fonts loaded: Cinzel id=" << fId1 << "Lora id=" << fId2;

    QQmlApplicationEngine engine;
    qWarning() << "TaroApp: [main] QQmlApplicationEngine constructed";

    // CRITICAL: Ensure QML module path is visible (Android fix)
    engine.addImportPath("qrc:/qt/qml");
    qWarning() << "TaroApp: [main] import paths:" << engine.importPathList();

    // ---- Register image providers ----
    // QML usage: Image { source: "image://cardface/13" }
    // QML usage: Image { source: "image://cardface/back" }
    engine.addImageProvider(QStringLiteral("cardface"), new CardImageProvider());
    qWarning() << "TaroApp: [main] image provider 'cardface' registered";

    // ---- Capture QML warnings ----
    QObject::connect(&engine, &QQmlEngine::warnings,
                     [](const QList<QQmlError> &warnings) {
                         qWarning() << "TaroApp: ==== QML WARNINGS ====";
                         for (const auto &w : warnings)
                             qWarning() << "TaroApp: QML WARN:" << w.toString();
                         qWarning() << "TaroApp: ==== END QML WARNINGS ====";
                     });

    // ---- Controller ----
    AppController controller;
    qWarning() << "TaroApp: [main] AppController constructed";
    engine.rootContext()->setContextProperty("appController", &controller);
    qWarning() << "TaroApp: [main] appController context property set";

    // ---- Haptics helper ----
    Haptics haptics;
    engine.rootContext()->setContextProperty("haptics", &haptics);
    qWarning() << "TaroApp: [main] haptics context property set (available=" << haptics.available() << ")";

    qWarning() << "TaroApp: [main] Engine created, loading module...";

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [](const QUrl &url) {
                         qWarning() << "TaroApp: FATAL - QML objectCreationFailed for" << url;
                     }, Qt::QueuedConnection);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [](QObject *obj, const QUrl &url) {
                         if (obj)
                             qWarning() << "TaroApp: objectCreated OK for" << url;
                         else
                             qWarning() << "TaroApp: objectCreated NULL for" << url << "— parse/compile failed";
                     }, Qt::QueuedConnection);

    // ---- Load QML module ----
    qWarning() << "TaroApp: [main] calling engine.loadFromModule('TaroCardDeck', 'Main')...";
    engine.loadFromModule("TaroCardDeck", "Main");

    qWarning() << "TaroApp: [main] loadFromModule returned; rootObjects count =" << engine.rootObjects().size();

    if (engine.rootObjects().isEmpty()) {
        qWarning() << "TaroApp: ROOT OBJECT EMPTY - exiting";
        qWarning() << "TaroApp: ============================================";
        qWarning() << "TaroApp: Likely cause: QML parse error in Main.qml or";
        qWarning() << "TaroApp: one of its inline Component {} children.";
        qWarning() << "TaroApp: Scroll up for 'QML WARN:' lines for details.";
        qWarning() << "TaroApp: ============================================";
        return -1;
    }

    qWarning() << "TaroApp: [main] root object created successfully; entering event loop";
    // Note: controller.initialize() is called from Main.qml Component.onCompleted

    return app.exec();
}
