import 'package:flutter/material.dart';
import '../widgets/sidebar_kader.dart';
import 'buat_jadwal.dart';
import '../widgets/bottom_navbar_kader.dart';

class Jadwal extends StatefulWidget {
  const Jadwal({super.key});

  @override
  State<Jadwal> createState() => _JadwalState();
}

class _JadwalState extends State<Jadwal> {
  int selectedTab = 0; // 0 = akan datang, 1 = selesai

  // 🔥 TAMBAHAN DATA DUMMY
  final List<Map<String, String>> jadwalList = [
    {
      "nama": "Posyandu Melati",
      "tanggal": "Rabu, 05 Juli 2024",
      "jam": "08.00-11.00",
      "alamat": "Jl. Sejahtera RT 03 RW 06",
      "poster": "assets/templatekuning.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 1),
      drawer: const SidebarKader(),
      backgroundColor: const Color(0xFFF6F6F6),

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
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Icon(Icons.notifications_none, color: Colors.white),
                  ],
                ),

                const SizedBox(height: 15),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Jadwal Posyandu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Kader dapat membuat dan membagikan jadwal posyandu\nmenggunakan poster melalui WhatsApp",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TEMPLATE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Template Poster Posyandu",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Lihat semua", style: TextStyle(color: Colors.pink)),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      templateCard("Tema Kuning"),
                      const SizedBox(width: 10),
                      templateCard("Tema Biru"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// TAB
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        tabItem("Akan datang (2)", 0),
                        tabItem("Selesai", 1),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// LIST JADWAL
                  jadwalCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= TEMPLATE CARD =================
  Widget templateCard(String title) {
    String image = title == "Tema Kuning"
        ? "assets/templatekuning.jpg"
        : "assets/templatebiru.jpg";

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(image, height: 100, fit: BoxFit.cover),
            ),
            const SizedBox(height: 10),
            Text(title),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {
                // 🔥 NAVIGASI KE HALAMAN BUAT JADWAL
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BuatJadwalPage(template: image),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE85D75),
                minimumSize: const Size(double.infinity, 30),
              ),
              child: const Text("Pilih"),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= TAB =================
  Widget tabItem(String text, int index) {
    bool active = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE85D75) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: active ? Colors.white : Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  /// ================= JADWAL CARD =================
  Widget jadwalCard() {
    var data = jadwalList[0];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          /// POSTER
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              data["poster"]!,
              width: 70,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 10),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["nama"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(data["tanggal"]!, style: const TextStyle(fontSize: 12)),
                Text(data["jam"]!, style: const TextStyle(fontSize: 12)),
                Text(data["alamat"]!, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),

          /// BUTTON WA
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Bagikan"),
          ),
        ],
      ),
    );
  }
}
