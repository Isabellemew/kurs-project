import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AnketaScreen extends StatefulWidget {
  const AnketaScreen({super.key});

  @override
  State<AnketaScreen> createState() => _AnketaScreenState();
}

class _AnketaScreenState extends State<AnketaScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  Set<String> selectedSubjects = {};
  bool isLoading = false;
  bool isUploadingImage = false;
  String? currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('anketas')
            .where('userId', isEqualTo: user.uid)
            .get();
        
        if (snapshot.docs.isNotEmpty && mounted) {
          final data = snapshot.docs.first.data();
          setState(() {
            nameController.text = data['tutorName'] ?? '';
            descriptionController.text = data['description'] ?? '';
            experienceController.text = data['experience'] ?? '';
            locationController.text = data['location'] ?? '';
            selectedSubjects = Set<String>.from(data['subjects'] ?? []);
            currentAvatarUrl = data['avatarUrl'];
          });
        } else {
          // If no anketa, try to get avatar from user doc
          final userAvatar = await AuthService().getUserAvatar();
          setState(() {
            currentAvatarUrl = userAvatar;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        isUploadingImage = true;
      });
      try {
        final File file = File(image.path);
        final String downloadUrl = await AuthService().uploadTeacherAvatar(file);
        await AuthService().updateUserAvatar(downloadUrl);
        setState(() {
          currentAvatarUrl = downloadUrl;
        });
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
            isUploadingImage = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    experienceController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Анкета репетитора'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryPink, width: 2),
                      ),
                      child: ClipOval(
                        child: isUploadingImage
                          ? const Center(child: CircularProgressIndicator())
                          : (currentAvatarUrl != null && currentAvatarUrl!.isNotEmpty)
                            ? Image.network(
                                currentAvatarUrl!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 80, color: Colors.grey),
                              )
                            : const Icon(Icons.person, size: 80, color: Colors.grey),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryPink,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildFieldLabel('ФИО'),
              _buildTextField(nameController, 'Ваше ФИО', Icons.person),
              const SizedBox(height: 20),

              _buildFieldLabel('Описание'),
              _buildTextField(descriptionController, 'О чем вы хотите рассказать ученикам?', Icons.description, maxLines: 4),
              const SizedBox(height: 20),

              _buildFieldLabel('Опыт работы'),
              _buildTextField(experienceController, 'Ваш стаж и достижения', Icons.history_edu, maxLines: 3),
              const SizedBox(height: 20),

              _buildFieldLabel('Местоположение'),
              _buildTextField(locationController, 'Город или район', Icons.location_on),
              const SizedBox(height: 20),

              _buildFieldLabel('Предметы'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSubjectChip('Математика'),
                    _buildSubjectChip('Физика'),
                    _buildSubjectChip('Химия'),
                    _buildSubjectChip('Биология'),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || selectedSubjects.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Заполните ФИО и выберите предметы')),
                      );
                      return;
                    }

                    try {
                      setState(() => isLoading = true);
                      await AuthService().submitAnketa(
                        name: nameController.text,
                        subjects: selectedSubjects.toList(),
                        experience: experienceController.text,
                        description: descriptionController.text,
                        location: locationController.text,
                        avatarUrl: currentAvatarUrl,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Анкета отправлена на модерацию!')),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ошибка при сохранении: $e')),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => isLoading = false);
                    }
                  },
                  child: const Text('Сохранить анкету'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryYellow),
      ),
    );
  }

  Widget _buildSubjectChip(String subject) {
    final isSelected = selectedSubjects.contains(subject);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedSubjects.remove(subject);
          } else {
            selectedSubjects.add(subject);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPink : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryPink),
        ),
        child: Text(
          subject,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
