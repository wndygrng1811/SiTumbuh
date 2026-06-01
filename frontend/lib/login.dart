import 'package:si_tumbuh/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'Orangtua/halaman_utama.dart';
import 'kader/halaman_utama_kader.dart';
import 'daftar_akun.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isHidden = true;

  // 🔥 TAMBAHAN
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> handleLoginFixed() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    print('Mencoba login dengan: $email / $password');

    final result = await ApiService.login(email, password);

    print('Hasil login: $result');

    if (result['success'] == true) {
      if (result['role'] == 'orang_tua') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HalamanUtama()),
        );
      } else if (result['role'] == 'kader') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HalamanUtamaKader()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Login gagal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),

      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', width: 150),
                      const SizedBox(height: 16),
                      const Text(
                        "SiTumbuh",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE95A7B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Pantau tumbuh kembang\nanak dengan mudah",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                //  FORM
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // EMAIL
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "Email",
                          prefixIcon: const Icon(Icons.email),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFF7A1C2E),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFFE95A7B),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // PASSWORD
                      TextField(
                        controller: passwordController,
                        obscureText: isHidden,
                        decoration: InputDecoration(
                          hintText: "Kata Sandi",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                isHidden = !isHidden;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFF7A1C2E),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFFE95A7B),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // BUTTON LOGIN
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: handleLoginFixed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD86487),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // REGISTER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Belum punya akun? ",
                            style: TextStyle(color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DaftarAkunPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Daftar",
                              style: TextStyle(
                                color: Color(0xFFE95A7B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
