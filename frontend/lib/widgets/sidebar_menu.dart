import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/Orangtua/halaman_utama.dart';
import 'package:si_tumbuh/Orangtua/cek_pertumbuhan.dart';
import 'package:si_tumbuh/Orangtua/grafik.dart';
import 'package:si_tumbuh/Orangtua/edukasi.dart';
import 'package:si_tumbuh/Orangtua/riwayat_kunjungan.dart';
import 'package:si_tumbuh/Orangtua/profil_lengkap.dart';
import 'package:si_tumbuh/Orangtua/data_anak.dart';
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
  String _namaOrangTua = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentAnakId = prefs.getInt('anak_id') ?? 0;
      _currentNamaAnak = prefs.getString('nama_anak') ?? '';
      _currentJenisKelamin = prefs.getString('jenis_kelamin') ?? '';
      _namaOrangTua = prefs.getString('nama') ?? 'Orang Tua';
    });
  }

  // ===== FUNGSI UNTUK REFRESH DATA SETELAH UPDATE PROFIL =====
  void _onProfileUpdated(Map<String, dynamic> data) {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE85D75),
              const Color(0xFFD44B66),
              const Color(0xFFC0395A),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER PROFIL =====
            SafeArea(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar dengan border
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 36,
                          color: Color(0xFFE85D75),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _namaOrangTua,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.baby_changing_station,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _currentNamaAnak.isNotEmpty
                              ? 'Anak: $_currentNamaAnak'
                              : 'Belum ada data anak',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 4),

            // ===== MENU =====
            Expanded(
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.dashboard_rounded,
                    "Halaman Utama",
                    0,
                    () => _navigateTo(context, const HalamanUtama()),
                  ),

                  _buildMenuItem(
                    Icons.favorite_border,
                    "Cek Pertumbuhan",
                    1,
                    () => _navigateTo(context, const CekPertumbuhanPage()),
                  ),

                  _buildMenuItem(
                    Icons.trending_up,
                    "Riwayat Pertumbuhan",
                    2,
                    () => _navigateTo(
                      context,
                      GrafikPage(
                        anakId: _currentAnakId,
                        namaAnak: _currentNamaAnak,
                        jenisKelamin: _currentJenisKelamin,
                      ),
                    ),
                  ),

                  _buildMenuItem(
                    Icons.history,
                    "Riwayat Kunjungan",
                    3,
                    () => _navigateTo(
                      context,
                      RiwayatKunjunganPage(anakId: _currentAnakId),
                    ),
                  ),

                  _buildMenuItem(
                    Icons.menu_book,
                    "Edukasi",
                    4,
                    () => _navigateTo(context, const EdukasiPage()),
                  ),

                  _buildMenuItem(
                    Icons.people_outline,
                    "Data Anak",
                    5,
                    () => _navigateTo(
                      context,
                      DataAnakPage(anakId: _currentAnakId),
                    ),
                  ),

                  _buildMenuItem(
                    Icons.person_outline,
                    "Profil",
                    6,
                    () => _navigateTo(
                      context,
                      ProfilLengkapPage(
                        anakId: _currentAnakId,
                        onProfileUpdated: _onProfileUpdated,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ===== DIVIDER =====
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 8),

                  // ===== LOGOUT =====
                  _buildMenuItem(
                    Icons.logout,
                    "Keluar",
                    6,
                    () => _showLogoutDialog(context),
                    isLogout: true,
                  ),
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
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 0.5,
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.white,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isLogout
                      ? Colors.white.withValues(alpha: 0.8)
                      : Colors.white,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    // Tutup drawer terlebih dahulu
    Navigator.pop(context);
    // Navigasi ke halaman
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  // ========== LOGOUT ==========
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Color(0xFFE85D75), size: 24),
            const SizedBox(width: 10),
            const Text(
              "Konfirmasi Keluar",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A2A2A),
              ),
            ),
          ],
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
