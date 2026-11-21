class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'super_admin', 'admin', 'faculty', 'student'
  final String department;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.department = '',
  });

  // Convert to Map for Firestore (like JSON in MongoDB)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'department': department,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Create UserModel from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      department: map['department'] ?? '',
    );
  }
}
