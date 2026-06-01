import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/Orangtua/grafik.dart';
import 'package:si_tumbuh/Orangtua/halaman_utama.dart';
import 'package:si_tumbuh/Orangtua/profil.dart';
import 'package:si_tumbuh/Orangtua/edukasi.dart';

class BottomNav extends StatefulWidget {
  final int currentIndex;

  const BottomNav({super.key, required this.currentIndex});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _anakId = 0;
  String _namaAnak = '';
  String _jenisKelamin = '';

  @override
  void initState() {
    super.initState();
    _loadAnakData();
  }

  Future<void> _loadAnakData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _anakId = prefs.getInt('anak_id') ?? 0;
      _namaAnak = prefs.getString('nama_anak') ?? '';
      _jenisKelamin = prefs.getString('jenis_kelamin') ?? '';
    });
  }

  void _navigate(BuildContext context, int index) {
    if (index == widget.currentIndex) return;

    Widget page;

    switch (index) {
      case 0:
        page = const HalamanUtama();
        break;
      case 1:
        page = GrafikPage(
          anakId: _anakId,
          namaAnak: _namaAnak,
          jenisKelamin: _jenisKelamin,
        );
        break;
      case 2:
        page = const EdukasiPage();
        break;
      case 3:
        page = ProfilePage(
          anakId: _anakId,
          namaAnak: _namaAnak,
          jenisKelamin: _jenisKelamin,
        );
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
      currentIndex: widget.currentIndex,
      onTap: (index) => _navigate(context, index),
      backgroundColor: const Color(0xFF76172D), // Warna bottom navbar
      selectedItemColor: const Color(
        0xFFFFFFFF,
      ), // Ikon & teks putih saat aktif
      unselectedItemColor: const Color(
        0xFFFFFFFF,
      ).withOpacity(0.7), // Ikon & teks putih transparan saat tidak aktif
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      iconSize: 22,
      selectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
      landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 22),
          activeIcon: Icon(Icons.home, size: 22),
          label: "Beranda",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart_outlined, size: 22),
          activeIcon: Icon(Icons.show_chart, size: 22),
          label: "Pertumbuhan",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined, size: 22),
          activeIcon: Icon(Icons.calendar_today, size: 22),
          label: "Edukasi",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, size: 22),
          activeIcon: Icon(Icons.person, size: 22),
          label: "Profil",
        ),
      ],
    );
  }
}
