import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/custom_bottom_nav.dart';
import 'cal_screen.dart';
import 'anketa_screen.dart';
import 'notifications_screen.dart';
import 'create_article_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  bool showReviews = false;
  bool _isLoadingAvatar = false;

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[200],
      child: const Icon(Icons.person, size: 80, color: Colors.grey),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _isLoadingAvatar = true;
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
            _isLoadingAvatar = false;
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
                    const SnackBar(content: Text('Аватарка успешно обновлена!')),
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
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Панель учителя'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Профиль', icon: Icon(Icons.person)),
            Tab(text: 'Уведомления', icon: Icon(Icons.notifications)),
          ],
          labelColor: AppColors.primaryPink,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryPink,
        ),
      ),
      body: TabBarView(
        children: [
          // Tab 1: Profile View
          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('anketas')
                  .where('userId', isEqualTo: currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                TutorAnketa? myAnketa;
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  myAnketa = TutorAnketa.fromFirestore(snapshot.data!.docs.first);
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Tutor Image
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _isLoadingAvatar 
                                ? Container(
                                    width: double.infinity,
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: const Center(child: CircularProgressIndicator()),
                                  )
                                : (myAnketa?.avatarUrl != null && myAnketa!.avatarUrl!.isNotEmpty)
                                  ? Image.network(
                                      myAnketa!.avatarUrl!,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                                    )
                                  : _buildPlaceholderImage(),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _showAvatarEditDialog(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.edit, size: 20, color: AppColors.primaryPink),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Name and Tags
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    AuthService().getCurrentUserName(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Wrap(
                                  alignment: WrapAlignment.end,
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: myAnketa != null && myAnketa.subjects.isNotEmpty
                                    ? myAnketa.subjects.map((s) => _buildTag(s)).toList()
                                    : [_buildTag('Предмет не указан')],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Status Badge
                            if (myAnketa != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: myAnketa.status == 'approved' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  myAnketa.status == 'approved' ? '● Активен' : '● На модерации',
                                  style: TextStyle(
                                    color: myAnketa.status == 'approved' ? Colors.green : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Description
                            Text(
                              myAnketa?.description ?? 'Вы еще не заполнили описание в анкете.',
                              style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                            ),
                            const SizedBox(height: 20),

                            // Experience
                            const Text('Ваш опыт работы', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              myAnketa?.experience ?? 'Информация об опыте появится здесь после заполнения анкеты.',
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(height: 24),

                            // Fill/Edit Anketa Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryPink.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryPink,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AnketaScreen()),
                                  );
                                },
                                child: Text(myAnketa == null ? 'Заполнить анкету репетитора' : 'Редактировать анкету'),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Publish Article Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.accentBlue.withOpacity(0.5)),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentBlue.withOpacity(0.1),
                                  foregroundColor: Colors.black87,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CreateArticleScreen()),
                                  );
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.edit_note, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Опубликовать статью', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Account Section
                            const Text('Аккаунт', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            
                            // Logout button
                            InkWell(
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
                                    Text('Выйти из аккаунта', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Delete Account button
                            InkWell(
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
                                        child: const Text('Да, удалить мой аккаунт', style: TextStyle(color: Colors.red)),
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
                            
                            const SizedBox(height: 30),

                            // Reviews Toggle
                            StreamBuilder<List<Review>>(
                              stream: AuthService().getTeacherReviews(currentUserId),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Ошибка: ${snapshot.error}');
                                }
                                final reviewsCount = snapshot.data?.length ?? 0;
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(() => showReviews = !showReviews),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Отзывы ($reviewsCount)',
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                                          ),
                                          Icon(showReviews ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                                        ],
                                      ),
                                    ),
                                    if (showReviews) ...[
                                      const SizedBox(height: 12),
                                      if (reviewsCount == 0)
                                        const Text('У вас пока нет отзывов', style: TextStyle(color: Colors.grey)),
                                      if (snapshot.hasData)
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: snapshot.data!.length,
                                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                                          itemBuilder: (context, index) {
                                            final review = snapshot.data![index];
                                            return _buildReviewCard(review);
                                          },
                                        ),
                                    ],
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 100),
                           ],
                         ),
                       ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Tab 2: Notifications View
          const NotificationsScreen(),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryPink,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryPink.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(review.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '${review.timestamp.day}.${review.timestamp.month}.${review.timestamp.year}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.comment, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
