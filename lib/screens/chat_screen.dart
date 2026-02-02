import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String? title;
  final String? teacherId; // Used when student starts a chat

  const ChatScreen({
    super.key, 
    this.chatId, 
    this.title,
    this.teacherId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late String _chatId;
  late String _title;

  @override
  void initState() {
    super.initState();
    _title = widget.title ?? 'Чат';
    // If we're coming from notifications, we have chatId.
    // If student is starting, we might need to derive it.
    if (widget.chatId != null) {
      _chatId = widget.chatId!;
    } else if (widget.teacherId != null) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      _chatId = '${userId}_${widget.teacherId}';
    } else {
      _chatId = 'test_chat';
    }
    
    // Mark as read when opened
    AuthService().markChatAsRead(_chatId);
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // If it's a real chat session
      if (widget.teacherId != null) {
         await AuthService().sendMessage(widget.teacherId!, _title, text);
      } else {
        // Generic send for existing chat
        await FirebaseFirestore.instance.collection('chats').doc(_chatId).collection('messages').add({
          'senderId': user.uid,
          'text': text,
          'timestamp': FieldValue.serverTimestamp(),
        });
        
        await FirebaseFirestore.instance.collection('chats').doc(_chatId).update({
          'lastMessage': text,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
      
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Messages area
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return const Center(child: Text('Сообщений пока нет'));
                }

                return ListView.builder(
                  reverse: true, // Show latest at bottom
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final bool isMe = data['senderId'] == currentUserId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!isMe) ...[
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primaryYellow,
                              child: Icon(Icons.person, size: 18, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMe ? AppColors.primaryPink : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: isMe ? null : Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                data['text'] ?? '',
                                style: const TextStyle(fontSize: 15, height: 1.4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input area
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Написать сообщение...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primaryPink,
                      child: Icon(Icons.send, color: Colors.black, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
