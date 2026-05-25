import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:si_tumbuh/Orangtua/profil_lengkap.dart';
import 'package:si_tumbuh/Orangtua/riwayat_kunjungan.dart';
import 'package:si_tumbuh/widgets/sidebar_menu.dart';
import 'package:si_tumbuh/Orangtua/data_anak.dart';
import 'package:si_tumbuh/login.dart';

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

  // Data Anak (lengkap)
  String tanggalLahir = '';
  String beratLahir = '';
  String tinggiLahir = '';
  String lingkarKepalaLahir = '';
  String statusGizi = 'Normal';
  String namaLengkapAnak = '';
  String jk = '';

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

    await Future.wait([_loadUserData(), _loadAnakDetailData()]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0;
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://your-api.com/api/orangtua/profile/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            namaOrangTua = data['data']['nama_lengkap'] ?? '';
            email = data['data']['email'] ?? '';
            noHp = data['data']['no_hp'] ?? '';
            alamat = data['data']['alamat'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error load user data: $e');
    }
  }

  Future<void> _loadAnakDetailData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://your-api.com/api/anak/${widget.anakId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            namaLengkapAnak = data['data']['nama_anak'] ?? widget.namaAnak;
            jk = data['data']['jenis_kelamin'] ?? widget.jenisKelamin;
            tanggalLahir = data['data']['tanggal_lahir'] ?? '-';
            beratLahir = data['data']['berat_lahir']?.toString() ?? '-';
            tinggiLahir = data['data']['tinggi_lahir']?.toString() ?? '-';
            lingkarKepalaLahir =
                data['data']['lingkar_kepala_lahir']?.toString() ?? '-';
            statusGizi = data['data']['status_gizi'] ?? 'Normal';
          });
        }
      }
    } catch (e) {
      print('Error load anak detail: $e');
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

      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadAllData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B1E3F),
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // HEADER
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD86487),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 16,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Scaffold.of(context).openDrawer();
                                },
                                child: const Icon(
                                  Icons.menu,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                "SiTumbuh",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const Icon(
                                Icons.notifications_none,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: -45,
                          left: 0,
                          right: 0,
                          child: const Center(
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: Color(0xFF7A1C2E),
                              child: Icon(
                                Icons.person,
                                size: 45,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),

                    // USER INFO - DARI DATABASE
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            namaOrangTua.isNotEmpty
                                ? namaOrangTua
                                : "Orang Tua",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF5A2A2A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            email,
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
                    ),
                    const SizedBox(height: 20),

                    // PROFIL ANAK - DARI DATABASE
                    _profilAnak(),

                    const SizedBox(height: 16),

                    _menu(context, "Profil lengkap", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfilLengkapPage(anakId: widget.anakId),
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
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
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
      ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
            "Berat badan lahir : ${beratLahir != '-' ? '$beratLahir kg' : 'Belum diisi'}",
          ),
          Text(
            "Tinggi badan lahir : ${tinggiLahir != '-' ? '$tinggiLahir cm' : 'Belum diisi'}",
          ),
          Text(
            "Lingkar kepala lahir : ${lingkarKepalaLahir != '-' ? '$lingkarKepalaLahir cm' : 'Belum diisi'}",
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
                // Hapus semua data session
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // Navigasi ke login
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Keluar"),
            ),
          ],
        );
      },
    );
  }
}
