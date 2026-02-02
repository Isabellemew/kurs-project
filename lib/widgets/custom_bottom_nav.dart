import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../screens/menu_screen.dart';
import '../screens/teacher_screen.dart';
import '../screens/rep_screen.dart';
import '../screens/cal_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/teacherprofile_screen.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  void _loadRole() async {
    final role = await AuthService().getUserRole();
    if (mounted) {
      setState(() {
        _role = role;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If role is not yet loaded, show a simple placeholder or just icons without navigation
    final isTeacher = _role == 'Учитель';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                context, 
                Icons.home, 
                0, 
                isTeacher ? const TeacherScreen() : const MenuScreen()
              ),
              _buildNavItem(context, Icons.menu_book, 1, const RepScreen()),
              _buildNavItem(context, Icons.calendar_today, 2, const CalScreen()),
              _buildNavItem(
                context, 
                Icons.person, 
                3, 
                isTeacher ? const TeacherProfileScreen() : const ProfileScreen()
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index, Widget screen) {
    final bool isSelected = widget.currentIndex == index;
    final Color iconColor = isSelected ? AppColors.primaryPink : AppColors.primaryYellow;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => screen,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
      child: Icon(
        icon,
        color: iconColor,
        size: 28,
      ),
    );
  }
}
