# Firebase Setup Guide

This guide will help you set up Firebase configuration for the Jagrata app.

## Prerequisites

1. Access to the Firebase project console
2. Flutter development environment set up

## Setup Steps

### 1. Firebase Configuration Files

The app requires Firebase configuration files that are not included in this repository for security reasons. You need to create them from the template files:

#### Web Configuration
1. Copy `lib/firebase_options_web.template.dart` to `lib/firebase_options_web.dart`
2. Replace placeholder values with your Firebase web app configuration

#### iOS Configuration  
1. Copy `lib/firebase_options_ios.template.dart` to `lib/firebase_options_ios.dart`
2. Replace placeholder values with your Firebase iOS app configuration

#### Android Configuration
1. Copy `lib/firebase_options.template.dart` to `lib/firebase_options.dart`
2. Replace placeholder values with your Firebase Android app configuration

### 2. Platform-Specific Files

#### Android
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/google-services.json`

#### iOS
1. Download `GoogleService-Info.plist` from Firebase Console  
2. Place it in `ios/Runner/GoogleService-Info.plist`

### 3. Getting Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings (gear icon)
4. In the "General" tab, scroll down to "Your apps"
5. For each platform (Web, Android, iOS), click on the app and copy the configuration

### 4. Firebase Services Required

Make sure these services are enabled in your Firebase project:

- **Authentication** (for user management)
- **Firestore Database** (for storing incidents)
- **Storage** (for file uploads, if needed)
- **Analytics** (optional, for app insights)

### 5. Firestore Security Rules

Set up appropriate security rules in Firestore for your app's data access patterns.

### 6. Verification

After setting up the configuration files, run:

```bash
flutter clean
flutter pub get
flutter run
```

## Troubleshooting

- If you get compilation errors, make sure all configuration files are created from templates
- Verify that your Firebase project has the required services enabled
- Check that bundle IDs and package names match your Firebase app configuration

## Security Note

⚠️ **Never commit the actual Firebase configuration files to version control!** They contain sensitive API keys and should be kept secure. 