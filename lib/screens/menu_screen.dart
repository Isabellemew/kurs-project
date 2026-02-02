import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';
import 'rep_screen.dart';
import 'poisk_screen.dart';
import 'teacher_screen.dart';
import 'article_screen.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Avatar and Greeting
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPink,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.bolt, color: Colors.black, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Привет, ${AuthService().getCurrentUserName()}!',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600, // Менее жирный
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Давай подберем тебе репетитора!',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400, // Менее жирный
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar - NOW ON TOP
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PoiskScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink.withOpacity(0.5), // Более светлый розовый
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryPink.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.black54, size: 22),
                        SizedBox(width: 12),
                        Text(
                          'Кого будем искать?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54, // Менее насыщенный черный
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.tune, color: Colors.black54, size: 22),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Top Teachers Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Наши лучшие учителя',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                    ),
                    SizedBox(width: 8),
                    Text('🔥', style: TextStyle(fontSize: 19)),
                  ],
                ),
              ),
              
              StreamBuilder<List<TutorAnketa>>(
                stream: AuthService().getTopTwoTutors(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return StreamBuilder<List<TutorAnketa>>(
                      stream: FirebaseFirestore.instance
                          .collection('anketas')
                          .where('status', isEqualTo: 'approved')
                          .limit(2)
                          .snapshots()
                          .map((s) => s.docs.map((d) => TutorAnketa.fromFirestore(d)).toList()),
                      builder: (context, fallbackSnapshot) {
                        final tutors = fallbackSnapshot.data ?? [];
                        if (tutors.isEmpty) return _buildEmptyTop();
                        return _buildTopList(context, tutors);
                      },
                    );
                  }
                  
                  final tutors = snapshot.data ?? [];
                  if (tutors.isEmpty && snapshot.connectionState == ConnectionState.active) {
                    return _buildEmptyTop();
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                     return const Center(child: Padding(
                       padding: EdgeInsets.all(20.0),
                       child: CircularProgressIndicator(color: AppColors.primaryPink),
                     ));
                  }
                  
                  return _buildTopList(context, tutors);
                },
              ),

              const SizedBox(height: 8),

              // Articles Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Интересные статьи',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ArticlesScreen()),
                            );
                          },
                          child: const Text('Все', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ArticlesScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(color: AppColors.primaryPink.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.primaryPink,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(Icons.menu_book_rounded, color: Colors.black, size: 30),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Как подготовиться к экзаменам?',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '5 работающих советов от наших лучших репетиторов для успешной сдачи...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildEmptyTop() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Center(
        child: Text('Пока нет активных репетиторов', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildTopList(BuildContext context, List<TutorAnketa> tutors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: tutors.map((tutor) => Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentTutorProfileScreen(tutor: tutor),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: AppColors.primaryPink.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: tutor.avatarUrl != null && tutor.avatarUrl!.isNotEmpty
                      ? Image.network(
                          tutor.avatarUrl!,
                          width: double.infinity,
                          height: 110, // Уменьшил высоту
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(110),
                        )
                      : _buildPlaceholder(110),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Более компактные отступы
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tutor.tutorName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4), // Уменьшил отступ
                        Row(
                          children: [
                            const Icon(Icons.favorite, color: Colors.pink, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${tutor.likesCount}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox.shrink(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildPlaceholder(double height) {
    return Container(
      width: double.infinity,
      height: height,
      color: Colors.grey[100],
      child: const Icon(Icons.person, color: Colors.grey, size: 50),
    );
  }
}
