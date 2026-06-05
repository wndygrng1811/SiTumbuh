import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/widgets/custom_app_bar.dart';
import 'package:si_tumbuh/widgets/bottom_nav.dart';
import 'package:si_tumbuh/widgets/sidebar_menu.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:si_tumbuh/services/api_service.dart';

class EdukasiPage extends StatefulWidget {
  const EdukasiPage({super.key});

  @override
  State<EdukasiPage> createState() => _EdukasiPageState();
}

class _EdukasiPageState extends State<EdukasiPage> {
  String selectedTab = "Semua";
  final List<String> mainTabs = ["Semua", "Nutrisi", "Stunting"];
  final List<String> moreTabs = [
    "Imunisasi",
    "Tumbuh Kembang",
    "Kesehatan Umum",
  ];

  List<Map<String, dynamic>> _artikelList = [];
  bool _isLoading = true;

  final Map<int, String> _kategoriMapping = {
    1: 'Stunting',
    2: 'Nutrisi',
    3: 'Imunisasi',
    4: 'Tumbuh Kembang',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadFromCache();
    await _fetchDataFromApi();
  }

  Future<void> _loadFromCache() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedData = prefs.getString('edukasi_cache');

      if (cachedData != null && mounted) {
        setState(() {
          _artikelList = List<Map<String, dynamic>>.from(
            json.decode(cachedData),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading cache: $e');
    }
  }

  Future<void> _refreshData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('edukasi_cache');
    await _fetchDataFromApi();
  }

  // 🔥 FUNGSI UNTUK EKSTRAK GAMBAR DARI URL ARTIKEL
  Future<String?> _extractImageFromUrl(String articleUrl) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String cacheKey = 'img_${articleUrl.hashCode}';
      String? cachedImage = prefs.getString(cacheKey);

      if (cachedImage != null && cachedImage.isNotEmpty) {
        return cachedImage;
      }

      final response = await http
          .get(Uri.parse(articleUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        String html = response.body;

        // Cari meta tag og:image
        RegExp ogImageRegex = RegExp(
          r'<meta\s+property="og:image"\s+content="([^"]+)"',
        );
        RegExpMatch? ogMatch = ogImageRegex.firstMatch(html);

        if (ogMatch != null) {
          String imageUrl = ogMatch.group(1)!;
          if (imageUrl.isNotEmpty) {
            await prefs.setString(cacheKey, imageUrl);
            return imageUrl;
          }
        }

        // Cari gambar pertama
        RegExp imgRegex = RegExp(
          r'<img[^>]+src="([^">]+)"',
          caseSensitive: false,
        );
        RegExpMatch? imgMatch = imgRegex.firstMatch(html);

        if (imgMatch != null) {
          String imageUrl = imgMatch.group(1)!;

          if (imageUrl.startsWith('/')) {
            Uri baseUri = Uri.parse(articleUrl);
            imageUrl = '${baseUri.scheme}://${baseUri.host}$imageUrl';
          }

          if (imageUrl.isNotEmpty) {
            await prefs.setString(cacheKey, imageUrl);
            return imageUrl;
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error extracting image: $e');
      return null;
    }
  }

  Future<void> _fetchDataFromApi() async {
    try {
      final List<dynamic> data = await ApiService.getEdukasi();

      if (data.isNotEmpty && mounted) {
        List<Map<String, dynamic>> artikelBaru = [];

        for (var item in data) {
          int kategoriId = item['kategori_id'] ?? 1;
          String kategori = _kategoriMapping[kategoriId] ?? 'Stunting';
          String isi = item['isi'] ?? '';

          // Cek cache gambar
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String cacheKey = 'img_${isi.hashCode}';
          String? cachedImage = prefs.getString(cacheKey);

          artikelBaru.add({
            'edukasi_id': item['edukasi_id'] ?? 0,
            'judul': item['judul'] ?? 'Artikel Edukasi',
            'isi': isi,
            'kategori': kategori,
            'gambar': cachedImage ?? 'assets/images/stunting.jpg',
          });
        }

        setState(() {
          _artikelList = artikelBaru;
          _isLoading = false;
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('edukasi_cache', json.encode(artikelBaru));

        // 🔥 AMBIL GAMBAR DI BACKGROUND (TIDAK MENGGANGGU LOADING)
        _fetchAllImagesInBackground(data);
      } else if (mounted && _artikelList.isEmpty) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetch edukasi: $e');
      if (mounted && _artikelList.isEmpty) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 🔥 PROSES AMBIL GAMBAR DI BACKGROUND
  Future<void> _fetchAllImagesInBackground(List<dynamic> data) async {
    for (var item in data) {
      String url = item['isi'] ?? '';
      String? imageUrl = await _extractImageFromUrl(url);

      if (imageUrl != null && mounted) {
        setState(() {
          int index = _artikelList.indexWhere((art) => art['isi'] == url);
          if (index != -1) {
            _artikelList[index]['gambar'] = imageUrl;
          }
        });

        // Update cache
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('edukasi_cache', json.encode(_artikelList));
      }
    }
  }

  List<Map<String, dynamic>> get _filteredArtikel {
    if (selectedTab == "Semua") {
      return _artikelList;
    }
    return _artikelList.where((e) => e['kategori'] == selectedTab).toList();
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ...moreTabs.map((tab) {
                return ListTile(
                  leading: Icon(
                    _getCategoryIcon(tab),
                    color: const Color(0xFF8B1E3F),
                  ),
                  title: Text(tab),
                  trailing: selectedTab == tab
                      ? const Icon(Icons.check_circle, color: Color(0xFF8B1E3F))
                      : null,
                  onTap: () {
                    setState(() {
                      selectedTab = tab;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String kategori) {
    switch (kategori) {
      case 'Imunisasi':
        return Icons.vaccines;
      case 'Tumbuh Kembang':
        return Icons.timeline;
      case 'Kesehatan Umum':
        return Icons.health_and_safety;
      default:
        return Icons.menu_book;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarMenu(),
      backgroundColor: const Color(0xFFF4EDEE),
      appBar: CustomAppBar(
        title: 'Edukasi',
        backgroundColor: const Color(0xFFD86487),
        titleColor: Colors.white,
        iconColor: Colors.white,
        showBackButton: false,
        showNotificationIcon: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading && _artikelList.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 10),
                  _buildTabFilter(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _filteredArtikel.isEmpty
                        ? _buildEmptyState()
                        : _buildArtikelGrid(),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }

  Widget _buildTabFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          ...mainTabs.map((tab) {
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
                  color: active ? const Color(0xFF8B1E3F) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.grey.shade600,
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
          const Spacer(),
          GestureDetector(
            onTap: () => _showMoreMenu(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: moreTabs.contains(selectedTab)
                    ? const Color(0xFF8B1E3F)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.more_horiz,
                color: moreTabs.contains(selectedTab)
                    ? Colors.white
                    : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Belum ada artikel edukasi',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan cek kembali nanti',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B1E3F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtikelGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.99,
      ),
      itemCount: _filteredArtikel.length,
      itemBuilder: (context, index) {
        return EduCard(data: _filteredArtikel[index]);
      },
    );
  }
}

class EduCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const EduCard({super.key, required this.data});

  void _openArticle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WebViewArtikelPage(title: data['judul'], url: data['isi']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String gambar = data['gambar'] ?? 'assets/images/stunting.jpg';
    bool isNetworkImage = gambar.startsWith('http');

    return GestureDetector(
      onTap: () => _openArticle(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔥 GAMBAR - SUPPORT NETWORK IMAGE (dari artikel) dan ASSET (default)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              child: isNetworkImage
                  ? Image.network(
                      gambar,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        color: const Color(0xFFFDE2E7),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Color(0xFFD86487),
                            size: 32,
                          ),
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 100,
                          color: const Color(0xFFFDE2E7),
                          child: const Center(
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFD86487),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      gambar,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        color: const Color(0xFFFDE2E7),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Color(0xFFD86487),
                            size: 32,
                          ),
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE2E7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      data['kategori'],
                      style: const TextStyle(
                        fontSize: 8,
                        color: Color(0xFFD86487),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['judul'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text(
                        "Baca",
                        style: TextStyle(
                          color: Color(0xFF8B1E3F),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 7,
                        color: Color(0xFF8B1E3F),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WebViewArtikelPage extends StatefulWidget {
  final String title;
  final String url;

  const WebViewArtikelPage({super.key, required this.title, required this.url});

  @override
  State<WebViewArtikelPage> createState() => _WebViewArtikelPageState();
}

class _WebViewArtikelPageState extends State<WebViewArtikelPage> {
  late final WebViewController _controller;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF4EDEE))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _progress = 0;
            });
          },
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _progress = 1.0;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..setUserAgent(
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      );

    final uri = Uri.tryParse(widget.url);
    if (uri != null) {
      _controller.loadRequest(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EDEE),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFD86487),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _controller.reload(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
