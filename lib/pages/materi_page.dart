import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/materi_model.dart';
import '../widgets/gradient_scaffold.dart';
import 'detail_materi_page.dart';

class MateriPage extends StatelessWidget {
  const MateriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: 'Materi Pembelajaran',
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: daftarMateri.length,
        itemBuilder: (context, index) {
          final materi = daftarMateri[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailMateriPage(
                      materi: materi,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: materi.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        materi.icon,
                        color: materi.color,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            materi.judul,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            materi.deskripsi,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textGrey,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.textGrey,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}