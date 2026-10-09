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

// Jenis slide untuk materi dan aktivitas interaktif
enum JenisSlide {
  materi,
  pilihanGanda,
  tebakGambar,
  mencocokkan,
  klasifikasi,
  simulasi,
}

// REVISI 2: Model untuk menyimpan satu slide pembelajaran
class SlideMateriModel {
  final String judul;
  final String isi;
  final IconData ikon;
  final JenisSlide jenis;

  // Dipakai untuk pilihan jawaban pada aktivitas
  final List<String> pilihan;
  final int jawabanBenar;
  final String penjelasan;

  const SlideMateriModel({
    required this.judul,
    required this.isi,
    this.ikon = Icons.computer_rounded,
    this.jenis = JenisSlide.materi,
    this.pilihan = const [],
    this.jawabanBenar = 0,
    this.penjelasan = '',
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