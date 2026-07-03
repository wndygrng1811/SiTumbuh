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
  bool _obscurePassword = true;

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final telpController = TextEditingController();
  final passwordController = TextEditingController();
  final alamatController = TextEditingController();

  final namaAnakController = TextEditingController();

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  // ===== VALIDASI =====

  String? _validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName harus diisi';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email harus diisi';
    }

    // Cek format email sederhana: harus ada @ dan domain
    if (!value.contains('@') || !value.contains('.')) {
      return 'Format email tidak valid (contoh: email@domain.com)';
    }

    // Cek apakah ada karakter setelah @ dan setelah .
    final emailParts = value.trim().split('@');
    if (emailParts.length != 2) {
      return 'Format email tidak valid';
    }

    final localPart = emailParts[0];
    final domainPart = emailParts[1];

    if (localPart.isEmpty) {
      return 'Bagian sebelum @ tidak boleh kosong';
    }

    if (domainPart.isEmpty || !domainPart.contains('.')) {
      return 'Domain email tidak valid (contoh: .com, .co.id)';
    }

    final domainParts = domainPart.split('.');
    if (domainParts.length < 2) {
      return 'Domain email tidak valid (contoh: .com, .co.id)';
    }

    final tld = domainParts.last;
    if (tld.length < 2) {
      return 'Domain email tidak valid';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon harus diisi';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Nomor telepon hanya boleh berisi angka';
    }
    if (value.length < 10) {
      return 'Nomor telepon minimal 10 digit';
    }
    if (!value.startsWith('08')) {
      return 'Nomor telepon harus diawali dengan 08';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi harus diisi';
    }
    if (value.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }
    return null;
  }

  String? _validateAlamat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Alamat harus diisi';
    }
    return null;
  }

  String? _validateTanggalLahir(DateTime? value) {
    if (value == null) {
      return 'Tanggal lahir harus diisi';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (value.isAfter(today)) {
      return 'Tanggal lahir tidak boleh melebihi hari ini';
    }
    return null;
  }

  Future<void> register() async {
    if (!_formKey2.currentState!.validate()) {
      return;
    }

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
        "nama_orangtua": namaController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text,
        "alamat": alamatController.text.trim(),
        "no_telp": telpController.text.trim(),
        "nama_anak": namaAnakController.text.trim(),
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
    return Form(
      key: _formKey1,
      child: Column(
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
                    validator: (v) => _validateName(v, 'Nama orang tua'),
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
                    obscure: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: Colors.grey.shade400,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: alamatController,
                    icon: Icons.location_on_outlined,
                    label: "Alamat",
                    hint: "Masukkan alamat lengkap",
                    maxLines: 2,
                    validator: _validateAlamat,
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
                if (_formKey1.currentState!.validate()) {
                  setState(() {
                    step = 2;
                  });
                }
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
      ),
    );
  }

  // ===== STEP 2: DATA ANAK =====
  Widget _buildStep2() {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFFE85D75),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    step = 1;
                  });
                },
              ),
              const SizedBox(width: 8),
              const Text(
                "Data Anak",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF3A2A2D),
                ),
              ),
            ],
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
                    validator: (v) => _validateName(v, 'Nama anak'),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLoginLink(),
        ],
      ),
    );
  }

  // ===== DATE PICKER =====
  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tanggal Lahir",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF3A2A2D),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: today.subtract(const Duration(days: 365 * 2)),
              firstDate: DateTime(2018),
              lastDate: today,
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFFE85D75),
                    onPrimary: Colors.white,
                    onSurface: Color(0xFF3A2A2D),
                  ),
                  dialogTheme: const DialogThemeData(
                    backgroundColor: Colors.white,
                  ),
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
              border: Border.all(
                color: tanggalLahir == null
                    ? Colors.grey.shade300
                    : const Color(0xFFE85D75),
                width: tanggalLahir == null ? 1.5 : 2,
              ),
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
                    child: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (tanggalLahir != null && _validateTanggalLahir(tanggalLahir) != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              _validateTanggalLahir(tanggalLahir)!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
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
        if (gender.isEmpty && step == 2)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: const Text(
              'Silakan pilih jenis kelamin',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _genderButton(String text, IconData icon, Color color) {
    bool selected = gender == text;

    return Expanded(
      child: GestureDetector(
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
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  color: selected ? color : Colors.grey.shade700,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.check_circle,
                    color: Color(0xFFE85D75),
                    size: 16,
                  ),
                ),
            ],
          ),
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
    Widget? suffixIcon,
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
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFE85D75), size: 20),
            suffixIcon: suffixIcon,
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
