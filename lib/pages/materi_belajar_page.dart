import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';
import '../models/materi_model.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mengubah halaman menjadi StatefulWidget
// agar isi materi bisa berpindah slide.
class MateriBelajarPage extends StatefulWidget {
  // REVISI 10: Menyimpan topik yang dipilih pengguna
  final MateriModel materi;
  final int initialSlide;

  const MateriBelajarPage({
    super.key,
    required this.materi,
    this.initialSlide = 0,
  });

  @override
  State<MateriBelajarPage> createState() => _MateriBelajarPageState();
}

class _MateriBelajarPageState extends State<MateriBelajarPage> {
  // REVISI: Membersihkan pemutar audio saat halaman ditutup
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // REVISI 25: Memuat slide sesuai topik pilihan
  @override
  void initState() {
    super.initState();
    _slides = _buatSlides(widget.materi.judul);
    _slideAktif = widget.initialSlide.clamp(0, _slides.length - 1).toInt();
  }

  int _slideAktif = 0;

  // REVISI 33A: Menyimpan posisi slide terakhir
  Future<void> _simpanProgres() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('materiTerakhir', widget.materi.judul);
    await prefs.setInt('slideTerakhir', _slideAktif);

    debugPrint('MENYIMPAN MATERI: ${widget.materi.judul}');
    debugPrint('MENYIMPAN SLIDE: $_slideAktif');
  }

  // Menimpan jawaban aktivitas
  int? _jawabanDipilih;
  bool _aktivitasSelesai = false;
  bool _popUpAktivitasTampil = false;
  // REVISI: Pemutar efek suara aktivitas
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _putarEfek(String namaFile) async {
    try {
      await _audioPlayer.play(AssetSource('audio/$namaFile'));
    } catch (e) {
      debugPrint('Gagal memutar suara $namaFile: $e');
    }
  }

  Future<void> _jawabTrueFalse(int jawaban) async {
    if (_aktivitasSelesai) return;

    final benar = jawaban == (_slides[_slideAktif]['jawabanBenar'] as int);

    setState(() {
      _jawabanDipilih = jawaban;
      _aktivitasSelesai = true;
    });

    try {
      await _putarEfek(benar ? 'correct.mp3' : 'wrong.mp3');
    } catch (e) {
      debugPrint('Gagal memutar suara: $e');
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          benar
              ? '🎉 Benar! Hebat, lanjut ke materi berikutnya!'
              : 'Belum tepat, tetap semangat ya!',
        ),
        duration: const Duration(milliseconds: 900),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    if (benar && _slideAktif < _slides.length - 1) {
      setState(() {
        _slideAktif++;
        _jawabanDipilih = null;
        _aktivitasSelesai = false;
      });
      await _simpanProgres();
    } else if (!benar) {
      setState(() {
        _jawabanDipilih = null;
        _aktivitasSelesai = false;
      });
    }
  }

  Future<void> _tampilkanPopUpAktivitas() async {
    if (_popUpAktivitasTampil) return;

    _popUpAktivitasTampil = true;

    final aktivitas = _slides[_slideAktif];
    int? jawabanDipilih;
    String? pesan;

    final pilihan = aktivitas['jenis'] == 'trueFalse'
        ? ['TRUE', 'FALSE']
        : aktivitas['pilihan'] as List<String>;

    final hasil = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.purple),
                  SizedBox(width: 8),
                  Expanded(child: Text('Aktivitas Interaktif')),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aktivitas['isi'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...List.generate(pilihan.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            final benar = index == aktivitas['jawabanBenar'];

                            if (benar) {
                              await _putarEfek('correct.mp3');
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext, true);
                              }
                            } else {
                              await _putarEfek('wrong.mp3');
                              setDialogState(() {
                                jawabanDipilih = index;
                                pesan = 'Belum tepat, coba lagi ya! 💪';
                              });
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: jawabanDipilih == index
                                ? Colors.red
                                : AppColors.purple,
                          ),
                          child: Text(
                            '${String.fromCharCode(65 + index)}. ${pilihan[index]}',
                          ),
                        ),
                      ),
                    );
                  }),

                  if (pesan != null)
                    Text(
                      pesan!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );

    _popUpAktivitasTampil = false;

    if (!mounted) return;

    if (hasil == true) {
      setState(() {
        _slideAktif++;
        _jawabanDipilih = null;
        _aktivitasSelesai = false;
      });

      await _simpanProgres();
    }
  }

  // REVISI 25: Daftar slide mengikuti subbab yang dipilih
  late final List<Map<String, dynamic>> _slides;

  // REVISI 26: Memilih materi sesuai subbab
  List<Map<String, dynamic>> _buatSlides(String judul) {
    switch (judul) {
      case 'Pengenalan Teknologi':
        return [
          {
            'judul': 'Pengertian Teknologi',
            'isi':
                'Teknologi adalah penerapan ilmu pengetahuan '
                'untuk membantu manusia menyelesaikan pekerjaan '
                'dan memenuhi kebutuhan. Contohnya komputer, '
                'smartphone, dan internet.',
            'ikon': Icons.devices_rounded,
          },
          {
            'judul': 'Contoh Teknologi di Sekitar Kita',
            'isi':
                'Smartphone membantu komunikasi, komputer '
                'membantu mengerjakan tugas, dan mesin ATM '
                'membantu melakukan transaksi perbankan.',
            'ikon': Icons.phone_android_rounded,
          },
          {
            'jenis': 'aktivitas',
            'judul': 'Aktivitas 1: Mengenal Teknologi',
            'isi':
                'Manakah contoh teknologi yang digunakan '
                'untuk berkomunikasi jarak jauh?',
            'pilihan': ['Smartphone', 'Penggaris', 'Buku tulis', 'Pensil'],
            'jawabanBenar': 0,
            'ikon': Icons.quiz_rounded,
          },
          {
            'judul': 'Manfaat Teknologi',
            'isi':
                'Teknologi membantu manusia belajar, bekerja, '
                'berkomunikasi, dan mencari informasi. Teknologi '
                'perlu digunakan secara bijak dan bertanggung jawab.',
            'ikon': Icons.lightbulb_rounded,
          },

          {
            'jenis': 'trueFalse',
            'judul': 'Aktivitas 2: Benar atau Salah',
            'isi': 'Smartphone dapat digunakan untuk berkomunikasi jarak jauh.',
            'jawabanBenar': 0,
            'ikon': Icons.fact_check_rounded,
          },

          {
            'judul': 'Menggunakan Teknologi dengan Bijak',
            'isi':
                'Periksa kebenaran informasi, jaga data pribadi, '
                'dan gunakan perangkat untuk kegiatan yang '
                'bermanfaat.',
            'ikon': Icons.verified_user_rounded,
          },
        ];

      case 'Sistem Komputer':
        return [
          {
            'judul': 'Pengertian Sistem Komputer',
            'isi':
                'Sistem komputer terdiri dari komponen yang '
                'bekerja sama untuk mengolah data menjadi informasi. '
                'Komponen utamanya meliputi hardware, software, '
                'dan brainware.',
            'ikon': Icons.computer_rounded,
          },
          {
            'judul': 'Hardware (Perangkat Keras)',
            'isi':
                'Hardware adalah bagian fisik komputer yang '
                'dapat dilihat atau disentuh, seperti monitor, '
                'keyboard, mouse, dan printer.',
            'ikon': Icons.desktop_windows_rounded,
          },
          {
            'jenis': 'aktivitas',
            'judul': 'Aktivitas: Mengenal Hardware',
            'isi': 'Manakah yang termasuk perangkat keras?',
            'pilihan': [
              'Keyboard',
              'Microsoft Word',
              'Windows',
              'Google Chrome',
            ],
            'jawabanBenar': 0,
            'ikon': Icons.quiz_rounded,
          },
          {
            'judul': 'Software (Perangkat Lunak)',
            'isi':
                'Software adalah program atau instruksi yang '
                'digunakan komputer untuk menjalankan tugas. '
                'Contohnya sistem operasi dan aplikasi pengolah kata.',
            'ikon': Icons.apps_rounded,
          },
          {
            'judul': 'Brainware (Pengguna)',
            'isi':
                'Brainware adalah orang yang menggunakan atau '
                'mengelola komputer, misalnya siswa, guru, '
                'programmer, dan teknisi.',
            'ikon': Icons.person_rounded,
          },
        ];

      case 'Jaringan dan Internet':
        return [
          {
            'judul': 'Pengertian Jaringan Komputer',
            'isi':
                'Jaringan komputer menghubungkan dua atau lebih '
                'perangkat agar dapat berkomunikasi dan berbagi data.',
            'ikon': Icons.lan_rounded,
          },
          {
            'judul': 'Mengenal Internet',
            'isi':
                'Internet menghubungkan banyak jaringan komputer '
                'sehingga pengguna dapat mencari informasi, '
                'berkomunikasi, dan mengakses layanan digital.',
            'ikon': Icons.language_rounded,
          },
          {
            'jenis': 'aktivitas',
            'judul': 'Aktivitas: Jaringan Komputer',
            'isi':
                'Jaringan yang biasanya menghubungkan komputer '
                'dalam satu laboratorium sekolah disebut apa?',
            'pilihan': ['LAN', 'WAN', 'MAN', 'PAN'],
            'jawabanBenar': 0,
            'ikon': Icons.quiz_rounded,
          },
        ];

      case 'Keamanan Digital':
        return [
          {
            'judul': 'Pengertian Keamanan Digital',
            'isi':
                'Keamanan digital merupakan upaya melindungi '
                'perangkat, akun, dan informasi pribadi dari '
                'akses atau tindakan yang tidak diinginkan.',
            'ikon': Icons.security_rounded,
          },
          {
            'judul': 'Melindungi Akun',
            'isi':
                'Gunakan kata sandi yang kuat dan berbeda untuk '
                'setiap akun. Jangan membagikan kata sandi atau '
                'kode OTP kepada orang lain.',
            'ikon': Icons.lock_rounded,
          },
          {
            'jenis': 'aktivitas',
            'judul': 'Aktivitas: Keamanan Akun',
            'isi': 'Apa tindakan yang paling aman untuk melindungi akun?',
            'pilihan': [
              'Membagikan kata sandi kepada teman',
              'Menggunakan kata sandi yang kuat',
              'Memakai kata sandi 123456',
              'Membagikan kode OTP',
            ],
            'jawabanBenar': 1,
            'ikon': Icons.quiz_rounded,
          },
        ];

      case 'Artificial Intelligence':
      case 'Artificial Intelligence (AI)':
        return [
          {
            'judul': 'Pengertian Artificial Intelligence',
            'isi':
                'Artificial Intelligence (AI) atau kecerdasan '
                'buatan merupakan teknologi yang memungkinkan '
                'komputer melakukan tugas tertentu, seperti '
                'mengenali pola dan memahami bahasa.',
            'ikon': Icons.smart_toy_rounded,
          },
          {
            'judul': 'Contoh Penggunaan AI',
            'isi':
                'AI dapat digunakan pada chatbot, penerjemah '
                'otomatis, sistem rekomendasi, dan pengenalan suara.',
            'ikon': Icons.psychology_rounded,
          },
          {
            'jenis': 'aktivitas',
            'judul': 'Aktivitas: Mengenal AI',
            'isi': 'Manakah contoh penggunaan AI?',
            'pilihan': [
              'Chatbot yang menjawab pertanyaan',
              'Penggaris biasa',
              'Buku cetak',
              'Kursi belajar',
            ],
            'jawabanBenar': 0,
            'ikon': Icons.quiz_rounded,
          },
           {
            'judul': 'Contoh Penggunaan AI',
            'isi':
                'AI dapat digunakan pada chatbot, penerjemah '
                'otomatis, sistem rekomendasi, dan pengenalan suara.',
            'ikon': Icons.psychology_rounded,
          },
        ];

      default:
        return [
          {
            'judul': 'Materi Belum Tersedia',
            'isi': 'Materi untuk subbab ini sedang disiapkan.',
            'ikon': Icons.menu_book_rounded,
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: widget.materi.judul,
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

            // Aktivitas Benar atau Salah
            if (_slides[_slideAktif]['jenis'] == 'trueFalse') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _aktivitasSelesai
                          ? null
                          : () => _jawabTrueFalse(0),
                      child: const Text('TRUE'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _aktivitasSelesai
                          ? null
                          : () => _jawabTrueFalse(1),
                      child: const Text('FALSE'),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // REVISI 5: Ilustrasi untuk setiap slide materi
            Center(
              child: Container(
                width: 160,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.10),
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

            // REVISI 21: Navigasi antar-slide
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _slideAktif > 0
                        ? () async {
                            setState(() {
                              _slideAktif--;
                              _jawabanDipilih = null;
                              _aktivitasSelesai = false;
                            });
                            await _simpanProgres();
                          }
                        : null,
                    child: const Text('Kembali'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_slideAktif < _slides.length - 1) {
                        final slideBerikutnya = _slideAktif + 1;

                        setState(() {
                          _slideAktif = slideBerikutnya;
                          _jawabanDipilih = null;
                          _aktivitasSelesai = false;
                        });

                        final jenis = _slides[_slideAktif]['jenis'];

                        if (jenis == 'aktivitas' || jenis == 'trueFalse') {
                          await _tampilkanPopUpAktivitas();
                        } else {
                          await _simpanProgres();
                        }
                      } else {
                        final prefs = await SharedPreferences.getInstance();

                        await prefs.setBool(
                          'materiSelesai_${widget.materi.judul}',
                          true,
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
