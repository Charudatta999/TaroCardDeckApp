#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCoreApplication>
#include <QDebug>
#include <QQmlError>

#include "AppController.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QCoreApplication::setApplicationName("TaroCardDeckApp");
    QCoreApplication::setOrganizationName("cjadhav");

    QQmlApplicationEngine engine;
    qWarning() << "Import paths:";
    for (auto &p : engine.importPathList())
        qWarning() << p;
    // 🔥 CRITICAL: Ensure QML module path is visible (Android fix)
    engine.addImportPath("qrc:/qt/qml");

    // ---- Debug: print import paths ----
    qWarning() << "==== QML Import Paths ====";
    for (const auto &p : engine.importPathList())
        qWarning() << p;

    // ---- Capture QML warnings ----
    QObject::connect(&engine, &QQmlEngine::warnings,
                     [](const QList<QQmlError> &warnings) {
                         qWarning() << "==== QML WARNINGS ====";
                         for (const auto &w : warnings)
                             qWarning() << w.toString();
                     });

    // ---- Controller ----
    AppController controller;
    engine.rootContext()->setContextProperty("appController", &controller);

    qWarning() << "TaroApp: Engine created, loading module...";

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() {
                         qWarning() << "TaroApp: FATAL - QML root not created!";
                     }, Qt::QueuedConnection);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [](QObject *obj, const QUrl &url) {
                         if (obj)
                             qWarning() << "TaroApp: objectCreated OK for" << url;
                         else
                             qWarning() << "TaroApp: objectCreated NULL for" << url;
                     }, Qt::QueuedConnection);

    // ---- Load QML module (correct for qt_add_qml_module) ----
    engine.loadFromModule("TaroCardDeck", "Main");

    qWarning() << "TaroApp: loadFromModule called";

    if (engine.rootObjects().isEmpty()) {
        qWarning() << "TaroApp: ROOT OBJECT EMPTY — exiting";
        return -1;
    }

    controller.initialize();

    return app.exec();
}