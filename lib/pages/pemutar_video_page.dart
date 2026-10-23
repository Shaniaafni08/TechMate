import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PemutarVideoPage extends StatefulWidget {
  const PemutarVideoPage({super.key});

  @override
  State<PemutarVideoPage> createState() => _PemutarVideoPageState();
}

class _PemutarVideoPageState extends State<PemutarVideoPage> {
  late final VideoPlayerController _controller;
  late final Future<void> _inisialisasiVideo;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(
      'assets/videos/pengenalan_teknologi.mp4',
    );

    _inisialisasiVideo = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

 
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF4F5FA),
    appBar: AppBar(
      title: const Text(
        'Video Pembelajaran',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xFF6A35D9),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    body: FutureBuilder<void>(
      future: _inisialisasiVideo,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Video gagal dibuka. Periksa file video kamu.',
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Pengenalan Teknologi',
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
                    child: Row(
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
                      Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF6A35D9),
                      ),
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
