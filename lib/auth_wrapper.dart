import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/auth/login_screen.dart';
import 'screens/faculty/faculty_dashboard.dart';
import 'screens/student/student_profile_screen.dart';
import 'services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        // Checking initial login state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;

        // User is NOT logged in -> Show Login
        if (user == null) {
          return const LoginScreen();
        }

        // User IS logged in -> Fetch their Firestore profile & role
        return FutureBuilder<UserModel?>(
          future: authService.getUserData(user.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Verifying user permissions...'),
                    ],
                  ),
                ),
              );
            }

            final userModel = userSnapshot.data;

            // If user logged in via Auth but no Firestore record yet
            if (userModel == null) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('User profile not found.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => authService.signOut(),
                        child: const Text('Log Out'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // RBAC ROUTING BASED ON ROLE
            switch (userModel.role.toLowerCase()) {
              case 'super_admin':
              case 'admin':
                return AdminDashboard(currentUser: userModel);
              case 'faculty':
                return FacultyDashboard(currentUser: userModel);
              case 'student':
              default:
                return StudentProfileScreen(currentUser: userModel);
            }
          },
        );
      },
    );
  }
}
