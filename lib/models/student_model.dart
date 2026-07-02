class StudentModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? parentPhoneNumber;
  final String? parentEmail;
  final String busId;
  final String stopId; // Their pickup/drop stop
  final bool isOnBus;
  final DateTime? boardedTime;
  final DateTime? droppedTime;

  StudentModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.parentPhoneNumber,
    this.parentEmail,
    required this.busId,
    required this.stopId,
    this.isOnBus = false,
    this.boardedTime,
    this.droppedTime,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      parentPhoneNumber: map['parentPhoneNumber'],
      parentEmail: map['parentEmail'],
      busId: map['busId'] ?? '',
      stopId: map['stopId'] ?? '',
      isOnBus: map['isOnBus'] ?? false,
      boardedTime: map['boardedTime']?.toDate(),
      droppedTime: map['droppedTime']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'parentPhoneNumber': parentPhoneNumber,
      'parentEmail': parentEmail,
      'busId': busId,
      'stopId': stopId,
      'isOnBus': isOnBus,
      'boardedTime': boardedTime,
      'droppedTime': droppedTime,
    };
  }
}



