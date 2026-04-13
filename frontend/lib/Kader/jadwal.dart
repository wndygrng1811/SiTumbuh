import 'package:flutter/material.dart';
import '../widgets/sidebar_kader.dart';

class Jadwal extends StatefulWidget {
  const Jadwal({super.key});

  @override
  State<Jadwal> createState() => _JadwalState();
}

class _JadwalState extends State<Jadwal> {
  int selectedTab = 0; // 0 = akan datang, 1 = selesai

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: Text("Poster")),
            ),
            const SizedBox(height: 10),
            Text(title),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {},
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
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          /// POSTER
          Container(
            width: 70,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.orange.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Text("Poster")),
          ),

          const SizedBox(width: 10),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Posyandu Melati",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 5),

                Text("Rabu, 05 Juli 2024", style: TextStyle(fontSize: 12)),

                Text("08.00 - 12.00", style: TextStyle(fontSize: 12)),

                Text(
                  "Jl. Sejahtera No 123 RW 05",
                  style: TextStyle(fontSize: 12),
                ),
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
