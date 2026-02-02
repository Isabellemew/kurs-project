import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'user_schedule_screen.dart';

class BookingScreen extends StatefulWidget {
  final TutorAnketa? tutor;
  final String? selectedDate;

  const BookingScreen({
    super.key, 
    this.tutor,
    this.selectedDate,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String selectedDuration = '30 минут';
  String selectedTime = '19:00';
  bool isLoading = false;

  final List<String> times = ['09:00', '10:00', '11:00', '12:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00'];

  @override
  Widget build(BuildContext context) {
    final tutorName = widget.tutor?.tutorName ?? 'Выберите репетитора';
    final dateDisp = widget.selectedDate ?? 'Выберите дату';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Забронировать'),
        centerTitle: true,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryPink),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primaryPink),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Урок с репетитором $tutorName на $dateDisp',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Time selection
                const Text('Выберите время', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: times.length,
                  itemBuilder: (context, index) {
                    final time = times[index];
                    final isSelected = selectedTime == time;
                    return GestureDetector(
                      onTap: () => setState(() => selectedTime = time),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryPink : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryPink),
                        ),
                        child: Center(
                          child: Text(
                            time,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Duration
                const Text('Длительность', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDurationChip('30 минут'),
                    _buildDurationChip('60 минут'),
                    _buildDurationChip('90 минут'),
                  ],
                ),

                const SizedBox(height: 48),

                // Bottom Buttons
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink),
                    onPressed: () async {
                      if (widget.tutor == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Для бронирования нужно выбрать репетитора')),
                        );
                        return;
                      }

                      setState(() => isLoading = true);
                      try {
                        await AuthService().createBooking(
                          teacherId: widget.tutor!.userId,
                          teacherName: widget.tutor!.tutorName,
                          date: dateDisp,
                          time: selectedTime,
                          duration: selectedDuration,
                        );

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Урок успешно забронирован!')),
                          );
                          
                          // Redirect back to chat
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatId: '${FirebaseAuth.instance.currentUser?.uid}_${widget.tutor!.userId}',
                                title: widget.tutor!.tutorName,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ошибка бронирования: $e')),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => isLoading = false);
                      }
                    },
                    child: const Text('Завершить бронирование'),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildDurationChip(String label) {
    final isSelected = selectedDuration == label;
    return GestureDetector(
      onTap: () => setState(() => selectedDuration = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPink : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryPink),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
