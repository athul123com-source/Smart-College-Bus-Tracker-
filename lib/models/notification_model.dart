enum NotificationType {
  studentDropped,
  detour,
  routeChange,
  busDelayed,
  busCancelled,
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String? busId;
  final String? studentId;
  final String? routeId;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.busId,
    this.studentId,
    this.routeId,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => NotificationType.routeChange,
      ),
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      busId: map['busId'],
      studentId: map['studentId'],
      routeId: map['routeId'],
      timestamp: map['timestamp']?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      data: map['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'message': message,
      'busId': busId,
      'studentId': studentId,
      'routeId': routeId,
      'timestamp': timestamp,
      'isRead': isRead,
      'data': data,
    };
  }
}



