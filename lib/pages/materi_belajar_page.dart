import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';
import '../models/materi_model.dart';

// Mengubah halaman menjadi StatefulWidget
// agar isi materi bisa berpindah slide.
class MateriBelajarPage extends StatefulWidget {
  // REVISI 10: Menyimpan topik yang dipilih pengguna
  final MateriModel materi;

  const MateriBelajarPage({
    super.key,
    required this.materi,
  });

  @override
  State<MateriBelajarPage> createState() => _MateriBelajarPageState();
}

class _MateriBelajarPageState extends State<MateriBelajarPage> {
  int _slideAktif = 0;
  // Menimpan jawaban aktivitas
  int? _jawabanDipilih;
  bool _aktivitasSelesai = false;

  // Daftar materi yang ditampilkan per slide.
  final List<Map<String, dynamic>> _slides = [
    {
      'judul': 'Pengertian Sistem Komputer',
      'isi':
          'Sistem komputer adalah sekumpulan komponen '
          'yang bekerja sama untuk mengolah data menjadi informasi.',
      'ikon': Icons.computer_rounded,
    },
    {
      'judul': 'Hardware (Perangkat Keras)',
      'isi':
          'Hardware adalah bagian fisik komputer yang dapat '
          'dilihat dan disentuh, seperti monitor, keyboard, '
          'mouse, dan CPU.',
      'ikon': Icons.desktop_windows_rounded,
    },

    // REVISI 11: Aktivitas interaktif di tengah materi
    {
      'jenis': 'aktivitas',
      'judul': 'Aktivitas Interaktif',
      'isi': 'Manakah yang termasuk perangkat keras komputer?',
      'pilihan': ['Keyboard', 'Microsoft Word', 'Windows', 'Google Chrome'],
      'jawabanBenar': 0,
      'ikon': Icons.quiz_rounded,
    },
    {
      'judul': 'Software (Perangkat Lunak)',
      'isi':
          'Software adalah program yang menjalankan perintah '
          'pada komputer, contohnya Windows, Microsoft Word, '
          'dan aplikasi browser.',
      'ikon': Icons.apps_rounded,
    },
    {
      'judul': 'Brainware (Pengguna)',
      'isi':
          'Brainware adalah manusia yang menggunakan atau '
          'mengelola komputer, seperti siswa, guru, dan teknisi.',
      'ikon': Icons.person_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: 'Materi Pembelajaran',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul mengikuti slide yang aktif
            Text(
              _slides[_slideAktif]['judul'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 12),


    // REVISI 12: Menampilkan isi sesuai jenis slide
    Text(
      _slides[_slideAktif]['isi'],
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textGrey,
        height: 1.6,
      ),
    ),

    // Pilihan jawaban hanya muncul pada slide aktivitas
    if (_slides[_slideAktif]['jenis'] == 'aktivitas') ...[
      const SizedBox(height: 20),

      ...List.generate(
        (_slides[_slideAktif]['pilihan'] as List<String>).length,
        (index) {
          final pilihan =
              (_slides[_slideAktif]['pilihan'] as List<String>)[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _aktivitasSelesai
                    ? null
                    : () {
                        setState(() {
                          _jawabanDipilih = index;
                          _aktivitasSelesai = true;
                        });

                        final benar =
                            index ==
                            _slides[_slideAktif]['jawabanBenar'];

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              benar
                                  ? 'Benar! Keyboard termasuk perangkat keras.'
                                  : 'Belum tepat, coba pelajari lagi materinya.',
                            ),
                          ),
                        );
                      },
                child: Text(pilihan),
              ),
            ),
          );
        },
      ),

      if (_aktivitasSelesai)
        Text(
          _jawabanDipilih ==
                  _slides[_slideAktif]['jawabanBenar']
              ? 'Jawaban kamu benar!'
              : 'Jawaban kamu belum tepat.',
          style: TextStyle(
            color: _jawabanDipilih ==
                    _slides[_slideAktif]['jawabanBenar']
                ? Colors.green
                : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
    ],

            const SizedBox(height: 24),

            // REVISI 5: Ilustrasi untuk setiap slide materi
            Center(
              child: Container(
                width: 160,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _slides[_slideAktif]['ikon'] as IconData,
                  size: 80,
                  color: AppColors.purple,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // REVISI 6: Nomor slide
            Center(
              child: Text(
                'Slide ${_slideAktif + 1} dari ${_slides.length}',
                style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
              ),
            ),

            // REVISI 7: Navigasi antar-slide
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _slideAktif > 0
                        ? () {
                            setState(() {
                              _slideAktif++;
                              _jawabanDipilih = null;
                              _aktivitasSelesai = false;
                            });
                          }
                        : null,
                    child: const Text('Kembali'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_slideAktif < _slides.length - 1) {
                        setState(() {
                          _slideAktif++;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Materi Sistem Komputer selesai!'),
                          ),
                        );
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                    },
                    child: Text(
                      _slideAktif == _slides.length - 1 ? 'Selesai' : 'Lanjut',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
