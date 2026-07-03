import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/services/api_service.dart';
import 'package:flutter/services.dart';

class ProfilLengkapPage extends StatefulWidget {
  final int anakId;
  final Function(Map<String, dynamic>) onProfileUpdated;

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
  bool _isSaving = false;
  bool _isEditing = false;
  String _errorMessage = '';

  // ============ DATA DARI DATABASE ============
  String namaLengkap = '';
  String email = '';
  String noHp = '';
  String alamat = '';

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ============ LOAD DATA DARI API ============
  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      int orangtuaId = prefs.getInt('orangtua_id') ?? 0;
      int userId = prefs.getInt('user_id') ?? 0;

      int idToUse = orangtuaId > 0 ? orangtuaId : userId;

      if (idToUse == 0) {
        setState(() {
          _errorMessage = 'Session tidak valid, silakan login ulang';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/orangtua/${idToUse}/profile-lengkap'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final userData = data['data'];

          await prefs.setString(
            'nama',
            userData['nama_lengkap'] ?? userData['nama'] ?? '',
          );
          await prefs.setString('email', userData['email'] ?? '');
          await prefs.setString('no_hp', userData['no_hp']?.toString() ?? '');
          await prefs.setString('alamat', userData['alamat'] ?? '');

          setState(() {
            namaLengkap = userData['nama_lengkap'] ?? userData['nama'] ?? '';
            email = userData['email'] ?? '';
            noHp = userData['no_hp']?.toString() ?? '';
            alamat = userData['alamat'] ?? '';

            _namaController.text = namaLengkap;
            _emailController.text = email;
            _noHpController.text = noHp;
            _alamatController.text = alamat;

            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Gagal memuat data profil';
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage =
              'Data profil tidak ditemukan. Silakan isi data diri Anda.';
          _isLoading = false;
          _isEditing = true;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = 'Session habis, silakan login ulang';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data profil (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error load profile: $e');
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  // ============ VALIDASI EMAIL ============
  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // ============ VALIDASI NO HP ============
  bool _isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    final phoneRegex = RegExp(r'^[0-9]{10,13}$');
    if (!phoneRegex.hasMatch(phone)) return false;

    if (!phone.startsWith('08') &&
        !phone.startsWith('62') &&
        !phone.startsWith('+62')) {
      return false;
    }
    return true;
  }

  // ============ UPDATE DATA ============
  Future<void> _updateProfile() async {
    if (_namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama lengkap wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String emailValue = _emailController.text.trim();
    if (emailValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!_isValidEmail(emailValue)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid (contoh: nama@domain.com)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String noHpValue = _noHpController.text.trim();
    if (noHpValue.isNotEmpty && !_isValidPhone(noHpValue)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nomor HP harus 10-13 digit dan diawali 08, 62, atau +62',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (password.isNotEmpty || confirmPassword.isNotEmpty) {
      if (password.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password minimal 6 karakter'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password dan konfirmasi tidak sesuai'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      int orangtuaId = prefs.getInt('orangtua_id') ?? 0;
      int userId = prefs.getInt('user_id') ?? 0;
      int idToUse = orangtuaId > 0 ? orangtuaId : userId;

      Map<String, dynamic> requestBody = {
        'nama_lengkap': _namaController.text.trim(),
        'email': emailValue,
        'no_hp': noHpValue,
        'alamat': _alamatController.text.trim(),
      };

      if (password.isNotEmpty) {
        requestBody['password'] = password;
      }

      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/orangtua/${idToUse}/profile-lengkap'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Update profile response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          await prefs.setString('nama', _namaController.text.trim());
          await prefs.setString('email', emailValue);
          await prefs.setString('no_hp', noHpValue);
          await prefs.setString('alamat', _alamatController.text.trim());

          setState(() {
            namaLengkap = _namaController.text.trim();
            email = emailValue;
            noHp = noHpValue;
            alamat = _alamatController.text.trim();
            _isEditing = false;
            _isSaving = false;
            _passwordController.clear();
            _confirmPasswordController.clear();
          });

          widget.onProfileUpdated({
            'nama_lengkap': namaLengkap,
            'email': email,
            'no_hp': noHp,
            'alamat': alamat,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diupdate'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'] ?? 'Gagal mengupdate profil',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        final errorData = json.decode(response.body);
        String errorMsg =
            errorData['message'] ??
            'Gagal mengupdate profil (${response.statusCode})';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('Error update profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Batalkan Perubahan?'),
        content: const Text('Perubahan yang belum disimpan akan hilang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Lanjutkan Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isEditing = false;
                _namaController.text = namaLengkap;
                _emailController.text = email;
                _noHpController.text = noHp;
                _alamatController.text = alamat;
                _passwordController.clear();
                _confirmPasswordController.clear();
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Profil Lengkap",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFE85D75),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_isEditing) {
              _showCancelConfirmation();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE85D75),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: const Color(
                        0xFFE85D75,
                      ).withOpacity(0.15),
                      child: Icon(
                        _isEditing ? Icons.edit : Icons.person,
                        size: 45,
                        color: const Color(0xFFE85D75),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    namaLengkap.isNotEmpty ? namaLengkap : "",
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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isEditing ? _buildEditForm() : _buildInfoView(),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () {
                                if (_isEditing) {
                                  _updateProfile();
                                } else {
                                  setState(() {
                                    _isEditing = true;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE85D75),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
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
                ],
              ),
            ),
    );
  }

  Widget _buildInfoView() {
    return Column(
      children: [
        _infoItem("Nama Lengkap", namaLengkap.isNotEmpty ? namaLengkap : ""),
        const Divider(height: 1, thickness: 0.5, color: Colors.grey),
        _infoItem("Email", email.isNotEmpty ? email : ""),
        const Divider(height: 1, thickness: 0.5, color: Colors.grey),
        _infoItem("Nomor HP", noHp.isNotEmpty ? noHp : ""),
        const Divider(height: 1, thickness: 0.5, color: Colors.grey),
        _infoItem("Alamat", alamat.isNotEmpty ? alamat : ""),
      ],
    );
  }

  Widget _infoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
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
        _editField(_namaController, "Nama Lengkap", Icons.person),
        const Divider(height: 1, thickness: 0.5, color: Colors.grey),
        _editFieldEmail(),
        const Divider(height: 1, thickness: 0.5, color: Colors.grey),
        _editFieldPhone(),
        const Divider(height: 1, thickness: 0.5, color: Colors.grey),
        _editField(_alamatController, "Alamat", Icons.location_on),
        const Divider(height: 1, thickness: 0.5, color: Colors.grey),
        _editPasswordField(),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.blue.shade700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Kosongkan password jika tidak ingin mengubah',
                    style: TextStyle(fontSize: 10, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _editField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: Colors.black87),
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFFE85D75)),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Widget _editFieldEmail() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: const TextStyle(fontSize: 12, color: Colors.black87),
          prefixIcon: const Icon(
            Icons.email,
            size: 18,
            color: Color(0xFFE85D75),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          errorText:
              _emailController.text.isNotEmpty &&
                  !_isValidEmail(_emailController.text)
              ? 'Format email tidak valid'
              : null,
          errorStyle: const TextStyle(fontSize: 10),
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _editFieldPhone() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: _noHpController,
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Nomor HP',
          labelStyle: const TextStyle(fontSize: 12, color: Colors.black87),
          prefixIcon: const Icon(
            Icons.phone,
            size: 18,
            color: Color(0xFFE85D75),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          errorText:
              _noHpController.text.isNotEmpty &&
                  !_isValidPhone(_noHpController.text)
              ? 'Harus angka (10-13 digit), diawali 08, 62, atau +62'
              : null,
          errorStyle: const TextStyle(fontSize: 10),
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _editPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          TextField(
            controller: _passwordController,
            obscureText: !_showPassword,
            decoration: InputDecoration(
              labelText: 'Password Baru',
              labelStyle: const TextStyle(fontSize: 12, color: Colors.black87),
              prefixIcon: const Icon(
                Icons.lock,
                size: 18,
                color: Color(0xFFE85D75),
              ),
              // ============ IKON MATA YANG BENAR ============
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword
                      ? Icons
                            .visibility // Password terlihat → mata normal 👁️
                      : Icons
                            .visibility_off, // Password tersembunyi → mata dicoret 👁️‍🗨️
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              hintText: 'Minimal 6 karakter',
              hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _confirmPasswordController,
            obscureText: !_showConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Konfirmasi Password',
              labelStyle: const TextStyle(fontSize: 12, color: Colors.black87),
              prefixIcon: const Icon(
                Icons.lock_outline,
                size: 18,
                color: Color(0xFFE85D75),
              ),
              // ============ IKON MATA YANG BENAR ============
              suffixIcon: IconButton(
                icon: Icon(
                  _showConfirmPassword
                      ? Icons
                            .visibility // Password terlihat → mata normal 👁️
                      : Icons
                            .visibility_off, // Password tersembunyi → mata dicoret 👁️‍🗨️
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _showConfirmPassword = !_showConfirmPassword;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
