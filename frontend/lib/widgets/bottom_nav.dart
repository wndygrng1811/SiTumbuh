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

  // Warna-warna tampilan
  static const Color _maroon = Color(0xFF76172D); // warna bubble aktif
  static const Color _softPink = Color(0xFFE85D75); // background navbar
  static const Color _inactiveColor = Color(
    0xFF76172D,
  ); // ikon & label nonaktif

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
    return Material(
      color: _softPink, // Background card full-lebar, nempel kiri-kanan
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.none, // Biar bubble boleh "keluar" dari card
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64, // Tinggi card TETAP, tidak ikut membesar
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_navItems.length, (index) {
              final bool isActive = widget.currentIndex == index;
              final item = _navItems[index];

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _navigate(context, index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Transform.translate cuma geser tampilan,
                      // TIDAK menambah tinggi layout -> card tetap fixed
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
                      // Geser label ikut naik sedikit biar pas
                      // di bawah card seperti contoh gambar
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
