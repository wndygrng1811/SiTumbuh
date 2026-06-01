import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/widgets/custom_app_bar.dart';
import 'package:si_tumbuh/widgets/bottom_nav.dart';
import 'dart:convert';
import 'package:si_tumbuh/services/api_service.dart';

class EdukasiPage extends StatefulWidget {
  const EdukasiPage({super.key});

  @override
  State<EdukasiPage> createState() => _EdukasiPageState();
}

class _EdukasiPageState extends State<EdukasiPage> {
  String selectedTab = "Semua";
  final List<String> tabs = ["Semua", "Nutrisi", "Stunting"];

  List<Map<String, dynamic>> _artikelList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 🔥 CEK CACHE DULU (SUPAY CEPAT)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('edukasi_cache');

    if (cachedData != null) {
      setState(() {
        _artikelList = List<Map<String, dynamic>>.from(json.decode(cachedData));
        _isLoading = false;
      });
    }

    // 🔥 AMBIL DATA BARU DARI DATABASE DI BACKGROUND
    _fetchDataFromApi();
  }

  Future<void> _fetchDataFromApi() async {
    try {
      final List<dynamic> data = await ApiService.getEdukasi();

      if (data.isNotEmpty) {
        List<Map<String, dynamic>> artikelBaru = data.map((item) {
          return {
            'id': item['edukasi_id'],
            'title': item['judul'],
            'link': item['isi'],
            'kategori': item['kategori'] ?? 'Stunting',
            'image': 'assets/images/stunting.jpg',
          };
        }).toList();

        if (mounted) {
          setState(() {
            _artikelList = artikelBaru;
            _isLoading = false;
          });
        }

        // 🔥 SIMPAN KE CACHE
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('edukasi_cache', json.encode(artikelBaru));
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetch edukasi: $e');
      if (mounted && _artikelList.isEmpty) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedTab == "Semua"
        ? _artikelList
        : _artikelList.where((e) => e['kategori'] == selectedTab).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4EDEE),
      appBar: CustomAppBar(
        title: 'Edukasi',
        backgroundColor: const Color(0xFFD86487),
        titleColor: Colors.white,
        iconColor: Colors.white,
        showBackButton: false,
      ),
      body: _isLoading && _artikelList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 10),
                // TAB FILTER
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
                          onTap: () => setState(() => selectedTab = tab),
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
                // GRID EDUKASI
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('Belum ada artikel edukasi'))
                      : GridView.count(
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
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }
}

// CARD EDUKASI - BUKA PAKAI WEBVIEW
class EduCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const EduCard({super.key, required this.data});

  void _openArticle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WebViewPage(url: data['link'], title: data['title']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openArticle(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.asset(
                data['image'],
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 90,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                data['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Color(0xFF8B1E3F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// HALAMAN WEBVIEW UNTUK MEMBUKA ARTIKEL
class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({super.key, required this.url, required this.title});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) => setState(() => _isLoading = true),
          onPageFinished: (String url) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: widget.title,
        backgroundColor: const Color(0xFFD86487),
        titleColor: Colors.white,
        iconColor: Colors.white,
        showBackButton: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B1E3F)),
            ),
        ],
      ),
    );
  }
}
