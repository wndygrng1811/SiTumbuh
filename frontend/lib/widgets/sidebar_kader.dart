import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/Kader/data_orangtua.dart';
import 'package:si_tumbuh/Kader/data_pertumbuhan.dart';
import 'package:si_tumbuh/Kader/kehadiran.dart';
import 'package:si_tumbuh/Kader/edukasi_kader.dart';
import 'package:si_tumbuh/Kader/laporan.dart';
import 'package:si_tumbuh/login.dart';

class SidebarKader extends StatefulWidget {
  const SidebarKader({super.key});

  @override
  State<SidebarKader> createState() => _SidebarKaderState();
}

class _SidebarKaderState extends State<SidebarKader> {
  String _namaKader = 'Kader';
  String _emailKader = 'kader@email.com';

  @override
  void initState() {
    super.initState();
    _loadKaderData();
  }

  Future<void> _loadKaderData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaKader = prefs.getString('nama') ?? 'Kader';
      _emailKader = prefs.getString('email') ?? 'kader@email.com';
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
                    Text(
                      _namaKader,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _emailKader,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context,
                    Icons.people,
                    "Data Orang Tua",
                    const KelolaDaftarOrangTuaPage(),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.show_chart,
                    "Data Pertumbuhan Anak",
                    const DataPertumbuhanPage(),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.check_circle,
                    "Kehadiran",
                    const Kehadiran(),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.book,
                    "Edukasi",
                    const EdukasiKaderPage(),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.assessment,
                    "Laporan",
                    const LaporanPage(),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white30),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                "Keluar",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => _showLogoutDialog(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
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
