import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class TutorAnketa {
  final String id;
  final String tutorName;
  final List<String> subjects;
  final String experience;
  final String description;
  final String location;
  final String status;
  final String userId;
  final String? avatarUrl;
  final int likesCount;

  TutorAnketa({
    required this.id,
    required this.tutorName,
    required this.subjects,
    required this.experience,
    required this.description,
    required this.location,
    this.status = 'pending',
    required this.userId,
    this.avatarUrl,
    this.likesCount = 0,
  });

  factory TutorAnketa.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TutorAnketa(
      id: doc.id,
      tutorName: data['tutorName'] ?? '',
      subjects: List<String>.from(data['subjects'] ?? []),
      experience: data['experience'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      status: data['status'] ?? 'pending',
      userId: data['userId'] ?? '',
      avatarUrl: data['avatarUrl'],
      likesCount: data['likesCount'] ?? 0,
    );
  }
}

class Review {
  final String id;
  final String studentId;
  final String studentName;
  final String teacherId;
  final String comment;
  final bool isLike;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.teacherId,
    required this.comment,
    required this.isLike,
    required this.timestamp,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      teacherId: data['teacherId'] ?? '',
      comment: data['comment'] ?? '',
      isLike: data['isLike'] ?? true,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class Article {
  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;

  Article({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.timestamp,
  });

  factory Article.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Article(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? validatePassword(String password) {
    if (password.length < 8) return 'Пароль должен быть не менее 8 символов';
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(password)) {
      return 'Пароль должен содержать латинские буквы и цифры';
    }
    return null;
  }

  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> register(String name, String email, String password, String role) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(name);
      
      // Save role to Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // await sendVerificationEmail(); // Disabled for now
      return true;
    } catch (e) {
      debugPrint("Registration error: $e");
      return false;
    }
  }

  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
    } catch (e) {
      debugPrint("Error fetching user role: $e");
    }
    return null;
  }

  Future<fb.User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      debugPrint("Login error: $e");
      return null;
    }
  }

  void logout() async {
    await _auth.signOut();
  }

  bool isModerator(String? email) {
    return email == 'a.serikbay007@gmail.com';
  }

  String getCurrentUserName() {
    final user = _auth.currentUser;
    return user?.displayName ?? 'Пользователь';
  }

  // Teacher Anketa Methods
  Future<void> submitAnketa({
    required String name,
    required List<String> subjects,
    required String experience,
    required String description,
    required String location,
    String? avatarUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Check if an anketa already exists for this user with a timeout
      final existingAnketas = await _firestore
          .collection('anketas')
          .where('userId', isEqualTo: user.uid)
          .get()
          .timeout(const Duration(seconds: 10));

      final data = {
        'tutorName': name,
        'subjects': subjects,
        'experience': experience,
        'description': description,
        'location': location,
        'status': 'pending', 
        'userId': user.uid,
        'avatarUrl': avatarUrl,
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (existingAnketas.docs.isNotEmpty) {
        await _firestore
            .collection('anketas')
            .doc(existingAnketas.docs.first.id)
            .update(data)
            .timeout(const Duration(seconds: 10));
      } else {
        await _firestore
            .collection('anketas')
            .add(data)
            .timeout(const Duration(seconds: 10));
      }
    } catch (e) {
      debugPrint("Error submitting anketa: $e");
      if (e.toString().contains('PERMISSION_DENIED')) {
        throw 'Ошибка доступа: включите Firestore в консоли Firebase';
      }
      rethrow;
    }
  }

  Stream<List<TutorAnketa>> getPendingAnketas() {
    return _firestore
        .collection('anketas')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TutorAnketa.fromFirestore(doc)).toList());
  }

  Stream<List<TutorAnketa>> getAllAnketas() {
    return _firestore
        .collection('anketas')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TutorAnketa.fromFirestore(doc)).toList());
  }

  Future<void> approveAnketa(String id) async {
    await _firestore.collection('anketas').doc(id).update({'status': 'approved'});
  }

  Future<void> deleteAnketa(String id) async {
    await _firestore.collection('anketas').doc(id).delete();
  }

  Future<void> sendForRevision(String id) async {
    await _firestore.collection('anketas').doc(id).update({'status': 'revision'});
  }

  Future<void> updateUserAvatar(String url) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Update user doc
    await _firestore.collection('users').doc(user.uid).update({'avatarUrl': url});

    // Update anketa if exists
    final anketas = await _firestore
        .collection('anketas')
        .where('userId', isEqualTo: user.uid)
        .get();
    
    if (anketas.docs.isNotEmpty) {
      await _firestore.collection('anketas').doc(anketas.docs.first.id).update({'avatarUrl': url});
    }
  }

  Future<String> uploadTeacherAvatar(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not logged in';

    final ref = FirebaseStorage.instance
        .ref()
        .child('avatars')
        .child('${user.uid}.jpg');

    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final String userId = user.uid;

    try {
      // 1. Delete user document
      await _firestore.collection('users').doc(userId).delete();

      // 2. Delete teacher anketa if exists
      final anketas = await _firestore.collection('anketas').where('userId', isEqualTo: userId).get();
      for (var doc in anketas.docs) {
        await doc.reference.delete();
      }

      // 3. Delete bookings
      final studentBookings = await _firestore.collection('bookings').where('studentId', isEqualTo: userId).get();
      for (var doc in studentBookings.docs) {
        await doc.reference.delete();
      }
      final teacherBookings = await _firestore.collection('bookings').where('teacherId', isEqualTo: userId).get();
      for (var doc in teacherBookings.docs) {
        await doc.reference.delete();
      }

      // 4. Delete reviews
      final studentReviews = await _firestore.collection('reviews').where('studentId', isEqualTo: userId).get();
      for (var doc in studentReviews.docs) {
        await doc.reference.delete();
      }
      final teacherReviews = await _firestore.collection('reviews').where('teacherId', isEqualTo: userId).get();
      for (var doc in teacherReviews.docs) {
        await doc.reference.delete();
      }

      // 5. Delete chats
      final studentChats = await _firestore.collection('chats').where('studentId', isEqualTo: userId).get();
      for (var doc in studentChats.docs) {
        await doc.reference.delete();
      }
      final teacherChats = await _firestore.collection('chats').where('teacherId', isEqualTo: userId).get();
      for (var doc in teacherChats.docs) {
        await doc.reference.delete();
      }

      // 6. Delete Authentication account
      await user.delete();
    } catch (e) {
      debugPrint("Error deleting account: $e");
      rethrow;
    }
  }

  Future<String?> getUserAvatar() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data()?['avatarUrl'] as String?;
  }

  // Chat Methods
  Future<void> sendMessage(String teacherId, String teacherName, String text) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final chatId = '${user.uid}_$teacherId';
    
    // Update or create chat document (for the notification list)
    await _firestore.collection('chats').doc(chatId).set({
      'studentId': user.uid,
      'studentName': user.displayName ?? 'Студент',
      'teacherId': teacherId,
      'teacherName': teacherName,
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'isRead': false,
    }, SetOptions(merge: true));

    // Add message to subcollection
    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': user.uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Booking Methods
  Future<void> createBooking({
    required String teacherId,
    required String teacherName,
    required String date,
    required String time,
    required String duration,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Fetch student name from Firestore if displayName is empty
    String studentName = user.displayName ?? 'Студент';
    if (studentName == 'Студент' || studentName.isEmpty) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      studentName = userDoc.data()?['name'] ?? 'Студент';
    }

    await _firestore.collection('bookings').add({
      'studentId': user.uid,
      'studentName': studentName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'date': date,
      'time': time,
      'duration': duration,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Automatically create/initialize chat if it doesn't exist
    final chatId = '${user.uid}_$teacherId';
    await _firestore.collection('chats').doc(chatId).set({
      'studentId': user.uid,
      'studentName': studentName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'lastMessage': 'Забронирован урок на $date в $time',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'isRead': false,
    }, SetOptions(merge: true));
  }

  Future<void> markChatAsRead(String chatId) async {
    await _firestore.collection('chats').doc(chatId).update({'isRead': true});
  }

  Stream<List<DocumentSnapshot>> getBookings() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    
    return _firestore
        .collection('bookings')
        .where(
          Filter.or(
            Filter('studentId', isEqualTo: user.uid),
            Filter('teacherId', isEqualTo: user.uid),
          )
        )
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs;
          // Сортируем локально, чтобы не требовать сложные индексы в Firebase
          docs.sort((a, b) {
            final t1 = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            final t2 = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            if (t1 == null) return 1;
            if (t2 == null) return -1;
            return t2.compareTo(t1);
          });
          return docs;
        });
  }

  // Review Methods
  Future<void> submitReview({
    required String teacherId,
    required String comment,
    required bool isLike,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Get student name from Firestore for accuracy
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final studentName = userDoc.data()?['name'] ?? user.displayName ?? 'Студент';

    // 1. Add review
    await _firestore.collection('reviews').add({
      'studentId': user.uid,
      'studentName': studentName,
      'teacherId': teacherId,
      'comment': comment,
      'isLike': isLike,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Update teacher rating in their anketa
    final anketas = await _firestore
        .collection('anketas')
        .where('userId', isEqualTo: teacherId)
        .limit(1)
        .get();

    if (anketas.docs.isNotEmpty) {
      final docId = anketas.docs.first.id;
      final currentRating = anketas.docs.first.data()['likesCount'] ?? 0;
      await _firestore.collection('anketas').doc(docId).update({
        'likesCount': isLike ? currentRating + 1 : currentRating - 1,
      });
    }
  }

  Future<void> deleteReview(String reviewId, String teacherId, bool wasLike) async {
    // 1. Delete the review
    await _firestore.collection('reviews').doc(reviewId).delete();

    // 2. Adjust teacher rating
    final anketas = await _firestore
        .collection('anketas')
        .where('userId', isEqualTo: teacherId)
        .limit(1)
        .get();

    if (anketas.docs.isNotEmpty) {
      final docId = anketas.docs.first.id;
      final currentRating = anketas.docs.first.data()['likesCount'] ?? 0;
      await _firestore.collection('anketas').doc(docId).update({
        'likesCount': wasLike ? currentRating - 1 : currentRating + 1,
      });
    }
  }

  Future<void> updateReview({
    required String reviewId,
    required String teacherId,
    required String newComment,
    required bool wasLike,
    required bool newIsLike,
  }) async {
    // 1. Update review
    await _firestore.collection('reviews').doc(reviewId).update({
      'comment': newComment,
      'isLike': newIsLike,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Adjust teacher rating if like status changed
    if (wasLike != newIsLike) {
      final anketas = await _firestore
          .collection('anketas')
          .where('userId', isEqualTo: teacherId)
          .limit(1)
          .get();

      if (anketas.docs.isNotEmpty) {
        final docId = anketas.docs.first.id;
        final currentRating = anketas.docs.first.data()['likesCount'] ?? 0;
        // If it was a like and now it's a dislike: -1 then -1 = -2
        // If it was a dislike and now it's a like: +1 then +1 = +2
        int adjustment = newIsLike ? 2 : -2;
        await _firestore.collection('anketas').doc(docId).update({
          'likesCount': currentRating + adjustment,
        });
      }
    }
  }

  Stream<List<Review>> getTeacherReviews(String teacherId) {
    return _firestore
        .collection('reviews')
        .where('teacherId', isEqualTo: teacherId)
        // .orderBy('timestamp', descending: true) // Temporarily disabled to check if index is missing
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  Stream<List<TutorAnketa>> getTopTwoTutors() {
    return _firestore
        .collection('anketas')
        .where('status', isEqualTo: 'approved')
        .orderBy('likesCount', descending: true)
        .limit(2)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TutorAnketa.fromFirestore(doc)).toList());
  }

  Stream<List<TutorAnketa>> getFilteredTutors({String? name, List<String>? subjects}) {
    Query query = _firestore.collection('anketas').where('status', isEqualTo: 'approved');

    if (subjects != null && subjects.isNotEmpty) {
      query = query.where('subjects', arrayContainsAny: subjects);
    }

    return query.snapshots().map((snapshot) {
      var tutors = snapshot.docs.map((doc) => TutorAnketa.fromFirestore(doc)).toList();
      
      if (name != null && name.isNotEmpty) {
        final searchStr = name.toLowerCase();
        tutors = tutors.where((t) => t.tutorName.toLowerCase().contains(searchStr)).toList();
      }
      
      return tutors;
    });
  }

  // Article Methods
  Future<void> publishArticle(String title, String content) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    await _firestore.collection('articles').add({
      'authorId': user.uid,
      'authorName': user.displayName ?? 'Учитель',
      'title': title,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Article>> getArticles() {
    return _firestore
        .collection('articles')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Article.fromFirestore(doc)).toList());
  }
}
