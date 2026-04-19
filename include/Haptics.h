#ifndef HAPTICS_H
#define HAPTICS_H

#include <QObject>

// Lightweight haptic-feedback helper.
//
// Exposed to QML as the context property `haptics`. All methods are
// Q_INVOKABLE and safe to call from any thread — on non-Android builds
// they are silent no-ops (so desktop dev doesn't need any #ifdef at
// call sites).
//
// On Android we talk to the system Vibrator service via QJniObject.
// On API 26+ we use VibrationEffect.createOneShot / createWaveform
// (crisper, honours user haptic settings). On older devices we fall
// back to the deprecated vibrate(long) / vibrate(long[]).
class Haptics : public QObject
{
    Q_OBJECT

public:
    explicit Haptics(QObject *parent = nullptr);

    // Semantic intents — callers pick by meaning, not duration.
    Q_INVOKABLE void light();       // tiny tap — filter chip, list row, nav button
    Q_INVOKABLE void medium();      // card flip, sheet toggle
    Q_INVOKABLE void heavy();       // READ, SHUFFLE, major commits
    Q_INVOKABLE void selection();   // swipe between cards (subtle)
    Q_INVOKABLE void tick();        // very short sharp click — detent / cylinder step
    Q_INVOKABLE void success();     // pattern — READ lands / card flipped open
    Q_INVOKABLE void warning();     // pattern — invalid action

    // Raw duration in ms (capped at 500).
    Q_INVOKABLE void vibrate(int ms);

    // Is haptic output actually available on this device?
    Q_INVOKABLE bool available() const;

    // Per-process mute (e.g. settings screen later).
    Q_INVOKABLE void setEnabled(bool on);
    Q_INVOKABLE bool enabled() const { return m_enabled; }

private:
    void vibrateOneShot(int ms, int amplitude);
    void vibrateWaveform(const QList<long> &timings, const QList<int> &amplitudes);

    bool m_enabled = true;
};

#endif // HAPTICS_H
