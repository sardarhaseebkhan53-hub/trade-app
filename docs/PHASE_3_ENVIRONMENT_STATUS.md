# AURUM — Phase 3 local environment status

**Checked:** 2026-08-11 (Asia/Karachi session date)

## Required-command verification

| Command | Result in this workspace |
| --- | --- |
| `flutter --version` | Blocked: `flutter` was not preinstalled. A clean stable Flutter SDK source checkout was created at `/home/user/.flutter-sdk`, but Flutter cannot bootstrap its bundled Dart SDK because this environment cannot establish TLS to `storage.googleapis.com`. |
| `dart --version` | Blocked: Dart is provided by Flutter in this setup and is not preinstalled. |
| `flutter doctor -v` | Blocked until Flutter's bundled Dart SDK can be downloaded. |
| `flutter devices` | Blocked until Flutter starts; additionally `adb` and the Android SDK are not installed in this sandbox. |
| physical Android device | Not connected to this remote sandbox. A USB device must be connected to the developer's workstation for device validation. |

## Remediation performed

1. Verified GitHub connectivity and cloned the official Flutter stable branch to `/home/user/.flutter-sdk`.
2. Retried Flutter bootstrap against the official storage host and documented the failure. The blocked host is required to retrieve Flutter's engine-matched Dart SDK; substituting an unverified runtime would not be an acceptable development setup.
3. Checked for Flutter, Dart, Android SDK, `adb`, Java, Gradle and standard SDK locations. None were available.
4. Attempted the system package index refresh. Outbound package-host connections are also unavailable in this sandbox.

## What is ready in the repository

The committed project is a standard Flutter/Android source layout with a VS Code launch configuration and no secrets. Once Flutter and the Android SDK are installed on a development workstation, run:

```bash
export PATH="$HOME/flutter/bin:$PATH" # adjust if Flutter is installed elsewhere
flutter doctor -v
flutter doctor --android-licenses
flutter devices
flutter pub get
flutter analyze
flutter test
flutter run -d <physical-device-id>
```

The device must have Developer options and USB debugging enabled, and the RSA prompt must be accepted. The source is deliberately mock-backed in Phase 3: no real market, AI, transaction or authentication API key is required.

## Validation boundary

The Flutter commands above cannot truthfully be marked as passed from this sandbox until the official SDK/toolchain and a physical Android device are available. This document exists so that a missing local toolchain is not misrepresented as a successful device validation.
