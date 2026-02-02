import 'package:flutter/material.dart';

class EleArt extends StatelessWidget {
  const EleArt({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFF0),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Stack(
                children: [
                  // Кнопка назад слева
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF8D0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: Color(0xFFFFD700),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  // Текст по центру
                  Center(
                    child: Text(
                      'Balapan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE8C4F5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Фото учителя
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/elena.png',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),

                    // Имя учителя
                    Text(
                      'Елена "Эврика" Кузнецова',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Теги предметов
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8C4F5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Математика',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8C4F5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Физика',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Заголовок статьи
                    Text(
                      'От "боюсь" до "люблю": как изменить своё отношение к алгебре',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Текст статьи
                    Text(
                      'Для многих учеников алгебра — это не просто предмет, а настоящий источник страха. Мы видим запутанные формулы, слышим слово "уравнение", и мозг моментально ставит блок. Но задача не в том, чтобы "победить" страх, а в том, чтобы понять и полюбить его. И можно!',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 16),

                    Text(
                      'Вот три простых шага, которые помогут вам превратить страх в уверенность:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Шаг 1
                    _buildStep(
                      '1. Перестаньте бояться "не знаю"',
                      'Первый враг новичка — желание сразу решить задачу быстро. В итоге мы судорожно листаем учебники, пытаемся найти путаемся в уравнениях, впечатываем в формулы. Спросите себя:\n   - "Почему не я справляюсь, хотя другие знакомы со сложностью?"\n   - "Почему мы, я, почему же может быть равен 0?"\n\nНе стесняйтесь! Задавать вопросы. Тщательно прописывайте каждый шаг. Скорость придёт — но это придёт тогда, когда станет понятно!',
                    ),
                    SizedBox(height: 16),

                    // Шаг 2
                    _buildStep(
                      '2. Формулы — это не случайный набор букв',
                      'Формулы — это не случайный набор букв. Это инструкция, история, которая объясняет "почему так работает". Например, уравнение (ax²+bx+c=0) — это не магия, а способ узнать, в какой точке график встречает ось X. Научитесь задавать простой вопрос: "А почему это?". Почему при этих коэффициентах именно такой ответ? А если один параметр изменю, что случится?',
                    ),
                    SizedBox(height: 16),

                    // Шаг 3
                    _buildStep(
                      '3. Попробуйте визуализировать',
                      'Ищите, как алгебра используется в ваших любимых играх или программировании. Как только вы увидите, зачем это нужно, вы перестанете "зубрить" и начнёте "понимать".',
                    ),
                    SizedBox(height: 16),

                    Text(
                      'Запишитесь на пробный урок, и мы вместе пройдем слабое звено, чтобы построить прочный фундамент знаний!',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            height: 1.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}