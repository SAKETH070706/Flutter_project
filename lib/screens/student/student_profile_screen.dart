import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/student_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/cloudinary_service.dart';
import '../../services/student_service.dart';
import '../../widgets/student_avatar.dart';

class StudentProfileScreen extends StatefulWidget {
  final UserModel currentUser;

  const StudentProfileScreen({super.key, required this.currentUser});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _studentService = StudentService();
  final _authService = AuthService();
  bool _isUploadingPhoto = false;

  void _showCompleteProfileDialog() {
    final rollNoController = TextEditingController();
    final courseController = TextEditingController(text: 'B.Tech');
    final yearController = TextEditingController(text: '2024');
    final phoneController = TextEditingController();
    String selectedDept = widget.currentUser.department.isNotEmpty &&
            widget.currentUser.department != 'All'
        ? widget.currentUser.department
        : 'Computer Science';

    final formKey = GlobalKey<FormState>();

    final departments = [
      'Computer Science',
      'Information Technology',
      'Electronics & Communication',
      'Mechanical Engineering',
      'Civil Engineering',
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Complete Your Student Profile'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter your college details to link your account to the Admin & Faculty database.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: rollNoController,
                  decoration: const InputDecoration(
                    labelText: 'Roll Number *',
                    hintText: 'e.g. CS101',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: departments.contains(selectedDept)
                      ? selectedDept
                      : departments.first,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                  items: departments
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) selectedDept = val;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: courseController,
                  decoration: const InputDecoration(
                    labelText: 'Course',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enrollment Year',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final newStudent = StudentModel(
                id: '',
                rollNo: rollNoController.text.trim().toUpperCase(),
                name: widget.currentUser.name,
                email: widget.currentUser.email.trim().toLowerCase(),
                phone: phoneController.text.trim(),
                department: selectedDept,
                course: courseController.text.trim(),
                enrollmentYear: int.tryParse(yearController.text.trim()) ?? 2024,
                createdBy: 'Self-Registered',
              );

              await _studentService.addStudent(newStudent);
              if (mounted) {
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile linked successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save & Link'),
          ),
        ],
      ),
    );
  }

  // Upload Photo to Cloudinary
  Future<void> _updatePhoto(StudentModel student) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() => _isUploadingPhoto = true);
      final bytes = await pickedFile.readAsBytes();

      final cloudUrl = await CloudinaryService.uploadImage(
        bytes,
        fileName: 'student_${student.rollNo}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      if (cloudUrl != null && cloudUrl.isNotEmpty) {
        final updated = StudentModel(
          id: student.id,
          rollNo: student.rollNo,
          name: student.name,
          email: student.email,
          phone: student.phone,
          department: student.department,
          course: student.course,
          enrollmentYear: student.enrollmentYear,
          photoUrl: cloudUrl,
          createdBy: student.createdBy,
        );

        await _studentService.updateStudent(updated);
      }

      setState(() => _isUploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Portal'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => _authService.signOut(),
          ),
        ],
      ),
      body: FutureBuilder<StudentModel?>(
        future: _studentService.getStudentByEmail(widget.currentUser.email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final student = snapshot.data;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar with Cloudinary edit button
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.deepPurple.shade100,
                              backgroundImage: getStudentImageProvider(student?.photoUrl),
                              child: _isUploadingPhoto
                                  ? const CircularProgressIndicator(color: Colors.deepPurple)
                                  : (student == null || student.photoUrl.isEmpty)
                                      ? Text(
                                          widget.currentUser.name.isNotEmpty
                                              ? widget.currentUser.name[0].toUpperCase()
                                              : 'S',
                                          style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                          ),
                                        )
                                      : null,
                            ),
                            if (student != null)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: _isUploadingPhoto ? null : () => _updatePhoto(student),
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: const BoxDecoration(
                                      color: Colors.deepPurple,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.currentUser.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'ROLE: ${widget.currentUser.role.toUpperCase()}',
                            style: TextStyle(
                              color: Colors.deepPurple.shade900,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 12),

                        if (student != null) ...[
                          _infoRow(Icons.badge, 'Roll Number', student.rollNo),
                          _infoRow(Icons.school, 'Course', student.course),
                          _infoRow(Icons.domain, 'Department', student.department),
                          _infoRow(Icons.calendar_today, 'Enrollment Year',
                              '${student.enrollmentYear}'),
                          _infoRow(Icons.email, 'Email', student.email),
                          if (student.phone.isNotEmpty)
                            _infoRow(Icons.phone, 'Phone', student.phone),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.link_off,
                                    color: Colors.orange, size: 36),
                                const SizedBox(height: 8),
                                const Text(
                                  'Your account is not yet linked to a Student Record.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Click the button below to link your roll number and branch so teachers and admins can view your record.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton.icon(
                                  onPressed: _showCompleteProfileDialog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.add_link),
                                  label: const Text('Complete & Link Profile'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 14),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
