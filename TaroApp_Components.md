# TaroCardDeckApp — Qt6 Component Reference

## QML Modules & Import Rules

| Module | Import Statement | Android .so Required |
|--------|-----------------|----------------------|
| QtQuick (core) | `import QtQuick` | `libQt6Quick_arm64-v8a.so` ✅ always deployed |
| QtQuick.Controls | `import QtQuick.Controls` | `libQt6QuickControls2_arm64-v8a.so` ✅ |
| QtQuick.Layouts | `import QtQuick.Layouts` | `libQt6QuickLayouts_arm64-v8a.so` ⚠️ must explicitly link `Qt6::QuickLayouts` in CMakeLists |

> **Rule:** Every `import X.Y` causes Qt to load the corresponding `.so` at runtime on Android.  
> If the `.so` is not bundled in the APK, the entire QML engine fails with  
> `QQmlApplicationEngine failed to load component` — blank screen, no other errors.

---

## QML Types Used in This App

### ApplicationWindow
```
import QtQuick.Controls
```
- Root window type for Controls-based apps
- Has `contentItem` area (below header, above footer)
- Use `visible: true`, `width`, `height`, `color` for setup
- Direct children go into `contentItem`
- **Do NOT put `Drawer` outside `ApplicationWindow`** — it is a Popup and must live inside the window

### StackView
```
import QtQuick.Controls
```
- `initialItem`: Component, URL, or Item instantiated on creation
- `replace(item, properties)` — swaps current screen, passes property dict to new item
- `push(item)` / `pop()` — for navigating back
- Transitions: `pushEnter`, `pushExit`, `replaceEnter`, `replaceExit`
- Items inside StackView receive attached property `StackView.status`

### Drawer
```
import QtQuick.Controls
```
- Inherits from **Popup** — must be direct child of ApplicationWindow or Page
- `edge`: `Qt.LeftEdge` (default), `Qt.RightEdge`, `Qt.TopEdge`, `Qt.BottomEdge`
- `width`, `height` — set explicitly; `height: parent.height` for full-height side drawer
- `open()` / `close()` — programmatic control
- `background`: custom Rectangle for styling
- ⚠️ **Android top/bottom edge drawers conflict with system UI** — use LeftEdge only

### Column / Row (core QtQuick — no Layouts import needed)
```
import QtQuick   ← already available
```
- `Column` — stacks children vertically, `spacing` between them
- `Row` — places children horizontally, `spacing` between them
- Children use `anchors.horizontalCenter: parent.horizontalCenter` to center within Column
- **Prefer Column/Row over ColumnLayout/RowLayout** for Android to avoid QtQuick.Layouts dependency

### ListView
```
import QtQuick
```
- `model`: any QAbstractListModel*, integer, or JS array
- `delegate`: Component — each item gets model role data as properties
- `clip: true` — must be set to prevent drawing outside bounds
- Roles from C++ model accessible as `model.roleName` in delegate
- `ListView.count` — number of items

### Text / Rectangle / Item / MouseArea / Repeater
```
import QtQuick   ← all from core QtQuick
```
- **Text** not **Label** when you don't need Controls styling — avoids implicit Controls dependency
- `Repeater { model: N; delegate: ... }` — creates N instances of delegate

---

## C++ Classes

### Card (Q_GADGET value type)
- Value type — **not** a QObject, use `Q_GADGET`
- Properties exposed via `Q_PROPERTY(type name MEMBER m_field)`
- `Q_DECLARE_METATYPE(Card)` at bottom of header
- QML roles accessed via `CardModel::roleNames()` return value

| Field | Type | QML Role Name |
|-------|------|---------------|
| m_id | int | `cardId` |
| m_cardType | QString | `cardType` |
| m_arcana | QString | `arcana` |
| m_uprightKeywords | QString | `uprightKeywords` |
| m_reversedKeywords | QString | `reversedKeywords` |
| m_name | QString | `name` (deity) |
| m_notes | QString | `notes` |
| m_imagePath | QString | `imagePath` |
| m_reversed | bool | `isReversed` |

### CardModel (QAbstractListModel)
- Subclass `QAbstractListModel`, use `Q_OBJECT` macro
- Must implement: `rowCount()`, `data()`, `roleNames()`
- `setCards(QVector<Card>)` — bulk replace, calls `beginResetModel()`/`endResetModel()`
- Exposed to QML as context property: `engine.rootContext()->setContextProperty("appController", &controller)`
- In QML ListView: `model: appController.catalogueModel`

### AppController (QObject — the QML bridge)
- Registered as context property `"appController"`
- `Q_INVOKABLE` methods callable from QML
- `Q_PROPERTY` with `NOTIFY` signal for binding

| Property / Method | QML Access |
|---|---|
| `catalogueModel` (CardModel*) | `appController.catalogueModel` |
| `readingEngine` (ReadingEngine*) | `appController.readingEngine` |
| `initialize()` | `appController.initialize()` |
| `searchCatalogue(query)` | `appController.searchCatalogue(text)` |

### ReadingEngine (QObject)
- Accessed via `appController.readingEngine`
- `Q_INVOKABLE void shuffle()` — randomises deck
- `Q_INVOKABLE void selectCard(int index)` — picks card for reading
- `Q_INVOKABLE void resetReading()` — clears current reading

---

## CMakeLists.txt Required Setup

```cmake
find_package(Qt6 REQUIRED COMPONENTS
    Core Gui Quick QuickControls2 QuickLayouts)

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
)

target_link_libraries(TaroCardDeckApp PRIVATE
    Qt6::Core Qt6::Gui Qt6::Quick Qt6::QuickControls2 Qt6::QuickLayouts)
```

**Rules for `qt_add_qml_module`:**
- All QML files in the same module share the URI namespace — no `import TaroCardDeck` needed inside those files (causes circular import crash)
- Adding a new `.qml` file requires re-running CMake configure, not just build
- Generated `qmldir` lives in `build-android/TaroCardDeck/qmldir`
- QML files are embedded at resource path `:/TaroCardDeck/qml/...`

---

## QML Module Rules (critical for Android)

1. **Never** `import TaroCardDeck` inside any `.qml` file that is itself part of `TaroCardDeck` — circular import → crash
2. **Only** `import QtQuick` and `import QtQuick.Controls` are safe without extra CMake setup
3. **`import QtQuick.Layouts`** requires `Qt6::QuickLayouts` in `target_link_libraries` AND a clean rebuild for androiddeployqt to bundle the `.so`
4. After adding new QML files to CMakeLists, do **CMake: Configure** then **CMake: Build** (not just Build)
5. After any QML change, do `adb uninstall` + fresh `adb install` to avoid stale APK cache

---

## Android Debug Checklist

```powershell
# 1. Configure (after CMakeLists change)
#    VS Code: Ctrl+Shift+P → "CMake: Configure"

# 2. Build
#    VS Code: Ctrl+Shift+B

# 3. Deploy
adb uninstall com.cjadhav.tarocarddeck
adb install "D:\cjadhav\TaroCardDeckApp\build-android\android-build\build\outputs\apk\debug\android-build-debug.apk"

# 4. Launch + check logs
adb logcat -c
adb shell am start -n "com.cjadhav.tarocarddeck/org.qtproject.qt.android.bindings.QtActivity"
Start-Sleep -Seconds 4
adb logcat -d | Select-String -Pattern "LOG:|TaroApp|failed|qml" -CaseSensitive:$false
```

**Reading the logs:**
| Log line | Meaning |
|---|---|
| `TaroApp: objectCreated OK for qrc:/...` | QML loaded successfully |
| `QQmlApplicationEngine failed to load component` | Import failed or syntax error — check imports |
| `LOG: Main.qml ApplicationWindow created OK` | Main.qml parsed and running |
| `LOG: HomeScreen created OK` | HomeScreen instantiated by StackView |
| `instaCrash: true` | Android crash-loop protection — do `adb uninstall` |
