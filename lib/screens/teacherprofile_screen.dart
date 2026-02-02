import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';
import 'anketa_screen.dart';
import 'settings_screen.dart';
import 'create_article_screen.dart';
import '../services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  bool _isLoading = false;

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text('👩‍🏫', style: TextStyle(fontSize: 80)),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final File file = File(image.path);
        final String downloadUrl = await AuthService().uploadTeacherAvatar(file);
        await AuthService().updateUserAvatar(downloadUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Аватарка успешно загружена!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка при загрузке: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showAvatarEditDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить аватарку'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _pickImage();
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Выбрать из галереи'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Или введите ссылку:'),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: 'https://example.com/photo.jpg',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (urlController.text.isNotEmpty) {
                await AuthService().updateUserAvatar(urlController.text);
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Аватарка обновлена!')),
                  );
                }
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

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
                    Stack(
                      children: [
                        _isLoading 
                          ? const SizedBox(
                              width: 120,
                              height: 120,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : FutureBuilder<String?>(
                              future: AuthService().getUserAvatar(),
                              builder: (context, snapshot) {
                                final avatarUrl = snapshot.data;
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: avatarUrl != null && avatarUrl.isNotEmpty
                                    ? Image.network(
                                        avatarUrl,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(),
                                      )
                                    : _buildAvatarPlaceholder(), // Changed fallback from Image.asset
                                );
                              },
                            ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _showAvatarEditDialog(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryPink,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, size: 20, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Teacher info card
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
                    Expanded(
                      child: Text(
                        AuthService().getCurrentUserName(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Subject tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school, color: Colors.black, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Математика и Физика',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Menu Items
              _buildMenuItem(
                context,
                title: 'Настройки',
                icon: Icons.settings,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),

              const SizedBox(height: 12),

              _buildMenuItem(
                context,
                title: 'Создать анкету',
                icon: Icons.article,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AnketaScreen()),
                  );
                },
              ),
              
              const SizedBox(height: 12),

              _buildMenuItem(
                context,
                title: 'Опубликовать статью',
                icon: Icons.edit_note,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateArticleScreen()),
                  );
                },
              ),

              const SizedBox(height: 12),

              _buildMenuItem(
                context,
                title: 'Выйти из системы',
                icon: Icons.logout,
                onTap: () {
                  AuthService().logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: InkWell(
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Удаление аккаунта'),
                        content: const Text(
                          'Вы уверены? Ваша анкета, отзывы, бронирования и чаты будут удалены навсегда без возможности восстановления.',
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Удалить аккаунт',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.delete_forever, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryPink.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Icon(icon, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}
