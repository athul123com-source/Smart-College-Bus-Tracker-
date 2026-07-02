import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';
import '../models/student_model.dart';
import '../models/route_change_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize notification service
  Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    }

    // Get FCM token
    String? token = await _messaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
      // Save token to user document
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  /// Send notification to parent when student is dropped
  Future<void> notifyParentStudentDropped({
    required StudentModel student,
    required String stopName,
    required DateTime droppedTime,
  }) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.studentDropped,
      title: 'Student Dropped Off',
      message: '${student.name} has been dropped off at $stopName',
      busId: student.busId,
      studentId: student.id,
      timestamp: droppedTime,
      data: {
        'stopName': stopName,
        'droppedTime': droppedTime.toIso8601String(),
      },
    );

    // Save notification to Firestore
    await _firestore
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap());

    // Send push notification if parent has FCM token
    if (student.parentPhoneNumber != null || student.parentEmail != null) {
      await _sendPushNotification(
        title: notification.title,
        body: notification.message,
        data: notification.data ?? {},
        userId: student.id, // Send to student's account (parent can access)
      );
    }
  }

  /// Send detour notification to all users
  Future<void> notifyDetour({
    required String busId,
    required String busNumber,
    required String reason,
    required double deviationKm,
  }) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.detour,
      title: 'Bus Detour Alert',
      message: 'Bus $busNumber is taking a detour. Reason: $reason',
      busId: busId,
      timestamp: DateTime.now(),
      data: {
        'busNumber': busNumber,
        'reason': reason,
        'deviationKm': deviationKm,
      },
    );

    // Save notification
    await _firestore
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap());

    // Get all users tracking this bus
    final usersSnapshot = await _firestore
        .collection('users')
        .where('busId', isEqualTo: busId)
        .get();

    // Send to all users
    for (var userDoc in usersSnapshot.docs) {
      await _sendPushNotification(
        title: notification.title,
        body: notification.message,
        data: notification.data ?? {},
        userId: userDoc.id,
      );
    }
  }

  /// Send route change notification before journey
  Future<void> notifyRouteChange({
    required RouteChangeModel routeChange,
  }) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.routeChange,
      title: 'Route Change Alert',
      message:
          'Bus ${routeChange.busNumber} route has changed. New route: ${routeChange.newRoute}',
      busId: routeChange.busId,
      routeId: routeChange.id,
      timestamp: DateTime.now(),
      data: {
        'originalRoute': routeChange.originalRoute,
        'newRoute': routeChange.newRoute,
        'reason': routeChange.reason,
        'effectiveTime': routeChange.effectiveTime.toIso8601String(),
        'affectedStops': routeChange.affectedStops,
        'newStops': routeChange.newStops,
      },
    );

    // Save notification
    await _firestore
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap());

    // Save route change
    await _firestore
        .collection('route_changes')
        .doc(routeChange.id)
        .set(routeChange.toMap());

    // Get all users tracking this bus or affected stops
    final usersSnapshot = await _firestore
        .collection('users')
        .where('busId', isEqualTo: routeChange.busId)
        .get();

    // Also get users whose stops are affected
    final affectedUsersSnapshot = await _firestore
        .collection('students')
        .where('stopId', whereIn: routeChange.affectedStops)
        .get();

    // Send to all affected users
    final userIds = <String>{};
    for (var userDoc in usersSnapshot.docs) {
      userIds.add(userDoc.id);
    }
    for (var studentDoc in affectedUsersSnapshot.docs) {
      final studentData = studentDoc.data();
      if (studentData['userId'] != null) {
        userIds.add(studentData['userId']);
      }
    }

    for (var userId in userIds) {
      await _sendPushNotification(
        title: notification.title,
        body: notification.message,
        data: notification.data ?? {},
        userId: userId,
      );
    }
  }

  /// Send push notification
  Future<void> _sendPushNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
    required String userId,
  }) async {
    // Get user's FCM token
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final fcmToken = userDoc.data()?['fcmToken'];

    if (fcmToken != null) {
      // In a real app, you would send this via Firebase Cloud Messaging API
      // or use a backend service
      print('Sending notification to $userId: $title - $body');
    }
  }

  /// Get notifications for a user
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
}



