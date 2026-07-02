# Run Frontend Demo (Without Firebase)

You can preview the UI without setting up Firebase! Here's how:

## 🚀 Quick Demo Mode

### Option 1: Run Demo Entry Point (Recommended)

```bash
flutter run -t lib/main_demo.dart
```

This will:
- ✅ Show a demo menu to navigate to any screen
- ✅ Display all UI screens without Firebase
- ✅ Let you preview the design and layout
- ⚠️ Maps won't work (needs API key)
- ⚠️ Real-time features won't work (needs Firebase)

### Option 2: Make Firebase Optional

I can modify `main.dart` to handle missing Firebase gracefully. Would you like me to do that?

---

## 📱 What You'll See

### Login Screen
- Beautiful login UI with role selection
- Email/password fields
- Material Design 3 styling

### Student Dashboard
- Bus selection interface
- Map view (will show error without API key, but UI is visible)
- ETA display cards
- Modern card-based design

### Driver Dashboard
- Trip status controls
- Map view
- Route configuration button
- Status indicators

---

## ⚠️ Limitations in Demo Mode

1. **Maps won't load** - Need Google Maps API key
2. **Authentication won't work** - Need Firebase
3. **Real-time tracking won't work** - Need Firebase
4. **Data won't persist** - Need Firestore

But you can still:
- ✅ See all UI screens
- ✅ Navigate between screens
- ✅ Preview the design
- ✅ Test the layout

---

## 🔧 If You Get Errors

### "Firebase not initialized"
→ This is expected in demo mode. The UI will still show.

### "Maps not loading"
→ This is expected. You need Google Maps API key for maps to work.

### "Location permission denied"
→ Grant permission when asked, or it will show a placeholder.

---

## 🎯 Next Steps

1. **Preview UI now**: Run `flutter run -t lib/main_demo.dart`
2. **Set up Firebase later**: Follow `SETUP_GUIDE.md` when ready
3. **Get Maps API key**: For full functionality

---

## 💡 Tip

The demo mode is perfect for:
- Showing the design to stakeholders
- Testing UI/UX
- Development without backend
- Learning the code structure




