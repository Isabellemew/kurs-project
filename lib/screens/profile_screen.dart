import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';
import 'teacherprofile_screen.dart';
import 'settings_screen.dart';
import 'user_schedule_screen.dart'; // Добавил
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Balapan',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryPink,
                    ),
                  ),
                ),
              ),

              // Avatar section
              Container(
                width: double.infinity,
                color: AppColors.primaryYellow,
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        'assets/images/profile.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '👧',
                                style: TextStyle(fontSize: 80),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // User info card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryPink,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.person, color: Colors.black, size: 28),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AuthService().getCurrentUserName(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // My Schedule Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserScheduleScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryPink.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 22, color: AppColors.primaryPink),
                        SizedBox(width: 12),
                        Text(
                          'Мое расписание',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.chevron_right, size: 24, color: AppColors.primaryPink),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Settings button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.settings_outlined, size: 20, color: Colors.black54),
                      const SizedBox(width: 12),
                        Text('Настройки', style: TextStyle(fontWeight: FontWeight.w500)),
                        Spacer(),
                        Icon(Icons.chevron_right, size: 20, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
              ),

              // Logout button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: InkWell(
                  onTap: () {
                    AuthService().logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.1)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Выйти', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),

              // Delete Account button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: InkWell(
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Удаление аккаунта'),
                        content: const Text(
                          'Вы уверены? Все ваши данные (профиль, бронирования, чаты) будут удалены навсегда без возможности восстановления.',
                          style: TextStyle(color: Colors.red),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Отмена'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Да, удалить всё', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        await AuthService().deleteAccount();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ваш аккаунт полностью удален')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ошибка при удалении: $e')),
                          );
                        }
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.delete_forever, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          'Удалить аккаунт',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 120), // Отступ для нижней панели
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}
