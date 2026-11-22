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
    bool jawabanBenar = false;

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
                              setDialogState(() {
                                jawabanDipilih = index;
                                jawabanBenar = true;
                                pesan = 'Benar! Jawaban kamu tepat 🎉';
                              });

                              await _putarEfek('correct.mp3');

                              await Future.delayed(
                                const Duration(milliseconds: 1000),
                              );

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
                                ? (jawabanBenar ? Colors.green : Colors.red)
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
                'Teknologi adalah penerapan ilmu pengetahuan, '
                'keterampilan, dan berbagai cara untuk membantu '
                'manusia menyelesaikan pekerjaan serta memenuhi '
                'kebutuhan dalam kehidupan sehari-hari. '
                '\n\n'
                'Teknologi diciptakan agar pekerjaan manusia '
                'menjadi lebih mudah, cepat, praktis, dan efisien. '
                'Teknologi tidak hanya berupa alat elektronik, '
                'tetapi juga dapat berupa alat, metode, maupun '
                'sistem yang membantu aktivitas manusia. '
                '\n\n'
                'Contohnya, smartphone digunakan untuk berkomunikasi '
                'dan mencari informasi, komputer digunakan untuk '
                'mengolah data serta membuat dokumen, sedangkan '
                'internet membantu manusia memperoleh informasi '
                'dan berkomunikasi tanpa harus bertemu secara langsung.',
            'ikon': Icons.devices_rounded,
            'gambar': 'assets/images/pengenalan_teknologi.png',
          },
          {
            'judul': 'Sejarah dan Perkembangan Teknologi',
            'isi':
                'Teknologi telah berkembang sejak manusia mulai '
                'menciptakan alat sederhana untuk memenuhi kebutuhan '
                'hidupnya. Seiring berjalannya waktu, teknologi '
                'mengalami perubahan dari bentuk sederhana menjadi '
                'semakin modern.\n\n'
                'Perkembangan teknologi dapat dibagi menjadi beberapa tahap:\n\n'
                '1. Masa Prasejarah\n'
                'Manusia menggunakan batu, kayu, dan tulang sebagai '
                'alat untuk berburu dan bertahan hidup.\n\n'
                '2. Masa Peradaban\n'
                'Mulai ditemukan roda, alat pertanian, serta teknologi '
                'pengolahan logam.\n\n'
                '3. Revolusi Industri\n'
                'Penggunaan mesin mulai berkembang untuk membantu '
                'proses produksi.\n\n'
                '4. Era Modern\n'
                'Berkembangnya listrik, telepon, komputer, dan internet.\n\n'
                '5. Era Digital\n'
                'Munculnya kecerdasan buatan (AI), robotika, '
                'komputasi awan, dan Internet of Things (IoT).\n\n'
                'Perkembangan tersebut menunjukkan bahwa teknologi '
                'terus berubah mengikuti kebutuhan dan kemajuan '
                'ilmu pengetahuan manusia.',
            'ikon': Icons.history_edu_rounded,
            'gambar': 'assets/images/sejarah_teknologi.png',
          },
          {
            'judul': 'Jenis-Jenis Teknologi',
            'isi':
                'Teknologi memiliki berbagai jenis yang digunakan '
                'untuk membantu manusia dalam bidang kehidupan '
                'yang berbeda-beda.\n\n'
                '1. Teknologi Informasi\n'
                'Digunakan untuk mengolah, menyimpan, dan menyampaikan '
                'informasi. Contohnya komputer dan laptop.\n\n'
                '2. Teknologi Komunikasi\n'
                'Digunakan untuk memudahkan manusia berkomunikasi. '
                'Contohnya smartphone dan aplikasi pesan.\n\n'
                '3. Teknologi Transportasi\n'
                'Digunakan untuk membantu manusia berpindah tempat. '
                'Contohnya mobil, kereta, dan pesawat.\n\n'
                '4. Teknologi Pendidikan\n'
                'Digunakan untuk mendukung kegiatan belajar. '
                'Contohnya komputer dan aplikasi pembelajaran.\n\n'
                '5. Teknologi Kesehatan\n'
                'Digunakan untuk membantu pemeriksaan dan perawatan '
                'kesehatan. Contohnya alat USG dan termometer digital.\n\n'
                '6. Teknologi Industri dan Pertanian\n'
                'Digunakan untuk membantu proses produksi dan '
                'pengolahan hasil pertanian. Contohnya mesin produksi '
                'dan traktor.',
            'ikon': Icons.category_rounded,
            'gambar': 'assets/images/jenis_teknologi.png',
          },
          {
            'judul': 'Fungsi Teknologi',
            'isi':
                'Teknologi memiliki berbagai fungsi yang membantu '
                'manusia dalam menjalankan aktivitas sehari-hari.\n\n'
                '1. Mempermudah Pekerjaan\n'
                'Teknologi membantu menyelesaikan pekerjaan dengan '
                'lebih mudah dan cepat.\n\n'
                '2. Meningkatkan Efisiensi\n'
                'Teknologi menghemat waktu, tenaga, dan biaya dalam '
                'melakukan suatu kegiatan.\n\n'
                '3. Mempermudah Komunikasi\n'
                'Manusia dapat berkomunikasi tanpa harus bertemu '
                'secara langsung.\n\n'
                '4. Mengolah Informasi\n'
                'Teknologi membantu mengumpulkan, mengolah, dan '
                'menyampaikan informasi.\n\n'
                '5. Menyimpan Data\n'
                'Berbagai informasi dapat disimpan secara digital '
                'dan diakses kembali ketika dibutuhkan.',
            'ikon': Icons.settings_suggest_rounded,
            'gambar': 'assets/images/fungsi_teknologi.png',
          },
          {
            'judul': 'Aktivitas Interaktif',
            'isi': 'Manakah yang merupakan fungsi utama teknologi?',
            'jenis': 'aktivitas',
            'pertanyaan': 'Manakah yang merupakan fungsi utama teknologi?',
            'pilihan': [
              'Mempersulit pekerjaan manusia',
              'Membantu pekerjaan manusia',
              'Menghambat komunikasi',
              'Mengurangi informasi',
            ],
            'jawabanBenar': 1,
            'ikon': Icons.quiz_rounded,
          },
          {
            'judul': 'Contoh Teknologi di Sekitar Kita',
            'isi':
                'Teknologi dapat ditemukan dengan mudah dalam '
                'kehidupan sehari-hari. Berikut beberapa contohnya:\n\n'
                '1. Smartphone\n'
                'Digunakan untuk berkomunikasi, mencari informasi, '
                'dan menjalankan berbagai aplikasi.\n\n'
                '2. Laptop dan Komputer\n'
                'Digunakan untuk mengetik, mengolah data, belajar, '
                'dan menyelesaikan pekerjaan.\n\n'
                '3. Internet\n'
                'Digunakan untuk mencari informasi, mengakses '
                'pembelajaran, dan berkomunikasi.\n\n'
                '4. Mesin Cuci\n'
                'Membantu mencuci pakaian sehingga pekerjaan rumah '
                'menjadi lebih mudah.\n\n'
                '5. ATM dan Mobile Banking\n'
                'Membantu melakukan transaksi keuangan secara '
                'lebih praktis.\n\n'
                '6. Aplikasi Pembelajaran\n'
                'Membantu siswa memperoleh materi dan belajar '
                'secara digital.',
            'ikon': Icons.lightbulb_rounded,
          },

          {
            'judul': 'Manfaat Teknologi',
            'isi':
                'Teknologi memberikan banyak manfaat dalam berbagai '
                'bidang kehidupan manusia.\n\n'
                '1. Bidang Pendidikan\n'
                'Membantu siswa mencari materi, mengikuti pembelajaran '
                'daring, dan mengakses sumber belajar.\n\n'
                '2. Bidang Kesehatan\n'
                'Membantu dokter melakukan pemeriksaan dan memberikan '
                'pelayanan kesehatan.\n\n'
                '3. Bidang Komunikasi\n'
                'Memudahkan manusia bertukar pesan dan informasi '
                'dengan cepat.\n\n'
                '4. Bidang Ekonomi\n'
                'Membantu kegiatan jual beli, pembayaran, dan '
                'pengembangan usaha.\n\n'
                '5. Bidang Transportasi\n'
                'Mempermudah perjalanan dan membantu menentukan '
                'rute perjalanan.',
            'ikon': Icons.lightbulb_rounded,
            'gambar': 'assets/images/manfaat_teknologi.png',
          },

          {
            'judul': 'Dampak Positif dan Negatif Teknologi',
            'isi':
                'Penggunaan teknologi memberikan dampak positif '
                'dan negatif bagi kehidupan manusia.\n\n'
                'Dampak Positif:\n'
                '1. Pekerjaan menjadi lebih mudah dan cepat.\n'
                '2. Informasi lebih mudah diperoleh.\n'
                '3. Komunikasi dapat dilakukan dari jarak jauh.\n'
                '4. Membantu kegiatan belajar dan bekerja.\n\n'
                'Dampak Negatif:\n'
                '1. Menimbulkan ketergantungan terhadap teknologi.\n'
                '2. Berisiko menyebabkan kebocoran data pribadi.\n'
                '3. Mempermudah penyebaran berita bohong atau hoaks.\n'
                '4. Mengurangi interaksi secara langsung.\n'
                '5. Beberapa pekerjaan dapat berubah akibat otomatisasi.\n\n'
                'Oleh karena itu, teknologi perlu digunakan secara '
                'bijak dan bertanggung jawab.',
            'ikon': Icons.balance_rounded,
            'gambar': 'assets/images/dampak_teknologi.png',
          },
          {
            'judul': 'Aktivitas Interaktif',
            'isi': 'Pilih tindakan yang menunjukkan penggunaan teknologi secara bijak!',
            'jenis': 'aktivitas',
            'pertanyaan': 'Manakah tindakan yang menunjukkan penggunaan teknologi secara bijak?',
            'pilihan': [
              'Membagikan kata sandi kepada teman',
              'Menyebarkan berita tanpa memeriksa kebenarannya',
              'Menjaga data pribadi dan memeriksa informasi',
              'Menggunakan gadget sepanjang waktu',
            ],
            'jawabanBenar': 2,
            'ikon': Icons.quiz_rounded,
          },

          {
            'judul': 'Menggunakan Teknologi dengan Bijak',
            'isi':
                'Teknologi harus digunakan secara bijak agar '
                'memberikan manfaat dan tidak merugikan diri sendiri '
                'maupun orang lain.\n\n'
                'Berikut beberapa cara menggunakan teknologi dengan bijak:\n\n'
                '1. Melindungi Data Pribadi\n'
                'Jangan membagikan kata sandi, alamat, atau informasi '
                'pribadi kepada sembarang orang.\n\n'
                '2. Memeriksa Kebenaran Informasi\n'
                'Pastikan informasi berasal dari sumber yang terpercaya '
                'sebelum membagikannya.\n\n'
                '3. Mengatur Waktu Penggunaan\n'
                'Gunakan perangkat digital sesuai kebutuhan dan '
                'jangan sampai mengganggu kegiatan belajar atau istirahat.\n\n'
                '4. Menggunakan untuk Hal Positif\n'
                'Manfaatkan teknologi untuk belajar, berkarya, dan '
                'mengembangkan kemampuan.\n\n'
                '5. Menghargai Orang Lain\n'
                'Berkomunikasilah dengan sopan dan jangan melakukan '
                'perundungan di dunia digital.\n\n'
                '6. Menghargai Hak Cipta\n'
                'Cantumkan sumber ketika menggunakan karya atau '
                'informasi milik orang lain.',
            'ikon': Icons.verified_user_rounded,
          },
          {
            'judul': 'Kesimpulan',
            'isi':
                'Teknologi merupakan penerapan ilmu pengetahuan '
                'dan keterampilan manusia untuk membantu memenuhi '
                'kebutuhan serta menyelesaikan berbagai pekerjaan.\n\n'
                'Teknologi terus berkembang dan digunakan dalam '
                'berbagai bidang, seperti pendidikan, kesehatan, '
                'komunikasi, ekonomi, dan transportasi.\n\n'
                'Teknologi memberikan banyak manfaat, tetapi juga '
                'memiliki dampak negatif apabila digunakan secara '
                'berlebihan atau tidak bertanggung jawab.\n\n'
                'Oleh karena itu, kita harus menggunakan teknologi '
                'secara bijak, aman, dan bertanggung jawab agar '
                'dapat memberikan manfaat bagi kehidupan.',
            'ikon': Icons.school_rounded,
            'gambar': 'assets/images/kesimpulan_teknologi.png',
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

            // Ilustrasi untuk setiap slide materi
            Center(
              child: Container(
                width: 160,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _slides[_slideAktif]['gambar'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          _slides[_slideAktif]['gambar'],
                          width: 160,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
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
