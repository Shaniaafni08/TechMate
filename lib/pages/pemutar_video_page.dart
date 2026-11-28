import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

class PemutarVideoPage extends StatefulWidget {
  final String judul;
  final String assetPath;

  const PemutarVideoPage({
    super.key,
    required this.judul,
    required this.assetPath,
  });

  @override
  State<PemutarVideoPage> createState() => _PemutarVideoPageState();
}

class _PemutarVideoPageState extends State<PemutarVideoPage> {
  late final VideoPlayerController _controller;
  late final Future<void> _inisialisasiVideo;
  Timer? _timerCekWaktu;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Pengaturan aktivitas interaktif di tengah video
  bool _aktivitasSudahMuncul = false;
  bool _dialogAktivitasTampil = false;

  // Waktu sementara untuk memunculkan pertanyaan
  static const Duration _waktuAktivitas = Duration(minutes: 2);

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.assetPath);

    _inisialisasiVideo = _controller.initialize().then((_) {
      if (!mounted) return;

      // Memeriksa posisi video setiap 200 milidetik
      _timerCekWaktu = Timer.periodic(const Duration(milliseconds: 200), (_) {
        _cekWaktuAktivitas();
      });
    });
  }

  void _cekWaktuAktivitas() {
    if (!mounted ||
        _aktivitasSudahMuncul ||
        _dialogAktivitasTampil ||
        !_controller.value.isInitialized) {
      return;
    }

    final posisiVideo = _controller.value.position;
    final sedangDiputar = _controller.value.isPlaying;

    if (sedangDiputar && posisiVideo >= _waktuAktivitas) {
      // Mencegah popup muncul lebih dari satu kali
      _aktivitasSudahMuncul = true;
      _dialogAktivitasTampil = true;

      // Menghentikan video secara otomatis
      _controller.pause();

      // Langsung menampilkan popup pertanyaan
      _tampilkanAktivitasDiVideo();
    }
  }

  Future<void> _putarEfek(String namaFile) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/$namaFile'));
    } catch (e) {
      debugPrint('Gagal memutar efek suara: $e');
    }
  }


Future<void> _tampilkanAktivitasDiVideo() async {
  int? jawabanDipilih;
  String? pesan;
  bool jawabanBenar = false;

  // Soal disesuaikan dengan judul video
  late final Map<String, dynamic> aktivitas;

  switch (widget.judul) {
    case 'Pengertian Teknologi':
      aktivitas = {
        'pertanyaan':
            'Apa tujuan utama penggunaan teknologi dalam kehidupan sehari-hari?',
        'pilihan': [
          'Mempermudah pekerjaan manusia',
          'Membuat pekerjaan semakin sulit',
          'Menghilangkan kebutuhan belajar',
          'Membatasi komunikasi',
        ],
        'jawabanBenar': 0,
      };
      break;

    case 'Perkembangan Teknologi':
      aktivitas = {
        'pertanyaan':
            'Manakah contoh perkembangan teknologi komunikasi saat ini?',
        'pilihan': [
          'Mengirim surat menggunakan kurir saja',
          'Menggunakan panggilan video melalui smartphone',
          'Menulis pesan di atas kertas',
          'Menggunakan mesin tik',
        ],
        'jawabanBenar': 1,
      };
      break;

    case 'Manfaat Teknologi':
      aktivitas = {
        'pertanyaan':
            'Bagaimana teknologi dapat membantu siswa dalam kegiatan belajar?',
        'pilihan': [
          'Mengurangi kesempatan memperoleh informasi',
          'Membuat siswa tidak perlu belajar',
          'Mempermudah mencari materi dan mengikuti pembelajaran online',
          'Menghilangkan semua tugas sekolah',
        ],
        'jawabanBenar': 2,
      };
      break;

    default:
      aktivitas = {
        'pertanyaan':
            'Apa salah satu manfaat teknologi dalam kehidupan sehari-hari?',
        'pilihan': [
          'Mempermudah aktivitas manusia',
          'Mempersulit komunikasi',
          'Menghambat pekerjaan',
          'Membatasi informasi',
        ],
        'jawabanBenar': 0,
      };
  }

  final List<String> pilihan =
      List<String>.from(aktivitas['pilihan']);

  final int kunciJawaban = aktivitas['jawabanBenar'];

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
                Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF6A35D9),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Aktivitas Interaktif'),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aktivitas['pertanyaan'],
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
                                final benar =
                                    index == kunciJawaban;

                                if (benar) {
                                  setDialogState(() {
                                    jawabanDipilih = index;
                                    jawabanBenar = true;
                                    pesan =
                                        'Benar! Jawaban kamu tepat 🎉';
                                  });

                                  // Efek suara jawaban benar
                                  await _putarEfek('correct.mp3');

                                  await Future.delayed(
                                    const Duration(
                                      milliseconds: 1000,
                                    ),
                                  );

                                  if (dialogContext.mounted) {
                                    Navigator.pop(
                                      dialogContext,
                                      true,
                                    );
                                  }
                                } else {
                                  // Efek suara jawaban salah
                                  await _putarEfek('wrong.mp3');

                                  if (!dialogContext.mounted) return;

                                  setDialogState(() {
                                    jawabanDipilih = index;
                                    pesan =
                                        'Belum tepat, coba lagi ya! 💪';
                                  });
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: jawabanDipilih == index
                              ? (jawabanBenar
                                  ? Colors.green
                                  : Colors.red)
                              : const Color(0xFF6A35D9),
                          side: BorderSide(
                            color: jawabanDipilih == index
                                ? (jawabanBenar
                                    ? Colors.green
                                    : Colors.red)
                                : const Color(0xFF6A35D9),
                          ),
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
                      color: jawabanBenar
                          ? Colors.green
                          : Colors.red,
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

  _dialogAktivitasTampil = false;

  if (!mounted) return;

  // Video dilanjutkan setelah jawaban benar
  if (hasil == true) {
    await _controller.play();
  }
}

  @override
  void dispose() {
    _timerCekWaktu?.cancel();
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      appBar: AppBar(
        title: Text(
          widget.judul,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6A35D9),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<void>(
        future: _inisialisasiVideo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Video gagal dibuka. Periksa file video kamu.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                widget.judul,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF30205D),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Yuk, kenali teknologi dan perannya dalam '
                'kehidupan sehari-hari!',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF66667A),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Area pemutar video
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),

                    Container(
                      color: const Color(0xFF30205D),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          // Progress bar video
                          VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            colors: const VideoProgressColors(
                              playedColor: Color(0xFF4FC3F7),
                              bufferedColor: Colors.white38,
                              backgroundColor: Colors.white24,
                            ),
                          ),

                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (_controller.value.isPlaying) {
                                      _controller.pause();
                                    } else {
                                      _controller.play();
                                    }
                                  });
                                },
                                icon: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 38,
                                ),
                              ),

                              const SizedBox(width: 8),

                              const Expanded(
                                child: Text(
                                  'Video Pembelajaran TechMate',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),

                              // Waktu berjalan dan total durasi
                              ValueListenableBuilder<VideoPlayerValue>(
                                valueListenable: _controller,
                                builder: (context, value, child) {
                                  String formatWaktu(Duration waktu) {
                                    final menit = waktu.inMinutes
                                        .remainder(60)
                                        .toString()
                                        .padLeft(2, '0');

                                    final detik = waktu.inSeconds
                                        .remainder(60)
                                        .toString()
                                        .padLeft(2, '0');

                                    return '$menit:$detik';
                                  }

                                  return Text(
                                    '${formatWaktu(value.position)} / '
                                    '${formatWaktu(value.duration)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Deskripsi video
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book_rounded, color: Color(0xFF6A35D9)),
                        SizedBox(width: 10),
                        Text(
                          'Tentang Materi',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF30205D),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Video ini membahas pengertian teknologi '
                      'menurut para ahli serta bagaimana teknologi '
                      'membantu manusia dalam menjalankan '
                      'aktivitas sehari-hari.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF66667A),
                      ),
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Tujuan Pembelajaran',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF30205D),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Memahami pengertian teknologi.\n'
                      '• Mengetahui peran teknologi dalam kehidupan.\n'
                      '• Mengenali contoh penggunaan teknologi.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.8,
                        color: Color(0xFF66667A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
