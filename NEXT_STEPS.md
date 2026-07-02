# Complete Project Setup Guide - Smart College Bus Tracker

**You've created a Firebase project and selected Flutter. Follow these steps to complete your app setup!**

---

## ✅ What You've Completed

- [x] Flutter dependencies installed (`flutter pub get`)
- [x] Firebase project created
- [x] Flutter selected in Firebase

---

## 📋 Step-by-Step: Complete Firebase Setup

### **Step 1: Add Android App to Firebase** (5 minutes)

Since you've already created the Firebase project, now add your Android app:

1. **In Firebase Console:**
   - Go to your project overview page
   - Click the **Android icon** (or click "Add app" → "Android")

2. **Register Your App:**
   - **Package name**: `com.example.smart_college_bus_tracker`
     - *This is the default package name. If you changed it, use your custom package name.*
   - **App nickname**: `Smart College Bus Tracker` (optional)
   - **Debug signing certificate SHA-1**: Leave blank for now (optional)

3. **Download `google-services.json`:**
   - Click "Register app"
   - Download the `google-services.json` file
   - **IMPORTANT:** Place it in: `android/app/google-services.json`
     - Create the `android/app/` folder if it doesn't exist
     - The file should be directly in `android/app/` folder

4. **Click "Next"** through the remaining steps (you can skip the rest for now)

---

### **Step 2: Enable Firebase Services** (10 minutes)

#### 2.1 Enable Authentication

1. In Firebase Console, go to **Authentication** (left sidebar)
2. Click **Get Started** (if first time)
3. Go to **Sign-in method** tab
4. Click on **Email/Password**
5. **Enable** the Email/Password provider
6. Click **Save**

#### 2.2 Create Firestore Database

1. In Firebase Console, go to **Firestore Database** (left sidebar)
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a **location** (choose the one closest to you)
5. Click **Enable**

**Note:** Test mode allows read/write for 30 days. For production, you'll need to set up security rules later.

---

### **Step 3: Configure Android Build Files** (5 minutes)

#### 3.1 Update `android/build.gradle`

1. Open `android/build.gradle` file
2. Find the `buildscript` section
3. Inside `dependencies`, add this line:
   ```gradle
   classpath 'com.google.gms:google-services:4.4.0'
   ```

**Example:**
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'  // Add this line
        // ... other dependencies
    }
}
```

#### 3.2 Update `android/app/build.gradle`

1. Open `android/app/build.gradle` file
2. Scroll to the **very bottom** of the file
3. Add this line at the end:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

4. Also check that `minSdkVersion` is at least 21:
   ```gradle
   android {
       defaultConfig {
           minSdkVersion 21  // Should be 21 or higher
           // ... other config
       }
   }
   ```

**If `android/app/build.gradle` doesn't exist**, create it with this structure:
```gradle
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    compileSdkVersion 33

    defaultConfig {
        applicationId "com.example.smart_college_bus_tracker"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}

apply plugin: 'com.google.gms.google-services'  // Add this at the end
```

---

### **Step 4: Get Google Maps API Key** (10 minutes)

#### 4.1 Enable Maps SDK

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. **Select your Firebase project** (or create a new one and link it to Firebase)
3. Go to **APIs & Services** → **Library**
4. Search for **"Maps SDK for Android"**
5. Click on it and click **Enable**

#### 4.2 Create API Key

1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **API Key**
3. **Copy the API key** that appears
4. (Optional but recommended) Click on the key to edit it:
   - Under **Application restrictions**: Add your package name
   - Under **API restrictions**: Restrict to "Maps SDK for Android"

#### 4.3 Add API Key to App

1. Open `android/app/src/main/AndroidManifest.xml`
2. Find this line:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
   ```
3. Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key

---

### **Step 5: Create Test Data** (15 minutes)

#### 5.1 Create Test Users in Firebase Authentication

1. In Firebase Console, go to **Authentication** → **Users**
2. Click **Add user**
3. Create these test users:

   **User 1 - Driver:**
   - Email: `driver@test.com`
   - Password: `test123`
   - Click **Add user**
   - **Copy the User UID** (you'll need it)

   **User 2 - Student:**
   - Email: `student@test.com`
   - Password: `test123`
   - Click **Add user**
   - **Copy the User UID**

   **User 3 - Teacher:**
   - Email: `teacher@test.com`
   - Password: `test123`
   - Click **Add user**
   - **Copy the User UID**

   **User 4 - Parent:**
   - Email: `parent@test.com`
   - Password: `test123`
   - Click **Add user**
   - **Copy the User UID**

   **User 5 - Admin:**
   - Email: `admin@test.com`
   - Password: `test123`
   - Click **Add user**
   - **Copy the User UID**

#### 5.2 Add User Data to Firestore

1. Go to **Firestore Database** in Firebase Console
2. Click **Start collection**
3. Collection ID: `users`
4. Click **Next**

5. **For each user**, create a document:
   - **Document ID**: Use the User UID from Authentication
   - **Fields** (add these fields):

   **Driver Document:**
   ```
   email: string → "driver@test.com"
   name: string → "Test Driver"
   role: string → "driver"
   phoneNumber: string → "1234567890" (optional)
   ```

   **Student Document:**
   ```
   email: string → "student@test.com"
   name: string → "Test Student"
   role: string → "student"
   phoneNumber: string → "1234567890" (optional)
   ```

   **Teacher Document:**
   ```
   email: string → "teacher@test.com"
   name: string → "Test Teacher"
   role: string → "teacher"
   phoneNumber: string → "1234567890" (optional)
   ```

   **Parent Document:**
   ```
   email: string → "parent@test.com"
   name: string → "Test Parent"
   role: string → "parent"
   phoneNumber: string → "1234567890" (optional)
   ```

   **Admin Document:**
   ```
   email: string → "admin@test.com"
   name: string → "Test Admin"
   role: string → "admin"
   phoneNumber: string → "1234567890" (optional)
   ```

#### 5.3 Create Test Bus in Firestore

1. In Firestore, click **Start collection**
2. Collection ID: `buses`
3. Click **Next**
4. Document ID: `bus_001`
5. Add these fields:

   ```
   id: string → "bus_001"
   busNumber: string → "BUS-001"
   routeName: string → "Main Campus Route"
   isActive: boolean → false
   driverId: string → "" (empty for now)
   driverName: string → "" (empty for now)
   stops: array → Click "Add field" → Select "array"
   ```

6. **Add stops to the array:**
   - Click on the `stops` array field
   - Click **Add item** (for each stop)

   **Stop 1:**
   ```
   id: string → "stop_1"
   name: string → "Main Gate"
   latitude: number → 11.0168
   longitude: number → 76.9558
   sequence: number → 1
   ```

   **Stop 2:**
   ```
   id: string → "stop_2"
   name: string → "Library"
   latitude: number → 11.0175
   longitude: number → 76.9565
   sequence: number → 2
   ```

7. Click **Save**

---

### **Step 6: Test Your App** (10 minutes)

#### 6.1 Clean and Rebuild

```bash
# Using Flutter from your project folder
.\flutter\bin\flutter.bat clean
.\flutter\bin\flutter.bat pub get
```

#### 6.2 Run the App

```bash
.\flutter\bin\flutter.bat run
```

Or if Flutter is in your PATH:
```bash
flutter run
```

#### 6.3 Test All User Roles

1. **Test Driver Login:**
   - Select "Driver" role
   - Email: `driver@test.com`
   - Password: `test123`
   - Should see Driver Dashboard

2. **Test Student Login:**
   - Logout
   - Select "Student" role
   - Email: `student@test.com`
   - Password: `test123`
   - Should see Student Dashboard

3. **Test Teacher Login:**
   - Logout
   - Select "Teacher" role
   - Email: `teacher@test.com`
   - Password: `test123`
   - Should see Teacher Dashboard

4. **Test Parent Login:**
   - Logout
   - Select "Parent" role
   - Email: `parent@test.com`
   - Password: `test123`
   - Should see Parent Dashboard

5. **Test Admin Login:**
   - Logout
   - Select "Admin" role
   - Email: `admin@test.com`
   - Password: `test123`
   - Should see Admin Dashboard

---

## 🎯 Quick Checklist

Track your progress:

- [ ] Step 1: Android app added to Firebase
- [ ] Step 1: `google-services.json` downloaded and placed in `android/app/`
- [ ] Step 2: Authentication enabled (Email/Password)
- [ ] Step 2: Firestore Database created (test mode)
- [ ] Step 3: `android/build.gradle` updated with Google Services
- [ ] Step 3: `android/app/build.gradle` updated with plugin
- [ ] Step 4: Google Maps API key obtained
- [ ] Step 4: API key added to `AndroidManifest.xml`
- [ ] Step 5: Test users created (5 users: driver, student, teacher, parent, admin)
- [ ] Step 5: User data added to Firestore
- [ ] Step 5: Test bus created in Firestore
- [ ] Step 6: App runs successfully
- [ ] Step 6: All 5 user roles can login

---

## 🐛 Troubleshooting

### "Firebase not initialized" Error

**Solution:**
- Check `google-services.json` is in `android/app/` folder
- Verify the file name is exactly `google-services.json` (not `google-services.json.txt`)
- Make sure you added `apply plugin: 'com.google.gms.google-services'` at the bottom of `android/app/build.gradle`

### "Maps not showing" Error

**Solution:**
- Verify Google Maps API key is correct in `AndroidManifest.xml`
- Check Maps SDK for Android is enabled in Google Cloud Console
- Make sure API key restrictions allow your package name

### "Build failed" Error

**Solution:**
```bash
.\flutter\bin\flutter.bat clean
.\flutter\bin\flutter.bat pub get
.\flutter\bin\flutter.bat run
```

### "Authentication failed" Error

**Solution:**
- Verify Email/Password is enabled in Firebase Console
- Check user exists in Authentication
- Verify user data exists in Firestore with correct role

### "Location permission denied"

**Solution:**
- Grant location permission when app asks
- Or enable in device Settings → Apps → Your App → Permissions

---

## 📚 Next Steps After Setup

Once everything is working:

1. **Build Release APK:**
   ```bash
   .\flutter\bin\flutter.bat build apk --release
   ```

2. **Test on Real Device:**
   - Transfer APK to phone
   - Install and test all features

3. **Prepare for Submission:**
   - See [SUBMISSION_STEPS.md](SUBMISSION_STEPS.md)
   - Take screenshots
   - Update documentation

---

## 🆘 Need Help?

- **Detailed Setup**: See [SETUP_GUIDE.md](SETUP_GUIDE.md)
- **Submission Guide**: See [SUBMISSION_STEPS.md](SUBMISSION_STEPS.md)
- **Flutter Docs**: https://flutter.dev/docs
- **Firebase Docs**: https://firebase.google.com/docs

---

## ✅ You're Almost Done!

Follow the steps above in order. Each step builds on the previous one. Once you complete all steps, your app will be fully functional!

**Estimated Total Time: 60-75 minutes**

Good luck! 🚀
