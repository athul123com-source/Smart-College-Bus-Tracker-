# Quick Start Guide

## 🚀 Fast Setup (5 minutes)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Firebase Setup (Required)

**Option A: Using FlutterFire CLI (Recommended)**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

**Option B: Manual Setup**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add Android app (package: `com.example.smart_college_bus_tracker`)
4. Download `google-services.json` → place in `android/app/`
5. Enable Authentication (Email/Password)
6. Enable Firestore Database (test mode)

### 3. Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable "Maps SDK for Android"
3. Create API Key
4. Edit `android/app/src/main/AndroidManifest.xml`
   - Replace `YOUR_GOOGLE_MAPS_API_KEY` with your key

### 4. Run the App
```bash
flutter run
```

### 5. Create Test Users

In Firebase Console → Authentication:
- Add user: `driver@test.com` / `test123`
- Add user: `student@test.com` / `test123`

In Firestore → `users` collection:
- Create document with user's UID
- Add: `email`, `name`, `role` ("driver" or "student")

---

## ⚠️ Important Notes

- **Location Permissions**: App will request location permission on first run
- **Test Mode**: Firestore starts in test mode (30 days free)
- **API Key**: Keep your Google Maps API key secure
- **Emulator**: Use Android emulator with Google Play Services for maps

---

## 📱 Testing

1. **Login as Driver:**
   - Select "Driver" role
   - Login with driver credentials
   - Start trip to begin tracking
   - Configure route from menu

2. **Login as Student:**
   - Select "Student" role
   - Login with student credentials
   - Select a bus from list
   - View real-time location and ETA

---

## 🔧 Troubleshooting

**"Firebase not initialized"**
→ Check `google-services.json` is in `android/app/`

**"Maps not loading"**
→ Verify API key in AndroidManifest.xml

**"Build errors"**
→ Run `flutter clean && flutter pub get`

---

For detailed setup, see [SETUP_GUIDE.md](SETUP_GUIDE.md)




