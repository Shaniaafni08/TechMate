import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/profil_tile.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Foto profil
            Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple.withOpacity(0.20),
                    blurRadius: 15,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 52,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Pelajar TechMate',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'pelajar@techmate.com',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),

            const SizedBox(height: 26),

            ProfilTile(
              icon: Icons.person_outline,
              title: 'Informasi Profil',
              subtitle: 'Lihat dan ubah informasi akun',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menu Informasi Profil'),
                  ),
                );
              },
            ),

            ProfilTile(
              icon: Icons.settings_outlined,
              title: 'Pengaturan',
              subtitle: 'Atur preferensi aplikasi',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menu Pengaturan'),
                  ),
                );
              },
            ),

            ProfilTile(
              icon: Icons.help_outline,
              title: 'Bantuan',
              subtitle: 'Pertanyaan dan bantuan penggunaan',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menu Bantuan'),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            ProfilTile(
              icon: Icons.logout,
              title: 'Keluar',
              subtitle: 'Keluar dari akun TechMate',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Keluar'),
                      content: const Text(
                        'Apakah kamu yakin ingin keluar?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text('Keluar'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'TechMate • Media Pendukung Pembelajaran TIK',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textGrey,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}