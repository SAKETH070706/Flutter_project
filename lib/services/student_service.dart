import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

class StudentService {
  final CollectionReference _studentsRef =
      FirebaseFirestore.instance.collection('students');

  // Stream of students with real-time updates and memory sorting
  Stream<List<StudentModel>> streamStudents({String? departmentFilter}) {
    Query query = _studentsRef;
    if (departmentFilter != null &&
        departmentFilter.isNotEmpty &&
        departmentFilter != 'All') {
      query = query.where('department', isEqualTo: departmentFilter);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return StudentModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      // Memory sorting prevents Firestore composite index errors
      list.sort((a, b) => a.rollNo.compareTo(b.rollNo));
      return list;
    });
  }

  // Add a new student
  Future<void> addStudent(StudentModel student) async {
    await _studentsRef.add(student.toMap());
  }

  // Update student
  Future<void> updateStudent(StudentModel student) async {
    await _studentsRef.doc(student.id).update(student.toMap());
  }

  // Delete student
  Future<void> deleteStudent(String studentId) async {
    await _studentsRef.doc(studentId).delete();
  }

  // Find student by email (for student role self-view)
  Future<StudentModel?> getStudentByEmail(String email) async {
    final snapshot = await _studentsRef
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return StudentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }
}
