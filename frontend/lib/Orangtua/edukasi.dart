import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:si_tumbuh/Orangtua/halaman_utama.dart';
import 'package:si_tumbuh/Orangtua/profil.dart';
import 'package:si_tumbuh/Orangtua/grafik.dart';

class Artikel {
  final String title;
  final String image;
  final String link;
  final String kategori;

  Artikel({
    required this.title,
    required this.image,
    required this.link,
    required this.kategori,
  });
}

final List<Artikel> artikelList = [
  Artikel(
    title: "Mengenal apa itu Stunting?",
    image: "assets/images/stunting.jpg",
    link:
        "https://keslan.kemkes.go.id/view_artikel/1388/mengenal-apa-itu-stunting",
    kategori: "Stunting",
  ),
  Artikel(
    title: "Penuhi kebutuhan gizi anak",
    image: "assets/images/stunting1.png",
    link:
        "https://gayahidup.rri.co.id/banda-aceh/kesehatan/110228/kemenkes-lakukan-pendekatan-gizi-spesifik-turunkan-angka-stunting",
    kategori: "Nutrisi",
  ),
  Artikel(
    title: "Data penurunan stunting",
    image: "assets/images/stunting2.jpg",
    link:
        "https://jateng.antaranews.com/berita/285739/kemenkes-lima-dari-10-ibu-hamil-anemia-potensi-lahirkan-anak-stunting",
    kategori: "Stunting",
  ),
  Artikel(
    title: "Cegah stunting sejak dini",
    image: "assets/images/stunting.jpg",
    link:
        "https://keslan.kemkes.go.id/view_artikel/1388/mengenal-apa-itu-stunting",
    kategori: "Stunting",
  ),
  Artikel(
    title: "Pentingnya gizi ibu hamil",
    image: "assets/images/stunting1.png",
    link:
        "https://jateng.antaranews.com/berita/285739/kemenkes-lima-dari-10-ibu-hamil-anemia-potensi-lahirkan-anak-stunting",
    kategori: "Nutrisi",
  ),
  Artikel(
    title: "Upaya turunkan stunting",
    image: "assets/images/stunting2.jpg",
    link:
        "https://gayahidup.rri.co.id/banda-aceh/kesehatan/110228/kemenkes-lakukan-pendekatan-gizi-spesifik-turunkan-angka-stunting",
    kategori: "Stunting",
  ),
  Artikel(
    title: "Mengenal Stunting Anak",
    image: "assets/images/stunting3.png",
    link:
        "https://ners.unair.ac.id/site/index.php/news-fkp-unair/30-lihat/1013-mengenal-stunting-dan-dampaknya-pada-tumbuh-kembang-anak",
    kategori: "Stunting",
  ),
];

class EdukasiPage extends StatefulWidget {
  const EdukasiPage({super.key});

  @override
  State<EdukasiPage> createState() => _EdukasiPageState();
}

class _EdukasiPageState extends State<EdukasiPage> {
  int _selectedIndex = 0;
  String selectedTab = "Stunting";

  final List<String> tabs = ["Semua", "Nutrisi", "Stunting"];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HalamanUtama()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GrafikPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HalamanUtama()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 FILTER DATA
    final filtered = selectedTab == "Semua"
        ? artikelList
        : artikelList.where((e) => e.kategori == selectedTab).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4EDEE),

      body: SafeArea(
        child: Column(
          children: [
            // 🔥 HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFFD86487),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.menu, color: Colors.white),
                  Text(
                    "SiTumbuh",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Icon(Icons.notifications_none, color: Colors.white),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🔥 TAB FILTER
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Row(
                children: [
                  ...tabs.map((tab) {
                    final active = tab == selectedTab;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = tab;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFF8B1E3F)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            color: active ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const Spacer(),
                  const Icon(Icons.more_horiz, color: Colors.grey),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔥 GRID EDUKASI (TETAP GridView.count, TIDAK DIUBAH STRUKTURNYA)
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: List.generate(
                  filtered.length,
                  (index) => EduCard(data: filtered[index]),
                ),
              ),
            ),
          ],
        ),
      ),

      // 🔥 BOTTOM NAV (TETAP)
      bottomNavigationBar: BottomNavigationBar(
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
            icon: Icon(Icons.trending_up),
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
    );
  }

  // ignore: unused_element
  static Widget _tab(String text, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF8B1E3F) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// 🔥 CARD (DITAMBAH DATA + CLICK + IMAGE REAL)
class EduCard extends StatelessWidget {
  final Artikel data;

  const EduCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(data.link);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 IMAGE REAL
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.asset(
                data.image,
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                data.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Baca selengkapnya",
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.arrow_forward_ios, size: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
