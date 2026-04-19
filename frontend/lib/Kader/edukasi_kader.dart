import 'package:flutter/material.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';
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

  KategoriModel copyWith({
    String? nama,
    String? deskripsi,
    String? image,
    String? status,
  }) => KategoriModel(
    id: id,
    nama: nama ?? this.nama,
    deskripsi: deskripsi ?? this.deskripsi,
    image: image ?? this.image,
    status: status ?? this.status,
  );
}

class EdukasiModel {
  String id, title, kategoriId, desc, image, status;

  EdukasiModel({
    required this.id,
    required this.title,
    required this.kategoriId,
    required this.desc,
    required this.image,
    required this.status,
  });

  EdukasiModel copyWith({
    String? title,
    String? kategoriId,
    String? desc,
    String? image,
    String? status,
  }) => EdukasiModel(
    id: id,
    title: title ?? this.title,
    kategoriId: kategoriId ?? this.kategoriId,
    desc: desc ?? this.desc,
    image: image ?? this.image,
    status: status ?? this.status,
  );
}

// ─────────────────────────────────────────────
// DUMMY DATA
// ─────────────────────────────────────────────

List<KategoriModel> _dummyKategori = [
  KategoriModel(
    id: 'k1',
    nama: 'Gizi',
    deskripsi: 'Edukasi tentang gizi seimbang yang diperlukan anak',
    image: 'assets/images/ikon_edu1.jpg',
    status: 'Dipublikasikan',
  ),
  KategoriModel(
    id: 'k2',
    nama: 'Kesehatan',
    deskripsi: 'Edukasi tentang status pertumbuhan dan kesehatan anak',
    image: 'assets/images/ikon_edu2.jpg',
    status: 'Dipublikasikan',
  ),
  KategoriModel(
    id: 'k3',
    nama: 'Tumbuh Kembang',
    deskripsi: 'Edukasi tentang ciri dan tahapan perkembangan anak',
    image: 'assets/images/ikon_edu3.jpg',
    status: 'Draft',
  ),
  KategoriModel(
    id: 'k4',
    nama: 'Pengasuhan',
    deskripsi: 'Edukasi tentang cara mengasuh anak dengan baik',
    image: 'assets/images/ikon_edu4.jpg',
    status: 'Draft',
  ),
];

List<EdukasiModel> _dummyEdukasi = [
  EdukasiModel(
    id: 'e1',
    title: 'Pentingnya Gizi Seimbang',
    kategoriId: 'k1',
    desc:
        'Pelajari bagaimana gizi seimbang membantu anak tumbuh sehat dan cerdas.',
    image: 'assets/edu1.jpg',
    status: 'Dipublikasikan',
  ),
  EdukasiModel(
    id: 'e2',
    title: 'Jadwal Imunisasi Anak',
    kategoriId: 'k2',
    desc:
        'Ketahui jadwal imunisasi penting untuk melindungi anak dari penyakit.',
    image: 'assets/edu2.jpg',
    status: 'Dipublikasikan',
  ),
  EdukasiModel(
    id: 'e3',
    title: 'Cara Mengukur Tinggi Badan',
    kategoriId: 'k3',
    desc: 'Panduan lengkap mengukur tinggi badan anak dengan benar di rumah.',
    image: 'assets/edu3.jpg',
    status: 'Draft',
  ),
];

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
  // ── State ──
  List<KategoriModel> _kategoriList = List.from(_dummyKategori);
  List<EdukasiModel> _edukasiList = List.from(_dummyEdukasi);
  String _filterKategoriId = 'semua';
  String _searchQuery = '';
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
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Computed ──
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

  // ── CRUD Edukasi ──
  Future<void> _bukaFormEdukasi({EdukasiModel? edit}) async {
    final result = await Navigator.push<EdukasiModel>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahEdukasiPage(
          kategoriList: _kategoriList,
          isEdit: edit != null,
          data: edit,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      if (edit == null) {
        _edukasiList.add(result);
        _showSnackbar('Edukasi berhasil ditambahkan ✓', Colors.green);
      } else {
        final idx = _edukasiList.indexWhere((e) => e.id == result.id);
        if (idx != -1) _edukasiList[idx] = result;
        _showSnackbar('Edukasi berhasil diperbarui ✓', Colors.blue);
      }
    });
  }

  void _hapusEdukasi(EdukasiModel e) {
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
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _edukasiList.removeWhere((x) => x.id == e.id);
                _showSnackbar('Edukasi dihapus', Colors.red);
              });
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // ── Navigasi Kategori ──
  Future<void> _bukaKategori() async {
    final result = await Navigator.push<List<KategoriModel>>(
      context,
      MaterialPageRoute(
        builder: (_) => KategoriKaderPage(
          kategoriList: _kategoriList,
          onKategoriChanged: (list) => setState(() => _kategoriList = list),
        ),
      ),
    );
    if (result != null) setState(() => _kategoriList = result);
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

  // ── Build ──
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Edukasi',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7A1635),
                        ),
                      ),
                      Text(
                        'Kelola konten edukasi untuk orang tua',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD05A7E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () => _bukaFormEdukasi(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Tambah',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Stat Cards ──
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

              // ── Search ──
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
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
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Kategori Filter ──
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
                      (k) => _kategoriChip(k.id, k.nama, Icons.label_outline),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Daftar Edukasi ──
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
                ],
              ),

              const SizedBox(height: 12),

              if (_filtered.isEmpty)
                _emptyState()
              else
                ..._filtered.map((e) => _edukasiCard(e)),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets Helper ──

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
        return false; // biar dialog yang handle
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
                // Gambar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    e.image,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
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
                      Row(
                        children: [
                          _badge(
                            namaKat,
                            Colors.grey.shade700,
                            Colors.grey.shade100,
                          ),
                          const SizedBox(width: 6),
                          _badge(
                            e.status,
                            warnaStatus,
                            warnaStatus.withOpacity(0.12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action menu
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
