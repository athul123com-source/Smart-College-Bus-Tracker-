class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'driver', 'student', 'teacher', 'parent', or 'admin'
  final String? phoneNumber;
  final String? busId; // For drivers: their bus ID, for students: selected bus ID

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.busId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      phoneNumber: map['phoneNumber'],
      busId: map['busId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phoneNumber': phoneNumber,
      'busId': busId,
    };
  }
}



