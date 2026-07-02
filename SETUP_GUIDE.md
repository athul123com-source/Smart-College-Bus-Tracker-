# Setup Guide - Smart College Bus Tracker

Follow these steps to get your app up and running:

## Prerequisites

1. **Flutter SDK** installed (version 3.0.0 or higher)
   - Check: `flutter --version`
   - Download: https://flutter.dev/docs/get-started/install

2. **Android Studio** or **VS Code** with Flutter extensions
3. **Firebase Account** (free tier is sufficient)
4. **Google Cloud Account** (for Maps API)

---

## Step 1: Install Dependencies

Open terminal in the project directory and run:

```bash
flutter pub get
```

This will download all required packages listed in `pubspec.yaml`.

---

## Step 2: Set Up Firebase Project

### 2.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select existing project
3. Follow the setup wizard:
   - Enter project name: "Smart College Bus Tracker"
   - Enable Google Analytics (optional)
   - Create project

### 2.2 Add Android App to Firebase

1. In Firebase Console, click the Android icon (or "Add app")
2. Register your app:
   - **Package name**: `com.example.smart_college_bus_tracker` (or your custom package)
   - **App nickname**: Smart College Bus Tracker
   - **Debug signing certificate**: (optional for now)
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

### 2.3 Add iOS App to Firebase (if developing for iOS)

1. In Firebase Console, click the iOS icon
2. Register your app:
   - **Bundle ID**: `com.example.smartCollegeBusTracker`
   - **App nickname**: Smart College Bus Tracker
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

### 2.4 Enable Firebase Services

In Firebase Console, enable:

1. **Authentication**:
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"

2. **Cloud Firestore**:
   - Go to Firestore Database
   - Click "Create database"
   - Start in **test mode** (for development)
   - Choose a location (closest to your region)

3. **Cloud Messaging** (for push notifications):
   - Go to Cloud Messaging
   - Enable it (no additional setup needed for basic use)

### 2.5 Install Firebase CLI Tools

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

Follow the prompts to select your Firebase project and platforms.

---

## Step 3: Set Up Google Maps API

### 3.1 Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Link it to your Firebase project (if not already linked)

### 3.2 Enable Maps SDK

1. In Google Cloud Console, go to "APIs & Services" → "Library"
2. Search for and enable:
   - **Maps SDK for Android**
   - **Maps SDK for iOS** (if developing for iOS)

### 3.3 Create API Key

1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "API Key"
3. Copy the API key
4. (Recommended) Restrict the key:
   - Click on the key to edit
   - Under "Application restrictions":
     - For Android: Add package name and SHA-1 certificate
     - For iOS: Add bundle identifier
   - Under "API restrictions": Restrict to Maps SDK

### 3.4 Add API Key to Android

Edit `android/app/src/main/AndroidManifest.xml`:

Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE"/>
```

### 3.5 Add API Key to iOS (if needed)

Edit `ios/Runner/AppDelegate.swift`:

Add this in the `application` method:

```swift
GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
```

---

## Step 4: Configure Android Build

### 4.1 Update build.gradle

Edit `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

Edit `android/app/build.gradle`:

Add at the bottom:

```gradle
apply plugin: 'com.google.gms.google-services'
```

### 4.2 Set Minimum SDK Version

Edit `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Required for geolocator
        targetSdkVersion 33
    }
}
```

---

## Step 5: Set Up Firestore Database Structure

### 5.1 Create Collections

In Firebase Console → Firestore Database, create these collections:

#### Users Collection
```
users/
  {userId}/
    - id: string
    - email: string
    - name: string
    - role: string ("driver" or "student")
    - phoneNumber: string (optional)
    - busId: string (optional)
```

#### Buses Collection
```
buses/
  {busId}/
    - id: string
    - busNumber: string
    - routeName: string
    - driverId: string (optional)
    - driverName: string (optional)
    - isActive: boolean
    - stops: array
      - id: string
      - name: string
      - latitude: number
      - longitude: number
      - sequence: number
    - currentLatitude: number (optional)
    - currentLongitude: number (optional)
    - currentSpeed: number (optional, in km/h)
    - lastUpdateTime: timestamp (optional)
```

### 5.2 Add Sample Data (for testing)

Create a test bus document:

```json
{
  "id": "bus_001",
  "busNumber": "BUS-001",
  "routeName": "Main Campus Route",
  "driverId": null,
  "driverName": null,
  "isActive": false,
  "stops": [
    {
      "id": "stop_1",
      "name": "Main Gate",
      "latitude": 11.0168,
      "longitude": 76.9558,
      "sequence": 1
    },
    {
      "id": "stop_2",
      "name": "Library",
      "latitude": 11.0175,
      "longitude": 76.9565,
      "sequence": 2
    }
  ]
}
```

---

## Step 6: Test the App

### 6.1 Check for Errors

```bash
flutter doctor
```

Fix any issues reported.

### 6.2 Run on Emulator/Device

**For Android:**
```bash
flutter run
```

**For iOS (Mac only):**
```bash
flutter run -d ios
```

### 6.3 Test Authentication

1. **Create a test user in Firebase Console:**
   - Go to Authentication → Users
   - Click "Add user"
   - Email: `driver@test.com` / Password: `test123`
   - Create another: `student@test.com` / Password: `test123`

2. **Add user data to Firestore:**
   - Go to Firestore Database
   - Create document in `users` collection with the user's UID
   - Add fields: `email`, `name`, `role` ("driver" or "student")

3. **Test login in the app:**
   - Select role (Driver/Student)
   - Enter test credentials
   - Should navigate to respective dashboard

---

## Step 7: Common Issues & Solutions

### Issue: "Firebase not initialized"
**Solution:** Make sure `google-services.json` is in `android/app/` directory

### Issue: "Maps not showing"
**Solution:** 
- Verify API key is correct in AndroidManifest.xml
- Check API key restrictions in Google Cloud Console
- Ensure Maps SDK is enabled

### Issue: "Location permission denied"
**Solution:**
- Add location permissions in AndroidManifest.xml (already done)
- Grant location permission when app requests it
- For testing, enable mock locations in emulator settings

### Issue: "Build failed"
**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

---

## Step 8: Next Steps

1. **Customize the app:**
   - Update app name and package name
   - Add your college logo
   - Customize colors in `lib/theme/app_theme.dart`

2. **Add more features:**
   - Push notifications setup
   - Route optimization
   - Attendance tracking

3. **Deploy:**
   - Build APK: `flutter build apk`
   - Build App Bundle: `flutter build appbundle`
   - For iOS: `flutter build ios`

---

## Quick Checklist

- [ ] Flutter SDK installed
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Firebase project created
- [ ] `google-services.json` added to Android
- [ ] Firebase Authentication enabled
- [ ] Firestore Database created
- [ ] Google Maps API key obtained
- [ ] API key added to AndroidManifest.xml
- [ ] Test users created in Firebase
- [ ] App runs without errors

---

## Need Help?

- Flutter Docs: https://flutter.dev/docs
- Firebase Docs: https://firebase.google.com/docs
- Google Maps Docs: https://developers.google.com/maps/documentation

Good luck with your Smart College Bus Tracker! 🚌



