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
  final VoidCallback? onChildChanged;

  const ProfilePage({
    super.key,
    required this.anakId,
    required this.namaAnak,
    required this.jenisKelamin,
    this.onChildChanged,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _errorMessage = '';

  // Data Orang Tua
  String namaOrangTua = '';
  String email = '';
  String noHp = '';
  String alamat = '';

  // Daftar Anak
  List<Map<String, dynamic>> _listAnak = [];
  int _selectedAnakId = 0;
  String _selectedNamaAnak = '';
  String _selectedJenisKelamin = '';

  // Data Anak yang ditampilkan (dari tabel ANAK)
  String tanggalLahir = '';
  String namaLengkapAnak = '';
  String jk = '';
  String beratLahir = '';
  String tinggiLahir = '';
  String lingkarKepalaLahir = '';
  String statusGiziLahir = 'Normal';

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
      // Load data orang tua
      await _loadUserData();

      // Load daftar anak
      await _loadListAnak();

      // Setelah daftar anak loaded, pastikan selected anakId dari widget (yang dikirim dari HalamanUtama)
      if (mounted) {
        setState(() {
          // PRIORITASKAN data dari widget (yang sudah tersimpan di SharedPreferences)
          if (widget.anakId != 0) {
            _selectedAnakId = widget.anakId;
            _selectedNamaAnak = widget.namaAnak;
            _selectedJenisKelamin = widget.jenisKelamin;
          } else {
            // Jika widget tidak ada, coba dari SharedPreferences
            _loadSelectedFromPrefs();
          }
        });

        // Load data anak yang dipilih
        if (_selectedAnakId != 0) {
          await _loadDataAnakFromTableAnak(_selectedAnakId);
        }
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      _loadDataFromPrefs();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSelectedFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedAnakId = prefs.getInt('anak_id') ?? 0;
    String savedNamaAnak = prefs.getString('nama_anak') ?? '';
    String savedJenisKelamin = prefs.getString('jenis_kelamin') ?? '';

    if (savedAnakId != 0) {
      _selectedAnakId = savedAnakId;
      _selectedNamaAnak = savedNamaAnak;
      _selectedJenisKelamin = savedJenisKelamin;
    } else if (_listAnak.isNotEmpty) {
      // Fallback ke anak pertama jika tidak ada yang tersimpan
      _selectedAnakId = _listAnak[0]['anak_id'];
      _selectedNamaAnak = _listAnak[0]['nama'];
      _selectedJenisKelamin = _listAnak[0]['jenis_kelamin'];
    }
  }

  Future<void> _loadListAnak() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int orangtuaId = prefs.getInt('user_id') ?? 0;

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/orangtua/$orangtuaId/anak'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List<dynamic> anakList = data['data'];

          if (mounted) {
            setState(() {
              _listAnak = anakList.map((item) {
                String jk = item['jenis_kelamin'] ?? '';
                if (jk == 'L') jk = 'Laki-laki';
                if (jk == 'P') jk = 'Perempuan';

                return {
                  'anak_id': item['anak_id'],
                  'nama': item['nama'] ?? '',
                  'jenis_kelamin': jk,
                  'tanggal_lahir': item['tanggal_lahir'] ?? '',
                };
              }).toList();
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error load list anak: $e');
    }
  }

  // Fungsi untuk mengambil data dari TABEL ANAK
  Future<void> _loadDataAnakFromTableAnak(int anakId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/anak/$anakId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final anakData = data['data'];
          if (mounted) {
            setState(() {
              namaLengkapAnak =
                  anakData['nama_anak'] ??
                  anakData['nama'] ??
                  _selectedNamaAnak;
              jk = anakData['jenis_kelamin'] ?? _selectedJenisKelamin;
              tanggalLahir = anakData['tanggal_lahir'] ?? '-';

              // Ambil data BB, TB, LK LAHIR dari tabel anak
              beratLahir =
                  anakData['berat_badan'] != null &&
                      anakData['berat_badan'].toString() != 'null'
                  ? anakData['berat_badan'].toString()
                  : '-';
              tinggiLahir =
                  anakData['tinggi_badan'] != null &&
                      anakData['tinggi_badan'].toString() != 'null'
                  ? anakData['tinggi_badan'].toString()
                  : '-';
              lingkarKepalaLahir =
                  anakData['lingkar_kepala'] != null &&
                      anakData['lingkar_kepala'].toString() != 'null'
                  ? anakData['lingkar_kepala'].toString()
                  : '-';
              statusGiziLahir = anakData['status_gizi'] ?? 'Normal';
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error load data anak from table anak: $e');
    }
  }

  void _onAnakChanged(int? newAnakId) async {
    if (newAnakId != null && newAnakId != _selectedAnakId) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _selectedAnakId = newAnakId;
          final selectedAnak = _listAnak.firstWhere(
            (a) => a['anak_id'] == newAnakId,
          );
          _selectedNamaAnak = selectedAnak['nama'];
          _selectedJenisKelamin = selectedAnak['jenis_kelamin'];
        });
      }

      // UPDATE KE SHARED PREFERENCES
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('anak_id', _selectedAnakId);
      await prefs.setString('nama_anak', _selectedNamaAnak);
      await prefs.setString('jenis_kelamin', _selectedJenisKelamin);

      // PANGGIL CALLBACK UNTUK UPDATE HALAMAN LAIN
      if (widget.onChildChanged != null) {
        widget.onChildChanged!();
      }

      // Load data dari tabel anak
      await _loadDataAnakFromTableAnak(_selectedAnakId);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });
    }

    // Refresh daftar anak
    await _loadListAnak();

    // Refresh data anak yang sedang dipilih
    if (_selectedAnakId != 0) {
      await _loadDataAnakFromTableAnak(_selectedAnakId);
    }

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _loadDataFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        namaOrangTua = prefs.getString('nama') ?? 'Bunda';
        email = prefs.getString('email') ?? 'bunda@gmail.com';
        noHp = prefs.getString('no_hp') ?? '08123456789';
        alamat = prefs.getString('alamat') ?? 'Batam';
        _selectedNamaAnak = prefs.getString('nama_anak') ?? 'Raffi Ahmad';
        _selectedJenisKelamin = prefs.getString('jenis_kelamin') ?? 'Laki-laki';
        _selectedAnakId = prefs.getInt('anak_id') ?? 1;
        tanggalLahir = '2025-01-01';
        beratLahir = '3.5';
        tinggiLahir = '50';
        lingkarKepalaLahir = '34';
        statusGiziLahir = 'Normal';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0;
      String? token = prefs.getString('token');

      if (userId == 0) {
        debugPrint('User ID tidak ditemukan');
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/orangtua/profile/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          if (mounted) {
            setState(() {
              namaOrangTua =
                  data['data']['nama_lengkap'] ?? data['data']['nama'] ?? '';
              email = data['data']['email'] ?? '';
              noHp = data['data']['no_hp']?.toString() ?? '';
              alamat = data['data']['alamat'] ?? '';
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error load user data: $e');
    }
  }

  void _updateProfileFromLengkap(Map<String, dynamic> dataBaru) {
    if (mounted) {
      setState(() {
        if (dataBaru.containsKey('nama_lengkap')) {
          namaOrangTua = dataBaru['nama_lengkap'];
        }
        if (dataBaru.containsKey('email')) {
          email = dataBaru['email'];
        }
        if (dataBaru.containsKey('no_hp')) {
          noHp = dataBaru['no_hp'];
        }
        if (dataBaru.containsKey('alamat')) {
          alamat = dataBaru['alamat'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarMenu(),
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: CustomAppBar(
        title: 'Profil',
        backgroundColor: const Color(0xFFD86487),
        titleColor: Colors.white,
        iconColor: Colors.white,
        showBackButton: false,
        showNotificationIcon: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildProfileHeader(),
                    const SizedBox(height: 20),
                    _buildAnakProfile(),
                    const SizedBox(height: 16),
                    _buildMenuItems(context),
                    const SizedBox(height: 20),
                    _buildFooterLinks(),
                    const SizedBox(height: 24),
                    _buildLogoutButton(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF7A1C2E),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          namaOrangTua.isNotEmpty ? namaOrangTua : "Orang Tua",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF5A2A2A),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Email berhasil disalin"),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Text(
            email.isNotEmpty ? email : "email@example.com",
            style: const TextStyle(
              color: Color(0xFFD86487),
              decoration: TextDecoration.none,
              fontWeight: FontWeight.normal,
            ),
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
    );
  }

  Widget _buildAnakProfile() {
    final displayNama = _selectedNamaAnak.isNotEmpty
        ? _selectedNamaAnak
        : "Raffi Ahmad";
    final displayJk = _selectedJenisKelamin.isNotEmpty
        ? _selectedJenisKelamin
        : "Laki-laki";
    final displayTglLahir = tanggalLahir.isNotEmpty && tanggalLahir != '-'
        ? tanggalLahir
        : "2025-01-01";
    final displayBerat =
        beratLahir.isNotEmpty && beratLahir != '-' && beratLahir != 'null'
        ? '$beratLahir kg'
        : '- kg';
    final displayTinggi =
        tinggiLahir.isNotEmpty && tinggiLahir != '-' && tinggiLahir != 'null'
        ? '$tinggiLahir cm'
        : '- cm';
    final displayLingkar =
        lingkarKepalaLahir.isNotEmpty &&
            lingkarKepalaLahir != '-' &&
            lingkarKepalaLahir != 'null'
        ? '$lingkarKepalaLahir cm'
        : '- cm';
    final displayStatus =
        statusGiziLahir.isNotEmpty && statusGiziLahir != 'null'
        ? statusGiziLahir
        : "Normal";

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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Profil Anak",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF7A1C2E),
                ),
              ),
              Icon(Icons.favorite, color: Color(0xFFD86487), size: 20),
            ],
          ),
          const Divider(color: Color(0xFFF0C4D0)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNamaAnakDropdown(displayNama),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: displayStatus == 'Normal'
                      ? Colors.green.shade100
                      : displayStatus == 'Kurang'
                      ? Colors.orange.shade100
                      : displayStatus == 'Stunting'
                      ? Colors.red.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: displayStatus == 'Normal'
                        ? Colors.green.shade300
                        : displayStatus == 'Kurang'
                        ? Colors.orange.shade300
                        : displayStatus == 'Stunting'
                        ? Colors.red.shade300
                        : Colors.orange.shade300,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  displayStatus,
                  style: TextStyle(
                    color: displayStatus == 'Normal'
                        ? Colors.green.shade700
                        : displayStatus == 'Kurang'
                        ? Colors.orange.shade700
                        : displayStatus == 'Stunting'
                        ? Colors.red.shade700
                        : Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            displayJk,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildInfoRow("Tanggal lahir", displayTglLahir),
          const SizedBox(height: 8),
          _buildInfoRow("Berat badan lahir", displayBerat),
          const SizedBox(height: 8),
          _buildInfoRow("Tinggi badan lahir", displayTinggi),
          const SizedBox(height: 8),
          _buildInfoRow("Lingkar kepala lahir", displayLingkar),
        ],
      ),
    );
  }

  Widget _buildNamaAnakDropdown(String currentName) {
    if (_listAnak.length <= 1) {
      return Text(
        currentName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xFF8B1E3F),
        ),
      );
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: _selectedAnakId,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Color(0xFF8B1E3F),
          size: 28,
        ),
        dropdownColor: Colors.white,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B1E3F),
        ),
        items: _listAnak.map((anak) {
          return DropdownMenuItem<int>(
            value: anak['anak_id'],
            child: Text(
              anak['nama'] ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B1E3F),
              ),
            ),
          );
        }).toList(),
        onChanged: _onAnakChanged,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
        const Text(":", style: TextStyle(fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final List<Map<String, dynamic>> menus = [
      {
        'icon': Icons.person_outline,
        'title': 'Profil lengkap',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilLengkapPage(
                anakId: _selectedAnakId,
                onProfileUpdated: _updateProfileFromLengkap,
              ),
            ),
          );
        },
      },
      {
        'icon': Icons.people_outline,
        'title': 'Data anak',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DataAnakPage(
                anakId: _selectedAnakId,
                onDataChanged: () {
                  _refreshData();
                },
              ),
            ),
          );
        },
      },
      {
        'icon': Icons.history_outlined,
        'title': 'Riwayat kunjungan',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RiwayatKunjunganPage(anakId: _selectedAnakId),
            ),
          );
        },
      },
    ];

    return Column(
      children: menus.map((menu) {
        return GestureDetector(
          onTap: menu['onTap'],
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
                Row(
                  children: [
                    Icon(
                      menu['icon'],
                      size: 22,
                      color: const Color(0xFFD86487),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      menu['title'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
      }).toList(),
    );
  }

  Widget _buildFooterLinks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFooterLink("Informasi Privasi"),
          Container(width: 1, height: 16, color: Colors.grey.shade300),
          _buildFooterLink("Syarat & Ketentuan"),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Fitur $text akan segera hadir"),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF7A1C2E),
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showLogoutDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5A1E28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(200, 48),
      ),
      child: const Text(
        "Keluar",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text("Konfirmasi Keluar"),
            ],
          ),
          content: const Text(
            "Apakah Anda yakin ingin keluar dari aplikasi?",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Keluar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
