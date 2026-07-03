import 'package:flutter/material.dart';
import 'package:si_tumbuh/Kader/data_anak.dart';
import 'package:si_tumbuh/Kader/halaman_utama_kader.dart';
import 'package:si_tumbuh/Kader/jadwal.dart';
import 'package:si_tumbuh/Kader/profil.dart';

class BottomNavbarKader extends StatelessWidget {
  final int selectedIndex;

  const BottomNavbarKader({super.key, required this.selectedIndex});

  final List<Map<String, dynamic>> _navItems = const [
    {'icon': Icons.home_rounded, 'label': 'Beranda'},
    {'icon': Icons.people_rounded, 'label': 'Data Anak'},
    {'icon': Icons.calendar_month_rounded, 'label': 'Posyandu'},
    {'icon': Icons.person_rounded, 'label': 'Profil'},
  ];

  void _navigate(BuildContext context, int index) {
    if (index == selectedIndex) return;

    final pages = [
      const HalamanUtamaKader(),
      const DataAnakPage(),
      const Jadwal(),
      const Profil(),
    ];

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => pages[index],
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
                final isActive = selectedIndex == index;
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
