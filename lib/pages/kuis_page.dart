import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';

class KuisPage extends StatefulWidget {
  const KuisPage({super.key});

  @override
  State<KuisPage> createState() => _KuisPageState();
}

class _KuisPageState extends State<KuisPage> {
  int _selectedAnswer = -1;
  int _score = 0;
  bool _answered = false;

  final String _question =
      'Manakah yang termasuk perangkat keras komputer?';

  final List<String> _answers = [
    'Microsoft Word',
    'Keyboard',
    'Google Chrome',
    'Windows',
  ];

  void _checkAnswer() {
    if (_selectedAnswer == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jawaban terlebih dahulu.'),
        ),
      );
      return;
    }

    setState(() {
      _answered = true;

      if (_selectedAnswer == 1) {
        _score = 100;
      } else {
        _score = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: 'Kuis',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informasi kuis
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Uji Pemahamanmu 🧠',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Pilih jawaban yang paling tepat.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Pertanyaan 1',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              _question,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            // Pilihan jawaban
            ...List.generate(
              _answers.length,
              (index) {
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
                              _answers[index],
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
              },
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _answered ? null : _checkAnswer,
                child: const Text('Periksa Jawaban'),
              ),
            ),

            if (_answered) ...[
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _score == 100
                      ? Colors.green.withOpacity(0.10)
                      : Colors.red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Icon(
                      _score == 100
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: _score == 100
                          ? Colors.green
                          : Colors.red,
                      size: 45,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _score == 100
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
                      'Nilai: $_score',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}