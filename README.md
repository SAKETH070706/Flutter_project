# 🎓 Student Registration & Database Portal

A cross-platform Flutter application featuring **Role-Based Access Control (RBAC)**, real-time **Cloud Firestore** database, **Firebase Authentication**, and **Cloudinary** media storage.

---

## ✨ Features

- **👑 Admin Portal**:
  - Full CRUD operations (Add, View, Edit, Delete students).
  - Real-time search by name, roll number, or email.
  - Filter by department and sort by Roll No, Name, or Enrollment Year.
  - Onboard new Faculty and Admin accounts.

- **👨‍🏫 Faculty Portal**:
  - Department-scoped access: Faculty members only see students from their assigned branch.
  - Read-only protection (no unauthorized additions or deletions).
  - Detailed student profile viewer.

- **🎓 Student Portal**:
  - Self-service registration automatically linked to the central student database.
  - Profile card displaying roll number, branch, course, and enrollment batch.
  - Direct profile photo upload to Cloudinary.

- **🔒 Security & RBAC**:
  - Unified Single Sign-On (SSO) login with automatic role detection.
  - Public registration is restricted to Students.
  - Staff & Admin onboarding is protected behind an institutional passkey (**`admin123`**).

---

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart) with Material 3 design
- **Authentication**: Firebase Auth (Email & Password)
- **Database**: Cloud Firestore (Real-time NoSQL)
- **Media Storage**: Cloudinary (Image CDN)

---

## 📁 Project Structure

```
lib/
├── models/
│   ├── student_model.dart          # Student schema & Firestore serializer
│   └── user_model.dart             # User profile & RBAC role model
├── services/
│   ├── auth_service.dart           # Authentication & role sync
│   ├── cloudinary_service.dart     # Signed photo uploads to Cloudinary
│   └── student_service.dart        # Firestore CRUD operations
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart       # Unified login with secret crest trigger
│   │   ├── register_screen.dart    # Public student self-registration
│   │   └── staff_register_screen.dart # Protected staff & faculty onboarding
│   ├── admin/
│   │   ├── admin_dashboard.dart    # Full management dashboard
│   │   ├── add_student_screen.dart # Register student + photo upload
│   │   └── edit_student_screen.dart# Update existing student records
│   ├── faculty/
│   │   └── faculty_dashboard.dart  # Scoped branch viewer
│   └── student/
│       └── student_profile_screen.dart # Student self-profile card
├── widgets/
│   └── student_avatar.dart         # Universal CDN & cache image handler
├── auth_wrapper.dart               # Gateway router directing users by role
├── firebase_options.dart           # Firebase configuration
└── main.dart                       # App entry point & theme configuration
```

---

## 🚀 Getting Started

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.16+)
- A web browser (Chrome) or an Android device/emulator

### 2. Clone the Repository
```bash
git clone https://github.com/SAKETH070706/Flutter_project.git
cd Flutter_project
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run the Application
```bash
# Run in Google Chrome (Fastest)
flutter run -d chrome

# Or run on connected Android device / emulator
flutter run
```

### 5. Build Release Android APK
```bash
flutter build apk --release
```
*The output file will be at: `build/app/outputs/flutter-apk/app-release.apk`*

---

## 🔑 Demo Access Notes

- **Student Registration**: Click **"Register as Student"** on the main sign-in screen.
- **Staff / Admin Registration**: Click the **College Crest Icon** at the top of the sign-in screen and enter the passkey:
  ```
  Passkey: admin123
  ```
- **Login**: Enter any registered credentials into the main login screen; the app automatically directs to the correct dashboard based on role.
