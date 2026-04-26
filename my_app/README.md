# SONIC_LAB

SONIC_LAB is a dark-mode Flutter app for speaker water ejection, dust removal, and manual tone testing. It uses calibrated sine waves and sweeps, Riverpod state, GoRouter navigation, generated PCM playback through `just_audio`, and a native volume MethodChannel.

## Setup

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Android requires a real device for system-volume changes. iOS does not allow apps to set hardware volume programmatically, so the app shows a manual max-volume prompt.

## Architecture

```text
lib/
  main.dart
  app.dart
  core/
    constants/        colors, durations, frequencies, sizing
    providers/        Riverpod settings, device, audio session, sonic lab state
    theme/            dark Material theme using Inter
    utils/            audio engine, device detector, haptics, volume channel
    widgets/          shared controls and painters
  features/
    splash/           animated launch flow
    onboarding/       first-run setup screens
    water/            165 Hz water ejection workflow
    dust/             8-12 kHz dust sweep workflow
    sonic/            manual 20 Hz-20 kHz tone lab
    settings/         preferences and terminate controls
  models/             phone profile and session state
```

## Frequency Science

Water mode uses a low 165 Hz sine tone by default because low-frequency speaker displacement is better at pushing droplets out of the grille. Samsung profiles use 200 Hz at 90% amplitude, Pixel profiles use 180 Hz, and iPhone profiles use 165 Hz.

Dust mode uses a safe high-frequency sweep. The general profile sweeps 8 kHz to 12 kHz with a sawtooth amplitude pattern capped at 85%. iPhone narrows the sweep to 9-11 kHz, Samsung uses 7-13 kHz, and Pixel uses 8.5-11.5 kHz.

Sonic Lab maps the manual slider logarithmically from 20 Hz to 20 kHz so low and high ranges are controllable with similar precision.

## Platform Notes

Android:
- `MODIFY_AUDIO_SETTINGS` lets the app set `AudioManager.STREAM_MUSIC` to max volume.
- `RECORD_AUDIO` is declared for low-latency audio packages that require microphone/audio processing permissions.

iOS:
- `NSMicrophoneUsageDescription` is included for audio processing.
- Programmatic hardware volume changes are restricted by iOS. The MethodChannel returns `false` for `setMaxVolume`, and the UI asks users to raise volume manually.

Crashlytics and RevenueCat are represented as integration skeletons/no-op boundaries so the app is buildable before Firebase or store credentials are configured.
