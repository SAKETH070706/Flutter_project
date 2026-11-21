class StudentModel {
  final String id;
  final String rollNo;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String course;
  final int enrollmentYear;
  final String photoUrl; // Can be URL or Base64 string
  final String createdBy;

  StudentModel({
    required this.id,
    required this.rollNo,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.course,
    required this.enrollmentYear,
    this.photoUrl = '',
    this.createdBy = '',
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'rollNo': rollNo,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'course': course,
      'enrollmentYear': enrollmentYear,
      'photoUrl': photoUrl,
      'createdBy': createdBy,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Create Student from Firestore Map
  factory StudentModel.fromMap(Map<String, dynamic> map, String id) {
    return StudentModel(
      id: id,
      rollNo: map['rollNo'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      department: map['department'] ?? '',
      course: map['course'] ?? '',
      enrollmentYear: (map['enrollmentYear'] is int)
          ? map['enrollmentYear']
          : int.tryParse(map['enrollmentYear']?.toString() ?? '2024') ?? 2024,
      photoUrl: map['photoUrl'] ?? '',
      createdBy: map['createdBy'] ?? '',
    );
  }
}
