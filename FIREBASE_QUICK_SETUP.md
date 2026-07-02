# Firebase Quick Setup - After Creating Project

**You've created Firebase project and selected Flutter. Do these next:**

---

## 🚀 Quick Steps (60 minutes total)

### 1️⃣ Add Android App (5 min)
- Firebase Console → Click Android icon
- Package name: `com.example.smart_college_bus_tracker`
- Download `google-services.json`
- Place in: `android/app/google-services.json`

### 2️⃣ Enable Services (10 min)
- **Authentication** → Sign-in method → Enable Email/Password
- **Firestore** → Create database → Test mode → Choose location

### 3️⃣ Update Build Files (5 min)
- `android/build.gradle` → Add: `classpath 'com.google.gms:google-services:4.4.0'`
- `android/app/build.gradle` → Add at end: `apply plugin: 'com.google.gms.google-services'`

### 4️⃣ Get Maps API Key (10 min)
- Google Cloud Console → Enable Maps SDK for Android
- Create API Key
- Add to `AndroidManifest.xml` (replace `YOUR_GOOGLE_MAPS_API_KEY`)

### 5️⃣ Create Test Data (15 min)
- Create 5 users in Authentication:
  - `driver@test.com` / `test123`
  - `student@test.com` / `test123`
  - `teacher@test.com` / `test123`
  - `parent@test.com` / `test123`
  - `admin@test.com` / `test123`
- Add user data to Firestore `users` collection
- Create test bus in Firestore `buses` collection

### 6️⃣ Test App (10 min)
```bash
.\flutter\bin\flutter.bat clean
.\flutter\bin\flutter.bat pub get
.\flutter\bin\flutter.bat run
```

---

## 📋 Test Credentials

| Role | Email | Password |
|------|-------|----------|
| Driver | driver@test.com | test123 |
| Student | student@test.com | test123 |
| Teacher | teacher@test.com | test123 |
| Parent | parent@test.com | test123 |
| Admin | admin@test.com | test123 |

---

## ✅ Checklist

- [ ] `google-services.json` in `android/app/`
- [ ] Authentication enabled
- [ ] Firestore created
- [ ] Build files updated
- [ ] Maps API key added
- [ ] Test users created
- [ ] Test bus created
- [ ] App runs successfully

---

**For detailed steps, see [NEXT_STEPS.md](NEXT_STEPS.md)**


