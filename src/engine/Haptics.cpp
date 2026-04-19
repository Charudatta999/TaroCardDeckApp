#include "Haptics.h"
#include <QDebug>

#ifdef Q_OS_ANDROID
#  include <QJniObject>
#  include <QJniEnvironment>
#  include <QCoreApplication>
#  include <jni.h>
#endif

namespace {
// Android amplitude range is 1..255. We pick three levels.
constexpr int kAmpLight  = 80;
constexpr int kAmpMedium = 160;
constexpr int kAmpHeavy  = 255;

constexpr int kMsLight  = 12;
constexpr int kMsMedium = 22;
constexpr int kMsHeavy  = 38;
}

Haptics::Haptics(QObject *parent)
    : QObject(parent)
{
#ifdef Q_OS_ANDROID
    qWarning() << "Haptics: Android build — JNI path active";
#else
    qWarning() << "Haptics: non-Android build — no-op stub";
#endif
}

bool Haptics::available() const
{
#ifdef Q_OS_ANDROID
    return m_enabled;
#else
    return false;
#endif
}

void Haptics::setEnabled(bool on)
{
    m_enabled = on;
    qWarning() << "Haptics: enabled =" << on;
}

void Haptics::light()     { vibrateOneShot(kMsLight,  kAmpLight); }
void Haptics::medium()    { vibrateOneShot(kMsMedium, kAmpMedium); }
void Haptics::heavy()     { vibrateOneShot(kMsHeavy,  kAmpHeavy); }
void Haptics::selection() { vibrateOneShot(8,         kAmpLight); }

// Detent click — very short, sharp, high amplitude. Meant to be fired
// rapidly (e.g. per step while scrolling a wheel / revolver cylinder),
// so keep the duration tiny or successive pulses will overlap into a
// continuous buzz.
void Haptics::tick()      { vibrateOneShot(5,         kAmpHeavy); }

void Haptics::success()
{
    vibrateWaveform({0, 18, 60, 28}, {0, kAmpMedium, 0, kAmpHeavy});
}

void Haptics::warning()
{
    vibrateWaveform({0, 30, 80, 30}, {0, kAmpHeavy,  0, kAmpHeavy});
}

void Haptics::vibrate(int ms)
{
    if (ms <= 0) return;
    if (ms > 500) ms = 500;
    vibrateOneShot(ms, kAmpMedium);
}

// -----------------------------------------------------------------------------
// Android JNI implementation
// -----------------------------------------------------------------------------
#ifdef Q_OS_ANDROID

static QJniObject getVibratorService()
{
    // Context ctx = QtNative.getContext()  (QtActivity)
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (!activity.isValid()) {
        qWarning() << "Haptics: no Android context";
        return {};
    }

    // API 31+: VibratorManager -> getDefaultVibrator()
    QJniEnvironment env;
    const jint sdk = QJniObject::getStaticField<jint>(
        "android/os/Build$VERSION", "SDK_INT");

    if (sdk >= 31) {
        QJniObject vibMgrName =
            QJniObject::getStaticObjectField("android/content/Context",
                                             "VIBRATOR_MANAGER_SERVICE",
                                             "Ljava/lang/String;");
        QJniObject vibMgr = activity.callObjectMethod(
            "getSystemService",
            "(Ljava/lang/String;)Ljava/lang/Object;",
            vibMgrName.object<jstring>());
        if (vibMgr.isValid()) {
            QJniObject vib = vibMgr.callObjectMethod(
                "getDefaultVibrator", "()Landroid/os/Vibrator;");
            if (vib.isValid()) return vib;
        }
        // fall through to legacy path if the manager route failed
    }

    QJniObject vibName =
        QJniObject::getStaticObjectField("android/content/Context",
                                         "VIBRATOR_SERVICE",
                                         "Ljava/lang/String;");
    QJniObject vib = activity.callObjectMethod(
        "getSystemService",
        "(Ljava/lang/String;)Ljava/lang/Object;",
        vibName.object<jstring>());
    return vib;
}

void Haptics::vibrateOneShot(int ms, int amplitude)
{
    if (!m_enabled || ms <= 0) return;

    QJniObject vib = getVibratorService();
    if (!vib.isValid()) return;

    const jint sdk = QJniObject::getStaticField<jint>(
        "android/os/Build$VERSION", "SDK_INT");

    if (sdk >= 26) {
        // VibrationEffect.createOneShot(long, int)
        QJniObject effect = QJniObject::callStaticObjectMethod(
            "android/os/VibrationEffect",
            "createOneShot",
            "(JI)Landroid/os/VibrationEffect;",
            jlong(ms), jint(amplitude));
        if (effect.isValid()) {
            vib.callMethod<void>(
                "vibrate",
                "(Landroid/os/VibrationEffect;)V",
                effect.object());
            return;
        }
    }

    // Legacy fallback: vibrate(long milliseconds)
    vib.callMethod<void>("vibrate", "(J)V", jlong(ms));
}

void Haptics::vibrateWaveform(const QList<long> &timings,
                              const QList<int>  &amplitudes)
{
    if (!m_enabled || timings.isEmpty()) return;

    QJniObject vib = getVibratorService();
    if (!vib.isValid()) return;

    QJniEnvironment env;
    const jint sdk = QJniObject::getStaticField<jint>(
        "android/os/Build$VERSION", "SDK_INT");

    // Build Java long[] of timings.
    const int n = timings.size();
    jlongArray jTimings = env->NewLongArray(n);
    {
        QVarLengthArray<jlong> buf(n);
        for (int i = 0; i < n; ++i) buf[i] = timings[i];
        env->SetLongArrayRegion(jTimings, 0, n, buf.data());
    }

    if (sdk >= 26 && amplitudes.size() == n) {
        // Build int[] of amplitudes.
        jintArray jAmps = env->NewIntArray(n);
        QVarLengthArray<jint> abuf(n);
        for (int i = 0; i < n; ++i) abuf[i] = amplitudes[i];
        env->SetIntArrayRegion(jAmps, 0, n, abuf.data());

        QJniObject effect = QJniObject::callStaticObjectMethod(
            "android/os/VibrationEffect",
            "createWaveform",
            "([J[II)Landroid/os/VibrationEffect;",
            jTimings, jAmps, jint(-1) /* no repeat */);
        env->DeleteLocalRef(jAmps);

        if (effect.isValid()) {
            vib.callMethod<void>(
                "vibrate",
                "(Landroid/os/VibrationEffect;)V",
                effect.object());
            env->DeleteLocalRef(jTimings);
            return;
        }
    }

    // Legacy: vibrate(long[] pattern, int repeat)
    vib.callMethod<void>("vibrate", "([JI)V", jTimings, jint(-1));
    env->DeleteLocalRef(jTimings);
}

#else  // ---------------- non-Android stubs ----------------

void Haptics::vibrateOneShot(int, int) {}
void Haptics::vibrateWaveform(const QList<long> &, const QList<int> &) {}

#endif
