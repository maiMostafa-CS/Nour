# Islamic App

Flutter Islamic application using:

- Clean Architecture
- BLoC
- GetIt
- Offline prayer-time calculation with `adhan_dart`
- Local Quran and Adhkar JSON assets
- Location permission
- Dark mode foundation

## Run

```bash
flutter pub get
flutter run
```

## Architecture

Presentation -> Domain -> Data

Prayer times are calculated locally and do not require an API.
The default calculation method is the Egyptian General Authority of Survey.

## Important

This repository contains a starter Quran/Adhkar data structure, not a complete verified Quran text.
Before publishing, replace the sample assets with a verified Quran source and a verified Adhkar dataset.
