
import 'package:flutter/material.dart';
import 'pemutar_video_page.dart';

class DaftarVideoPage extends StatelessWidget {
  const DaftarVideoPage({super.key});

  static const Color ungu = Color(0xFF6A35D9);
  static const Color biru = Color(0xFF2B7FFF);
  static const Color latar = Color(0xFFF4F5FA);

  static const List<Map<String, String>> daftarVideo = [
    {
      'judul': 'Pengertian Teknologi',
      'deskripsi':
          'Mengenal pengertian dan konsep dasar teknologi.',
      'file': 'assets/videos/pengenalan_teknologi.mp4',
    },
    {
      'judul': 'Perkembangan Teknologi',
      'deskripsi':
          'Mempelajari perkembangan teknologi dari masa ke masa.',
      'file': 'assets/videos/video1.mp4',
    },
    {
      'judul': 'Manfaat Teknologi',
      'deskripsi':
          'Mengenal manfaat teknologi dalam kehidupan sehari-hari.',
      'file': 'assets/videos/video2.mp4',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latar,
      appBar: AppBar(
        title: const Text(
          'Video Pembelajaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: ungu,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header materi
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ungu, biru],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: ungu.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.devices_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Pengenalan Teknologi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pelajari teknologi melalui video '
                  'yang menarik dan mudah dipahami.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      '${daftarVideo.length} video pembelajaran',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Daftar Video',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF30205D),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih video yang ingin kamu pelajari.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF77778A),
            ),
          ),
          const SizedBox(height: 16),

          // Daftar kartu video
          ...List.generate(daftarVideo.length, (index) {
            final video = daftarVideo[index];
            final warna = index.isEven ? ungu : biru;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Thumbnail ilustrasi
                    Container(
                      width: 94,
                      height: 108,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            warna,
                            warna.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.ondemand_video_rounded,
                            color: Colors.white.withOpacity(0.3),
                            size: 62,
                          ),
                          Container(
                            width: 43,
                            height: 43,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: warna,
                              size: 31,
                            ),
                          ),
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Text(
                              'VIDEO ${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            video['judul']!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF30205D),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            video['deskripsi']!,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: Color(0xFF77778A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 36,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PemutarVideoPage(
                                      judul: video['judul']!,
                                      assetPath: video['file']!,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.play_arrow_rounded,
                                size: 18,
                              ),
                              label: const Text('Tonton'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: warna,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
