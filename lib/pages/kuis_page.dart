import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';

class KuisPage extends StatefulWidget {
  const KuisPage({super.key});

  @override
  State<KuisPage> createState() => _KuisPageState();
}

class _KuisPageState extends State<KuisPage> {
  int _currentQuestion = 0;
  int _selectedAnswer = -1;
  int _correctAnswers = 0;
  bool _answered = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Manakah yang termasuk perangkat keras komputer?',
      'answers': ['Microsoft Word', 'Keyboard', 'Google Chrome', 'Windows'],
      'correctAnswer': 1,
    },
    {
      'question':
          'Perhatikan gambar berikut. Perangkat apakah yang ditampilkan?',
      'image': 'assets/images/komputer.jpg',
      'answers': ['Komputer', 'Printer', 'Scanner', 'Speaker'],
      'correctAnswer': 0,
    },
    {
      'question': 'Manakah yang termasuk sistem operasi?',
      'answers': ['Google Chrome', 'Microsoft Word', 'Windows', 'Keyboard'],
      'correctAnswer': 2,
    },
    {
      'question': 'Apa kepanjangan dari CPU?',
      'answers': [
        'Central Processing Unit',
        'Computer Personal Unit',
        'Central Program Utility',
        'Computer Processing User',
      ],
      'correctAnswer': 0,
    },
    {
      'question': 'Perangkat yang digunakan untuk mencetak dokumen adalah...',
      'answers': ['Monitor', 'Printer', 'Keyboard', 'Mouse'],
      'correctAnswer': 1,
    },
  ];

  void _checkAnswer() {
    if (_selectedAnswer == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jawaban terlebih dahulu.')),
      );
      return;
    }

    setState(() {
      _answered = true;

      final correctAnswer = _questions[_currentQuestion]['correctAnswer'];

      if (_selectedAnswer == correctAnswer) {
        _correctAnswers++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = -1;
        _answered = false;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestion = 0;
      _selectedAnswer = -1;
      _correctAnswers = 0;
      _answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestion];

    final List<String> answers = List<String>.from(currentQuestion['answers']);

    final int correctAnswer = currentQuestion['correctAnswer'];

    final bool isLastQuestion = _currentQuestion == _questions.length - 1;

    final int score = ((_correctAnswers / _questions.length) * 100).round();

    return GradientScaffold(
      title: 'Kuis',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple.withOpacity(0.20),
                    blurRadius: 15,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SIAP UJI KEMAMPUANMU? 🚀',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Ayo Taklukkan Kuis!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Soal ${_currentQuestion + 1} dari ${_questions.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (_currentQuestion + 1) / _questions.length,
                            minHeight: 7,
                            backgroundColor: Colors.white30,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.psychology_alt_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // TAMBAHKAN BAGIAN INI
            Text(
              'Pertanyaan ${_currentQuestion + 1}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              currentQuestion['question'],
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            if (currentQuestion['image'] != null) ...[
  const SizedBox(height: 16),

  ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: Image.asset(
      currentQuestion['image'],
      width: double.infinity,
      height: 190,
      fit: BoxFit.contain,
    ),
  ),

  const SizedBox(height: 20),
],

            ...List.generate(answers.length, (index) {
              final isSelected = _selectedAnswer == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: _answered
                      ? null
                      : () {
                          setState(() {
                            _selectedAnswer = index;
                          });
                        },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.purple.withOpacity(0.10)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.purple
                            : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.purple
                                  : AppColors.textGrey,
                              width: 1.5,
                            ),
                            color: isSelected
                                ? AppColors.purple
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 17,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            answers[index],
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 10),

            if (!_answered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checkAnswer,
                  child: const Text('Periksa Jawaban'),
                ),
              ),

            if (_answered) ...[
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _selectedAnswer == correctAnswer
                      ? Colors.green.withOpacity(0.10)
                      : Colors.red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedAnswer == correctAnswer
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: _selectedAnswer == correctAnswer
                          ? Colors.green
                          : Colors.red,
                      size: 45,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedAnswer == correctAnswer
                          ? 'Jawaban Benar! 🎉'
                          : 'Jawaban Belum Tepat',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _selectedAnswer == correctAnswer
                          ? 'Jawaban kamu benar.'
                          : 'Jawaban yang benar adalah: ${answers[correctAnswer]}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              if (!isLastQuestion)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    child: const Text('Soal Berikutnya'),
                  ),
                ),

              if (isLastQuestion) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 50,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Kuis Selesai! 🎉',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jawaban benar: $_correctAnswers dari ${_questions.length}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Nilai: $score',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _restartQuiz,
                    child: const Text('Ulangi Kuis'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
