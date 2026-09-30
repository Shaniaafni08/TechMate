import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: 'Video Pembelajaran',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _VideoCard(
            title: 'Pengenalan Teknologi',
            description: 'Video pengantar tentang teknologi.',
            icon: Icons.devices,
            color: AppColors.purple,
          ),
          const SizedBox(height: 14),
          _VideoCard(
            title: 'Sistem Komputer',
            description: 'Mengenal perangkat keras dan perangkat lunak.',
            icon: Icons.computer,
            color: AppColors.blue,
          ),
          const SizedBox(height: 14),
          _VideoCard(
            title: 'Jaringan dan Internet',
            description: 'Memahami dasar jaringan komputer dan internet.',
            icon: Icons.wifi,
            color: Colors.green,
          ),
          const SizedBox(height: 14),
          _VideoCard(
            title: 'Keamanan Digital',
            description: 'Belajar menjaga keamanan data digital.',
            icon: Icons.security,
            color: Colors.orange,
          ),
          const SizedBox(height: 14),
          _VideoCard(
            title: 'Artificial Intelligence',
            description: 'Mengenal dasar kecerdasan buatan.',
            icon: Icons.smart_toy,
            color: Colors.pink,
          ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _VideoCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Membuka video: $title'),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                  Container(
                    width: 25,
                    height: 25,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: color,
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textGrey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.play_circle_outline_rounded,
              color: AppColors.purple,
              size: 27,
            ),
          ],
        ),
      ),
    );
  }
}