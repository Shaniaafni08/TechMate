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
    final isTrueFalse = aktivitas['jenis'] == 'trueFalse';

    int? jawabanDipilih;
    String? pesan;
    bool jawabanBenar = false;
    int nomorPertanyaan = 0;

    final daftarPertanyaan = isTrueFalse
        ? List<Map<String, dynamic>>.from(aktivitas['pertanyaan'])
        : <Map<String, dynamic>>[];

    final pilihan = isTrueFalse
        ? ['TRUE', 'FALSE']
        : aktivitas['pilihan'] as List<String>;

    final hasil = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isiPertanyaan = isTrueFalse
                ? daftarPertanyaan[nomorPertanyaan]['teks']
                : aktivitas['isi'];

            final jawabanBenarAktif = isTrueFalse
                ? daftarPertanyaan[nomorPertanyaan]['jawabanBenar']
                : aktivitas['jawabanBenar'];

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
                  if (isTrueFalse)
                    Text(
                      'Pertanyaan ${nomorPertanyaan + 1} dari ${daftarPertanyaan.length}',
                      style: const TextStyle(
                        color: AppColors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  const SizedBox(height: 8),

                  Text(
                    isiPertanyaan,
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
                          onPressed: jawabanBenar
                              ? null
                              : () async {
                                  final benar = index == jawabanBenarAktif;

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

                                    if (!dialogContext.mounted) return;

                                    if (isTrueFalse &&
                                        nomorPertanyaan <
                                            daftarPertanyaan.length - 1) {
                                      setDialogState(() {
                                        nomorPertanyaan++;
                                        jawabanDipilih = null;
                                        jawabanBenar = false;
                                        pesan = null;
                                      });
                                    } else {
                                      Navigator.pop(dialogContext, true);
                                    }
                                  } else {
                                    await _putarEfek('wrong.mp3');

                                    setDialogState(() {
                                      jawabanDipilih = index;
                                      jawabanBenar = false;
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
                      style: TextStyle(
                        color: jawabanBenar ? Colors.green : Colors.red,
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
            'gambar': 'assets/images/sejarah_teknologi.jpg',
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
            'gambar': 'assets/images/contoh.jpg',
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
            'gambar': 'assets/images/kesimpulan.png',
          },
        ];

      case 'Sistem Komputer':
        return [
          {
            'judul': 'Pengertian Sistem Komputer',

            'isi':
                'Sistem komputer adalah sekumpulan komponen '
                'yang saling berhubungan dan bekerja sama untuk '
                'mengolah data menjadi informasi yang berguna.\n\n'
                'Dalam penggunaannya, komputer tidak hanya terdiri '
                'dari perangkat yang dapat dilihat secara fisik. '
                'Ada juga program yang mengatur kerja komputer serta '
                'manusia yang mengoperasikannya.\n\n'
                'Sistem komputer memiliki tiga komponen utama, yaitu:\n'
                '1. Hardware (perangkat keras).\n'
                '2. Software (perangkat lunak).\n'
                '3. Brainware (pengguna).\n\n'
                'Contoh: ketika siswa mengetik tugas menggunakan '
                'Microsoft Word, keyboard digunakan untuk memasukkan '
                'data, software mengolah perintah, dan monitor '
                'menampilkan hasilnya.',

            'ikon': Icons.computer_rounded,
          },
          {
            'judul': 'Hardware (Perangkat Keras)',

            'isi':
                'Hardware atau perangkat keras adalah seluruh '
                'komponen fisik komputer yang dapat dilihat dan '
                'disentuh secara langsung.\n\n'
                'Hardware memiliki peran penting karena menjadi '
                'tempat pengguna memberikan perintah, tempat data '
                'diproses, dan tempat hasil pengolahan ditampilkan.\n\n'
                'Beberapa contoh hardware antara lain:\n\n'
                '1. Monitor: menampilkan informasi dalam bentuk gambar '
                'dan tulisan.\n'
                '2. Keyboard: memasukkan huruf, angka, dan perintah.\n'
                '3. Mouse: menggerakkan kursor dan memilih menu.\n'
                '4. Processor: mengolah data dan menjalankan instruksi.\n'
                '5. Printer: mencetak dokumen atau gambar.\n\n'
                'Contoh dalam kehidupan sehari-hari: ketika kita '
                'mengetik tugas, keyboard digunakan untuk memasukkan '
                'teks, processor mengolah perintah, dan monitor '
                'menampilkan hasil ketikan.',

            'ikon': Icons.desktop_windows_rounded,
          },
          {
            'judul': 'Komponen Utama Hardware',

            'isi':
                'Hardware dapat dikelompokkan berdasarkan fungsi '
                'dan cara kerjanya. Secara umum, terdapat empat '
                'kelompok utama perangkat keras, yaitu:\n\n'
                '1. Input Device (Perangkat Masukan)\n'
                'Digunakan untuk memasukkan data atau perintah '
                'ke dalam komputer.\n'
                'Contoh: keyboard, mouse, scanner, dan microphone.\n\n'
                '2. Process Device (Perangkat Pemroses)\n'
                'Digunakan untuk mengolah data dan menjalankan '
                'instruksi yang diberikan oleh pengguna.\n'
                'Contoh: processor (CPU) dan RAM.\n\n'
                '3. Output Device (Perangkat Keluaran)\n'
                'Digunakan untuk menampilkan hasil pengolahan '
                'data kepada pengguna.\n'
                'Contoh: monitor, printer, dan speaker.\n\n'
                '4. Storage Device (Perangkat Penyimpanan)\n'
                'Digunakan untuk menyimpan data dan informasi '
                'agar dapat digunakan kembali.\n'
                'Contoh: hard disk, SSD, dan flashdisk.\n\n'
                'Keempat kelompok perangkat tersebut saling '
                'mendukung agar komputer dapat bekerja dengan baik.',

            'ikon': Icons.memory_rounded,
          },
          {
            'judul': 'Software (Perangkat Lunak)',

            'isi':
                'Software atau perangkat lunak adalah kumpulan '
                'program dan instruksi yang digunakan untuk '
                'mengatur serta menjalankan berbagai tugas pada komputer.\n\n'
                'Berbeda dengan hardware, software tidak memiliki '
                'bentuk fisik sehingga tidak dapat disentuh secara '
                'langsung. Namun, software dapat dilihat dan digunakan '
                'melalui tampilan komputer.\n\n'
                'Software berfungsi untuk menghubungkan pengguna '
                'dengan perangkat keras. Tanpa software, hardware '
                'tidak dapat menjalankan tugas sesuai kebutuhan pengguna.\n\n'
                'Contoh software dalam kehidupan sehari-hari:\n\n'
                '1. Windows: sistem operasi untuk mengelola komputer.\n'
                '2. Microsoft Word: membuat dan mengedit dokumen.\n'
                '3. Microsoft PowerPoint: membuat presentasi.\n'
                '4. Google Chrome: mengakses halaman internet.\n'
                '5. Paint: membuat dan mengedit gambar.\n\n'
                'Contoh: ketika siswa membuat tugas menggunakan '
                'Microsoft Word, software membantu mengolah tulisan, '
                'mengatur halaman, dan menyimpan dokumen.',

            'ikon': Icons.apps_rounded,
          },
          {
            'judul': 'Jenis-Jenis Software',
            'isi':
                'Software dapat dibedakan menjadi beberapa jenis:\n\n'
                '1. Sistem operasi: mengatur seluruh kerja komputer, '
                'contohnya Windows dan Linux.\n'
                '2. Aplikasi: membantu pengguna melakukan pekerjaan, '
                'contohnya Microsoft Word dan PowerPoint.\n'
                '3. Utility: membantu merawat dan melindungi komputer, '
                'contohnya antivirus.',
            'ikon': Icons.settings_applications_rounded,
          },
          {
            'jenis': 'aktivitas',
            'judul': 'Aktivitas 1: Pilihan Ganda',
            'isi': 'Manakah yang termasuk perangkat keras komputer?',
            'pilihan': [
              'Microsoft Word',
              'Keyboard',
              'Windows',
              'Google Chrome',
            ],
            'jawabanBenar': 1,
            'ikon': Icons.quiz_rounded,
          },
          {
            'judul': 'Brainware (Pengguna)',
            'isi':
                'Brainware adalah manusia yang menggunakan, '
                'mengoperasikan, atau mengelola sistem komputer.\n\n'
                'Contohnya siswa, guru, programmer, operator komputer, '
                'dan teknisi.',
            'ikon': Icons.person_rounded,
          },
          {
            'judul': 'Hubungan Ketiga Komponen',
            'isi':
                'Hardware, software, dan brainware saling membutuhkan '
                'agar komputer dapat bekerja dengan baik.\n\n'
                'Hardware menyediakan perangkat fisik, software '
                'memberikan instruksi, sedangkan brainware memberikan '
                'perintah dan mengoperasikan komputer.',
            'ikon': Icons.hub_rounded,
          },
          {
            'judul': 'Cara Kerja Sistem Komputer',
            'isi':
                'Sistem komputer bekerja melalui empat tahapan utama:\n\n'
                '1. Input: data dimasukkan melalui keyboard atau mouse.\n'
                '2. Process: processor mengolah data sesuai instruksi.\n'
                '3. Output: hasil ditampilkan melalui monitor atau printer.\n'
                '4. Storage: data dapat disimpan ke media penyimpanan.\n\n'
                'Contoh: saat mengetik tugas, komputer menerima '
                'ketikan, mengolahnya, lalu menampilkan tulisan di layar.',
            'ikon': Icons.sync_alt_rounded,
          },

          {
            'jenis': 'trueFalse',
            'judul': 'Aktivitas 2: Benar atau Salah',
            'isi': 'Jawablah pernyataan berikut dengan benar atau salah.',
            'pertanyaan': [
              {'teks': 'Keyboard termasuk perangkat input.', 'jawabanBenar': 0},
              {
                'teks': 'Brainware adalah manusia yang menggunakan komputer.',
                'jawabanBenar': 0,
              },
            ],
            'ikon': Icons.fact_check_rounded,
          },

          {
            'judul': 'Kesimpulan',
            'isi':
                'Sistem komputer merupakan kesatuan dari hardware, '
                'software, dan brainware yang saling bekerja sama.\n\n'
                'Ketiga komponen tersebut memiliki fungsi berbeda, '
                'tetapi semuanya dibutuhkan agar komputer dapat '
                'menerima, mengolah, menyimpan, dan menghasilkan informasi.\n\n'
                'Dengan memahami sistem komputer, kita dapat '
                'menggunakan teknologi dengan lebih baik.',
            'ikon': Icons.school_rounded,
          },
        ];

      case 'Jaringan dan Internet':
        return [
          {
            'judul': 'Pengertian Jaringan Komputer',
            'isi':
                'Jaringan komputer adalah sekumpulan dua atau lebih '
                'perangkat yang saling terhubung untuk melakukan '
                'komunikasi, bertukar data, dan berbagi sumber daya. '
                'Perangkat yang terhubung tidak hanya berupa komputer, '
                'tetapi juga laptop, smartphone, printer, server, '
                'dan perangkat lainnya yang mendukung koneksi jaringan.\n\n'
                'Hubungan antarperangkat dapat dilakukan menggunakan '
                'media kabel maupun tanpa kabel (nirkabel). Contoh '
                'koneksi menggunakan kabel adalah kabel Ethernet, '
                'sedangkan koneksi nirkabel dapat menggunakan Wi-Fi '
                'atau Bluetooth.\n\n'
                'Jaringan komputer memungkinkan pengguna mengirim '
                'file, mengakses informasi, berkomunikasi, serta '
                'menggunakan perangkat secara bersama-sama. Dengan '
                'adanya jaringan, pengguna tidak perlu selalu '
                'memindahkan data menggunakan flashdisk atau media '
                'penyimpanan lainnya.\n\n'
                'Dalam sebuah jaringan terdapat beberapa unsur '
                'penting, yaitu perangkat yang saling terhubung, '
                'media transmisi sebagai jalur pengiriman data, '
                'perangkat jaringan yang mengatur hubungan, serta '
                'protokol yang menjadi aturan komunikasi antarperangkat.\n\n'
                'Contohnya dapat ditemukan di laboratorium komputer '
                'sekolah. Beberapa komputer dihubungkan dalam satu '
                'jaringan agar siswa dapat bertukar file, mengakses '
                'internet, dan menggunakan printer yang sama.\n\n'
                'Dengan demikian, jaringan komputer membantu '
                'mempermudah pekerjaan, mempercepat pertukaran '
                'informasi, dan meningkatkan efisiensi penggunaan '
                'sumber daya.',
            'ikon': Icons.lan_rounded,
          },
          {
            'judul': 'Tujuan dan Manfaat Jaringan Komputer',
            'isi':
                'Jaringan komputer dibuat untuk mempermudah hubungan '
                'dan pertukaran informasi antara satu perangkat '
                'dengan perangkat lainnya. Jaringan juga memungkinkan '
                'pengguna memanfaatkan sumber daya secara bersama-sama '
                'tanpa harus memiliki perangkat yang sama pada setiap '
                'komputer.\n\n'
                'Berikut beberapa tujuan dan manfaat jaringan komputer:\n\n'
                '1. Berbagi Data dan Informasi\n'
                'Pengguna dapat mengirim, menerima, dan membuka file '
                'dari perangkat lain yang terhubung dalam jaringan. '
                'Contohnya siswa dapat mengirimkan tugas kepada guru '
                'melalui jaringan sekolah.\n\n'
                '2. Berbagi Perangkat Keras\n'
                'Beberapa komputer dapat menggunakan satu perangkat '
                'yang sama, seperti printer. Hal ini dapat menghemat '
                'biaya pembelian perangkat.\n\n'
                '3. Mempermudah Komunikasi\n'
                'Jaringan memungkinkan pengguna berkomunikasi melalui '
                'email, pesan instan, dan panggilan video.\n\n'
                '4. Mempermudah Akses Informasi\n'
                'Pengguna dapat memperoleh informasi dari berbagai '
                'perangkat dan layanan yang tersedia dalam jaringan.\n\n'
                '5. Meningkatkan Efisiensi Pekerjaan\n'
                'Pertukaran data dan penggunaan sumber daya dapat '
                'dilakukan dengan lebih cepat sehingga pekerjaan '
                'menjadi lebih praktis.\n\n'
                'Dalam lingkungan sekolah, jaringan komputer dapat '
                'membantu kegiatan pembelajaran, pengumpulan tugas, '
                'pengelolaan data siswa, dan penggunaan laboratorium '
                'komputer.',
            'ikon': Icons.share_rounded,
          },
          {
            'judul': 'Jenis-Jenis Jaringan Komputer',
            'isi':
                'Jaringan komputer dapat dibedakan berdasarkan '
                'jangkauan wilayah atau area yang dihubungkannya. '
                'Setiap jenis jaringan memiliki cakupan dan kegunaan '
                'yang berbeda.\n\n'
                '1. PAN (Personal Area Network)\n'
                'PAN merupakan jaringan dengan jangkauan sangat dekat '
                'yang digunakan untuk menghubungkan perangkat pribadi. '
                'Contohnya menghubungkan smartphone dengan headset '
                'atau speaker menggunakan Bluetooth.\n\n'
                '2. LAN (Local Area Network)\n'
                'LAN merupakan jaringan yang mencakup area terbatas, '
                'seperti rumah, ruang kantor, sekolah, atau laboratorium '
                'komputer. Jaringan ini biasanya digunakan untuk '
                'menghubungkan beberapa perangkat dalam satu lokasi.\n\n'
                '3. MAN (Metropolitan Area Network)\n'
                'MAN merupakan jaringan yang memiliki jangkauan lebih '
                'luas dibandingkan LAN dan dapat mencakup wilayah satu '
                'kota. Jaringan ini dapat menghubungkan beberapa '
                'jaringan lokal yang berada di lokasi berbeda.\n\n'
                '4. WAN (Wide Area Network)\n'
                'WAN merupakan jaringan dengan jangkauan sangat luas, '
                'bahkan dapat menghubungkan wilayah antar kota, '
                'antarprovinsi, hingga antarnegara. Internet merupakan '
                'contoh jaringan global yang menggunakan konsep '
                'jaringan luas.\n\n'
                'Perbedaan utama keempat jenis jaringan tersebut '
                'terletak pada luas wilayah yang dapat dijangkau. '
                'Semakin luas cakupan wilayahnya, semakin besar pula '
                'kebutuhan infrastruktur yang digunakan.',
            'ikon': Icons.account_tree_rounded,
          },
          {
            'jenis': 'aktivitas',
            'judul': 'Aktivitas 1: Mengenal Jenis Jaringan',
            'isi':
                'Sebuah laboratorium komputer di sekolah memiliki '
                'beberapa komputer yang saling terhubung untuk '
                'berbagi file dan menggunakan printer. Jenis jaringan '
                'apa yang paling sesuai dengan kondisi tersebut?',
            'pilihan': ['LAN', 'WAN', 'MAN', 'PAN'],
            'jawabanBenar': 0,
            'ikon': Icons.quiz_rounded,
          },
          {
            'judul': 'Media Transmisi Jaringan',
            'isi':
                'Media transmisi jaringan adalah jalur atau media '
                'yang digunakan untuk mengirimkan data dari satu '
                'perangkat ke perangkat lainnya. Media ini berperan '
                'penting agar informasi dapat berpindah melalui '
                'jaringan dengan baik.\n\n'
                'Secara umum, media transmisi dibagi menjadi dua jenis:\n\n'
                '1. Media Kabel (Wired)\n'
                'Media kabel menggunakan penghantar fisik untuk '
                'mengirimkan data. Beberapa contohnya adalah:\n\n'
                '- Kabel UTP: kabel yang sering digunakan untuk '
                'menghubungkan komputer dengan switch atau router '
                'dalam jaringan lokal.\n'
                '- Kabel Fiber Optic: menggunakan cahaya untuk '
                'mengirimkan data dengan kecepatan tinggi dan dapat '
                'digunakan untuk jarak yang jauh.\n'
                '- Kabel Coaxial: kabel yang memiliki lapisan '
                'pelindung dan pernah banyak digunakan pada jaringan '
                'komputer serta sistem televisi.\n\n'
                '2. Media Tanpa Kabel (Wireless)\n'
                'Media wireless mengirimkan data tanpa menggunakan '
                'kabel fisik. Contohnya adalah Wi-Fi, Bluetooth, '
                'dan jaringan seluler.\n\n'
                'Wi-Fi biasanya digunakan untuk menghubungkan laptop '
                'dan smartphone ke jaringan secara nirkabel. Bluetooth '
                'digunakan untuk komunikasi jarak dekat, misalnya '
                'menghubungkan HP dengan headset.\n\n'
                'Pemilihan media transmisi disesuaikan dengan kebutuhan, '
                'jarak, kecepatan, kondisi lingkungan, dan biaya '
                'pemasangan jaringan.',
            'ikon': Icons.cable_rounded,
          },
          {
            'judul': 'Perangkat Jaringan Komputer',
            'isi':
                'Agar jaringan komputer dapat bekerja dengan baik, '
                'dibutuhkan perangkat pendukung yang berfungsi '
                'menghubungkan, mengatur, dan mengirimkan data '
                'antarperangkat.\n\n'
                'Beberapa perangkat jaringan yang sering digunakan '
                'antara lain:\n\n'
                '1. Router\n'
                'Router berfungsi menghubungkan jaringan yang berbeda '
                'dan menentukan jalur pengiriman paket data menuju '
                'jaringan tujuan. Router sering digunakan untuk '
                'menghubungkan jaringan rumah atau kantor ke internet.\n\n'
                '2. Switch\n'
                'Switch berfungsi menghubungkan beberapa perangkat '
                'dalam satu jaringan lokal (LAN) dan meneruskan data '
                'ke perangkat tujuan yang sesuai.\n\n'
                '3. Modem\n'
                'Modem merupakan perangkat yang membantu proses '
                'komunikasi data antara jaringan pengguna dan layanan '
                'penyedia internet dengan menyesuaikan bentuk sinyal '
                'sesuai teknologi koneksi yang digunakan.\n\n'
                '4. Access Point\n'
                'Access Point menyediakan akses jaringan nirkabel '
                'sehingga perangkat seperti laptop dan smartphone '
                'dapat terhubung melalui Wi-Fi.\n\n'
                '5. Network Interface Card (NIC)\n'
                'NIC merupakan komponen pada komputer atau perangkat '
                'yang memungkinkan perangkat tersebut terhubung '
                'ke jaringan, baik menggunakan kabel maupun koneksi '
                'nirkabel.\n\n'
                'Setiap perangkat memiliki fungsi yang berbeda, tetapi '
                'saling mendukung agar komunikasi dan pertukaran data '
                'dalam jaringan dapat berjalan dengan baik.',
            'ikon': Icons.router_rounded,
          },
          {
            'judul': 'Topologi Jaringan Komputer',
            'isi':
                'Topologi jaringan adalah pola atau bentuk hubungan '
                'antarperangkat dalam sebuah jaringan komputer. '
                'Topologi menggambarkan bagaimana perangkat '
                'dihubungkan serta bagaimana jalur komunikasi '
                'data dibentuk.\n\n'
                'Beberapa jenis topologi jaringan yang umum dikenal '
                'adalah sebagai berikut:\n\n'
                '1. Topologi Bus\n'
                'Semua perangkat dihubungkan melalui satu kabel utama '
                'sebagai jalur komunikasi. Bentuknya sederhana, tetapi '
                'jika kabel utama mengalami gangguan, komunikasi '
                'jaringan dapat terganggu.\n\n'
                '2. Topologi Star\n'
                'Setiap perangkat terhubung ke satu perangkat pusat, '
                'biasanya switch. Topologi ini banyak digunakan karena '
                'mudah dikelola dan gangguan pada satu kabel perangkat '
                'biasanya tidak langsung memengaruhi perangkat lain.\n\n'
                '3. Topologi Ring\n'
                'Setiap perangkat dihubungkan membentuk lingkaran '
                'sehingga data mengalir mengikuti jalur tertentu '
                'dalam jaringan.\n\n'
                '4. Topologi Mesh\n'
                'Perangkat memiliki beberapa jalur hubungan dengan '
                'perangkat lainnya. Topologi ini menawarkan lebih '
                'banyak jalur komunikasi, tetapi membutuhkan lebih '
                'banyak koneksi dan biaya pemasangan.\n\n'
                'Pemilihan topologi harus disesuaikan dengan jumlah '
                'perangkat, kebutuhan komunikasi, biaya, dan kondisi '
                'lingkungan jaringan.',
            'ikon': Icons.hub_rounded,
          },
          {
            'judul': 'Mengenal Internet dan Layanannya',
            'isi':
                'Internet adalah jaringan global yang menghubungkan '
                'berbagai jaringan komputer di seluruh dunia. Melalui '
                'internet, pengguna dapat saling bertukar informasi '
                'meskipun berada di lokasi yang berbeda.\n\n'
                'Internet memungkinkan berbagai perangkat untuk '
                'berkomunikasi dan mengakses layanan digital. '
                'Penggunaannya sangat luas, mulai dari pendidikan, '
                'pekerjaan, bisnis, hiburan, hingga komunikasi.\n\n'
                'Beberapa layanan yang dapat digunakan melalui internet '
                'antara lain:\n\n'
                '1. World Wide Web (WWW)\n'
                'Layanan untuk mengakses berbagai halaman website '
                'yang berisi informasi, gambar, video, dan materi '
                'pembelajaran.\n\n'
                '2. Email\n'
                'Digunakan untuk mengirim dan menerima surat elektronik '
                'atau dokumen melalui internet.\n\n'
                '3. Mesin Pencari\n'
                'Digunakan untuk menemukan informasi berdasarkan '
                'kata kunci yang dimasukkan pengguna, contohnya Google.\n\n'
                '4. Video Conference\n'
                'Memungkinkan pengguna melakukan pertemuan melalui '
                'video dan suara, meskipun berada di tempat berbeda.\n\n'
                '5. Penyimpanan Awan (Cloud Storage)\n'
                'Memungkinkan pengguna menyimpan dan mengakses file '
                'melalui internet, misalnya Google Drive.\n\n'
                'Perlu diketahui bahwa internet dan website bukan '
                'hal yang sama. Internet merupakan jaringan yang '
                'menghubungkan perangkat di seluruh dunia, sedangkan '
                'website adalah salah satu layanan yang dapat '
                'diakses melalui internet.',
            'ikon': Icons.language_rounded,
          },
          {
            'judul': 'Cara Kerja Internet',
            'isi':
                'Internet bekerja dengan mengirimkan data dari '
                'perangkat pengguna menuju server melalui berbagai '
                'jaringan yang saling terhubung. Proses ini berlangsung '
                'dengan bantuan perangkat jaringan dan aturan komunikasi '
                'yang disebut protokol.\n\n'
                'Berikut gambaran sederhana cara kerja internet '
                'ketika pengguna membuka sebuah website:\n\n'
                '1. Pengguna membuka browser dan memasukkan alamat '
                'website yang ingin dikunjungi.\n\n'
                '2. Sistem DNS (Domain Name System) membantu '
                'menerjemahkan nama domain, seperti alamat website, '
                'menjadi alamat IP yang digunakan untuk menemukan '
                'server tujuan.\n\n'
                '3. Perangkat mengirimkan permintaan data melalui '
                'jaringan lokal, router, dan penyedia layanan internet '
                'atau Internet Service Provider (ISP).\n\n'
                '4. Permintaan diteruskan melalui jaringan internet '
                'hingga mencapai server yang menyimpan atau menyediakan '
                'data website tersebut.\n\n'
                '5. Server mengirimkan data yang diminta kembali '
                'melalui jaringan menuju perangkat pengguna.\n\n'
                '6. Browser menerima data tersebut dan menampilkan '
                'halaman website pada layar.\n\n'
                'Dalam proses ini, alamat IP membantu mengidentifikasi '
                'perangkat atau tujuan dalam jaringan. Protokol TCP/IP '
                'mendukung komunikasi dan pengiriman data antarperangkat.\n\n'
                'Contohnya, ketika siswa membuka website pembelajaran, '
                'browser mengirimkan permintaan ke server. Setelah '
                'server memberikan data, halaman pembelajaran dapat '
                'ditampilkan dan digunakan oleh siswa.',
            'ikon': Icons.sync_alt_rounded,
          },
          {
            'judul': 'Keamanan dan Etika Menggunakan Internet',
            'isi':
                'Internet memberikan banyak kemudahan, tetapi '
                'penggunaannya juga memiliki risiko. Tidak semua '
                'informasi dan aktivitas di internet aman. Oleh karena '
                'itu, pengguna harus memahami cara menjaga keamanan '
                'diri dan menggunakan internet secara bertanggung jawab.\n\n'
                'Beberapa risiko yang perlu diperhatikan adalah:\n\n'
                '1. Penipuan Online\n'
                'Penipuan dapat dilakukan melalui pesan, website palsu, '
                'atau tawaran yang menjanjikan keuntungan tidak masuk akal.\n\n'
                '2. Pencurian Data Pribadi\n'
                'Informasi seperti kata sandi, nomor telepon, dan '
                'data pribadi dapat disalahgunakan oleh pihak lain.\n\n'
                '3. Malware dan Virus\n'
                'Program berbahaya dapat merusak perangkat, mencuri '
                'informasi, atau mengganggu sistem komputer.\n\n'
                '4. Berita Palsu\n'
                'Informasi yang tidak benar dapat menyebar dengan cepat '
                'sehingga pengguna perlu memeriksa sumber informasi.\n\n'
                '5. Cyberbullying\n'
                'Perundungan dapat terjadi melalui komentar, pesan, '
                'atau aktivitas di media sosial.\n\n'
                'Untuk menjaga keamanan, lakukan beberapa langkah berikut:\n'
                '- Gunakan kata sandi yang kuat dan tidak mudah ditebak.\n'
                '- Jangan membagikan data pribadi kepada orang asing.\n'
                '- Hindari membuka tautan dan file yang mencurigakan.\n'
                '- Gunakan website yang terpercaya dan koneksi aman.\n'
                '- Periksa kebenaran informasi sebelum membagikannya.\n'
                '- Hargai orang lain ketika berkomunikasi di internet.\n\n'
                'Dengan menggunakan internet secara bijak, kita dapat '
                'memanfaatkan teknologi untuk belajar, bekerja, dan '
                'berkomunikasi tanpa mengabaikan keamanan serta '
                'tanggung jawab sebagai pengguna.',
            'ikon': Icons.security_rounded,
          },
          {
            'jenis': 'aktivitas',
            'judul': 'Aktivitas 2: Memahami Internet',
            'isi':
                'Ketika seseorang membuka sebuah website, perangkat '
                'yang bertugas menyimpan atau menyediakan data website '
                'dan mengirimkannya kepada pengguna disebut apa?',
            'pilihan': ['Keyboard', 'Server', 'Monitor', 'Mouse'],
            'jawabanBenar': 1,
            'ikon': Icons.quiz_rounded,
          },
          {
            'judul': 'Kesimpulan',
            'isi':
                'Jaringan komputer merupakan hubungan antara dua '
                'atau lebih perangkat yang memungkinkan terjadinya '
                'komunikasi, pertukaran data, dan penggunaan sumber '
                'daya secara bersama-sama.\n\n'
                'Jaringan komputer memiliki beberapa jenis berdasarkan '
                'jangkauannya, yaitu PAN, LAN, MAN, dan WAN. Agar '
                'jaringan dapat berfungsi, dibutuhkan media transmisi, '
                'perangkat jaringan, serta aturan komunikasi atau '
                'protokol.\n\n'
                'Internet merupakan jaringan global yang menghubungkan '
                'berbagai jaringan komputer di seluruh dunia. Internet '
                'dapat digunakan untuk mencari informasi, belajar, '
                'berkomunikasi, bekerja, dan mengakses berbagai layanan '
                'digital.\n\n'
                'Namun, penggunaan internet harus dilakukan secara '
                'bijak. Pengguna perlu menjaga data pribadi, menggunakan '
                'kata sandi yang kuat, menghindari penipuan, serta '
                'memeriksa kebenaran informasi sebelum membagikannya.\n\n'
                'Dengan memahami jaringan komputer dan internet, '
                'kita diharapkan mampu memanfaatkan teknologi secara '
                'tepat, aman, dan bertanggung jawab dalam kehidupan '
                'sehari-hari.',
            'ikon': Icons.school_rounded,
          },
        ];

      case 'Keamanan Digital':
        return [
          {
            'judul': 'Pengertian Keamanan Digital',
            'isi':
                'Keamanan digital adalah upaya untuk melindungi '
                'perangkat, akun, jaringan, dan informasi pribadi '
                'dari berbagai ancaman atau tindakan yang tidak '
                'diinginkan ketika menggunakan teknologi digital.\n\n'
                'Saat ini, banyak aktivitas dilakukan secara online, '
                'seperti belajar, berkomunikasi, berbelanja, dan '
                'mengakses layanan perbankan. Aktivitas tersebut '
                'melibatkan penggunaan data dan informasi pribadi '
                'yang perlu dijaga keamanannya.\n\n'
                'Keamanan digital tidak hanya berkaitan dengan '
                'penggunaan antivirus atau aplikasi keamanan. '
                'Kebiasaan pengguna juga memiliki peran penting, '
                'seperti menggunakan kata sandi yang kuat, tidak '
                'membagikan kode OTP, dan berhati-hati ketika '
                'membuka tautan dari sumber yang tidak dikenal.\n\n'
                'Contohnya, ketika siswa menggunakan akun email '
                'untuk mengirim tugas, siswa perlu menjaga kata '
                'sandi agar akun tidak digunakan oleh orang lain.\n\n'
                'Dengan memahami keamanan digital, kita dapat '
                'menggunakan teknologi secara lebih aman, nyaman, '
                'dan bertanggung jawab.',
            'ikon': Icons.security_rounded,
          },
          {
            'judul': 'Tujuan dan Pentingnya Keamanan Digital',
            'isi':
                'Keamanan digital diperlukan agar pengguna dapat '
                'memanfaatkan teknologi tanpa mudah mengalami '
                'pencurian informasi, penyalahgunaan akun, atau '
                'kerusakan perangkat.\n\n'
                'Beberapa tujuan keamanan digital antara lain:\n\n'
                '1. Melindungi Data Pribadi\n'
                'Menjaga informasi seperti nama lengkap, alamat, '
                'nomor telepon, email, dan data penting lainnya '
                'agar tidak disalahgunakan.\n\n'
                '2. Melindungi Akun\n'
                'Mencegah orang lain masuk atau menggunakan akun '
                'tanpa izin pemiliknya.\n\n'
                '3. Menjaga Perangkat\n'
                'Mengurangi risiko kerusakan sistem dan pencurian '
                'data akibat virus atau program berbahaya.\n\n'
                '4. Menjaga Privasi\n'
                'Membantu pengguna mengendalikan informasi yang '
                'dibagikan kepada orang lain melalui internet.\n\n'
                '5. Mencegah Kerugian\n'
                'Mengurangi risiko penipuan, penyalahgunaan identitas, '
                'dan kerugian akibat kejahatan digital.\n\n'
                'Oleh karena itu, keamanan digital perlu diterapkan '
                'oleh semua pengguna, baik ketika menggunakan '
                'komputer, smartphone, maupun layanan internet.',
            'ikon': Icons.verified_user_rounded,
          },
          {
            'judul': 'Data Pribadi dan Privasi Digital',
            'isi':
                'Data pribadi adalah informasi yang berkaitan dengan '
                'seseorang dan dapat digunakan untuk mengenali atau '
                'mengidentifikasi orang tersebut. Data pribadi perlu '
                'dijaga karena dapat disalahgunakan apabila jatuh '
                'ke tangan pihak yang tidak bertanggung jawab.\n\n'
                'Contoh data pribadi yang harus dijaga antara lain:\n\n'
                '1. Nama lengkap dan tanggal lahir.\n'
                '2. Alamat rumah dan nomor telepon.\n'
                '3. Alamat email dan informasi akun.\n'
                '4. Kata sandi dan kode OTP.\n'
                '5. Nomor identitas dan informasi keuangan.\n'
                '6. Foto atau dokumen pribadi.\n\n'
                'Privasi digital berkaitan dengan hak dan kemampuan '
                'pengguna untuk mengendalikan informasi pribadi '
                'yang dikumpulkan, digunakan, atau dibagikan secara '
                'online.\n\n'
                'Agar privasi tetap terjaga, jangan sembarangan '
                'mengunggah dokumen pribadi, membagikan lokasi secara '
                'terbuka, atau memberikan informasi penting kepada '
                'orang yang tidak dikenal.\n\n'
                'Contohnya, sebelum mengunggah foto atau informasi '
                'ke media sosial, perhatikan apakah unggahan tersebut '
                'mengandung alamat rumah, nomor telepon, atau '
                'informasi pribadi lainnya.',
            'ikon': Icons.privacy_tip_rounded,
          },
          {
            'judul': 'Jenis-Jenis Ancaman Digital',
            'isi':
                'Ancaman digital adalah berbagai tindakan atau '
                'program yang dapat mengganggu keamanan perangkat, '
                'akun, jaringan, maupun informasi pengguna. '
                'Ancaman tersebut dapat terjadi ketika pengguna '
                'mengakses internet atau menggunakan aplikasi.\n\n'
                'Beberapa jenis ancaman digital yang perlu diketahui:\n\n'
                '1. Virus Komputer\n'
                'Program berbahaya yang dapat menyebar dan mengganggu '
                'kerja komputer serta merusak atau mengubah file.\n\n'
                '2. Malware\n'
                'Istilah umum untuk perangkat lunak berbahaya yang '
                'dirancang untuk merusak sistem, mengganggu perangkat, '
                'atau melakukan tindakan tanpa izin pengguna.\n\n'
                '3. Ransomware\n'
                'Jenis malware yang dapat mengunci atau mengenkripsi '
                'data korban dan meminta pembayaran untuk memulihkan '
                'akses data tersebut.\n\n'
                '4. Phishing\n'
                'Tindakan penipuan yang menggunakan pesan atau '
                'website palsu untuk memperoleh informasi sensitif '
                'seperti kata sandi dan data akun.\n\n'
                '5. Pencurian Akun\n'
                'Tindakan mengambil alih akun seseorang tanpa izin, '
                'misalnya melalui pencurian kata sandi.\n\n'
                'Ancaman tersebut dapat menimbulkan kerugian, '
                'sehingga pengguna perlu berhati-hati saat menerima '
                'pesan, mengunduh file, atau membuka tautan.',
            'ikon': Icons.warning_rounded,
          },
          {
            'judul': 'Cara Membuat Kata Sandi yang Kuat',
            'isi':
                'Kata sandi atau password merupakan informasi '
                'rahasia yang digunakan untuk mengakses akun '
                'atau perangkat. Kata sandi berfungsi sebagai '
                'salah satu bentuk perlindungan agar akun tidak '
                'mudah digunakan oleh orang lain.\n\n'
                'Kata sandi yang lemah dapat dengan mudah ditebak '
                'oleh orang lain. Contohnya adalah penggunaan '
                'kombinasi sederhana seperti 123456, password, '
                'atau tanggal lahir.\n\n'
                'Berikut cara membuat kata sandi yang lebih kuat:\n\n'
                '1. Gunakan kombinasi huruf besar dan huruf kecil.\n'
                '2. Tambahkan angka dan simbol jika diperbolehkan.\n'
                '3. Gunakan kata sandi yang cukup panjang dan unik.\n'
                '4. Hindari menggunakan nama atau tanggal lahir.\n'
                '5. Jangan menggunakan kata sandi yang sama '
                'untuk semua akun.\n'
                '6. Jangan membagikan kata sandi kepada orang lain.\n\n'
                'Contoh: kombinasi kata, angka, dan simbol yang '
                'unik lebih baik dibandingkan menggunakan kata '
                'sandi sederhana yang mudah ditebak.\n\n'
                'Jika sulit mengingat banyak kata sandi, pengguna '
                'dapat mempertimbangkan pengelola kata sandi '
                '(password manager) yang tepercaya.\n\n'
                'Ingat, kata sandi merupakan informasi rahasia '
                'yang harus dijaga oleh pemilik akun.',
            'ikon': Icons.lock_rounded,
          },

          {
            'jenis': 'aktivitas',
            'judul': 'Aktivitas 1: Keamanan Akun',
            'isi':
                'Kamu menerima pesan yang meminta kode OTP dengan '
                'alasan akunmu akan segera diblokir. Apa tindakan '
                'yang paling tepat untuk menjaga keamanan akun?',
            'pilihan': [
              'Memberikan kode OTP agar akun tidak diblokir',
              'Mengabaikan permintaan dan memeriksa melalui layanan resmi',
              'Mengirim kode OTP kepada teman untuk diperiksa',
              'Membalas pesan dengan memberikan kata sandi',
            ],
            'jawabanBenar': 1,
            'ikon': Icons.quiz_rounded,
          },

          {
            'judul': 'Verifikasi Dua Langkah dan Kode OTP',
            'isi':
                'Verifikasi dua langkah atau Two-Factor Authentication '
                '(2FA) merupakan metode keamanan yang meminta '
                'pengguna melakukan dua bentuk pemeriksaan identitas '
                'ketika masuk ke sebuah akun.\n\n'
                'Dengan menggunakan verifikasi dua langkah, '
                'perlindungan akun menjadi lebih baik karena '
                'kata sandi saja tidak cukup untuk menyelesaikan '
                'proses masuk.\n\n'
                'Salah satu bentuk verifikasi tambahan adalah '
                'kode OTP (One-Time Password). OTP merupakan kode '
                'sementara yang digunakan untuk memverifikasi '
                'identitas pengguna dan biasanya hanya berlaku '
                'dalam waktu terbatas.\n\n'
                'Contoh penerapannya adalah ketika seseorang '
                'masuk ke akun email. Setelah memasukkan kata sandi, '
                'pengguna mungkin diminta memasukkan kode verifikasi '
                'yang dikirim melalui metode autentikasi tertentu.\n\n'
                'Hal penting yang perlu diperhatikan:\n\n'
                '1. Jangan pernah memberikan kode OTP kepada orang lain.\n'
                '2. Jangan memasukkan kode OTP pada website yang '
                'tidak jelas atau mencurigakan.\n'
                '3. Aktifkan verifikasi dua langkah jika tersedia.\n'
                '4. Perhatikan notifikasi masuk yang tidak dikenal.\n\n'
                'Kode OTP bersifat rahasia. Pihak lain yang meminta '
                'kode tersebut dengan alasan apa pun perlu diwaspadai.',
            'ikon': Icons.phonelink_lock_rounded,
          },
          {
            'judul': 'Mengenal Phishing dan Penipuan Online',
            'isi':
                'Phishing merupakan salah satu bentuk kejahatan '
                'digital yang dilakukan dengan cara menipu pengguna '
                'agar memberikan informasi rahasia, seperti kata '
                'sandi, kode OTP, atau informasi akun lainnya.\n\n'
                'Pelaku biasanya menyamar sebagai pihak yang dikenal, '
                'seperti layanan bank, perusahaan, toko online, '
                'atau penyedia layanan digital.\n\n'
                'Contohnya, seseorang menerima pesan yang menyatakan '
                'bahwa akunnya akan diblokir jika tidak segera '
                'mengklik sebuah tautan. Tautan tersebut ternyata '
                'mengarah ke website palsu yang menyerupai website '
                'asli untuk mencuri informasi pengguna.\n\n'
                'Ciri-ciri pesan atau tautan yang mencurigakan:\n\n'
                '1. Menjanjikan hadiah atau keuntungan yang tidak wajar.\n'
                '2. Meminta kata sandi atau kode OTP.\n'
                '3. Menggunakan kalimat yang mendesak atau mengancam.\n'
                '4. Memiliki alamat website yang tidak sesuai '
                'dengan layanan aslinya.\n'
                '5. Berisi tautan atau lampiran dari sumber yang '
                'tidak dikenal.\n\n'
                'Cara menghindarinya adalah dengan tidak terburu-buru '
                'mengklik tautan, memeriksa alamat website, dan '
                'memastikan informasi melalui saluran resmi.\n\n'
                'Jika menerima pesan mencurigakan, jangan memberikan '
                'informasi pribadi dan jangan mengunduh lampiran '
                'yang tidak diketahui sumbernya.',
            'ikon': Icons.link_off_rounded,
          },
          {
            'judul': 'Keamanan Saat Menggunakan Internet',
            'isi':
                'Selain menjaga kata sandi dan data pribadi, '
                'pengguna juga perlu memperhatikan keamanan ketika '
                'mengakses internet. Kebiasaan yang baik dapat '
                'mengurangi risiko terjadinya penipuan dan '
                'penyalahgunaan informasi.\n\n'
                'Berikut beberapa cara menggunakan internet '
                'dengan lebih aman:\n\n'
                '1. Gunakan Website Tepercaya\n'
                'Pastikan website memiliki alamat yang benar dan '
                'perhatikan penggunaan HTTPS ketika memasukkan '
                'informasi penting.\n\n'
                '2. Hindari Wi-Fi Publik yang Tidak Dikenal\n'
                'Berhati-hatilah ketika mengakses akun penting '
                'melalui jaringan Wi-Fi umum yang tidak diketahui '
                'keamanannya.\n\n'
                '3. Perbarui Sistem dan Aplikasi\n'
                'Pembaruan dapat memperbaiki kesalahan dan menutup '
                'celah keamanan yang ditemukan pada perangkat lunak.\n\n'
                '4. Gunakan Antivirus atau Fitur Keamanan\n'
                'Perlindungan keamanan dapat membantu mendeteksi '
                'dan menangani file atau program yang berbahaya.\n\n'
                '5. Periksa Sebelum Mengunduh\n'
                'Unduh aplikasi dan file dari sumber resmi atau '
                'sumber yang dapat dipercaya.\n\n'
                '6. Keluar dari Akun pada Perangkat Bersama\n'
                'Jangan lupa melakukan logout setelah menggunakan '
                'akun pada komputer umum atau perangkat milik '
                'orang lain.\n\n'
                'Dengan membiasakan langkah-langkah tersebut, '
                'pengguna dapat mengurangi risiko ketika belajar, '
                'berkomunikasi, dan melakukan aktivitas lainnya '
                'melalui internet.',
            'ikon': Icons.public_rounded,
          },
          {
            'judul': 'Sikap Bijak dan Etika Digital',
            'isi':
                'Keamanan digital tidak hanya berkaitan dengan '
                'perlindungan perangkat dan akun, tetapi juga '
                'mencakup sikap serta tanggung jawab pengguna '
                'ketika beraktivitas di ruang digital.\n\n'
                'Etika digital adalah aturan dan sikap yang perlu '
                'diperhatikan saat berkomunikasi, membagikan '
                'informasi, atau menggunakan layanan digital.\n\n'
                'Beberapa contoh sikap bijak dan etika digital:\n\n'
                '1. Menggunakan bahasa yang sopan saat berkomentar '
                'atau mengirim pesan.\n'
                '2. Tidak menyebarkan berita yang belum terbukti '
                'kebenarannya.\n'
                '3. Menghargai privasi dan pendapat orang lain.\n'
                '4. Tidak melakukan perundungan atau cyberbullying.\n'
                '5. Menghargai hak cipta dengan mencantumkan sumber '
                'ketika menggunakan karya orang lain.\n'
                '6. Berpikir terlebih dahulu sebelum mengunggah '
                'foto, video, atau informasi ke media sosial.\n\n'
                'Setiap aktivitas di internet dapat meninggalkan '
                'jejak digital, yaitu rekaman aktivitas pengguna '
                'dalam ruang digital. Oleh karena itu, kita perlu '
                'berhati-hati dalam membuat unggahan atau komentar.\n\n'
                'Menjadi pengguna teknologi yang baik berarti '
                'mampu melindungi diri sendiri sekaligus menghormati '
                'orang lain di lingkungan digital.',
            'ikon': Icons.groups_rounded,
          },

          {
            'jenis': 'trueFalse',
            'judul': 'Aktivitas 2: Benar atau Salah',
            'isi': 'Jawablah pernyataan berikut dengan benar atau salah.',
            'pertanyaan': [
              {
                'teks':
                    'Kode OTP boleh dibagikan kepada teman atau orang lain.',
                'jawabanBenar': 1,
              },
              {
                'teks': 'Menggunakan kata sandi yang kuat dapat membantu melindungi akun.',
                'jawabanBenar': 0,
              },
            ],
            'ikon': Icons.fact_check_rounded,
          },

          {
            'judul': 'Kesimpulan',
            'isi':
                'Keamanan digital merupakan upaya melindungi '
                'perangkat, akun, jaringan, dan informasi pribadi '
                'dari berbagai ancaman yang dapat terjadi ketika '
                'menggunakan teknologi.\n\n'
                'Beberapa hal penting dalam keamanan digital '
                'meliputi menjaga data pribadi, menggunakan kata '
                'sandi yang kuat, mengaktifkan verifikasi dua '
                'langkah, dan berhati-hati terhadap phishing '
                'serta penipuan online.\n\n'
                'Pengguna juga perlu menjaga keamanan perangkat '
                'dengan memperbarui aplikasi, menggunakan sumber '
                'unduhan tepercaya, serta menghindari tautan dan '
                'file yang mencurigakan.\n\n'
                'Selain itu, kita harus menerapkan etika digital '
                'dengan menghormati privasi orang lain, tidak '
                'menyebarkan informasi palsu, dan menghindari '
                'perundungan di internet.\n\n'
                'Dengan menerapkan kebiasaan tersebut, kita dapat '
                'memanfaatkan teknologi secara aman, bijak, '
                'dan bertanggung jawab dalam kehidupan sehari-hari.',
            'ikon': Icons.school_rounded,
          },
        ];

      case 'Artificial Intelligence':
      case 'Artificial Intelligence (AI)':
        return [
          {
            'judul': 'Pengertian Artificial Intelligence',
            'isi':
                'Artificial Intelligence (AI) atau kecerdasan buatan '
                'merupakan teknologi yang memungkinkan komputer '
                'melakukan tugas tertentu yang biasanya membutuhkan '
                'kemampuan kecerdasan manusia.\n\n'
                'Kemampuan tersebut meliputi mengenali gambar, '
                'memahami bahasa, mengenali suara, menemukan pola, '
                'menganalisis informasi, dan memberikan rekomendasi '
                'berdasarkan data.\n\n'
                'AI dikembangkan menggunakan algoritma dan model '
                'komputer yang dapat memproses data untuk menghasilkan '
                'prediksi, keputusan, atau jawaban sesuai dengan '
                'tujuan penggunaannya.\n\n'
                'Contohnya adalah chatbot yang dapat menjawab '
                'pertanyaan, aplikasi penerjemah bahasa, sistem '
                'pengenalan wajah, dan rekomendasi video.\n\n'
                'AI bukan berarti komputer memiliki pikiran dan '
                'perasaan seperti manusia. AI bekerja berdasarkan '
                'data, pola, instruksi, dan model yang dirancang '
                'oleh manusia.',
            'ikon': Icons.smart_toy_rounded,
          },
          {
            'judul': 'Sejarah dan Perkembangan AI',
            'isi':
                'Gagasan mengenai kecerdasan buatan mulai berkembang '
                'ketika para ilmuwan mencoba membuat mesin yang '
                'mampu melakukan tugas-tugas yang membutuhkan '
                'kemampuan berpikir dan pemecahan masalah.\n\n'
                'Istilah Artificial Intelligence mulai dikenal '
                'secara luas pada tahun 1956 melalui kegiatan '
                'Dartmouth Summer Research Project yang menjadi '
                'salah satu tonggak penting perkembangan bidang AI.\n\n'
                'Seiring perkembangan teknologi komputer, kemampuan '
                'AI semakin berkembang. Ketersediaan data dalam '
                'jumlah besar, peningkatan kemampuan komputer, '
                'dan kemajuan algoritma membantu pengembangan '
                'berbagai teknologi AI.\n\n'
                'Beberapa tahap perkembangan AI antara lain:\n\n'
                '1. AI awal: komputer dikembangkan untuk menjalankan '
                'permainan sederhana dan menyelesaikan masalah '
                'berdasarkan aturan tertentu.\n\n'
                '2. Expert System: sistem yang dirancang untuk '
                'memberikan rekomendasi berdasarkan pengetahuan '
                'dan aturan dari seorang ahli.\n\n'
                '3. Machine Learning: teknologi yang memungkinkan '
                'komputer mempelajari pola dari data.\n\n'
                '4. Deep Learning: pengembangan machine learning '
                'yang menggunakan jaringan saraf tiruan berlapis '
                'untuk memproses pola yang lebih kompleks.\n\n'
                '5. Generative AI: teknologi yang mampu menghasilkan '
                'konten baru, seperti teks, gambar, suara, dan kode '
                'berdasarkan perintah pengguna.',
            'ikon': Icons.history_rounded,
          },
          {
            'judul': 'Cara Kerja Artificial Intelligence',
            'isi':
                'AI bekerja dengan memproses data menggunakan '
                'algoritma dan model tertentu untuk mengenali pola '
                'serta menghasilkan keluaran sesuai dengan tujuan '
                'yang diberikan.\n\n'
                'Secara sederhana, cara kerja AI dapat dijelaskan '
                'melalui beberapa tahapan berikut:\n\n'
                '1. Pengumpulan Data\n'
                'AI membutuhkan data sebagai bahan untuk mempelajari '
                'pola. Data dapat berupa teks, gambar, suara, '
                'atau angka.\n\n'
                '2. Pengolahan Data\n'
                'Data dipersiapkan agar dapat diproses oleh sistem. '
                'Tahap ini dapat meliputi pemeriksaan, pengelompokan, '
                'dan pembersihan data.\n\n'
                '3. Pelatihan Model\n'
                'Algoritma digunakan untuk mempelajari pola dari '
                'data sehingga model dapat menjalankan tugas tertentu.\n\n'
                '4. Pengujian Model\n'
                'Model diuji menggunakan data yang sesuai untuk '
                'menilai kemampuan dan ketepatan hasilnya.\n\n'
                '5. Menghasilkan Keluaran\n'
                'Setelah digunakan, AI dapat memberikan hasil berupa '
                'prediksi, klasifikasi, rekomendasi, atau jawaban.\n\n'
                'Contohnya, aplikasi pengenalan gambar memproses '
                'gambar yang diberikan pengguna, kemudian menggunakan '
                'pola yang telah dipelajari untuk mengenali objek '
                'di dalam gambar tersebut.',
            'ikon': Icons.settings_suggest_rounded,
          },
          {
            'judul': 'Jenis dan Teknologi dalam AI',
            'isi':
                'Artificial Intelligence memiliki beberapa bidang '
                'dan teknologi yang digunakan untuk menyelesaikan '
                'berbagai jenis tugas.\n\n'
                '1. Machine Learning\n'
                'Machine Learning merupakan bagian dari AI yang '
                'memungkinkan komputer mempelajari pola dari data '
                'untuk membuat prediksi atau keputusan tanpa harus '
                'diberikan aturan khusus untuk setiap kemungkinan.\n'
                'Contoh: sistem yang mempelajari kebiasaan pengguna '
                'untuk memberikan rekomendasi film.\n\n'
                '2. Deep Learning\n'
                'Deep Learning merupakan bagian dari machine learning '
                'yang menggunakan jaringan saraf tiruan berlapis '
                'untuk mempelajari pola yang lebih kompleks.\n'
                'Contoh: teknologi pengenalan wajah dan pengenalan suara.\n\n'
                '3. Natural Language Processing (NLP)\n'
                'Teknologi yang membantu komputer memproses dan '
                'memahami bahasa manusia.\n'
                'Contoh: chatbot, penerjemah otomatis, dan asisten virtual.\n\n'
                '4. Computer Vision\n'
                'Teknologi yang memungkinkan komputer menganalisis '
                'dan memahami informasi dari gambar atau video.\n'
                'Contoh: pengenalan wajah dan pendeteksian objek.\n\n'
                '5. Generative AI\n'
                'Teknologi AI yang dapat menghasilkan konten baru '
                'berdasarkan pola yang telah dipelajari.\n'
                'Contoh: menghasilkan teks, gambar, suara, dan kode '
                'berdasarkan perintah pengguna.\n\n'
                'Setiap teknologi memiliki kemampuan dan kegunaan '
                'yang berbeda sesuai dengan kebutuhan penerapannya.',
            'ikon': Icons.psychology_rounded,
          },
          {
            'jenis': 'aktivitas',
            'judul': 'Aktivitas 1: Mengenal Teknologi AI',
            'isi':
                'Sebuah aplikasi dapat memahami pertanyaan pengguna '
                'dalam bentuk teks dan memberikan jawaban secara '
                'otomatis. Teknologi AI yang berkaitan dengan '
                'pemrosesan bahasa manusia disebut apa?',
            'pilihan': [
              'Computer Vision',
              'Natural Language Processing (NLP)',
              'Storage Device',
              'Operating System',
            ],
            'jawabanBenar': 1,
            'ikon': Icons.quiz_rounded,
          },
          {
            'judul': 'Contoh Penggunaan AI dalam Kehidupan Sehari-hari',
            'isi':
                'Teknologi AI sudah banyak digunakan dalam berbagai '
                'aktivitas sehari-hari. Pengguna mungkin telah '
                'memanfaatkan AI tanpa menyadari bahwa teknologi '
                'tersebut bekerja di balik sebuah aplikasi.\n\n'
                'Berikut beberapa contoh penerapan AI:\n\n'
                '1. Asisten Virtual\n'
                'Digunakan untuk membantu pengguna melalui perintah '
                'suara atau teks, seperti menjawab pertanyaan dan '
                'mengatur pengingat.\n\n'
                '2. Sistem Rekomendasi\n'
                'Digunakan untuk memberikan saran film, musik, '
                'atau produk berdasarkan pola aktivitas pengguna.\n\n'
                '3. Penerjemah Otomatis\n'
                'Membantu menerjemahkan teks dari satu bahasa '
                'ke bahasa lainnya.\n\n'
                '4. Pengenalan Wajah\n'
                'Digunakan untuk mengenali wajah dalam foto atau '
                'mendukung fitur keamanan pada perangkat.\n\n'
                '5. Navigasi Digital\n'
                'Membantu memperkirakan waktu perjalanan dan '
                'menentukan rute berdasarkan informasi yang tersedia.\n\n'
                '6. Chatbot\n'
                'Dapat menjawab pertanyaan dan membantu pengguna '
                'memperoleh informasi melalui percakapan.\n\n'
                'Contoh tersebut menunjukkan bahwa AI dapat '
                'membantu manusia melakukan berbagai kegiatan '
                'dengan lebih praktis.',
            'ikon': Icons.devices_rounded,
          },
          {
            'judul': 'Pemanfaatan AI dalam Dunia Pendidikan',
            'isi':
                'Artificial Intelligence dapat dimanfaatkan untuk '
                'mendukung proses pembelajaran di sekolah maupun '
                'di luar sekolah. AI dapat membantu siswa memperoleh '
                'informasi, memahami materi, dan mengembangkan '
                'keterampilan belajar.\n\n'
                'Beberapa contoh pemanfaatan AI dalam pendidikan:\n\n'
                '1. Asisten Belajar\n'
                'AI dapat membantu menjelaskan konsep pelajaran '
                'dan memberikan contoh tambahan ketika siswa '
                'mengalami kesulitan.\n\n'
                '2. Pembuatan Latihan Soal\n'
                'AI dapat membantu menghasilkan contoh pertanyaan '
                'dan latihan berdasarkan topik pembelajaran.\n\n'
                '3. Penerjemah Bahasa\n'
                'AI membantu siswa memahami materi yang menggunakan '
                'bahasa asing.\n\n'
                '4. Pembelajaran yang Lebih Personal\n'
                'Sistem tertentu dapat memberikan rekomendasi '
                'materi berdasarkan perkembangan dan kebutuhan '
                'belajar siswa.\n\n'
                '5. Membantu Guru Menyiapkan Pembelajaran\n'
                'AI dapat digunakan sebagai alat bantu untuk '
                'menyusun ide materi, contoh soal, atau rancangan '
                'aktivitas pembelajaran.\n\n'
                'Meskipun bermanfaat, AI tidak boleh digunakan '
                'sebagai pengganti proses berpikir siswa. Siswa '
                'tetap perlu membaca, memahami, memeriksa, dan '
                'mengolah kembali informasi yang diperoleh.\n\n'
                'Dengan penggunaan yang tepat, AI dapat menjadi '
                'alat pendukung untuk meningkatkan pengalaman '
                'belajar.',
            'ikon': Icons.school_rounded,
          },
          {
            'judul': 'Manfaat dan Kelebihan AI',
            'isi':
                'Penggunaan Artificial Intelligence memberikan '
                'berbagai manfaat dalam bidang pendidikan, kesehatan, '
                'industri, bisnis, dan kehidupan sehari-hari.\n\n'
                'Beberapa manfaat AI antara lain:\n\n'
                '1. Mempercepat Pekerjaan\n'
                'AI dapat membantu mengolah informasi dan menjalankan '
                'tugas tertentu dengan lebih cepat.\n\n'
                '2. Mengolah Data dalam Jumlah Besar\n'
                'AI dapat membantu menganalisis kumpulan data '
                'untuk menemukan pola yang sulit diamati secara manual.\n\n'
                '3. Membantu Pengambilan Keputusan\n'
                'Hasil analisis AI dapat menjadi bahan pertimbangan '
                'bagi manusia dalam mengambil keputusan.\n\n'
                '4. Mempermudah Aktivitas\n'
                'AI dapat membantu menjalankan tugas seperti '
                'penerjemahan, pencarian informasi, dan rekomendasi.\n\n'
                '5. Mendukung Inovasi\n'
                'AI membantu pengembangan berbagai teknologi baru '
                'di bidang pendidikan, transportasi, kesehatan, '
                'dan industri.\n\n'
                'Walaupun memiliki banyak manfaat, hasil yang '
                'diberikan AI tetap perlu diperiksa karena '
                'teknologi ini dapat menghasilkan informasi '
                'yang kurang tepat.',
            'ikon': Icons.trending_up_rounded,
          },
          {
            'judul': 'Dampak dan Risiko Penggunaan AI',
            'isi':
                'Selain memberikan manfaat, penggunaan AI juga '
                'memiliki dampak dan risiko yang perlu diperhatikan. '
                'Teknologi ini harus digunakan secara bijak agar '
                'tidak menimbulkan masalah bagi pengguna maupun '
                'masyarakat.\n\n'
                'Beberapa risiko penggunaan AI antara lain:\n\n'
                '1. Informasi Tidak Akurat\n'
                'AI dapat memberikan jawaban yang salah atau '
                'menyesatkan. Oleh karena itu, informasi penting '
                'harus diperiksa melalui sumber tepercaya.\n\n'
                '2. Ketergantungan Teknologi\n'
                'Penggunaan AI secara berlebihan dapat membuat '
                'pengguna kurang berlatih berpikir kritis dan '
                'menyelesaikan masalah secara mandiri.\n\n'
                '3. Privasi dan Keamanan Data\n'
                'Memasukkan informasi pribadi atau rahasia ke '
                'layanan AI dapat menimbulkan risiko terhadap '
                'privasi pengguna.\n\n'
                '4. Bias dalam Hasil AI\n'
                'Data yang digunakan untuk melatih AI dapat '
                'memengaruhi hasilnya sehingga sistem dapat '
                'memberikan keluaran yang tidak adil atau bias.\n\n'
                '5. Penyalahgunaan Teknologi\n'
                'AI dapat digunakan untuk membuat konten palsu, '
                'penipuan, atau informasi yang menyesatkan.\n\n'
                'Karena itu, pengguna perlu memahami keterbatasan '
                'AI, memeriksa hasilnya, menjaga data pribadi, '
                'dan tidak langsung mempercayai semua jawaban '
                'yang diberikan oleh sistem.',
            'ikon': Icons.warning_rounded,
          },
          {
            'judul': 'Etika Menggunakan Artificial Intelligence',
            'isi':
                'Etika penggunaan AI merupakan prinsip dan '
                'tanggung jawab yang perlu diperhatikan ketika '
                'memanfaatkan teknologi kecerdasan buatan.\n\n'
                'Penggunaan AI harus dilakukan secara jujur, '
                'bertanggung jawab, dan tidak merugikan orang lain.\n\n'
                'Berikut beberapa hal yang perlu diperhatikan:\n\n'
                '1. Memeriksa Kebenaran Informasi\n'
                'Jangan langsung mempercayai seluruh jawaban AI. '
                'Bandingkan informasi dengan buku, materi pelajaran, '
                'atau sumber tepercaya.\n\n'
                '2. Menjaga Data Pribadi\n'
                'Jangan memasukkan kata sandi, kode OTP, alamat '
                'rumah, atau informasi rahasia ke dalam layanan AI.\n\n'
                '3. Menggunakan AI Secara Jujur\n'
                'Dalam mengerjakan tugas, gunakan AI sebagai alat '
                'bantu belajar dan tetap ikuti aturan yang diberikan '
                'oleh guru atau dosen.\n\n'
                '4. Menghargai Hak Cipta\n'
                'Perhatikan sumber dan hak penggunaan konten yang '
                'dihasilkan atau dibantu oleh AI.\n\n'
                '5. Tidak Menyalahgunakan Teknologi\n'
                'Hindari penggunaan AI untuk membuat penipuan, '
                'menyebarkan informasi palsu, atau merugikan orang lain.\n\n'
                'AI sebaiknya digunakan sebagai alat bantu manusia. '
                'Manusia tetap memiliki tanggung jawab untuk '
                'memeriksa hasil dan menentukan bagaimana teknologi '
                'tersebut digunakan.',
            'ikon': Icons.gavel_rounded,
          },
          {
            'jenis': 'aktivitas',
            'judul': 'Aktivitas 2: Penerapan AI',
            'isi':
                'Sebuah aplikasi musik memberikan rekomendasi lagu '
                'berdasarkan lagu yang sering didengarkan oleh '
                'penggunanya. Teknologi AI tersebut digunakan '
                'untuk melakukan apa?',
            'pilihan': [
              'Menghapus semua file pengguna',
              'Memberikan rekomendasi berdasarkan pola penggunaan',
              'Mengganti perangkat keras komputer',
              'Mencetak dokumen secara otomatis',
            ],
            'jawabanBenar': 1,
            'ikon': Icons.quiz_rounded,
          },
          {
            'judul': 'Kesimpulan',
            'isi':
                'Artificial Intelligence atau kecerdasan buatan '
                'merupakan teknologi yang memungkinkan komputer '
                'menjalankan tugas tertentu dengan memanfaatkan '
                'data, algoritma, dan model AI.\n\n'
                'AI memiliki berbagai teknologi, seperti Machine '
                'Learning, Deep Learning, Natural Language Processing, '
                'Computer Vision, dan Generative AI. Teknologi '
                'tersebut digunakan dalam berbagai bidang kehidupan.\n\n'
                'Contoh penerapan AI dapat ditemukan pada chatbot, '
                'penerjemah otomatis, sistem rekomendasi, pengenalan '
                'wajah, dan layanan pendidikan.\n\n'
                'AI memberikan manfaat berupa kemudahan, kecepatan, '
                'dan bantuan dalam mengolah informasi. Namun, '
                'pengguna juga harus memperhatikan risiko seperti '
                'informasi tidak akurat, masalah privasi, bias, '
                'dan penyalahgunaan teknologi.\n\n'
                'Oleh karena itu, AI harus digunakan secara bijak '
                'dan bertanggung jawab. Manusia tetap perlu berpikir '
                'kritis, memeriksa hasil AI, menjaga data pribadi, '
                'serta menggunakan teknologi untuk tujuan yang positif.',
            'ikon': Icons.school_rounded,
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
                            int slideSebelumnya = _slideAktif - 1;

                            // Lewati slide aktivitas agar kembali ke materi
                            while (slideSebelumnya >= 0) {
                              final jenisSebelumnya =
                                  _slides[slideSebelumnya]['jenis'];

                              if (jenisSebelumnya == 'aktivitas' ||
                                  jenisSebelumnya == 'trueFalse') {
                                slideSebelumnya--;
                              } else {
                                break;
                              }
                            }

                            if (slideSebelumnya < 0) {
                              slideSebelumnya = 0;
                            }

                            setState(() {
                              _slideAktif = slideSebelumnya;
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

                        // Memutar suara ketika materi selesai
                        await _putarEfek('finish.mp3');

                        // Memberi waktu agar suara selesai diputar
                        await Future.delayed(
                          const Duration(milliseconds: 1500),
                        );

                        if (!mounted) return;

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
