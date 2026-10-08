import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';

class MateriBelajarPage extends StatelessWidget {
  const MateriBelajarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: 'Materi Pembelajaran',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengertian Sistem Komputer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Sistem komputer adalah sekumpulan komponen '
              'yang saling berhubungan dan bekerja sama untuk '
              'mengolah data menjadi informasi.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textGrey,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Komponen Sistem Komputer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    'Sistem komputer terdiri dari beberapa '
                    'komponen utama yang saling mendukung, yaitu:',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 14),

                  Text(
                    '1. Hardware (Perangkat Keras)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'Hardware merupakan bagian fisik komputer '
                    'yang dapat dilihat dan disentuh, seperti '
                    'keyboard, monitor, mouse, dan CPU.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 14),

                  Text(
                    '2. Software (Perangkat Lunak)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'Software adalah program yang digunakan '
                    'untuk menjalankan berbagai fungsi pada komputer.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 14),

                  Text(
                    '3. Brainware',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'Brainware adalah manusia yang menggunakan '
                    'dan mengoperasikan sistem komputer.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Lanjut'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}