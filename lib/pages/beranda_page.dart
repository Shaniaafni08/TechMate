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
    return ((_slideTerakhir + 1) / 5).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _muatProgres();
  }

  Future<void> _muatProgres() async {
    final prefs = await SharedPreferences.getInstance();

    final materi = prefs.getString('materiTerakhir');
    final slide = prefs.getInt('slideTerakhir');

    debugPrint('MATERI TERSIMPAN: $materi');
    debugPrint('SLIDE TERSIMPAN: $slide');

    if (!mounted) return;

    setState(() {
      _materiTerakhir = materi ?? 'Sistem Komputer';
      _slideTerakhir = slide ?? 0;
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                          'Hai, Sobat TechMate! 👋',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Yuk, belajar teknologi hari ini!',
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
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.gradient,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withOpacity(0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Lingkaran dekoratif
                    Positioned(
                      top: -35,
                      right: 65,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: -45,
                      right: 100,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),

                    // Isi banner
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Belajar TIK Jadi Lebih Seru! 🚀',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                'Jelajahi dunia teknologi lewat materi, video dan kuis.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                ),
                                child: const Text(
                                  '📚 Belajar • Eksplorasi • Berkarya',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Ikon komputer
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.computer_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ],
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
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MenuCard(
                    item: item,
                    onTap: () {
                      if (item.title == 'Materi') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MateriPage()),
                        ).then((_) {
                          _muatProgres();
                        });
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
