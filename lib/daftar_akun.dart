import 'package:flutter/material.dart';
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
            /// PROGRESS BAR
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

            /// CARD
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

  /// ===============================
  /// STEP 1 DATA ORANG TUA
  /// ===============================

  Widget step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Data Orang Tua",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        const SizedBox(height: 20),

        input(Icons.person, "Nama Lengkap"),

        const SizedBox(height: 12),

        input(Icons.email, "Email"),

        const SizedBox(height: 12),

        input(Icons.phone, "No telepon"),

        const SizedBox(height: 12),

        input(Icons.lock, "Kata Sandi", obscure: true),

        const SizedBox(height: 12),

        input(Icons.location_on, "Alamat"),

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
                  MaterialPageRoute(builder: (context) => LoginPage()),
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

  /// ===============================
  /// STEP 2 DATA ANAK
  /// ===============================

  Widget step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Data Anak",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        const SizedBox(height: 20),

        input(Icons.child_care, "Nama Anak"),

        const SizedBox(height: 12),

        /// DATE PICKER
        GestureDetector(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2022),
              firstDate: DateTime(2018),
              lastDate: DateTime.now(),
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
                const Icon(Icons.calendar_month),

                const SizedBox(width: 10),

                Text(
                  tanggalLahir == null
                      ? "Pilih Tanggal"
                      : "${tanggalLahir!.day}-${tanggalLahir!.month}-${tanggalLahir!.year}",
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 15),

        /// GENDER
        Row(
          children: [
            Expanded(child: genderButton("Laki-laki")),

            const SizedBox(width: 10),

            Expanded(child: genderButton("Perempuan")),
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

            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },

            child: const Text("Daftar"),
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
                  MaterialPageRoute(builder: (context) => LoginPage()),
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

  /// ===============================
  /// INPUT FIELD
  /// ===============================

  Widget input(IconData icon, String hint, {bool obscure = false}) {
    return TextField(
      obscureText: obscure,

      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  /// ===============================
  /// GENDER BUTTON
  /// ===============================

  Widget genderButton(String text) {
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
