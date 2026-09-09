# Platform setup

This ZIP contains the complete Dart/Flutter source structure. Run it from a machine with Flutter installed.

## Commands

flutter pub get
flutter analyze
flutter run

## Android location permission

Add this inside android/app/src/main/AndroidManifest.xml:

<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

## iOS location permission

Add to ios/Runner/Info.plist:

<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location to calculate prayer times and Qibla direction.</string>
