import 'package:flutter/material.dart';
import 'package:si_tumbuh/orangtua/grafik.dart';
import 'package:si_tumbuh/orangtua/halaman_utama.dart';
import 'package:si_tumbuh/orangtua/profil.dart';
import 'package:si_tumbuh/orangtua/edukasi.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;

    switch (index) {
      case 0:
        page = const HalamanUtama();
        break;

      case 1:
        page = const GrafikPage();
        break;

      case 2:
        page = const EdukasiPage(); // nanti bisa diganti halaman jadwal
        break;

      case 3:
        page = const ProfilePage();
        break;

      default:
        page = const HalamanUtama();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _navigate(context, index),
      selectedItemColor: const Color(0xFFE85D75),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: "Pertumbuhan",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "Edukasi",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
      ],
    );
  }
}
