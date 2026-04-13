import 'package:flutter/material.dart';
import 'daftar_akun.dart';
import 'orangtua/halaman_utama.dart';
import 'kader/halaman_utama_kader.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // CONTROLLER
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // DATA USER DUMMY
  final List<Map<String, String>> users = [
    {"email": "siti@email.com", "password": "123456", "role": "ortu"},
    {"email": "kader@email.com", "password": "123456", "role": "kader"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      body: Column(
        children: [
          /// ================= TOP AREA =================
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/logo.png", width: 140),
                  const SizedBox(height: 10),

                  const Text(
                    "SiTumbuh",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE85D75),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Pantau tumbuh kembang\nanak dengan mudah",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          /// ================= LOGIN CARD =================
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),

              child: Column(
                children: [
                  /// EMAIL
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined),
                      hintText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// PASSWORD
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: const Icon(Icons.visibility_off),
                      hintText: "Kata Sandi",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  /// BUTTON LOGIN
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
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();

                        var user = users.firstWhere(
                          (u) =>
                              u["email"] == email && u["password"] == password,
                          orElse: () => {},
                        );

                        if (user.isNotEmpty) {
                          if (user["role"] == "ortu") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HalamanUtama(),
                              ),
                            );
                          } else if (user["role"] == "kader") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HalamanUtamaKader(),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Email atau password salah"),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// DAFTAR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Belum punya akun?"),

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
                          " Daftar",
                          style: TextStyle(
                            color: Color(0xFFE85D75),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
