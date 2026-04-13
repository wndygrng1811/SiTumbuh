import 'package:flutter/material.dart';

// IMPORT HALAMAN
import 'package:si_tumbuh/Kader/halaman_utama_kader.dart';
import 'package:si_tumbuh/Kader/jadwal.dart';
import 'package:si_tumbuh/Kader/kehadiran.dart';
import 'package:si_tumbuh/Kader/profil.dart';

class SidebarKader extends StatelessWidget {
  const SidebarKader({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          /// ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFFE85D75),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.grey),
                ),
                SizedBox(height: 10),
                Text(
                  "Kader Siti",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "kader@email.com",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          /// ================= MENU =================
          Expanded(
            child: ListView(
              children: [
                menu(
                  context,
                  Icons.dashboard,
                  "Dashboard",
                  const HalamanUtamaKader(),
                ),
                menu(context, Icons.event, "Jadwal Posyandu", const Jadwal()),
                menu(
                  context,
                  Icons.check_circle,
                  "Kehadiran",
                  const Kehadiran(),
                ),
                menu(context, Icons.person, "Profil", const Profil()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ================= FUNCTION MENU =================
  Widget menu(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),

      onTap: () {
        Navigator.pop(context); // tutup sidebar

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
