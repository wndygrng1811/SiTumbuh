import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  bool isLoading = true;
  bool isSaving = false;

  String nama = "";
  String email = "";
  String telp = "";
  String alamat = "";
  final int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    loadProfil();
  }

  // LOAD PROFIL DARI API - menggunakan route /kader/profil/{userId}
  Future<void> loadProfil() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Ambil user_id dari SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      print('📡 Memuat profil untuk user_id: $userId');

      // 🔥 PAKAI ROUTE: /kader/profil/{userId}
      final response = await ApiService.get('/kader/profil/$userId');

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);

        if (result['success'] == true) {
          final data = result['data'];
          setState(() {
            nama = data['nama'] ?? '';
            email = data['email'] ?? '';
            telp = data['no_telp'] ?? '';
            alamat = data['alamat'] ?? '';
            isLoading = false;
          });
          print('✅ Profil loaded: $nama');
        } else {
          setState(() {
            isLoading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Gagal load profil'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Gagal terhubung ke server (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Error load profil: $e');
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // UPDATE PROFIL KE API - menggunakan route /kader/profil/{userId}
  Future<void> updateProfil({
    required String newNama,
    required String newEmail,
    required String newTelp,
    required String newAlamat,
  }) async {
    setState(() {
      isSaving = true;
    });

    try {
      // Ambil user_id dari SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      print('📡 Mengupdate profil untuk user_id: $userId');
      print(
        '📤 Data: nama=$newNama, email=$newEmail, telp=$newTelp, alamat=$newAlamat',
      );

      // 🔥 PAKAI ROUTE: /kader/profil/{userId}
      final response = await ApiService.put('/kader/profil/$userId', {
        'nama': newNama,
        'email': newEmail,
        'no_telp': newTelp,
        'alamat': newAlamat,
      });

      print('📡 Update Status Code: ${response.statusCode}');
      print('📡 Update Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);

        if (result['success'] == true) {
          final data = result['data'];
          setState(() {
            nama = data['nama'] ?? newNama;
            email = data['email'] ?? newEmail;
            telp = data['no_telp'] ?? newTelp;
            alamat = data['alamat'] ?? newAlamat;
            isSaving = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profil berhasil diupdate"),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception(result['message'] ?? 'Gagal update profil');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error update profil: $e');
      setState(() {
        isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarKader(),
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE85D75),
        elevation: 0,
        title: const Text("Profil"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// HEADER PROFIL
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE85D75),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Color(0xFFE85D75),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          nama.isEmpty ? "Kader" : nama,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          email.isEmpty ? "email@example.com" : email,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// DATA CARD
                  infoCard(Icons.person, "Nama", nama.isEmpty ? "-" : nama),
                  infoCard(Icons.email, "Email", email.isEmpty ? "-" : email),
                  infoCard(
                    Icons.phone,
                    "No Telepon",
                    telp.isEmpty ? "-" : telp,
                  ),
                  infoCard(
                    Icons.location_on,
                    "Alamat",
                    alamat.isEmpty ? "-" : alamat,
                  ),

                  const SizedBox(height: 20),

                  /// BUTTON EDIT
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () => showEditDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE85D75),
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Edit Profil"),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavbarKader(selectedIndex: _selectedIndex),
    );
  }

  /// POPUP EDIT PROFIL
  void showEditDialog(BuildContext context) {
    final namaC = TextEditingController(text: nama);
    final emailC = TextEditingController(text: email);
    final telpC = TextEditingController(text: telp);
    final alamatC = TextEditingController(text: alamat);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Edit Profil"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              inputField(namaC, "Nama", Icons.person),
              const SizedBox(height: 12),
              inputField(emailC, "Email", Icons.email),
              const SizedBox(height: 12),
              inputField(telpC, "No Telepon", Icons.phone),
              const SizedBox(height: 12),
              inputField(alamatC, "Alamat", Icons.location_on),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85D75),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              updateProfil(
                newNama: namaC.text,
                newEmail: emailC.text,
                newTelp: telpC.text,
                newAlamat: alamatC.text,
              );
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  /// WIDGET INFO CARD
  Widget infoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE85D75), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// WIDGET INPUT FIELD
  Widget inputField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFE85D75), size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE85D75), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
