import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';
import '../widgets/custom_app_bar.dart'; // ← IMPORT CUSTOM APP BAR
import '../services/api_service.dart';
import 'tambah_edukasi_kader.dart';
import 'kategori_kader.dart';

// ─────────────────────────────────────────────
// SHARED MODELS
// ─────────────────────────────────────────────

class KategoriModel {
  String id, nama, deskripsi, image, status;

  KategoriModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.image,
    required this.status,
  });

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      id: json['id'].toString(),
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? 'Draft',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'image': image,
      'status': status,
    };
  }
}

class EdukasiModel {
  String id, title, kategoriId, desc, status, youtubeUrl, jenisKonten;
  String? image;

  EdukasiModel({
    required this.id,
    required this.title,
    required this.kategoriId,
    required this.desc,
    required this.status,
    this.youtubeUrl = '',
    this.jenisKonten = 'artikel',
    this.image,
  });

  factory EdukasiModel.fromJson(Map<String, dynamic> json) {
    return EdukasiModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      kategoriId: json['kategori_id'].toString(),
      desc: json['desc'] ?? '',
      status: json['status'] ?? 'Draft',
      youtubeUrl: json['youtube_url'] ?? '',
      jenisKonten: json['jenis_konten'] ?? 'artikel',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'kategori_id': kategoriId,
      'desc': desc,
      'status': status,
      'youtube_url': youtubeUrl,
      'jenis_konten': jenisKonten,
    };
  }
}

// ─────────────────────────────────────────────
// EDUKASI KADER PAGE
// ─────────────────────────────────────────────

class EdukasiKaderPage extends StatefulWidget {
  const EdukasiKaderPage({super.key});

  @override
  State<EdukasiKaderPage> createState() => _EdukasiKaderPageState();
}

class _EdukasiKaderPageState extends State<EdukasiKaderPage>
    with SingleTickerProviderStateMixin {
  List<KategoriModel> _kategoriList = [];
  List<EdukasiModel> _edukasiList = [];
  final Map<String, String> _imageCache = {};
  String _filterKategoriId = 'semua';
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isGeneratingImages = false;
  String _errorMessage = '';

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadData();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await Future.wait([_loadKategori(), _loadEdukasi()]);
    } catch (e) {
      setState(() => _errorMessage = 'Gagal memuat data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadKategori() async {
    try {
      final response = await ApiService.get('/kategori');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data'] ?? [];
          setState(() {
            _kategoriList = list
                .map((item) => KategoriModel.fromJson(item))
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error load kategori: $e');
    }
  }

  String _getYoutubeThumbnail(String url) {
    if (url.isEmpty) return '';

    String videoId = '';
    if (url.contains('watch?v=')) {
      videoId = url.split('watch?v=')[1].split('&')[0];
    } else if (url.contains('youtu.be/')) {
      videoId = url.split('youtu.be/')[1].split('?')[0];
    } else if (url.contains('embed/')) {
      videoId = url.split('embed/')[1].split('?')[0];
    } else {
      videoId = url;
    }

    return 'https://img.youtube.com/vi/$videoId/0.jpg';
  }

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
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        String html = response.body;

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
      print('Error extracting image: $e');
      return null;
    }
  }

  Future<void> _loadEdukasi() async {
    try {
      final response = await ApiService.get('/edukasi');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data'] ?? [];

          List<EdukasiModel> edukasiList = [];

          for (var item in list) {
            EdukasiModel edu = EdukasiModel.fromJson(item);

            if (edu.youtubeUrl.isNotEmpty) {
              edu.jenisKonten = 'video';
              edu.image = _getYoutubeThumbnail(edu.youtubeUrl);
            } else {
              edu.jenisKonten = 'artikel';
              if (edu.desc.isNotEmpty && edu.desc.startsWith('http')) {
                String cacheKey = 'img_${edu.desc.hashCode}';
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? cachedImage = prefs.getString(cacheKey);
                if (cachedImage != null && cachedImage.isNotEmpty) {
                  edu.image = cachedImage;
                }
              }
            }
            edukasiList.add(edu);
          }

          setState(() {
            _edukasiList = edukasiList;
          });

          await _generateMissingImages();
        }
      }
    } catch (e) {
      print('Error load edukasi: $e');
    }
  }

  Future<void> _generateMissingImages() async {
    List<EdukasiModel> needImages = _edukasiList
        .where(
          (e) =>
              e.jenisKonten == 'artikel' &&
              e.image == null &&
              e.desc.isNotEmpty &&
              e.desc.startsWith('http'),
        )
        .toList();

    if (needImages.isEmpty) return;

    setState(() => _isGeneratingImages = true);

    for (var edu in needImages) {
      String? imageUrl = await _extractImageFromUrl(edu.desc);
      if (imageUrl != null && mounted) {
        setState(() {
          int index = _edukasiList.indexWhere((e) => e.id == edu.id);
          if (index != -1) {
            _edukasiList[index].image = imageUrl;
          }
        });
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (mounted) {
      setState(() => _isGeneratingImages = false);
    }
  }

  List<EdukasiModel> get _filtered {
    return _edukasiList.where((e) {
      final matchKat =
          _filterKategoriId == 'semua' || e.kategoriId == _filterKategoriId;
      final matchSearch =
          _searchQuery.isEmpty ||
          e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.desc.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchKat && matchSearch;
    }).toList();
  }

  String _namaKategori(String id) {
    try {
      return _kategoriList.firstWhere((k) => k.id == id).nama;
    } catch (_) {
      return id;
    }
  }

  Future<void> _bukaFormEdukasi({EdukasiModel? edit}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahEdukasiPage(
          kategoriList: _kategoriList,
          isEdit: edit != null,
          data: edit,
        ),
      ),
    );

    if (result == true) {
      await _loadEdukasi();
      _showSnackbar(
        edit == null
            ? 'Edukasi berhasil ditambahkan ✓'
            : 'Edukasi berhasil diperbarui ✓',
        Colors.green,
      );
    }
  }

  Future<void> _hapusEdukasi(EdukasiModel e) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Edukasi?'),
        content: Text('Yakin ingin menghapus "${e.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final response = await ApiService.delete('/edukasi/${e.id}');
                if (response.statusCode == 200) {
                  await _loadEdukasi();
                  _showSnackbar('Edukasi dihapus', Colors.red);
                } else {
                  _showSnackbar('Gagal menghapus', Colors.red);
                }
              } catch (error) {
                _showSnackbar('Error: $error', Colors.red);
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(EdukasiModel e, String newStatus) async {
    try {
      final response = await ApiService.put('/edukasi/${e.id}', {
        'status': newStatus,
      });
      if (response.statusCode == 200) {
        await _loadEdukasi();
        _showSnackbar('Status berhasil diubah', Colors.blue);
      }
    } catch (error) {
      _showSnackbar('Gagal mengubah status', Colors.red);
    }
  }

  Future<void> _bukaKategori() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => KategoriKaderPage(
          kategoriList: _kategoriList,
          onKategoriChanged: (list) async {
            await _loadKategori();
            await _loadEdukasi();
          },
        ),
      ),
    );
    if (result == true) {
      await _loadKategori();
      await _loadEdukasi();
    }
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _edukasiList.length;
    final dipub = _edukasiList
        .where((e) => e.status == 'Dipublikasikan')
        .length;
    final draft = _edukasiList.where((e) => e.status == 'Draft').length;
    final totalKat = _kategoriList.length;

    return Scaffold(
      drawer: const SidebarKader(),
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 0),
      backgroundColor: const Color(0xFFF5F5F5),
      // ========== MENGGUNAKAN CUSTOM APP BAR ==========
      appBar: CustomAppBar(
        backgroundColor: const Color(0xFFD86487),
        iconColor: Colors.white,
        showBackButton: false,
        showDrawerIcon: true,
        showNotificationIcon: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : Stack(
              children: [
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _statCard(
                              'Total',
                              '$total',
                              const Color(0xFF4CAF50),
                              Icons.book,
                            ),
                            _statCard(
                              'Publik',
                              '$dipub',
                              const Color(0xFF2196F3),
                              Icons.public,
                            ),
                            _statCard(
                              'Draft',
                              '$draft',
                              const Color(0xFFFF9800),
                              Icons.edit_note,
                            ),
                            _statCard(
                              'Kategori',
                              '$totalKat',
                              const Color(0xFF7B61FF),
                              Icons.category,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Cari judul edukasi...',
                            hintStyle: const TextStyle(fontSize: 13),
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Kategori',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            GestureDetector(
                              onTap: _bukaKategori,
                              child: const Text(
                                'Kelola Kategori →',
                                style: TextStyle(
                                  color: Color(0xFFD05A7E),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _kategoriChip('semua', 'Semua', Icons.grid_view),
                              ..._kategoriList.map(
                                (k) => _kategoriChip(
                                  k.id,
                                  k.nama,
                                  Icons.label_outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Daftar Edukasi (${_filtered.length})',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            if (_isGeneratingImages)
                              const Row(
                                children: [
                                  SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Mengambil gambar...',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildEdukasiList(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edukasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A1635),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Kelola konten edukasi',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 32,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD05A7E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => _bukaFormEdukasi(),
            icon: const Icon(Icons.add, size: 14),
            label: const Text(
              'Tambah',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEdukasiList() {
    if (_filtered.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: _filtered.asMap().entries.map((entry) {
        final index = entry.key;
        final e = entry.value;
        return Container(
          key: ValueKey('${e.id}_$index'),
          margin: const EdgeInsets.only(bottom: 12),
          child: _edukasiCard(e),
        );
      }).toList(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(_errorMessage),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD05A7E),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String total, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              total,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 18,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kategoriChip(String id, String label, IconData icon) {
    final selected = _filterKategoriId == id;
    return GestureDetector(
      onTap: () => setState(() => _filterKategoriId = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD05A7E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFD05A7E) : Colors.grey.shade300,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFFD05A7E).withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? Colors.white : Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _edukasiCard(EdukasiModel e) {
    final isPub = e.status == 'Dipublikasikan';
    final namaKat = _namaKategori(e.kategoriId);
    final warnaStatus = isPub ? Colors.green : Colors.orange;
    final hasVideo = e.youtubeUrl.isNotEmpty;

    String imageUrl;
    if (hasVideo) {
      imageUrl = _getYoutubeThumbnail(e.youtubeUrl);
    } else if (e.image != null && e.image!.isNotEmpty) {
      imageUrl = e.image!;
    } else {
      imageUrl = 'assets/images/stunting.jpg';
    }

    return Dismissible(
      key: Key(e.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white),
            Text('Hapus', style: TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        _hapusEdukasi(e);
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _bukaFormEdukasi(edit: e),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl.startsWith('http')
                      ? Image.network(
                          imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          loadingBuilder: (_, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _imagePlaceholder(loading: true);
                          },
                        )
                      : Image.asset(
                          imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _badge(
                            namaKat,
                            Colors.grey.shade700,
                            Colors.grey.shade100,
                          ),
                          _badge(
                            e.status,
                            warnaStatus,
                            warnaStatus.withOpacity(0.12),
                          ),
                          if (hasVideo)
                            _badge('Video', Colors.red, Colors.red.shade50),
                        ],
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Colors.grey,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (v) {
                    if (v == 'edit') _bukaFormEdukasi(edit: e);
                    if (v == 'hapus') _hapusEdukasi(e);
                    if (v == 'publish' && e.status != 'Dipublikasikan') {
                      _updateStatus(e, 'Dipublikasikan');
                    }
                    if (v == 'draft' && e.status != 'Draft') {
                      _updateStatus(e, 'Draft');
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (e.status != 'Dipublikasikan')
                      const PopupMenuItem(
                        value: 'publish',
                        child: Row(
                          children: [
                            Icon(Icons.publish, size: 18, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Publikasikan'),
                          ],
                        ),
                      ),
                    if (e.status != 'Draft')
                      const PopupMenuItem(
                        value: 'draft',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_note,
                              size: 18,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Text('Simpan ke Draft'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'hapus',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder({bool loading = false}) {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey.shade200,
      child: loading
          ? const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  Widget _badge(String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 60,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tidak ada hasil untuk "$_searchQuery"'
                  : 'Belum ada edukasi',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
