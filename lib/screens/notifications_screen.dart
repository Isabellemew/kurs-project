import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_theme.dart';
import 'chat_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Вы не авторизованы'));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('teacherId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Уведомлений пока нет',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            return _buildNotificationItem(
              context,
              studentName: data['studentName'] ?? 'Студент',
              lastMessage: data['lastMessage'] ?? 'Новое сообщение',
              time: _formatTime(data['lastMessageTime']),
              isRead: data['isRead'] ?? false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen(
                    chatId: doc.id,
                    title: data['studentName'] ?? 'Чат',
                  )),
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    final DateTime dt = (timestamp as Timestamp).toDate();
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required String studentName,
    required String lastMessage,
    required String time,
    required bool isRead,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : AppColors.primaryPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isRead ? Colors.grey.shade200 : AppColors.primaryPink),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryYellow,
          child: Text(studentName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
        ),
        title: Text(
          studentName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.black54),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
            if (!isRead)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primaryPink,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
