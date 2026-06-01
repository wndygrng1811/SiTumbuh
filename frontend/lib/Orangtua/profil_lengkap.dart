import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/services/api_service.dart';

class ProfilLengkapPage extends StatefulWidget {
  final int anakId;
  final Function(Map<String, dynamic>)
  onProfileUpdated; // 🔥 callback dengan data

  const ProfilLengkapPage({
    super.key,
    required this.anakId,
    required this.onProfileUpdated,
  });

  @override
  State<ProfilLengkapPage> createState() => _ProfilLengkapPageState();
}

class _ProfilLengkapPageState extends State<ProfilLengkapPage> {
  bool _isLoading = true;
  bool _isEditing = false;

  String namaLengkap = '';
  String email = '';
  String noHp = '';
  String alamat = '';

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int userId = prefs.getInt('user_id') ?? 0;

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/orangtua/$userId/profile-lengkap'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            namaLengkap = data['data']['nama_lengkap'] ?? '';
            email = data['data']['email'] ?? '';
            noHp = data['data']['no_hp'] ?? '';
            alamat = data['data']['alamat'] ?? '';

            _namaController.text = namaLengkap;
            _emailController.text = email;
            _noHpController.text = noHp;
            _alamatController.text = alamat;

            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int userId = prefs.getInt('user_id') ?? 0;

      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/orangtua/$userId/profile-lengkap'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nama_lengkap': _namaController.text,
          'email': _emailController.text,
          'no_hp': _noHpController.text,
          'alamat': _alamatController.text,
        }),
      );

      if (response.statusCode == 200) {
        final dataBaru = {
          'nama_lengkap': _namaController.text,
          'email': _emailController.text,
          'no_hp': _noHpController.text,
          'alamat': _alamatController.text,
        };

        // 🔥 HANYA UPDATE NAMA ORANG TUA (BUKAN NAMA ANAK)
        await prefs.setString('nama', _namaController.text);
        // ❌ JANGAN update 'nama_anak' di sini!

        // 🔥 Panggil callback dengan data baru
        widget.onProfileUpdated(dataBaru);

        // 🔥 Kembali ke halaman profil sambil bawa data
        Navigator.pop(context, dataBaru);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diupdate'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFF1),
      appBar: AppBar(
        title: const Text(
          "Profil lengkap",
          style: TextStyle(
            color: Color(0xFF76172D),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF76172D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  const Center(
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Color(0xFFD86487),
                      child: Icon(Icons.person, size: 45, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    namaLengkap.isNotEmpty ? namaLengkap : "Orang Tua",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF5A2A2A),
                    ),
                  ),
                  const Text(
                    "Data diri & kontak anda",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 30),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isEditing ? _buildEditForm() : _buildInfoView(),
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_isEditing) {
                            _updateProfile();
                          } else {
                            setState(() {
                              _isEditing = true;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD86487),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          _isEditing ? "Simpan" : "Ubah Profil",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoView() {
    return Column(
      children: [
        _infoItem("Email", email),
        const Divider(height: 1, thickness: 0.5, color: Colors.grey),
        _infoItem("Nomor HP", noHp),
        const Divider(height: 1, thickness: 0.5, color: Colors.grey),
        _infoItem("Alamat", alamat),
      ],
    );
  }

  Widget _infoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "Belum diisi",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        _editField(_namaController, "Nama Lengkap"),
        const Divider(height: 1, thickness: 0.5, color: Colors.grey),
        _editField(_emailController, "Email"),
        const Divider(height: 1, thickness: 0.5, color: Colors.grey),
        _editField(_noHpController, "Nomor HP"),
        const Divider(height: 1, thickness: 0.5, color: Colors.grey),
        _editField(_alamatController, "Alamat"),
      ],
    );
  }

  Widget _editField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          border: InputBorder.none,
          isDense: true,
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
