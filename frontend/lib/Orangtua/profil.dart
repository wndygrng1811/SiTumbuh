import 'package:flutter/material.dart';
import 'package:si_tumbuh/Orangtua/profil_lengkap.dart';
import 'package:si_tumbuh/Orangtua/riwayat_kunjungan.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD86487),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 10,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(Icons.menu, color: Colors.white),
                        Text(
                          "SiTumbuh",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Icon(Icons.notifications_none, color: Colors.white),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: -45,
                    left: 0,
                    right: 0,
                    child: const Center(
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Color(0xFF7A1C2E),
                        child: Icon(
                          Icons.person,
                          size: 45,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // USER INFO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: const [
                    Text(
                      "Aisyah Ramadhani",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF5A2A2A),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "aisyah@gmail.com",
                      style: TextStyle(
                        color: Color(0xFFD86487),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "No Hp : 081234567890",
                      style: TextStyle(
                        color: Color(0xFF7A1C2E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _profilAnak(),

              const SizedBox(height: 16),

              _menu(context, "Profil lengkap", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilLengkapPage()),
                );
              }),
              _menu(context, "Data anak", () {}),
              _menu(context, "Riwayat kunjungan", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RiwayatKunjunganPage(),
                  ),
                );
              }),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Text(
                      "Informasi Privasi",
                      style: TextStyle(
                        color: Color(0xFF7A1C2E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Syarat & Ketentuan",
                      style: TextStyle(
                        color: Color(0xFF7A1C2E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A1E28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                  child: Text(
                    "Keluar",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _profilAnak() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Profil Anak",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF7A1C2E),
            ),
          ),
          const Divider(color: Color(0xFFF0C4D0)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Raffi Ahmad",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text("Laki-laki", style: TextStyle(color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade300, width: 0.5),
                ),
                child: const Text(
                  "Normal",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Tanggal lahir : 18 April 2026"),
          const Text("Berat badan ketika lahir : 3.8 kg"),
          const Text("Tinggi badan ketika lahir : 52 cm"),
          const Text("Lingkar kepala ketika lahir : 46 cm"),
        ],
      ),
    );
  }

  Widget _menu(BuildContext context, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFD86487),
            ),
          ],
        ),
      ),
    );
  }
}
