import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/Orangtua/cek_pertumbuhan.dart';
import 'package:si_tumbuh/Orangtua/grafik.dart';
import 'package:si_tumbuh/Orangtua/edukasi.dart';
import 'package:si_tumbuh/login.dart';

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
        color: const Color(0xFFE85D75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 32, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Orang Tua",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "SiTumbuh App",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.favorite_border,
                    "Cek pertumbuhan",
                    0,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CekPertumbuhanPage(),
                        ),
                      );
                    },
                  ),

                  _buildMenuItem(
                    Icons.trending_up,
                    "Riwayat pertumbuhan",
                    1,
                    () {
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
                    },
                  ),

                  _buildMenuItem(
                    Icons.calendar_today,
                    "Jadwal posyandu",
                    2,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Fitur jadwal posyandu sedang dikembangkan',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),

                  _buildMenuItem(Icons.menu_book, "Edukasi", 3, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EdukasiPage(),
                      ),
                    );
                  }),

                  const Spacer(),

                  const Divider(color: Colors.white30, height: 24),

                  _buildMenuItem(Icons.logout, "Keluar", 4, () {
                    _showLogoutDialog(context);
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== LOGOUT YANG BENAR-BENAR KELUAR ==========
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Konfirmasi Keluar",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5A2A2A),
          ),
        ),
        content: const Text(
          "Apakah Anda yakin ingin keluar dari aplikasi?",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE85D75),
            ),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Hapus SEMUA data SharedPreferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (mounted) {
                Navigator.pop(context); // Tutup dialog

                // Hapus semua halaman dalam stack dan arahkan ke login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85D75),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
  }
}
