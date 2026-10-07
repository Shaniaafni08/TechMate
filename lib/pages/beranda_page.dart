import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/menu_item.dart';
import '../widgets/menu_card.dart';
import '../widgets/lanjut_card.dart';
import 'materi_page.dart';
import 'video_page.dart';
import 'kuis_page.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menu = [
      MenuItem(
        title: 'Materi',
        subtitle: 'Pelajari materi TIK dan Informatika',
        icon: Icons.menu_book_rounded,
        color: AppColors.purple,
      ),
      MenuItem(
        title: 'Video',
        subtitle: 'Belajar melalui video interaktif',
        icon: Icons.play_circle_outline_rounded,
        color: AppColors.blue,
      ),
      MenuItem(
        title: 'Kuis',
        subtitle: 'Uji pemahamanmu melalui kuis',
        icon: Icons.quiz_outlined,
        color: Colors.orange,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradient,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.memory,
                      color: Colors.black,
                      size: 27,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, Pelajar! 👋',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Siap belajar hari ini?',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.gradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withOpacity(0.18),
                      blurRadius: 15,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Belajar TIK Jadi\nLebih Interaktif 🚀',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Jelajahi materi, video, dan kuis untuk meningkatkan pemahamanmu.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Lanjut Belajar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 12),

              LanjutCard(
                title: 'Sistem Komputer',
                subtitle: 'Perangkat keras dan perangkat lunak',
                progress: 0.65,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MateriPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 26),

              const Text(
                'Menu Utama',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 12),

              ...menu.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MenuCard(
                    item: item,
                    onTap: () {
                      if (item.title == 'Materi') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MateriPage(),
                          ),
                        );
                      } else if (item.title == 'Video') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VideoPage(),
                          ),
                        );
                      } else if (item.title == 'Kuis') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KuisPage(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}