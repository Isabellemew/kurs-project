import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/auth_service.dart';
import 'poisk_screen.dart';
import 'chat_screen.dart';
import 'cal_screen.dart';

class RepScreen extends StatefulWidget {
  const RepScreen({super.key});

  @override
  State<RepScreen> createState() => _RepScreenState();
}

class _RepScreenState extends State<RepScreen> {
  Stream<List<TutorAnketa>> _getApprovedTutors() {
    return FirebaseFirestore.instance
        .collection('anketas')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TutorAnketa.fromFirestore(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Balapan
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
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

              // Search Bar
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink.withOpacity(0.5), // Светло-розовый
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryPink.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.black54, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Поиск репетитора',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54, // Менее насыщенный черный
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.tune, color: Colors.black54, size: 20),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // All Tutors Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Наши репетиторы',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
              
              StreamBuilder<List<TutorAnketa>>(
                stream: _getApprovedTutors(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: AppColors.primaryYellow),
                    ));
                  }

                  final tutors = snapshot.data ?? [];

                  if (tutors.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text('Пока нет одобренных репетиторов'),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82, // Увеличил, чтобы карточки были короче
                    ),
                    itemCount: tutors.length,
                    itemBuilder: (context, index) {
                      final tutor = tutors[index];
                      return _buildTutorCard(tutor, height: 95); // Еще немного уменьшил высоту фото
                    },
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildTutorCard(TutorAnketa tutor, {double height = 140}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentTutorProfileScreen(tutor: tutor),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.primaryPink.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: tutor.avatarUrl != null && tutor.avatarUrl!.isNotEmpty
                      ? Image.network(
                          tutor.avatarUrl!,
                          width: double.infinity,
                          height: height,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(height),
                        )
                      : _buildImagePlaceholder(height),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tutor.subjects.isNotEmpty ? tutor.subjects.first : 'Предмет',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // Rating Badge
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite, color: Colors.pink, size: 10),
                        const SizedBox(width: 2),
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance.collection('anketas').doc(tutor.id).snapshots(),
                          builder: (context, snapshot) {
                            final likesCount = (snapshot.data?.data() as Map<String, dynamic>?)?['likesCount'] ?? 0;
                            return Text('$likesCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold));
                          }
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutor.tutorName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tutor.description,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(double height) {
    return Container(
      width: double.infinity,
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.person, size: 40, color: Colors.grey),
    );
  }
}

class StudentTutorProfileScreen extends StatefulWidget {
  final TutorAnketa tutor;

  const StudentTutorProfileScreen({super.key, required this.tutor});

  @override
  State<StudentTutorProfileScreen> createState() => _StudentTutorProfileScreenState();
}

class _StudentTutorProfileScreenState extends State<StudentTutorProfileScreen> {
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLike = true;

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await AuthService().submitReview(
        teacherId: widget.tutor.userId,
        comment: _reviewController.text.trim(),
        isLike: _isLike,
      );
      _reviewController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Отзыв опубликован!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showEditReviewDialog(Review review) {
    final TextEditingController editController = TextEditingController(text: review.comment);
    bool editIsLike = review.isLike;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Редактировать отзыв'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Row(
                children: [
                  const Text('Оценка: '),
                  IconButton(
                    icon: Icon(editIsLike ? Icons.thumb_up : Icons.thumb_up_outlined),
                    color: editIsLike ? Colors.green : Colors.grey,
                    onPressed: () => setDialogState(() => editIsLike = true),
                  ),
                  IconButton(
                    icon: Icon(!editIsLike ? Icons.thumb_down : Icons.thumb_down_outlined),
                    color: !editIsLike ? Colors.red : Colors.grey,
                    onPressed: () => setDialogState(() => editIsLike = false),
                  ),
                ],
              ),
              TextField(
                controller: editController,
                maxLines: 3,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () async {
                await AuthService().updateReview(
                  reviewId: review.id,
                  teacherId: widget.tutor.userId,
                  newComment: editController.text,
                  wasLike: review.isLike,
                  newIsLike: editIsLike,
                );
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.tutor.tutorName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                image: (widget.tutor.avatarUrl != null && widget.tutor.avatarUrl!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(widget.tutor.avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (widget.tutor.avatarUrl == null || widget.tutor.avatarUrl!.isEmpty)
                  ? const Center(child: Icon(Icons.person, size: 100, color: Colors.grey))
                  : null,
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.tutor.tutorName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.pink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite, color: Colors.pink, size: 20),
                            const SizedBox(width: 4),
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance.collection('anketas').doc(widget.tutor.id).snapshots(),
                              builder: (context, snapshot) {
                                final likes = (snapshot.data?.data() as Map<String, dynamic>?)?['likesCount'] ?? 0;
                                return Text('$likes', style: const TextStyle(fontWeight: FontWeight.bold));
                              }
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.tutor.subjects.map((s) => Chip(
                      label: Text(s),
                      backgroundColor: AppColors.primaryPink.withOpacity(0.3),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('О себе', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.tutor.description, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 20),
                  const Text('Опыт', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.tutor.experience, style: const TextStyle(fontSize: 16)),
                  
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),
                  
                  // Reviews Section
                  const Text('Отзывы и оценка', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Review Input
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('Ваша оценка: '),
                            IconButton(
                              icon: Icon(_isLike ? Icons.thumb_up : Icons.thumb_up_outlined),
                              color: _isLike ? Colors.green : Colors.grey,
                              onPressed: () => setState(() => _isLike = true),
                            ),
                            IconButton(
                              icon: Icon(!_isLike ? Icons.thumb_down : Icons.thumb_down_outlined),
                              color: !_isLike ? Colors.red : Colors.grey,
                              onPressed: () => setState(() => _isLike = false),
                            ),
                          ],
                        ),
                        TextField(
                          controller: _reviewController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Оставьте свой отзыв...',
                            border: InputBorder.none,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitReview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPink,
                            ),
                            child: _isSubmitting 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Отправить'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Reviews List
                  StreamBuilder<List<Review>>(
                    stream: AuthService().getTeacherReviews(widget.tutor.userId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Text('Ошибка: ${snapshot.error}');
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final reviews = snapshot.data ?? [];
                      if (reviews.isEmpty) return const Text('Пока нет отзывов');
                      
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          final isMyReview = review.studentId == currentUserId;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primaryPink.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(review.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Row(
                                      children: [
                                        Icon(review.isLike ? Icons.thumb_up : Icons.thumb_down, 
                                          size: 16, color: review.isLike ? Colors.green : Colors.red),
                                        if (isMyReview) ...[
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 16),
                                            onPressed: () => _showEditReviewDialog(review),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                            onPressed: () async {
                                              await AuthService().deleteReview(review.id, widget.tutor.userId, review.isLike);
                                            },
                                          ),
                                        ]
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(review.comment, style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: AppColors.primaryPink,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalScreen(tutor: widget.tutor)),
            );
          },
          child: const Text('Забронировать урок'),
        ),
      ),
    );
  }
}
