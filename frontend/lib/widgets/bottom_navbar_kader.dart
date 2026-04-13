import 'package:flutter/material.dart';

// IMPORT HALAMAN
import 'package:si_tumbuh/Kader/halaman_utama_kader.dart';
import 'package:si_tumbuh/Kader/jadwal.dart';
import 'package:si_tumbuh/Kader/kehadiran.dart';
import 'package:si_tumbuh/Kader/profil.dart';

class BottomNavbarKader extends StatelessWidget {
  final int selectedIndex;

  const BottomNavbarKader({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: const BoxDecoration(color: Color(0xFF8B1E3F)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          item(context, Icons.home, "Beranda", 0, const HalamanUtamaKader()),
          item(context, Icons.event, "Jadwal", 1, const Jadwal()),
          item(context, Icons.check_circle, "Kehadiran", 2, const Kehadiran()),
          item(context, Icons.person, "Profil", 3, const Profil()),
        ],
      ),
    );
  }

  Widget item(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    Widget page,
  ) {
    bool active = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (!active) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? Colors.white : Colors.white70),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
