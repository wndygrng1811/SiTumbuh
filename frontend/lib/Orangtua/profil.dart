import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:si_tumbuh/Orangtua/profil_lengkap.dart';
import 'package:si_tumbuh/Orangtua/riwayat_kunjungan.dart';
import 'package:si_tumbuh/widgets/sidebar_menu.dart';
import 'package:si_tumbuh/Orangtua/data_anak.dart';
import 'package:si_tumbuh/login.dart';
import 'package:si_tumbuh/widgets/custom_app_bar.dart';
import 'package:si_tumbuh/widgets/bottom_nav.dart';
import 'package:si_tumbuh/services/api_service.dart';

class ProfilePage extends StatefulWidget {
  final int anakId;
  final String namaAnak;
  final String jenisKelamin;

  const ProfilePage({
    super.key,
    required this.anakId,
    required this.namaAnak,
    required this.jenisKelamin,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  String _errorMessage = '';

  // Data Orang Tua
  String namaOrangTua = '';
  String email = '';
  String noHp = '';
  String alamat = '';

  // Data Anak (dari tabel anak)
  String tanggalLahir = '';
  String namaLengkapAnak = '';
  String jk = '';

  // Data Pertumbuhan TERBARU (dari tabel pertumbuhan)
  String beratTerbaru = '';
  String tinggiTerbaru = '';
  String lingkarKepalaTerbaru = '';
  String statusGizi = 'Normal';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await Future.wait([
        _loadUserData().timeout(const Duration(seconds: 10)),
        _loadAnakData().timeout(const Duration(seconds: 10)),
        _loadPertumbuhanTerbaru().timeout(const Duration(seconds: 10)),
      ]);
    } catch (e) {
      print('Timeout atau error: $e');
      _loadDataFromPrefs();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _loadDataFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      namaOrangTua = prefs.getString('nama_anak') ?? 'Bunda A';
      email = prefs.getString('email') ?? 'bunda@gmail.com';
      noHp = '08123456789';
      alamat = 'Batam';
      namaLengkapAnak = widget.namaAnak.isNotEmpty
          ? widget.namaAnak
          : 'Raffi Ahmad';
      jk = widget.jenisKelamin.isNotEmpty ? widget.jenisKelamin : 'Laki-laki';
      tanggalLahir = '2025-01-15';
      beratTerbaru = '9.8';
      tinggiTerbaru = '78';
      lingkarKepalaTerbaru = '44';
      statusGizi = 'Normal';
    });
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0;
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/orangtua/profile/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Profile response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            namaOrangTua = data['data']['nama_lengkap'] ?? '';
            email = data['data']['email'] ?? '';
            noHp = data['data']['no_hp']?.toString() ?? '';
            alamat = data['data']['alamat'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error load user data: $e');
    }
  }

  // Ambil data anak (nama, jenis kelamin, tanggal lahir)
  Future<void> _loadAnakData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/anak/${widget.anakId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Anak response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            namaLengkapAnak = data['data']['nama_anak'] ?? widget.namaAnak;
            jk = data['data']['jenis_kelamin'] ?? widget.jenisKelamin;
            tanggalLahir = data['data']['tanggal_lahir'] ?? '-';
          });
        }
      }
    } catch (e) {
      print('Error load anak data: $e');
    }
  }

  // Ambil data pertumbuhan TERBARU dari tabel pertumbuhan
  Future<void> _loadPertumbuhanTerbaru() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/pertumbuhan/${widget.anakId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Pertumbuhan response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true &&
            data['data'] != null &&
            data['data'].isNotEmpty) {
          var terbaru = data['data'].last;
          setState(() {
            beratTerbaru = terbaru['berat']?.toString() ?? '-';
            tinggiTerbaru = terbaru['tinggi']?.toString() ?? '-';
            lingkarKepalaTerbaru = terbaru['l_kepala']?.toString() ?? '-';
            statusGizi = terbaru['status'] ?? 'Normal';
          });
        }
      }
    } catch (e) {
      print('Error load pertumbuhan: $e');
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return const SidebarMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: CustomAppBar(
        title: 'Profil',
        backgroundColor: const Color(0xFFD86487),
        titleColor: Colors.white,
        iconColor: Colors.white,
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFF7A1C2E),
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      Text(
                        namaOrangTua.isNotEmpty ? namaOrangTua : "Orang Tua",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF5A2A2A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        email.isNotEmpty ? email : "email@example.com",
                        style: const TextStyle(
                          color: Color(0xFFD86487),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "No Hp : ${noHp.isNotEmpty ? noHp : '-'}",
                        style: const TextStyle(
                          color: Color(0xFF7A1C2E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _profilAnak(),
                  const SizedBox(height: 16),
                  _menu(context, "Profil lengkap", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilLengkapPage(
                          anakId: widget.anakId,
                          onProfileUpdated: (Map<String, dynamic> dataBaru) {
                            // 🔥 Update state langsung tanpa refresh
                            setState(() {
                              namaOrangTua = dataBaru['nama_lengkap'];
                              email = dataBaru['email'];
                              noHp = dataBaru['no_hp'];
                              alamat = dataBaru['alamat'];
                            });
                          },
                        ),
                      ),
                    );
                  }),
                  _menu(context, "Data anak", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DataAnakPage(anakId: widget.anakId),
                      ),
                    );
                  }),
                  _menu(context, "Riwayat kunjungan", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RiwayatKunjunganPage(anakId: widget.anakId),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text(
                          "Informasi Privasi",
                          style: TextStyle(
                            color: Color(0xFF7A1C2E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Syarat & Ketentuan",
                          style: TextStyle(
                            color: Color(0xFF7A1C2E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _showLogoutDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A1E28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 12,
                      ),
                      child: Text(
                        "Keluar",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
    );
  }

  Widget _profilAnak() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Profil Anak",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF7A1C2E),
            ),
          ),
          const Divider(color: Color(0xFFF0C4D0)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    namaLengkapAnak.isNotEmpty
                        ? namaLengkapAnak
                        : widget.namaAnak,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    jk.isNotEmpty ? jk : widget.jenisKelamin,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusGizi == 'Normal'
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusGizi == 'Normal'
                        ? Colors.green.shade300
                        : Colors.orange.shade300,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  statusGizi,
                  style: TextStyle(
                    color: statusGizi == 'Normal'
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Tanggal lahir : ${tanggalLahir != '-' ? tanggalLahir : 'Belum diisi'}",
          ),
          Text(
            "Berat badan : ${beratTerbaru != '-' ? '$beratTerbaru kg' : 'Belum diisi'}",
          ),
          Text(
            "Tinggi badan : ${tinggiTerbaru != '-' ? '$tinggiTerbaru cm' : 'Belum diisi'}",
          ),
          Text(
            "Lingkar kepala : ${lingkarKepalaTerbaru != '-' ? '$lingkarKepalaTerbaru cm' : 'Belum diisi'}",
          ),
        ],
      ),
    );
  }

  Widget _menu(BuildContext context, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFD86487),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Keluar"),
          content: const Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Keluar"),
            ),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                "Reset Data & Login Ulang",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
