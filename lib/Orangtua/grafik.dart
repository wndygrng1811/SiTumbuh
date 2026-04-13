import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:si_tumbuh/widgets/bottom_nav.dart';
import 'package:si_tumbuh/widgets/sidebar_menu.dart';

class GrafikPage extends StatefulWidget {
  const GrafikPage({super.key});

  @override
  State<GrafikPage> createState() => _GrafikPageState();
}

class _GrafikPageState extends State<GrafikPage> {
  int selectedTabIndex = 0;

  String selectedAnak = "Raffi Ahmad";

  final List<String> anakList = ["Raffi Ahmad", "Budi Santoso", "Siti Aisyah"];

  Widget _tabClick(String text, int index) {
    final active = selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTabIndex = index;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFD86487) : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFF1),

      // 🔥 SIDEBAR
      drawer: const SidebarMenu(),

      // 🔥 NAVBAR BAWAH
      bottomNavigationBar: const BottomNav(currentIndex: 1),

      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Color(0xFF76172D)),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  const Text(
                    "SiTumbuh",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF76172D),
                    ),
                  ),
                  const Icon(
                    Icons.notifications_none,
                    color: Color(0xFF76172D),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  /// DROPDOWN ANAK
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedAnak,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 13),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                        items: anakList.map((String value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedAnak = value!;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// TAB BERAT / TINGGI / KEPALA
                  Row(
                    children: [
                      _tabClick("Berat", 0),
                      _tabClick("Tinggi", 1),
                      _tabClick("L. Kepala", 2),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// CARD GRAFIK
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2E4E8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Grafik Pertumbuhan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF76172D),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// GRAFIK
                        SizedBox(
                          height: 180,
                          child: LineChart(
                            LineChartData(
                              minY: 5,
                              maxY: 11,
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 3,
                                  ),
                                ),
                              ),
                              lineBarsData: [
                                /// AREA KUNING
                                LineChartBarData(
                                  spots: const [
                                    FlSpot(0, 5),
                                    FlSpot(3, 6),
                                    FlSpot(6, 7),
                                    FlSpot(9, 7.5),
                                    FlSpot(12, 8),
                                  ],
                                  isCurved: true,
                                  barWidth: 0,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.yellow.withOpacity(0.6),
                                  ),
                                ),

                                /// AREA HIJAU
                                LineChartBarData(
                                  spots: const [
                                    FlSpot(0, 6),
                                    FlSpot(3, 7),
                                    FlSpot(6, 8),
                                    FlSpot(9, 9),
                                    FlSpot(12, 10),
                                  ],
                                  isCurved: true,
                                  barWidth: 0,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.green.withOpacity(0.4),
                                  ),
                                ),

                                /// GARIS ANAK
                                LineChartBarData(
                                  spots: const [
                                    FlSpot(0, 5.5),
                                    FlSpot(3, 6.5),
                                    FlSpot(6, 7.8),
                                    FlSpot(9, 8.5),
                                    FlSpot(12, 9.8),
                                  ],
                                  isCurved: true,
                                  color: Color(0xFF76172D),
                                  barWidth: 3,
                                  dotData: FlDotData(show: true),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// STATUS
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD86487),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                "Status: Normal ",
                                style: TextStyle(color: Colors.white),
                              ),
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 18,
                              ),
                              Text(
                                " Sesuai usia anak",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// RIWAYAT
                  const Text(
                    "Riwayat Pertumbuhan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF76172D),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _card("04 Maret 2026", "9.8 kg", "74.2 cm", "46.5 cm"),
                  _card("04 Februari 2026", "8.5 kg", "72 cm", "45 cm"),
                  _card("04 Januari 2026", "7 kg", "68 cm", "44.5 cm"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CARD RIWAYAT
  static Widget _card(String date, String berat, String tinggi, String kepala) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text("Berat: $berat     Tinggi: $tinggi"),
          Text("L. Kepala: $kepala"),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("Normal"),
            ),
          ),
        ],
      ),
    );
  }
}
