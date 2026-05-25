import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/Orangtua/halaman_utama.dart';
import 'package:si_tumbuh/Orangtua/profil.dart';
import 'package:si_tumbuh/Orangtua/edukasi.dart';
import 'package:si_tumbuh/Orangtua/grafik.dart';
import 'package:si_tumbuh/Orangtua/data_anak.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({super.key});

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  int _selectedIndex = 0;
  int _currentAnakId = 0;
  String _currentNamaAnak = '';
  String _currentJenisKelamin = '';

  @override
  void initState() {
    super.initState();
    _loadAnakData();
  }

  Future<void> _loadAnakData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentAnakId = prefs.getInt('anak_id') ?? 0;
      _currentNamaAnak = prefs.getString('nama_anak') ?? '';
      _currentJenisKelamin = prefs.getString('jenis_kelamin') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFD86487),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "SiTumbuh",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Icon(Icons.menu, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // MENU ITEMS
            _buildMenuItem(Icons.home, "Beranda", 0, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HalamanUtama()),
              );
            }),

            _buildMenuItem(Icons.person, "Profil", 1, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    anakId: _currentAnakId,
                    namaAnak: _currentNamaAnak,
                    jenisKelamin: _currentJenisKelamin,
                  ),
                ),
              );
            }),

            _buildMenuItem(Icons.favorite_border, "Cek pertumbuhan", 2, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GrafikPage(
                    anakId: _currentAnakId,
                    namaAnak: _currentNamaAnak,
                    jenisKelamin: _currentJenisKelamin,
                  ),
                ),
              );
            }),

            _buildMenuItem(Icons.trending_up, "Riwayat pertumbuhan", 3, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GrafikPage(
                    anakId: _currentAnakId,
                    namaAnak: _currentNamaAnak,
                    jenisKelamin: _currentJenisKelamin,
                  ),
                ),
              );
            }),

            _buildMenuItem(Icons.calendar_today, "Jadwal posyandu", 4, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur jadwal posyandu sedang dikembangkan'),
                ),
              );
            }),

            _buildMenuItem(Icons.menu_book, "Edukasi", 5, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EdukasiPage()),
              );
            }),

            _buildMenuItem(Icons.child_care, "Data Anak", 6, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DataAnakPage(anakId: _currentAnakId),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    int index,
    VoidCallback onTap,
  ) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
