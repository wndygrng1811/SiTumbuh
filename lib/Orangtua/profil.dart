import 'package:flutter/material.dart';
import 'package:si_tumbuh/Orangtua/halaman_utama.dart';
import 'package:si_tumbuh/orangtua/edit_profil.dart';
import 'package:si_tumbuh/widgets/bottom_nav.dart';
import 'package:si_tumbuh/widgets/sidebar_menu.dart';
import 'package:si_tumbuh/orangtua/data_anak.dart';
import 'package:si_tumbuh/orangtua/profil_lengkap.dart';
import 'package:si_tumbuh/orangtua/riwayat_kunjungan.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarMenu(),
      backgroundColor: const Color(0xFFF6F6F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFFE85D75),
        elevation: 0,
        title: const Text("SiTumbuh"),
        centerTitle: true,

        /// TOMBOL KEMBALI
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER PROFIL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFE85D75),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: const [
                  SizedBox(height: 20),

                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.pink),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Aisyah Ramadhani",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "aisyah@gmail.com",
                    style: TextStyle(color: Colors.white70),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "No Hp : 081234567890",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// TOMBOL UBAH PROFIL
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE85D75),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilOrangtua(),
                  ),
                );
              },
              child: const Text("Ubah Profil"),
            ),

            const SizedBox(height: 20),

            /// CARD DATA ANAK
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(blurRadius: 5, color: Colors.black12),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Profil Anak",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Normal",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Text("Raffi Ahmad"),
                  const Text("Laki-laki"),

                  const SizedBox(height: 10),

                  const Text("Tanggal lahir : 18 April 2026"),
                  const Text("Berat badan ketika lahir : 3.8 kg"),
                  const Text("Tinggi badan ketika lahir : 52 cm"),
                  const Text("Lingkar kepala ketika lahir : 46 cm"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// MENU
            menuItem(
              context,
              "Profil lengkap",
              page: const ProfilLengkapPage(),
            ),

            menuItem(context, "Data anak", page: const DataAnakPage()),

            menuItem(
              context,
              "Riwayat kunjungan",
              page: const RiwayatKunjunganPage(),
            ),

            const SizedBox(height: 20),

            /// TOMBOL KELUAR (LOGOUT)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D2C36),
                padding: const EdgeInsets.symmetric(
                  horizontal: 80,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HalamanUtama()),
                  (route) => false,
                );
              },
              child: const Text("Keluar"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: const BottomNav(currentIndex: 3),
    );
  }

  Widget menuItem(BuildContext context, String title, {Widget? page}) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
    );
  }
}
