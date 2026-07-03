import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/Orangtua/grafik.dart';
import 'package:si_tumbuh/Orangtua/halaman_utama.dart';
import 'package:si_tumbuh/Orangtua/profil.dart';
import 'package:si_tumbuh/Orangtua/edukasi.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({super.key, required this.currentIndex});

  final List<Map<String, dynamic>> _navItems = const [
    {'icon': Icons.home_rounded, 'label': 'Beranda'},
    {'icon': Icons.show_chart_rounded, 'label': 'Pertumbuhan'},
    {'icon': Icons.menu_book_rounded, 'label': 'Edukasi'},
    {'icon': Icons.person_rounded, 'label': 'Profil'},
  ];

  void _navigate(BuildContext context, int index) async {
    if (index == currentIndex) return;

    final prefs = await SharedPreferences.getInstance();
    final anakId = prefs.getInt('anak_id') ?? 0;
    final namaAnak = prefs.getString('nama_anak') ?? '';
    final jenisKelamin = prefs.getString('jenis_kelamin') ?? '';

    Widget page;

    switch (index) {
      case 0:
        page = const HalamanUtama();
        break;
      case 1:
        page = GrafikPage(
          anakId: anakId,
          namaAnak: namaAnak,
          jenisKelamin: jenisKelamin,
        );
        break;
      case 2:
        page = const EdukasiPage();
        break;
      case 3:
        page = ProfilePage(
          anakId: anakId,
          namaAnak: namaAnak,
          jenisKelamin: jenisKelamin,
        );
        break;
      default:
        page = const HalamanUtama();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFFD05A7E);
    final inactiveColor = const Color(0xFF76172D);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomAppBar(
          color: Colors.white,
          elevation: 0,
          height: 64,
          padding: EdgeInsets.zero,
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_navItems.length, (index) {
                final isActive = currentIndex == index;
                final item = _navItems[index];

                return GestureDetector(
                  onTap: () => _navigate(context, index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: isActive ? activeColor : inactiveColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          color: isActive ? activeColor : inactiveColor,
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: isActive ? 24 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
