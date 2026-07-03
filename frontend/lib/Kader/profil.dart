import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';
import '../widgets/custom_app_bar.dart';

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

  Future<void> loadProfil() async {
    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await ApiService.get('/kader/profil/$userId');

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
        } else {
          setState(() => isLoading = false);
          _showSnackbar(result['message'] ?? 'Gagal load profil', Colors.red);
        }
      } else {
        setState(() => isLoading = false);
        throw Exception('Gagal terhubung ke server (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Error load profil: $e');
      setState(() => isLoading = false);
      _showSnackbar('Error: $e', Colors.red);
    }
  }

  Future<void> updateProfil({
    required String newNama,
    required String newEmail,
    required String newTelp,
    required String newAlamat,
  }) async {
    setState(() => isSaving = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      final response = await ApiService.put('/kader/profil/$userId', {
        'nama': newNama,
        'email': newEmail,
        'no_telp': newTelp,
        'alamat': newAlamat,
      });

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
          _showSnackbar('Profil berhasil diupdate', Colors.green);
        } else {
          throw Exception(result['message'] ?? 'Gagal update profil');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error update profil: $e');
      setState(() => isSaving = false);
      _showSnackbar('Error: $e', Colors.red);
    }
  }

  void _showSnackbar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarKader(currentIndex: 3),
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(
        backgroundColor: const Color(0xFFE85D75),
        iconColor: Colors.white,
        showBackButton: false,
        showDrawerIcon: true,
        showNotificationIcon: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE85D75)),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildSectionLabel('Informasi Profil'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    Icons.person_outline_rounded,
                    'Nama',
                    nama.isEmpty ? '-' : nama,
                  ),
                  _buildInfoCard(
                    Icons.email_outlined,
                    'Email',
                    email.isEmpty ? '-' : email,
                  ),
                  _buildInfoCard(
                    Icons.phone_outlined,
                    'No Telepon',
                    telp.isEmpty ? '-' : telp,
                  ),
                  _buildInfoCard(
                    Icons.location_on_outlined,
                    'Alamat',
                    alamat.isEmpty ? '-' : alamat,
                  ),
                  const SizedBox(height: 24),
                  _buildEditButton(),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavbarKader(selectedIndex: _selectedIndex),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE85D75), Color(0xFFD44B66)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE85D75).withAlpha(64),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(102), width: 3),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white.withAlpha(51),
              child: Text(
                nama.isNotEmpty ? nama[0].toUpperCase() : 'K',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama.isEmpty ? 'Kader' : nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: Colors.white.withAlpha(179),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Kader Aktif',
                      style: TextStyle(
                        color: Colors.white.withAlpha(179),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: Colors.white.withAlpha(153),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        email.isEmpty ? 'email@example.com' : email,
                        style: TextStyle(
                          color: Colors.white.withAlpha(153),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFE85D75),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE85D75).withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFE85D75), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.edit_outlined, color: Colors.grey.shade300, size: 16),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : () => _showEditDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE85D75),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        icon: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.edit_rounded, size: 20),
        label: isSaving
            ? const Text('Menyimpan...')
            : const Text(
                'Edit Profil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final namaC = TextEditingController(text: nama);
    final emailC = TextEditingController(text: email);
    final telpC = TextEditingController(text: telp);
    final alamatC = TextEditingController(text: alamat);

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(38),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE85D75), Color(0xFFD44B66)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Profil',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Perbarui data diri Anda',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // BODY - PAKAI Flexible + SingleChildScrollView
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDialogField(
                          controller: namaC,
                          label: 'Nama Lengkap',
                          hint: 'Masukkan nama lengkap',
                          icon: Icons.person_outline_rounded,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Nama harus diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildDialogField(
                          controller: emailC,
                          label: 'Email',
                          hint: 'Masukkan email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Email harus diisi';
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(v!)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildDialogField(
                          controller: telpC,
                          label: 'No Telepon',
                          hint: 'Masukkan no telepon',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v?.isEmpty ?? true)
                              return 'No telepon harus diisi';
                            if (v!.length < 10) return 'Minimal 10 digit';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildDialogField(
                          controller: alamatC,
                          label: 'Alamat',
                          hint: 'Masukkan alamat',
                          icon: Icons.location_on_outlined,
                          maxLines: 2,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Alamat harus diisi' : null,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),

              // FOOTER
              Container(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE85D75),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            updateProfil(
                              newNama: namaC.text,
                              newEmail: emailC.text,
                              newTelp: telpC.text,
                              newAlamat: alamatC.text,
                            );
                          }
                        },
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        labelStyle: const TextStyle(
          color: Color(0xFF555555),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Container(
          width: 20,
          margin: const EdgeInsets.only(right: 4),
          child: Icon(icon, color: const Color(0xFFE85D75), size: 20),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE85D75), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: validator,
    );
  }
}
