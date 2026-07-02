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

  static const Color _maroon = Color(0xFF76172D);
  static const Color _pink = Color(0xFF76172D);
  static const Color _background = Colors.white;

  final List<_NavItemData> _navItems = const [
    _NavItemData(icon: Icons.home_rounded, label: "Beranda"),
    _NavItemData(icon: Icons.show_chart_rounded, label: "Pertumbuhan"),
    _NavItemData(icon: Icons.menu_book_rounded, label: "Edukasi"),
    _NavItemData(icon: Icons.person_rounded, label: "Profil"),
  ];

  @override
  void initState() {
    super.initState();
    _loadAnakData();
  }

  Future<void> _loadAnakData() async {
    final prefs = await SharedPreferences.getInstance();

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
              final isActive = widget.currentIndex == index;
              final item = _navItems[index];

              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _navigate(context, index),
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
                        alignment: Alignment.center,
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
                          size: 24,
                          color: isActive ? Colors.white : _maroon,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: _maroon, // Selalu maroon
                        ),
                        child: Transform.translate(
                          offset: Offset(0, isActive ? -8 : 0),
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
