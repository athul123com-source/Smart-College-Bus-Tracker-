import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/login_screen.dart';
import 'screens/driver/driver_dashboard.dart';
import 'screens/student/student_dashboard.dart';
import 'services/location_service.dart';
import 'providers/bus_provider.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';

/// Demo mode - Run this to see the UI without Firebase setup
/// Usage: flutter run -t lib/main_demo.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BusProvider()),
        Provider(create: (_) => LocationService()),
      ],
      child: MaterialApp(
        title: 'Smart College Bus Tracker (Demo)',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const DemoModeScreen(),
      ),
    );
  }
}

/// Demo mode screen - allows direct navigation to any screen
class DemoModeScreen extends StatelessWidget {
  const DemoModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Mode - Select Screen'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'Demo Mode',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'This is a demo version to preview the UI.\nFirebase is not required.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('View Login Screen'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const StudentDashboard(),
                  ),
                );
              },
              icon: const Icon(Icons.school),
              label: const Text('View Student Dashboard'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DriverDashboard(),
                  ),
                );
              },
              icon: const Icon(Icons.person),
              label: const Text('View Driver Dashboard'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('About Demo Mode'),
                    content: const Text(
                      'This demo mode allows you to preview the UI without setting up Firebase.\n\n'
                      'Note: Some features like real-time tracking and authentication will not work in demo mode.\n\n'
                      'To use the full app, set up Firebase and use main.dart instead.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('About Demo Mode'),
            ),
          ],
        ),
      ),
    );
  }
}




