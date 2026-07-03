import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:si_tumbuh/Kader/data_orangtua.dart';
import 'package:si_tumbuh/Kader/data_pertumbuhan.dart';
import 'package:si_tumbuh/Kader/kehadiran.dart';
import 'package:si_tumbuh/Kader/edukasi_kader.dart';
import 'package:si_tumbuh/Kader/laporan.dart';
import 'package:si_tumbuh/login.dart';
import '../services/api_service.dart';

class SidebarKader extends StatefulWidget {
  final int currentIndex;

  const SidebarKader({super.key, this.currentIndex = 0});

  @override
  State<SidebarKader> createState() => _SidebarKaderState();
}

class _SidebarKaderState extends State<SidebarKader> {
  String _namaKader = 'Kader';
  String _emailKader = 'kader@email.com';
  int _selectedIndex = 0;
  int? _userId;

  // Mapping halaman ke index
  static const Map<String, int> _pageIndexMap = {
    'DataOrangTua': 0,
    'DataPertumbuhan': 1,
    'Kehadiran': 2,
    'Edukasi': 3,
    'Laporan': 4,
  };

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _loadKaderData();
  }

  @override
  void didUpdateWidget(SidebarKader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = widget.currentIndex;
      });
    }
  }

  Future<void> _loadKaderData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _userId = prefs.getInt('user_id');

    setState(() {
      _namaKader =
          prefs.getString('nama_kader') ?? prefs.getString('nama') ?? 'Kader';

      _emailKader =
          prefs.getString('email_kader') ??
          prefs.getString('email') ??
          'kader@email.com';
    });

    if (_userId != null) {
      await _loadProfilFromApi(_userId!);
    }
  }

  Future<void> _loadProfilFromApi(int userId) async {
    try {
      final response = await ApiService.get('/kader/profil/$userId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final userData = data['data'];

          String nama = userData['nama'] ?? '';
          String email = userData['email'] ?? '';

          if (nama.isNotEmpty) {
            SharedPreferences prefs = await SharedPreferences.getInstance();

            await prefs.setString('nama_kader', nama);
            await prefs.setString('email_kader', email);
            await prefs.setString('nama', nama);
            await prefs.setString('email', email);

            if (mounted) {
              setState(() {
                _namaKader = nama;
                _emailKader = email.isNotEmpty ? email : 'kader@email.com';
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error load profil kader: $e');
    }
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
            SafeArea(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withAlpha(102),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          _namaKader.isNotEmpty
                              ? _namaKader[0].toUpperCase()
                              : 'K',
                          style: const TextStyle(
                            color: Color(0xFFE85D75),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _namaKader,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: Colors.white.withAlpha(179),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _emailKader,
                            style: TextStyle(
                              color: Colors.white.withAlpha(179),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(38),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Kader Aktif',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context,
                    Icons.family_restroom_rounded,
                    "Data Orang Tua",
                    const KelolaDaftarOrangTuaPage(),
                    0,
                    'DataOrangTua',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.show_chart_rounded,
                    "Data Pertumbuhan",
                    const DataPertumbuhanPage(),
                    1,
                    'DataPertumbuhan',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.check_circle_rounded,
                    "Kehadiran",
                    const Kehadiran(),
                    2,
                    'Kehadiran',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.book_rounded,
                    "Edukasi",
                    const EdukasiKaderPage(),
                    3,
                    'Edukasi',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.assessment_rounded,
                    "Laporan",
                    const LaporanPage(),
                    4,
                    'Laporan',
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 1,
              color: Colors.white.withAlpha(51),
            ),
            const SizedBox(height: 8),

            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.white),
              title: const Text(
                "Keluar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withAlpha(102),
                size: 16,
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
    int index,
    String routeName,
  ) {
    // Gunakan currentIndex dari widget, bukan _selectedIndex
    final isSelected = widget.currentIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withAlpha(51) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: Colors.white.withAlpha(77), width: 0.5)
            : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.logout_rounded,
              color: Color(0xFFE85D75),
              size: 24,
            ),
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
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (mounted) {
                Navigator.pop(context);
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
