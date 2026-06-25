import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import 'login.dart';

class DaftarAkunPage extends StatefulWidget {
  const DaftarAkunPage({super.key});

  @override
  State<DaftarAkunPage> createState() => _DaftarAkunPageState();
}

class _DaftarAkunPageState extends State<DaftarAkunPage> {
  int step = 1;

  DateTime? tanggalLahir;
  String gender = "";
  bool _isLoading = false;

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final telpController = TextEditingController();
  final passwordController = TextEditingController();
  final alamatController = TextEditingController();

  final namaAnakController = TextEditingController();

  // ===== VALIDATION =====
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email harus diisi';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'No telepon harus diisi';
    if (value.length < 10 || value.length > 15) {
      return 'No telepon harus 10-15 digit';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Kata sandi harus diisi';
    if (value.length < 6) return 'Kata sandi minimal 6 karakter';
    return null;
  }

  Future<void> register() async {
    // Validasi sebelum register
    if (tanggalLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal lahir anak'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih jenis kelamin anak'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.post('/register', {
        "nama_orangtua": namaController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "alamat": alamatController.text,
        "no_telp": telpController.text,
        "nama_anak": namaAnakController.text,
        "tanggal_lahir": tanggalLahir!.toIso8601String().split('T').first,
        "jenis_kelamin": gender,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data["success"] == true) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Registrasi berhasil! Silakan login.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${data['message'] ?? 'Registrasi gagal'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (response.statusCode == 422 && data['errors'] != null) {
          String errorMsg = '';
          data['errors'].forEach((key, value) {
            errorMsg += '$key: ${value.join(', ')}\n';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Validasi gagal:\n$errorMsg'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${data['message'] ?? 'Registrasi gagal'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF3A2A2D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Daftar Akun",
          style: TextStyle(
            color: Color(0xFF3A2A2D),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== STEP INDICATOR =====
              Row(
                children: [
                  _buildStepIndicator(1, "Data Orang Tua", step == 1),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: step == 1
                          ? const Color(0xFFE85D75)
                          : Colors.grey.shade300,
                    ),
                  ),
                  _buildStepIndicator(2, "Data Anak", step == 2),
                ],
              ),
              const SizedBox(height: 24),

              // ===== FORM =====
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: step == 1 ? _buildStep1() : _buildStep2(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== STEP INDICATOR =====
  Widget _buildStepIndicator(int number, String label, bool isActive) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFE85D75) : Colors.grey.shade300,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF3A2A2D) : Colors.grey.shade500,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ===== STEP 1: DATA ORANG TUA =====
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Data Orang Tua",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF3A2A2D),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Isi data diri Anda sebagai orang tua",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 20),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildInputField(
                  controller: namaController,
                  icon: Icons.person_outline,
                  label: "Nama Lengkap",
                  hint: "Masukkan nama lengkap Anda",
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Nama harus diisi' : null,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: emailController,
                  icon: Icons.email_outlined,
                  label: "Email",
                  hint: "contoh@email.com",
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: telpController,
                  icon: Icons.phone_outlined,
                  label: "No Telepon",
                  hint: "081234567890",
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: passwordController,
                  icon: Icons.lock_outline,
                  label: "Kata Sandi",
                  hint: "Minimal 6 karakter",
                  obscure: true,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: alamatController,
                  icon: Icons.location_on_outlined,
                  label: "Alamat",
                  hint: "Masukkan alamat lengkap",
                  maxLines: 2,
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Alamat harus diisi' : null,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // ===== BUTTON =====
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85D75),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              // Validasi sederhana
              if (namaController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  passwordController.text.isEmpty ||
                  alamatController.text.isEmpty ||
                  telpController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua data orang tua harus diisi!'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              setState(() {
                step = 2;
              });
            },
            child: const Text(
              "Lanjut",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLoginLink(),
      ],
    );
  }

  // ===== STEP 2: DATA ANAK =====
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Data Anak",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF3A2A2D),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Isi data anak Anda untuk pemantauan tumbuh kembang",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 20),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildInputField(
                  controller: namaAnakController,
                  icon: Icons.child_care_outlined,
                  label: "Nama Anak",
                  hint: "Masukkan nama anak Anda",
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Nama anak harus diisi' : null,
                ),
                const SizedBox(height: 16),

                // ===== DATE PICKER =====
                _buildDatePicker(),
                const SizedBox(height: 16),

                // ===== GENDER SELECTOR =====
                _buildGenderSelector(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // ===== BUTTON =====
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85D75),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _isLoading ? null : register,
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "Daftar",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLoginLink(),
      ],
    );
  }

  // ===== DATE PICKER =====
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
          firstDate: DateTime(2018),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFE85D75),
                onPrimary: Colors.white,
                onSurface: Color(0xFF3A2A2D),
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() {
            tanggalLahir = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFFE85D75),
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                tanggalLahir == null
                    ? "Pilih Tanggal Lahir Anak"
                    : _formatDate(tanggalLahir!),
                style: TextStyle(
                  color: tanggalLahir == null
                      ? Colors.grey.shade500
                      : Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
            if (tanggalLahir != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    tanggalLahir = null;
                  });
                },
                child: const Icon(Icons.close, color: Colors.grey, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ===== GENDER SELECTOR =====
  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Jenis Kelamin",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF3A2A2D),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _genderButton("Laki-laki", Icons.male, Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _genderButton("Perempuan", Icons.female, Colors.pink),
            ),
          ],
        ),
      ],
    );
  }

  Widget _genderButton(String text, IconData icon, Color color) {
    bool selected = gender == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          gender = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? color : Colors.grey.shade500,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: selected ? color : Colors.grey.shade700,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                fontSize: 15,
              ),
            ),
            if (selected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFFE85D75),
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===== INPUT FIELD =====
  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF3A2A2D),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFE85D75), size: 20),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE85D75),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  // ===== LOGIN LINK =====
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Sudah punya akun?",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: const Text(
            " Login",
            style: TextStyle(
              color: Color(0xFFE85D75),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
