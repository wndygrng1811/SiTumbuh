import 'package:flutter/material.dart';

// IMPORT HALAMAN
import 'package:si_tumbuh/Kader/halaman_utama_kader.dart';
import 'package:si_tumbuh/Kader/data_anak.dart'; // 🔥 FIX
import 'package:si_tumbuh/Kader/jadwal.dart';
import 'package:si_tumbuh/Kader/profil.dart';

class BottomNavbarKader extends StatelessWidget {
  final int selectedIndex;

  const BottomNavbarKader({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF7A1C2E),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            item(
              context,
              Icons.home_outlined,
              "Beranda",
              0,
              const HalamanUtamaKader(),
            ),

            /// 🔥 DATA ANAK (SUDAH BENAR SEKARANG)
            item(
              context,
              Icons.groups_outlined,
              "Data anak",
              1,
              const DataAnakPage(),
            ),

            /// 🔥 POSYANDU (KE HALAMAN JADWAL)
            item(
              context,
              Icons.calendar_month_outlined,
              "Posyandu",
              2,
              const Jadwal(),
            ),

            item(context, Icons.person_outline, "Profil", 3, const Profil()),
          ],
        ),
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
          Icon(icon, size: 26, color: active ? Colors.white : Colors.white70),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontSize: 11,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
