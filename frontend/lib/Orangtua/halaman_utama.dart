import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:si_tumbuh/Orangtua/grafik.dart';
import 'package:si_tumbuh/Orangtua/profil.dart';
import 'package:si_tumbuh/Orangtua/edukasi.dart';

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardContent(),
    const GrafikPage(),
    const Center(child: Text("Jadwal")),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFD86487),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "SiTumbuh",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Icon(Icons.menu, color: Colors.white),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _drawerItem(Icons.home, "Beranda", () {}),
            _drawerItem(Icons.person, "Profil", () {}),
            _drawerItem(Icons.favorite_border, "Cek pertumbuhan", () {}),
            _drawerItem(Icons.trending_up, "Riwayat pertumbuhan", () {}),
            _drawerItem(Icons.calendar_today, "Jadwal posyandu", () {}),
            _drawerItem(Icons.menu_book, "Edukasi", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EdukasiPage()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: text == "Beranda"
              ? Colors.white.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      backgroundColor: const Color(0xFFFFF5F7),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        color: const Color(0xFF8B1E3F),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF8B1E3F),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Pertumbuhan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Jadwal Posyandu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _autoSlide();
  }

  void _autoSlide() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      _currentPage++;
      if (_currentPage > 2) _currentPage = 0;

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      _autoSlide();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFF8B1E3F)),
                    onPressed: () {
                      Scaffold.maybeOf(context)?.openDrawer();
                    },
                  ),
                ),
                const Text(
                  "SiTumbuh",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF8B1E3F),
                  ),
                ),
                const Icon(Icons.notifications_none, color: Color(0xFF8B1E3F)),
              ],
            ),

            const SizedBox(height: 16),

            // BANNER AUTO SLIDE
            SizedBox(
              height: 120,
              child: PageView(
                controller: _pageController,
                children: [
                  _buildBanner(context, 'assets/images/stunting.jpg'),
                  _buildBanner(context, 'assets/images/stunting1.png'),
                  _buildBanner(context, 'assets/images/stunting3.png'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Hallo, Bunda!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Pantau pertumbuhan anak anda",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),

            // CARD DATA ANAK
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE2E7),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Raffi Ahmad",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B1E3F),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Info berat, tinggi, kepala dengan divider
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        InfoItem("Berat", "9.8 kg"),
                        VerticalDivider(color: Color(0xFF8B1E3F), thickness: 1),
                        InfoItem("Tinggi", "74.2 cm"),
                        VerticalDivider(color: Color(0xFF8B1E3F), thickness: 1),
                        InfoItem("L. Kepala", "46.5 cm"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Pemeriksaan Terakhir",
                        style: TextStyle(fontSize: 13),
                      ),
                      Text("04-03-2026", style: TextStyle(fontSize: 13)),
                    ],
                  ),

                  const Divider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Status pertumbuhan anak",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFDB5C7A),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDB5C7A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Cek disini",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // GRAFIK PERTUMBUHAN HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Grafik Pertumbuhan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF8B1E3F),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // CHART
            Container(
              height: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        minY: 5,
                        maxY: 11,
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            axisNameWidget: const Text(
                              'Berat Badan (kg)',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            axisNameSize: 20,
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 3,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineBarsData: [
                          // Zona kuning (bawah)
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
                          // Zona hijau (atas)
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
                          // Garis data anak
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 5.5),
                              FlSpot(3, 6.5),
                              FlSpot(6, 7.8),
                              FlSpot(9, 8.5),
                              FlSpot(12, 9.8),
                            ],
                            isCurved: true,
                            color: const Color(0xFF8B1E3F),
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lihat lainnya
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "Lihat lainnya",
                  style: TextStyle(color: Color(0xFF8B1E3F), fontSize: 13),
                ),
              ),
            ),

            // JADWAL POSYANDU
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE2E7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: const [
                  Icon(Icons.calendar_today, color: Color(0xFF8B1E3F)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Jadwal Kegiatan Posyandu",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Senin, 30 Maret 2026",
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF8B1E3F),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // EDUKASI ORANG TUA
            const Text(
              "Edukasi Orang Tua",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF8B1E3F),
              ),
            ),

            const SizedBox(height: 10),

            // CARD EDUKASI dengan gambar & navigasi ke EdukasiPage
            Row(
              children: [
                Expanded(
                  child: EduCard(
                    imagePath: 'assets/images/stunting.jpg',
                    caption:
                        'Cegah Hambatan Tumbuh Kembang Anak\ndengan Skrining Tumbuh Kembang!',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EdukasiPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: EduCard(
                    imagePath: 'assets/images/stunting2.jpg',
                    caption: '',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EdukasiPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Baca selengkapnya
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EdukasiPage(),
                    ),
                  );
                },
                child: const Text(
                  "Baca selengkapnya",
                  style: TextStyle(color: Color(0xFF8B1E3F), fontSize: 13),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

Widget _buildBanner(BuildContext context, String image) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EdukasiPage()),
      );
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(image, fit: BoxFit.cover, width: double.infinity),
      ),
    ),
  );
}

class InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const InfoItem(this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF8B1E3F),
          ),
        ),
        const Text(
          "Normal",
          style: TextStyle(fontSize: 11, color: Colors.green),
        ),
      ],
    );
  }
}

class EduCard extends StatelessWidget {
  final String imagePath;
  final String caption;
  final VoidCallback? onTap;

  const EduCard({
    super.key,
    required this.imagePath,
    required this.caption,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Gambar
            SizedBox(
              height: 130,
              width: double.infinity,
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
            // Overlay gradient bawah
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: caption.isNotEmpty
                    ? Text(
                        caption,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
