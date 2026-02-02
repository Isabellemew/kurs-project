import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/rep_screen.dart';
import 'screens/cal_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/teacher_screen.dart';
import 'screens/moderator_screen.dart';
import 'screens/teacherprofile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase error: $e. Using mock mode.");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Balapan App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/menu': (context) => const MenuScreen(),
        '/rep_screen': (context) => const RepScreen(),
        '/calendar': (context) => const CalScreen(),
        '/profile': (context) => ProfileScreen(),
        '/moderator': (context) => const ModeratorScreen(),
        '/teacher_home': (context) => TeacherScreen(),
        '/teacher_profile': (context) => TeacherProfileScreen(),
      },
    );
  }
}