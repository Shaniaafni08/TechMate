import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../widgets/menu_item.dart';
import '../widgets/menu_card.dart';
import '../widgets/lanjut_card.dart';
import 'materi_page.dart';
import '../models/materi_model.dart';
import 'video_page.dart';
import 'kuis_page.dart';
import 'materi_belajar_page.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  String _materiTerakhir = 'Sistem Komputer';
  int _slideTerakhir = 0;

  double get _progresBelajar {
    return (_slideTerakhir + 1) / 5;
  }

  @override
  void initState() {
    super.initState();
    _muatProgres();
  }

  Future<void> _muatProgres() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _materiTerakhir = prefs.getString('materiTerakhir') ?? 'Sistem Komputer';
      _slideTerakhir = prefs.getInt('slideTerakhir') ?? 0;
    });
  }

  void _lanjutBelajar() {
    final materi = daftarMateri.firstWhere(
      (item) => item.judul == _materiTerakhir,
      orElse: () => daftarMateri[1],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MateriBelajarPage(materi: materi, initialSlide: _slideTerakhir),
      ),
    );
  }

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
                          'Selamat Datang! 👋',
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

                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Belajar TIK Jadi Lebih Interaktif 🚀',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Jelajahi materi, video, dan kuis untuk meningkatkan pemahamanmu.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // REVISI 1: ilustrasi komputer sederhana
                    Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.computer_rounded,
                        color: Colors.white,
                        size: 42,
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
                title: _materiTerakhir,
                subtitle: 'Lanjutkan materi yang terakhir dipelajari',
                progress: _progresBelajar,
                onTap: _lanjutBelajar,
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

              // REVISI 3: Menu Utama dibuat menjadi 1 kolom dengan card yang lebih ringkas
              ...menu.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: MenuCard(
                    item: item,
                    onTap: () {
                      if (item.title == 'Materi') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MateriPage()),
                        );
                      } else if (item.title == 'Video') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VideoPage()),
                        );
                      } else if (item.title == 'Kuis') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const KuisPage()),
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
