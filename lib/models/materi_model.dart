import 'package:flutter/material.dart';

class MateriModel {
  final String judul;
  final String deskripsi;
  final IconData icon;
  final Color color;

  const MateriModel({
    required this.judul,
    required this.deskripsi,
    required this.icon,
    required this.color,
  });
}

const List<MateriModel> daftarMateri = [
  MateriModel(
    judul: 'Pengenalan Teknologi',
    deskripsi: 'Mengenal teknologi dan perkembangannya.',
    icon: Icons.devices,
    color: Color(0xFF6A35D9),
  ),
  MateriModel(
    judul: 'Sistem Komputer',
    deskripsi: 'Mengenal perangkat keras dan perangkat lunak.',
    icon: Icons.computer,
    color: Color(0xFF2B7FFF),
  ),
  MateriModel(
    judul: 'Jaringan dan Internet',
    deskripsi: 'Memahami jaringan komputer dan internet.',
    icon: Icons.wifi,
    color: Color(0xFF00A896),
  ),
  MateriModel(
    judul: 'Keamanan Digital',
    deskripsi: 'Mengenal keamanan dan perlindungan data digital.',
    icon: Icons.security,
    color: Color(0xFFE67E22),
  ),
  MateriModel(
    judul: 'Artificial Intelligence',
    deskripsi: 'Mengenal dasar-dasar kecerdasan buatan.',
    icon: Icons.smart_toy,
    color: Color(0xFFE91E63),
  ),
];