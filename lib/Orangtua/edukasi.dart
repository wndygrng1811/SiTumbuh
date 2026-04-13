import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:si_tumbuh/orangtua/profil.dart';
import 'package:si_tumbuh/orangtua/halaman_utama.dart';
import 'package:si_tumbuh/orangtua/grafik.dart';

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
    image: "assets/edu2.jpg",
    link:
        "https://keslan.kemkes.go.id/view_artikel/1388/mengenal-apa-itu-stunting",
    kategori: "Stunting",
  ),
  Artikel(
    title: "Penuhi kebutuhan gizi anak",
    image: "assets/edu3.jpg",
    link:
        "https://gayahidup.rri.co.id/banda-aceh/kesehatan/110228/kemenkes-lakukan-pendekatan-gizi-spesifik-turunkan-angka-stunting",
    kategori: "Nutrisi",
  ),
  Artikel(
    title: "Data penurunan stunting",
    image: "assets/edu1.jpg",
    link:
        "https://jateng.antaranews.com/berita/285739/kemenkes-lima-dari-10-ibu-hamil-anemia-potensi-lahirkan-anak-stunting",
    kategori: "Stunting",
  ),
  Artikel(
    title: "Cegah stunting sejak dini",
    image: "assets/edu3.jpg",
    link:
        "https://keslan.kemkes.go.id/view_artikel/1388/mengenal-apa-itu-stunting",
    kategori: "Stunting",
  ),
  Artikel(
    title: "Pentingnya gizi ibu hamil",
    image: "assets/edu2.jpg",
    link:
        "https://jateng.antaranews.com/berita/285739/kemenkes-lima-dari-10-ibu-hamil-anemia-potensi-lahirkan-anak-stunting",
    kategori: "Nutrisi",
  ),
  Artikel(
    title: "Upaya turunkan stunting",
    image: "assets/edu1.jpg",
    link:
        "https://gayahidup.rri.co.id/banda-aceh/kesehatan/110228/kemenkes-lakukan-pendekatan-gizi-spesifik-turunkan-angka-stunting",
    kategori: "Stunting",
  ),
];

class EdukasiPage extends StatefulWidget {
  const EdukasiPage({super.key});

  @override
  State<EdukasiPage> createState() => _EdukasiPageState();
}

class _EdukasiPageState extends State<EdukasiPage> {
  int _selectedIndex = 2;
  String selectedTab = "Semua";

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
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedTab == "Semua"
        ? artikelList
        : artikelList.where((e) => e.kategori == selectedTab).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6EFF1),

      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 110,
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
                      letterSpacing: 1,
                    ),
                  ),
                  Icon(Icons.notifications_none, color: Colors.white),
                ],
              ),
            ),

            const SizedBox(height: 14),

            /// FILTER TAB
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
                children: tabs.map((tab) {
                  final active = tab == selectedTab;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = tab;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFF8B1E3F)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            tab,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: active ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 18),

            /// GRID ARTIKEL
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.82,
                children: List.generate(
                  filtered.length,
                  (index) => EduCard(data: filtered[index]),
                ),
              ),
            ),
          ],
        ),
      ),

      /// BOTTOM NAV
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
            label: 'Edukasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

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
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Image.asset(
                data.image,
                height: 95,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                data.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Baca selengkapnya",
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.arrow_forward_ios, size: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
