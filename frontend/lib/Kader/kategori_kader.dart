import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';
import '../services/api_service.dart';
import 'tambah_kategori_kader.dart';
import 'edukasi_kader.dart';

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

class _KategoriKaderPageState extends State<KategoriKaderPage>
    with SingleTickerProviderStateMixin {
  late List<KategoriModel> _kategoriList;
  String _searchQuery = '';
  bool _isLoading = false;
  final _searchCtrl = TextEditingController();

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _kategoriList = List.from(widget.kategoriList);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
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

  List<KategoriModel> get _filtered {
    if (_searchQuery.isEmpty) return _kategoriList;
    return _kategoriList.where((k) {
      return k.nama.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
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
    // Cek apakah kategori sedang digunakan
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.delete('/kategori/${k.id}');
      final data = json.decode(response.body);

      if (data['success'] == true) {
        await _loadKategori();
        _showSnackbar(
          data['message'] ?? 'Kategori berhasil dihapus',
          Colors.green,
        );
      } else {
        _showSnackbar(
          data['message'] ?? 'Gagal menghapus kategori',
          Colors.red,
        );
      }
    } catch (e) {
      print('Error hapus kategori: $e');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Kategori?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yakin ingin menghapus kategori "${k.nama}"?'),
            const SizedBox(height: 8),
            const Text(
              'Perhatian: Kategori yang memiliki edukasi tidak dapat dihapus!',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            onPressed: () {
              Navigator.pop(context);
              _hapusKategori(k);
            },
            child: const Text('Hapus'),
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFD05A7E),
        title: const Text(
          'SiTumbuh',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Kelola Kategori',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7A1635),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Atur kategori konten edukasi',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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

                    // Stat Cards
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

                    // Search
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

                    // Daftar Kategori
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
        onTap: () => _editKategori(k),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFD05A7E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.category,
                  color: const Color(0xFFD05A7E),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: warnaStatus.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        k.status,
                        style: TextStyle(
                          fontSize: 10,
                          color: warnaStatus,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: Colors.blue,
                    ),
                    onPressed: () => _editKategori(k),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                    onPressed: () => _confirmHapus(k),
                  ),
                ],
              ),
            ],
          ),
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
