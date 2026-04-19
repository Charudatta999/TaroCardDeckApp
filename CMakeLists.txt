cmake_minimum_required(VERSION 3.21)
project(TaroCardDeckApp VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickControls2 QuickLayouts Multimedia)
qt_standard_project_setup()

set(QT_ANDROID_TARGET_SDK_VERSION 36)
set(QT_ANDROID_COMPILE_SDK_VERSION 36)

file(GLOB_RECURSE CARD_ASSET_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    assets/cards/*
)

# ---- C++ Sources ----
set(CPP_SOURCES
    # Headers
    include/CardData.h
    include/CardModel.h
    include/CardManager.h
    include/ReadingEngine.h
    include/AppController.h
    include/SymbolWatermarkRenderer.h
    include/CardFaceRenderer.h
    include/CardImageProvider.h
    include/Haptics.h

    # Models
    src/models/Card.cpp
    src/models/Deck.cpp
    src/models/Reading.cpp

    # Engine
    src/engine/CardModel.cpp
    src/engine/CardManager.cpp
    src/engine/ReadingEngine.cpp
    src/engine/AppController.cpp
    src/engine/SymbolWatermarkRenderer.cpp
    src/engine/CardFaceRenderer.cpp
    src/engine/CardImageProvider.cpp
    src/engine/Haptics.cpp
)

qt_add_executable(TaroCardDeckApp
    main.cpp
    ${CPP_SOURCES}
)

# ---- QML Module ----
qt_add_qml_module(TaroCardDeckApp
    URI TaroCardDeck
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/screens/HomeScreen.qml
        qml/screens/DrawScreen.qml
        qml/screens/SpreadScreen.qml
        qml/screens/CatalogueScreen.qml
        qml/components/CardView.qml
        qml/components/CardBack.qml
        qml/components/NamePanel.qml
        qml/components/WatermarkBackground.qml
        qml/components/FanCardBack.qml
        qml/components/ReadingCard.qml
    RESOURCE_PREFIX /qt/qml
)

# ---- Assets ----
qt_add_resources(TaroCardDeckApp "app_resources"
    PREFIX "/"
    FILES
        data/cards_data.json
        assets/sounds/mixkit-revolver-chamber-spin-1674.wav
        ${CARD_ASSET_FILES}
)

target_include_directories(TaroCardDeckApp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(TaroCardDeckApp PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::QuickLayouts
    Qt6::Multimedia
)

set_target_properties(TaroCardDeckApp PROPERTIES
    QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
)
