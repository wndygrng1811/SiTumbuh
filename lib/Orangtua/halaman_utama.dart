import 'dart:async';
import 'package:flutter/material.dart';
import 'package:si_tumbuh/widgets/bottom_nav.dart';
import 'package:si_tumbuh/widgets/sidebar_menu.dart';
import 'package:si_tumbuh/orangtua/cek_pertumbuhan.dart';
import 'package:si_tumbuh/orangtua/grafik.dart';
import 'package:si_tumbuh/orangtua/edukasi.dart';
import 'package:si_tumbuh/orangtua/riwayat_kunjungan.dart';

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  final PageController _bannerController = PageController();
  int bannerIndex = 0;
  Timer? timer;

  final List<String> banners = [
    "assets/banner1.jpg",
    "assets/banner2.jpg",
    "assets/banner3.jpg",
  ];

  /// DATA DUMMY ANAK
  double umur = 12; // bulan
  double berat = 9.8; // kg

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_bannerController.hasClients) {
        if (bannerIndex < banners.length - 1) {
          bannerIndex++;
        } else {
          bannerIndex = 0;
        }

        _bannerController.animateToPage(
          bannerIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarMenu(),
      backgroundColor: const Color(0xFFF7F7F7),

      /// ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "SiTumbuh",
          style: TextStyle(
            color: Color(0xFFE85D75),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      /// ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= BANNER =================
            SizedBox(
              height: 150,
              child: PageView.builder(
                controller: _bannerController,
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      image: DecorationImage(
                        image: AssetImage(banners[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            /// ================= SAPAAN =================
            const Text(
              "Hallo, Bunda!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const Text(
              "Pantau pertumbuhan anak anda",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),

            /// ================= CARD DATA ANAK =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE4E8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Raffi Ahmad",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _Data("Berat", "9.8 kg"),
                      _Data("Tinggi", "74.2 cm"),
                      _Data("L. Kepala", "46.5 cm"),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Status pertumbuhan anak"),

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
                              builder: (context) => const CekPertumbuhanPage(),
                            ),
                          );
                        },
                        child: const Text("Cek disini"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// ================= GRAFIK PERTUMBUHAN =================
            const Text(
              "Grafik Pertumbuhan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Container(
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFFBE4E8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: GrafikKMS(umur: umur, berat: berat),
              ),
            ),

            const SizedBox(height: 25),

            /// ================= JADWAL POSYANDU =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE4E8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: const [
                  Icon(Icons.calendar_month),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Jadwal Kegiatan Posyandu\nSenin, 30 Maret 2026",
                    ),
                  ),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// ================= EDUKASI =================
            const Text(
              "Edukasi Orang Tua",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  edukasiCard("assets/edu1.jpg"),
                  edukasiCard("assets/edu2.jpg"),
                  edukasiCard("assets/edu3.jpg"),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget edukasiCard(String image) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
    );
  }
}

/// ================= DATA ANAK =================
class _Data extends StatelessWidget {
  final String title;
  final String value;

  const _Data(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        const Text("Normal", style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// ================= WIDGET GRAFIK =================
class GrafikKMS extends StatelessWidget {
  final double umur;
  final double berat;

  const GrafikKMS({super.key, required this.umur, required this.berat});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GrafikPainter(umur, berat),
      size: Size.infinite,
    );
  }
}

class GrafikPainter extends CustomPainter {
  final double umur;
  final double berat;

  GrafikPainter(this.umur, this.berat);

  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;

    Paint grid = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    for (int i = 0; i <= 6; i++) {
      double y = height / 6 * i;
      canvas.drawLine(Offset(0, y), Offset(width, y), grid);
    }

    for (int i = 0; i <= 10; i++) {
      double x = width / 10 * i;
      canvas.drawLine(Offset(x, 0), Offset(x, height), grid);
    }

    /// ZONA HIJAU
    Paint green = Paint()..color = Colors.green.withOpacity(0.5);

    Path greenPath = Path();
    greenPath.moveTo(0, height * 0.7);
    greenPath.quadraticBezierTo(width * 0.5, height * 0.4, width, height * 0.3);
    greenPath.lineTo(width, height * 0.6);
    greenPath.quadraticBezierTo(width * 0.5, height * 0.8, 0, height * 0.9);
    greenPath.close();

    canvas.drawPath(greenPath, green);

    /// TITIK DATA ANAK
    double maxUmur = 60;
    double maxBerat = 20;

    double x = (umur / maxUmur) * width;
    double y = height - (berat / maxBerat) * height;

    Paint point = Paint()..color = Colors.red;

    canvas.drawCircle(Offset(x, y), 6, point);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
