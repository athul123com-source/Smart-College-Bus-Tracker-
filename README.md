# Smart College Bus Tracker

A real-time bus tracking application for college campuses with ETA prediction, built with Flutter.

## Features

- **Real-Time Tracking**: Live GPS tracking of college buses with map visualization
- **Dynamic ETA**: Accurate Estimated Time of Arrival calculations based on speed, distance, and traffic
- **Multi-Role Support**: 
  - **Driver**: Start/stop trips, configure routes, broadcast live location updates, detour detection
  - **Student**: Select bus, view location, check next stop, monitor ETA
  - **Teacher**: Track buses, monitor student attendance, view notifications
  - **Parent**: Track child's bus in real-time, receive drop-off notifications
  - **Admin**: Manage buses, users, routes, view analytics and system settings
- **Push Notifications**: Alerts for delays, arrivals, detours, and route changes
- **Secure Authentication**: Firebase-based authentication with role-based access
- **Modern UI**: Beautiful, responsive design with Material Design 3

## Tech Stack

- **Flutter**: Cross-platform mobile framework
- **Firebase**: Authentication and Firestore for real-time data
- **Google Maps API**: Map visualization and location services
- **Geolocator**: GPS location tracking
- **Provider**: State management

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_model.dart
│   └── bus_model.dart
├── screens/
│   ├── auth/
│   │   └── login_screen.dart
│   ├── driver/
│   │   ├── driver_dashboard.dart
│   │   ├── route_config_screen.dart
│   │   └── route_change_screen.dart
│   ├── student/
│   │   ├── student_dashboard.dart
│   │   └── bus_selection_screen.dart
│   ├── teacher/
│   │   └── teacher_dashboard.dart
│   ├── parent/
│   │   └── parent_dashboard.dart
│   ├── admin/
│   │   └── admin_dashboard.dart
│   └── notifications/
│       └── notifications_screen.dart
├── services/                 # Business logic
│   ├── auth_service.dart
│   └── location_service.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   └── bus_provider.dart
└── theme/
    └── app_theme.dart        # App theming
```

## 🚀 Quick Start

**New to this project?** Start here:

1. **Quick Setup (5 min)**: See [QUICK_START.md](QUICK_START.md)
2. **Detailed Setup**: See [SETUP_GUIDE.md](SETUP_GUIDE.md)

### Essential Steps

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Set up Firebase:**
   - Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Run `flutterfire configure` (or manually add `google-services.json`)
   - Enable Authentication (Email/Password) and Firestore

3. **Get Google Maps API Key:**
   - Enable Maps SDK in [Google Cloud Console](https://console.cloud.google.com)
   - Add API key to `android/app/src/main/AndroidManifest.xml`

4. **Run the app:**
   ```bash
   flutter run
   ```

📖 **For complete setup instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md)**

## Usage

### For Drivers

1. Login with driver credentials
2. Configure your bus route by adding stops
3. Start trip to begin broadcasting location
4. View your current location on the map
5. Stop trip when route is complete

### For Students

1. Login with student credentials
2. Select your bus from the available list
3. View real-time bus location on map
4. Check ETA for next stop
5. Receive notifications for arrivals

### For Teachers

1. Login with teacher credentials
2. Select bus to track
3. Monitor student attendance (coming soon)
4. View notifications and route updates

### For Parents

1. Login with parent credentials
2. Select your child's bus
3. Track bus location in real-time
4. Receive automatic notifications when child is dropped off
5. View trip history (coming soon)

### For Admins

1. Login with admin credentials
2. View system overview and statistics
3. Manage buses, users, and routes
4. Access analytics and reports
5. Configure system settings

## Firebase Database Structure

### Users Collection
```
users/
  {userId}/
    - id: string
    - email: string
    - name: string
    - role: 'driver' | 'student' | 'teacher' | 'parent' | 'admin'
    - phoneNumber: string (optional)
    - busId: string (optional)
```

### Buses Collection
```
buses/
  {busId}/
    - id: string
    - busNumber: string
    - routeName: string
    - driverId: string
    - driverName: string
    - isActive: boolean
    - stops: Array<BusStop>
    - currentLatitude: number
    - currentLongitude: number
    - currentSpeed: number (km/h)
    - lastUpdateTime: timestamp
```

## Future Enhancements

- AI-based route optimization
- RFID integration for attendance tracking
- Machine learning for predictive analytics
- Multi-language support
- Offline mode support

## License

This project is developed for educational purposes.

## Authors

Based on the research paper "Smart College Bus Tracker: Real-Time Location and ETA Predictor" by M. Sowndharya et al.

