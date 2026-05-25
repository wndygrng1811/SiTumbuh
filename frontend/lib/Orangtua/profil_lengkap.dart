import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilLengkapPage extends StatefulWidget {
  final int anakId;

  const ProfilLengkapPage({super.key, required this.anakId});

  @override
  State<ProfilLengkapPage> createState() => _ProfilLengkapPageState();
}

class _ProfilLengkapPageState extends State<ProfilLengkapPage> {
  bool _isLoading = true;
  String _errorMessage = '';

  String namaLengkap = '';
  String email = '';
  String noHp = '';
  String alamat = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int userId = prefs.getInt('user_id') ?? 0;

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
            namaLengkap = data['data']['nama_lengkap'] ?? '';
            email = data['data']['email'] ?? '';
            noHp = data['data']['no_hp'] ?? '';
            alamat = data['data']['alamat'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Gagal memuat data';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Gagal terhubung ke server';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFF1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6EFF1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF7A1C2E)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Profil lengkap",
          style: TextStyle(
            color: Color(0xFF7A1C2E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
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
                    onPressed: _loadProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD86487),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF7A1C2E),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  namaLengkap.isNotEmpty ? namaLengkap : "Orang Tua",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF5A2A2A),
                  ),
                ),
                const Text(
                  "Data diri & kontak anda",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                _item(
                  Icons.email,
                  "Email",
                  email.isNotEmpty ? email : "Belum diisi",
                ),
                _item(
                  Icons.phone,
                  "Nomor HP",
                  noHp.isNotEmpty ? noHp : "Belum diisi",
                ),
                _item(
                  Icons.location_on,
                  "Alamat",
                  alamat.isNotEmpty ? alamat : "Belum diisi",
                ),
              ],
            ),
    );
  }

  Widget _item(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE5E7),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD86487)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A1C2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Color(0xFF5A2A2A))),
            ],
          ),
        ],
      ),
    );
  }
}
