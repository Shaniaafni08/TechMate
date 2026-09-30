import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/materi_model.dart';
import '../widgets/gradient_scaffold.dart';

class DetailMateriPage extends StatelessWidget {
  final MateriModel materi;

  const DetailMateriPage({
    super.key,
    required this.materi,
  });

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: materi.judul,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon materi
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: materi.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  materi.icon,
                  color: materi.color,
                  size: 48,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Judul
            Text(
              materi.judul,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 8),

            // Deskripsi
            Text(
              materi.deskripsi,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Isi materi
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tentang Materi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Pada materi ini kamu akan mempelajari '
                    '${materi.judul.toLowerCase()} secara bertahap. '
                    'Materi disajikan dengan bahasa yang mudah dipahami '
                    'dan dilengkapi dengan contoh agar proses belajar '
                    'menjadi lebih interaktif.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Tujuan Pembelajaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _TujuanItem(
                    text: 'Memahami konsep dasar materi.',
                  ),
                  _TujuanItem(
                    text: 'Mengenali contoh penerapannya.',
                  ),
                  _TujuanItem(
                    text: 'Mampu menjelaskan kembali materi.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Tombol mulai belajar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Materi siap dipelajari!',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.play_arrow_rounded,
                ),
                label: const Text(
                  'Mulai Belajar',
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TujuanItem extends StatelessWidget {
  final String text;

  const _TujuanItem({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.purple,
            size: 19,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textGrey,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}