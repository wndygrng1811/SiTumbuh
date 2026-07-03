import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';
import '../widgets/custom_app_bar.dart';
import '../services/api_service.dart';
import 'tambah_kategori_kader.dart';
import '../models/kategori_model.dart';

class KategoriKaderPage extends StatefulWidget {
  final List<KategoriModel> kategoriList;
  final Function(List<KategoriModel>) onKategoriChanged;

  const KategoriKaderPage({
    super.key,
    required this.kategoriList,
    required this.onKategoriChanged,
  });

  @override
  State<KategoriKaderPage> createState() => _KategoriKaderPageState();
}

class _KategoriKaderPageState extends State<KategoriKaderPage> {
  late List<KategoriModel> _kategoriList;
  String _searchQuery = '';
  bool _isLoading = false;
  final _searchCtrl = TextEditingController();

  // Filter Dropdown
  String selectedFilter = "Terbaru";
  final List<String> filterList = ["Terbaru", "Terlama", "Abjad"];

  @override
  void initState() {
    super.initState();
    _kategoriList = List.from(widget.kategoriList);
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<KategoriModel> get _filtered {
    List<KategoriModel> result = List.from(_kategoriList);

    // Filter search
    if (_searchQuery.isNotEmpty) {
      result = result.where((k) {
        return k.nama.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Sort
    if (selectedFilter == "Terlama") {
      result.sort((a, b) {
        String dateA = a.createdAt ?? '1970-01-01';
        String dateB = b.createdAt ?? '1970-01-01';
        return dateA.compareTo(dateB);
      });
    } else if (selectedFilter == "Terbaru") {
      result.sort((a, b) {
        String dateA = a.createdAt ?? '1970-01-01';
        String dateB = b.createdAt ?? '1970-01-01';
        return dateB.compareTo(dateA);
      });
    } else {
      result.sort((a, b) => a.nama.compareTo(b.nama));
    }

    return result;
  }

  Future<void> _loadKategori() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/kategori');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data'] ?? [];
          _kategoriList = list
              .map((item) => KategoriModel.fromJson(item))
              .toList();
          widget.onKategoriChanged(_kategoriList);
          setState(() {});
        }
      }
    } catch (e) {
      print('Error load kategori: $e');
      _showSnackbar('Gagal memuat kategori', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _tambahKategori() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TambahKategoriKaderPage()),
    );
    if (result == true) {
      await _loadKategori();
      _showSnackbar('Kategori berhasil ditambahkan', Colors.green);
    }
  }

  Future<void> _editKategori(KategoriModel k) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahKategoriKaderPage(isEdit: true, data: k),
      ),
    );
    if (result == true) {
      await _loadKategori();
      _showSnackbar('Kategori berhasil diupdate', Colors.blue);
    }
  }

  Future<void> _hapusKategori(KategoriModel k) async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.delete('/kategori/${k.id}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await _loadKategori();
          _showSnackbar('Kategori berhasil dihapus', Colors.green);
        } else {
          _showSnackbar('Gagal menghapus kategori', Colors.red);
        }
      }
    } catch (e) {
      _showSnackbar('Terjadi kesalahan', Colors.red);
    } finally {
      setState(() => _isLoading = false);
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

  void _confirmHapus(KategoriModel k) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_forever_rounded,
                color: Colors.red.shade600,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Hapus Kategori',
              style: TextStyle(
                color: Color(0xFF7A1635),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yakin ingin menghapus kategori',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              '"${k.nama}"?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7A1635),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Kategori yang memiliki edukasi tidak dapat dihapus!',
                      style: TextStyle(fontSize: 12, color: Color(0xFFCC7A00)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            onPressed: () {
              Navigator.pop(context);
              _hapusKategori(k);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _kategoriList.length;
    final dipub = _kategoriList
        .where((k) => k.status == 'Dipublikasikan')
        .length;
    final draft = _kategoriList.where((k) => k.status == 'Draft').length;

    return Scaffold(
      drawer: const SidebarKader(),
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 0),
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(
        backgroundColor: const Color(0xFFD05A7E),
        iconColor: Colors.white,
        showBackButton: true,
        showDrawerIcon: false,
        showNotificationIcon: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kelola Kategori',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7A1635),
                        ),
                      ),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD05A7E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 0,
                            ),
                            minimumSize: const Size(0, 36),
                          ),
                          onPressed: _tambahKategori,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text(
                            'Tambah',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // STAT CARD
                  Row(
                    children: [
                      _statCard(
                        'Total',
                        '$total',
                        const Color(0xFF4CAF50),
                        Icons.category,
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
                    ],
                  ),

                  const SizedBox(height: 16),

                  // SEARCH
                  TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Cari kategori...',
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // DAFTAR KATEGORI + ICON FILTER (SEBARIS)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Kategori (${_filtered.length})',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.filter_list,
                          color: Color(0xFFD05A7E),
                          size: 24,
                        ),
                        offset: const Offset(0, 30),
                        onSelected: (String value) {
                          setState(() {
                            selectedFilter = value;
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return filterList.map((String option) {
                            return PopupMenuItem<String>(
                              value: option,
                              child: Row(
                                children: [
                                  if (selectedFilter == option)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFFD05A7E),
                                      size: 16,
                                    )
                                  else
                                    const Icon(
                                      Icons.circle_outlined,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                  const SizedBox(width: 10),
                                  Text(
                                    option,
                                    style: TextStyle(
                                      fontWeight: selectedFilter == option
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: selectedFilter == option
                                          ? const Color(0xFFD05A7E)
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _filtered.isEmpty
                      ? _emptyState()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final k = _filtered[index];
                            return _kategoriCard(k);
                          },
                        ),

                  const SizedBox(height: 20),
                ],
              ),
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

  Widget _kategoriCard(KategoriModel k) {
    final isPub = k.status == 'Dipublikasikan';
    final warnaStatus = isPub ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
        border: Border.all(
          color: isPub
              ? Colors.green.withOpacity(0.2)
              : Colors.orange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon Kategori - Klik untuk Edit
          InkWell(
            onTap: () => _editKategori(k),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFD05A7E).withOpacity(0.2),
                    const Color(0xFFD05A7E).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.category_rounded,
                color: const Color(0xFFD05A7E),
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Content - Klik untuk Edit
          Expanded(
            child: InkWell(
              onTap: () => _editKategori(k),
              borderRadius: BorderRadius.circular(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    k.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (k.deskripsi.isNotEmpty)
                    Text(
                      k.deskripsi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: warnaStatus.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: warnaStatus,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          k.status,
                          style: TextStyle(
                            fontSize: 10,
                            color: warnaStatus,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ICON TITIK TIGA -> DROPDOWN HAPUS (TANPA BACKGROUND, TANPA TANDA >)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey.shade500, size: 22),
            offset: const Offset(0, 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            color: Colors.white,
            onSelected: (String value) {
              if (value == 'hapus') {
                _confirmHapus(k);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'hapus',
                padding: EdgeInsets.zero,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red.shade600,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Hapus Kategori',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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
              Icons.category_outlined,
              size: 60,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tidak ada kategori untuk "$_searchQuery"'
                  : 'Belum ada kategori',
              style: TextStyle(color: Colors.grey.shade500),
            ),
            if (_searchQuery.isEmpty) const SizedBox(height: 12),
            if (_searchQuery.isEmpty)
              ElevatedButton.icon(
                onPressed: _tambahKategori,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Kategori'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD05A7E),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
