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

      print('📡 Register Response Status: ${response.statusCode}');
      print('📦 Register Response Body: ${response.body}');

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
      print("❌ REGISTER ERROR : $e");
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
      backgroundColor: const Color(0xFFFFF5F7),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("Daftar Akun", style: TextStyle(color: Colors.black)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Langkah $step dari 2",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: step == 1 ? 0.5 : 1,
              color: const Color(0xFFE85D75),
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: step == 1 ? step1() : step2(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Data Orang Tua",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),
        _buildInput(Icons.person, "Nama Lengkap", controller: namaController),
        const SizedBox(height: 12),
        _buildInput(Icons.email, "Email", controller: emailController),
        const SizedBox(height: 12),
        _buildInput(Icons.phone, "No telepon", controller: telpController),
        const SizedBox(height: 12),
        _buildInput(
          Icons.lock,
          "Kata Sandi",
          obscure: true,
          controller: passwordController,
        ),
        const SizedBox(height: 12),
        _buildInput(Icons.location_on, "Alamat", controller: alamatController),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85D75),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
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
            child: const Text("Lanjut"),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Sudah punya akun?"),
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
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Data Anak",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),
        _buildInput(
          Icons.child_care,
          "Nama Anak",
          controller: namaAnakController,
        ),
        const SizedBox(height: 12),

        /// DATE PICKER
        GestureDetector(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2022),
              firstDate: DateTime(2018),
              lastDate: DateTime.now(),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFFE85D75),
                    onPrimary: Colors.white,
                    onSurface: Color(0xFF2D2D2D),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Color(0xFFE85D75)),
                const SizedBox(width: 10),
                Text(
                  tanggalLahir == null
                      ? "Pilih Tanggal Lahir Anak"
                      : "${tanggalLahir!.day}-${tanggalLahir!.month}-${tanggalLahir!.year}",
                  style: TextStyle(
                    color: tanggalLahir == null ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(child: _genderButton("Laki-laki")),
            const SizedBox(width: 10),
            Expanded(child: _genderButton("Perempuan")),
          ],
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85D75),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _isLoading ? null : register,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text("Daftar"),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Sudah punya akun?"),
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
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInput(
    IconData icon,
    String hint, {
    bool obscure = false,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFE85D75)),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE85D75), width: 1.5),
        ),
      ),
    );
  }

  Widget _genderButton(String text) {
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
          color: selected ? const Color(0xFFE85D75) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE85D75)),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFFE85D75),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
