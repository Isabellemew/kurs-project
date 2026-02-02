import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';
import 'booking_screen.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';
import 'booking_detail_screen.dart';

class CalScreen extends StatefulWidget {
  final TutorAnketa? tutor;
  const CalScreen({super.key, this.tutor});

  @override
  State<CalScreen> createState() => _CalScreenState();
}

class _CalScreenState extends State<CalScreen> {
  DateTime currentMonth = DateTime(2025, 5);
  int? selectedDay;

  final List<String> weekDays = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВСК'];

  List<int?> getDaysInMonth() {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    int firstWeekday = firstDay.weekday;
    List<int?> days = [];
    for (int i = 1; i < firstWeekday; i++) {
      days.add(null);
    }
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(i);
    }
    return days;
  }

  void changeMonth(int delta) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + delta);
      selectedDay = null;
    });
  }

  String getMonthName(int month) {
    const months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final days = getDaysInMonth();

    return Scaffold(
      body: SafeArea(
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

            // Calendar Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // Month navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => changeMonth(-1),
                          child: const Icon(Icons.chevron_left, color: Colors.black, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${getMonthName(currentMonth.month)}, ${currentMonth.year}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => changeMonth(1),
                          child: const Icon(Icons.chevron_right, color: Colors.black, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Week days header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: weekDays.map((day) {
                        return SizedBox(
                          width: 36,
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: day == 'ВСК' ? Colors.red.shade300 : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Calendar grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                      ),
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        final day = days[index];
                        if (day == null) return const SizedBox();
                        final isWeekend = (index % 7 == 6);
                        return GestureDetector(
                          onTap: () => setState(() => selectedDay = day),
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedDay == day ? AppColors.primaryPink : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isWeekend ? Colors.red.shade300 : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // "Дальше" button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedDay == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Пожалуйста, выберите день на календаре')),
                      );
                      return;
                    }

                    final dateStr = '$selectedDay ${getMonthName(currentMonth.month)} ${currentMonth.year}';
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingScreen(
                          tutor: widget.tutor,
                          selectedDate: dateStr,
                        ),
                      ),
                    );
                  },
                  child: const Text('Забронировать'),
                ),
              ),
            ),

            const Spacer(),

            // Chicken illustration
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Image.asset(
                'assets/images/balapan.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.egg, size: 50, color: AppColors.primaryYellow);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
