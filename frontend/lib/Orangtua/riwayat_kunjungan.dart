import 'package:flutter/material.dart';
import 'package:si_tumbuh/widgets/bottom_nav.dart';
import 'package:si_tumbuh/widgets/sidebar_menu.dart';

class RiwayatKunjunganPage extends StatefulWidget {
  const RiwayatKunjunganPage({super.key});

  @override
  State<RiwayatKunjunganPage> createState() => _RiwayatKunjunganPageState();
}

class _RiwayatKunjunganPageState extends State<RiwayatKunjunganPage> {
  String selectedFilter = "Semua (Terbaru)";

  final List<String> filterList = ["Semua (Terbaru)", "Terlama"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFF1),

      body: SafeArea(
        child: Column(
          children: [
            // 🔥 HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 100,
              decoration: const BoxDecoration(color: Color(0xFFD86487)),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Riwayat Kunjungan",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      isExpanded: true,
                      items: filterList.map((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(value),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value!;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🔥 BODY (CARD LIST)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF6EFF1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    RiwayatCard(date: "04 Maret 2026"),
                    RiwayatCard(date: "04 Februari 2026"),
                    RiwayatCard(date: "04 Januari 2026"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RiwayatCard extends StatelessWidget {
  final String date;

  const RiwayatCard({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 DATE
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF8B1E3F),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B1E3F),
                  ),
                ),
              ],
            ),
          ),

          // 🔥 CONTENT
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAMA + STATUS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Raffi Ahmad",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text("Laki-laki", style: TextStyle(color: Colors.grey)),
                      ],
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Normal",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 🔥 POSYANDU
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2D7DD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFFD86487),
                      ),
                      SizedBox(width: 6),
                      Text("Posyandu Bukit Kemuning"),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 🔥 DESKRIPSI
                const Text(
                  "Pertumbuhan sesuai usia anak, tetap lanjutkan pola makan dan kontrol rutin.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
