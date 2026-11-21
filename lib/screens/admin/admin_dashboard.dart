import 'package:flutter/material.dart';
import '../../models/student_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/student_service.dart';
import '../../widgets/student_avatar.dart';
import '../auth/staff_register_screen.dart';
import 'add_student_screen.dart';
import 'edit_student_screen.dart';

class AdminDashboard extends StatefulWidget {
  final UserModel currentUser;

  const AdminDashboard({super.key, required this.currentUser});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _studentService = StudentService();
  final _authService = AuthService();
  final _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedDeptFilter = 'All';
  String _sortBy = 'Roll No'; // 'Roll No', 'Name', 'Year'

  final List<String> _departments = [
    'All',
    'Computer Science',
    'Information Technology',
    'Electronics & Communication',
    'Mechanical Engineering',
    'Civil Engineering',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddStudent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddStudentScreen(currentUser: widget.currentUser),
      ),
    );
  }

  Future<void> _confirmDelete(StudentModel student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Student Record'),
        content: Text(
          'Are you sure you want to permanently delete ${student.name} (${student.rollNo})? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _studentService.deleteStudent(student.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${student.name} has been removed.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _showStudentDetails(StudentModel student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.school, color: Colors.indigo),
            const SizedBox(width: 8),
            const Text('Student Profile'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.indigo.shade100,
                backgroundImage: getStudentImageProvider(student.photoUrl),
                child: student.photoUrl.isEmpty
                    ? Text(
                        student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                student.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Roll No: ${student.rollNo}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade800,
                ),
              ),
              const Divider(height: 24),
              _detailRow(Icons.domain, 'Department', student.department),
              _detailRow(Icons.book, 'Course', student.course),
              _detailRow(Icons.calendar_today, 'Enrollment Year', '${student.enrollmentYear}'),
              _detailRow(Icons.email, 'Email', student.email),
              if (student.phone.isNotEmpty)
                _detailRow(Icons.phone, 'Phone', student.phone),
              if (student.createdBy.isNotEmpty)
                _detailRow(Icons.person_pin, 'Registered By', student.createdBy),
            ],
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditStudentScreen(student: student),
                ),
              );
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit Details'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.indigo),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'College Admin Portal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Logged in: ${widget.currentUser.name} (${widget.currentUser.role.toUpperCase()})',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // Top Add Student Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: ElevatedButton.icon(
              onPressed: _navigateToAddStudent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text(
                'Add Student',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Onboard Faculty / Admin',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StaffRegisterScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => _authService.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Action & Controls Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              border: Border(bottom: BorderSide(color: Colors.indigo.shade100)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Search Box
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by student name or roll number...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                        ),
                        onChanged: (val) {
                          setState(() => _searchQuery = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Department Filter
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedDeptFilter,
                            isExpanded: true,
                            icon: const Icon(Icons.filter_alt_outlined),
                            items: _departments.map((dept) {
                              return DropdownMenuItem(
                                value: dept,
                                child: Text(
                                  dept == 'All' ? 'All Departments' : dept,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedDeptFilter = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Sort By Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortBy,
                          icon: const Icon(Icons.sort),
                          items: const [
                            DropdownMenuItem(value: 'Roll No', child: Text('Sort: Roll No')),
                            DropdownMenuItem(value: 'Name', child: Text('Sort: Name')),
                            DropdownMenuItem(value: 'Year', child: Text('Sort: Year')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _sortBy = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // STREAM BUILDER IS ONLY AROUND THE LIST (Prevents rebuilding search bar!)
          Expanded(
            child: StreamBuilder<List<StudentModel>>(
              stream: _studentService.streamStudents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error loading data: ${snapshot.error}'),
                    ),
                  );
                }

                final allStudents = snapshot.data ?? [];

                // Filter
                var filteredStudents = allStudents.where((s) {
                  final query = _searchQuery.toLowerCase().trim();
                  final matchesSearch = query.isEmpty ||
                      s.name.toLowerCase().contains(query) ||
                      s.rollNo.toLowerCase().contains(query) ||
                      s.email.toLowerCase().contains(query);
                  final matchesDept = _selectedDeptFilter == 'All' || s.department == _selectedDeptFilter;
                  return matchesSearch && matchesDept;
                }).toList();

                // Sort
                if (_sortBy == 'Name') {
                  filteredStudents.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                } else if (_sortBy == 'Year') {
                  filteredStudents.sort((a, b) => b.enrollmentYear.compareTo(a.enrollmentYear));
                } else {
                  filteredStudents.sort((a, b) => a.rollNo.compareTo(b.rollNo));
                }

                return Column(
                  children: [
                    // Quick Stats strip
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      child: Row(
                        children: [
                          Text(
                            'Showing ${filteredStudents.length} of ${allStudents.length} Students',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade900,
                              fontSize: 13,
                            ),
                          ),
                          if (_selectedDeptFilter != 'All') ...[
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(_selectedDeptFilter, style: const TextStyle(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                              onDeleted: () => setState(() => _selectedDeptFilter = 'All'),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            '💡 Click on any card to view full details',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),

                    // Student List
                    Expanded(
                      child: filteredStudents.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    allStudents.isEmpty
                                        ? 'No students registered yet.\nClick "+ Add Student" at the top to create one.'
                                        : 'No students match your search filter.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                                  ),
                                  if (allStudents.isEmpty) ...[
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: _navigateToAddStudent,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigo,
                                        foregroundColor: Colors.white,
                                      ),
                                      icon: const Icon(Icons.person_add),
                                      label: const Text('Add First Student'),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              itemCount: filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = filteredStudents[index];

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _showStudentDetails(student),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          // Avatar supporting Cloudinary and Base64
                                          CircleAvatar(
                                            radius: 26,
                                            backgroundColor: Colors.indigo.shade100,
                                            backgroundImage: getStudentImageProvider(student.photoUrl),
                                            child: student.photoUrl.isEmpty
                                                ? Text(
                                                    student.name.isNotEmpty
                                                        ? student.name[0].toUpperCase()
                                                        : '?',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Colors.indigo,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 14),

                                          // Student Details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      student.name,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.indigo.shade50,
                                                        borderRadius: BorderRadius.circular(6),
                                                        border: Border.all(
                                                          color: Colors.indigo.shade200,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        student.rollNo,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.indigo.shade900,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '🎓 ${student.course} • ${student.department} (Batch ${student.enrollmentYear})',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '✉️ ${student.email} ${student.phone.isNotEmpty ? " • 📞 " + student.phone : ""}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Action Buttons: Edit and Delete
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit_outlined, color: Colors.indigo),
                                                tooltip: 'Edit Student',
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => EditStudentScreen(student: student),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                                tooltip: 'Delete Student',
                                                onPressed: () => _confirmDelete(student),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
