import 'package:flutter/material.dart';
import 'package:si_tumbuh/Kader/data_anak.dart';
import 'package:si_tumbuh/Kader/halaman_utama_kader.dart';
import 'package:si_tumbuh/Kader/jadwal.dart';
import 'package:si_tumbuh/Kader/profil.dart';

class BottomNavbarKader extends StatefulWidget {
  final int selectedIndex;

  const BottomNavbarKader({super.key, required this.selectedIndex});

  @override
  State<BottomNavbarKader> createState() => _BottomNavbarKaderState();
}

class _BottomNavbarKaderState extends State<BottomNavbarKader> {
  static const Color _maroon = Color(0xFF76172D);
  static const Color _pink = Color(0xFF76172D);
  static const Color _background = Colors.white;

  final List<_NavItemData> _navItems = const [
    _NavItemData(icon: Icons.home_rounded, label: "Beranda"),
    _NavItemData(icon: Icons.people_rounded, label: "Data Anak"),
    _NavItemData(icon: Icons.calendar_month_rounded, label: "Posyandu"),
    _NavItemData(icon: Icons.person_rounded, label: "Profil"),
  ];

  void _navigate(BuildContext context, int index) {
    if (index == widget.selectedIndex) return;

    Widget page;

    switch (index) {
      case 0:
        page = const HalamanUtamaKader();
        break;
      case 1:
        page = const DataAnakPage();
        break;
      case 2:
        page = const Jadwal();
        break;
      case 3:
        page = const Profil();
        break;
      default:
        page = const HalamanUtamaKader();
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _background,
      elevation: 12,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.none,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 78,
          child: Row(
            children: List.generate(_navItems.length, (index) {
              final isActive = widget.selectedIndex == index;
              final item = _navItems[index];

              return Expanded(
                child: InkWell(
                  onTap: () => _navigate(context, index),
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        transform: Matrix4.translationValues(
                          0,
                          isActive ? -12 : 0,
                          0,
                        ),
                        width: isActive ? 50 : 26,
                        height: isActive ? 50 : 26,
                        decoration: BoxDecoration(
                          color: isActive ? _pink : Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: _pink.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          item.icon,
                          color: isActive ? Colors.white : _maroon,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          color: _maroon, // selalu maroon
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        child: Transform.translate(
                          offset: Offset(0, isActive ? -8 : 0),
                          child: Text(item.label),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;

  const _NavItemData({required this.icon, required this.label});
}
