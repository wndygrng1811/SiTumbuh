import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/Kader/halaman_utama_kader.dart';
import 'package:si_tumbuh/Kader/data_anak.dart';
import 'package:si_tumbuh/Kader/jadwal.dart';
import 'package:si_tumbuh/Kader/profil.dart';

class BottomNavbarKader extends StatefulWidget {
  final int selectedIndex;

  const BottomNavbarKader({super.key, required this.selectedIndex});

  @override
  State<BottomNavbarKader> createState() => _BottomNavbarKaderState();
}

class _BottomNavbarKaderState extends State<BottomNavbarKader> {
  // Warna-warna tampilan
  static const Color _maroon = Color(0xFF76172D); // warna bubble aktif
  static const Color _softPink = Color(0xFFE85D75); // background navbar
  static const Color _inactiveColor = Color.fromRGBO(
    250,
    249,
    249,
    1,
  ); // ikon & label nonaktif

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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _softPink,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.none,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_navItems.length, (index) {
              final bool isActive = widget.selectedIndex == index;
              final item = _navItems[index];

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _navigate(context, index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(
                        offset: isActive ? const Offset(0, -22) : Offset.zero,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          width: isActive ? 46 : 24,
                          height: isActive ? 46 : 24,
                          decoration: BoxDecoration(
                            color: isActive ? _maroon : Colors.transparent,
                            shape: BoxShape.circle,
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            item.icon,
                            size: 22,
                            color: isActive ? Colors.white : _inactiveColor,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: isActive ? const Offset(0, -10) : Offset.zero,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isActive ? _maroon : _inactiveColor,
                          ),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
