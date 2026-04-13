import 'package:flutter/material.dart';
import '../widgets/sidebar_kader.dart';

class HalamanUtamaKader extends StatelessWidget {
  const HalamanUtamaKader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarKader(),
      backgroundColor: const Color(0xFFF5F5F5),

      body: Column(
        children: [
          /// ================= HEADER =================
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFE85D75),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                /// TOP BAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// MENU
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),

                    const Text(
                      "SiTumbuh",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Row(
                      children: const [
                        Icon(Icons.notifications_none, color: Colors.white),
                        SizedBox(width: 10),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Kader sehat, anak sehat!",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 10),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Selamat Pagi, Kader Siti",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          /// ================= CONTENT =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  /// GRID CARD (🔥 FIX TANPA CONST)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      InfoCard(
                        title: "150 Anak",
                        icon: Icons.child_care,
                        color: Colors.orange,
                      ),
                      InfoCard(
                        title: "75 Orang Tua",
                        icon: Icons.family_restroom,
                        color: Colors.blue,
                      ),
                      InfoCard(
                        title: "95 Pemantauan",
                        icon: Icons.favorite,
                        color: Colors.teal,
                      ),
                      InfoCard(
                        title: "120 Kehadiran",
                        icon: Icons.assignment,
                        color: Colors.indigo,
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// JADWAL
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(blurRadius: 5, color: Colors.grey.shade300),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Jadwal Posyandu Terdekat",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("4 Mei 2026"),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 18),
                            SizedBox(width: 5),
                            Text("08.00 - 12.00 WIB"),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 18),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "Fasum Bukit Kemuning, Blok A\nPenimbangan, Pengukuran, Imunisasi",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// RINGKASAN
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Column(
                      children: [
                        SizedBox(height: 10),
                        Text(
                          "128 Anak",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("Ringkasan Pertumbuhan Anak Bulan April"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= INFO CARD =================
class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 35),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
