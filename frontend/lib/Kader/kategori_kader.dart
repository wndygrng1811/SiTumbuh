import 'package:flutter/material.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';
import 'tambah_kategori_kader.dart';
import 'edukasi_kader.dart'; // import KategoriModel

class KategoriKaderPage extends StatefulWidget {
  final List<KategoriModel> kategoriList;
  final void Function(List<KategoriModel>)? onKategoriChanged;

  const KategoriKaderPage({
    super.key,
    required this.kategoriList,
    this.onKategoriChanged,
  });

  @override
  State<KategoriKaderPage> createState() => _KategoriKaderPageState();
}

class _KategoriKaderPageState extends State<KategoriKaderPage>
    with SingleTickerProviderStateMixin {
  late List<KategoriModel> _list;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.kategoriList);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _notifyParent() {
    widget.onKategoriChanged?.call(_list);
  }

  Future<void> _bukaForm({KategoriModel? edit}) async {
    final result = await Navigator.push<KategoriModel>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TambahKategoriKaderPage(isEdit: edit != null, data: edit),
      ),
    );
    if (result == null) return;

    setState(() {
      if (edit == null) {
        _list.add(result);
        _showSnackbar('Kategori berhasil ditambahkan ✓', Colors.green);
      } else {
        final idx = _list.indexWhere((k) => k.id == result.id);
        if (idx != -1) _list[idx] = result;
        _showSnackbar('Kategori berhasil diperbarui ✓', Colors.blue);
      }
    });
    _notifyParent();
  }

  void _hapus(KategoriModel k) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Kategori?'),
        content: Text('Yakin ingin menghapus kategori "${k.nama}"?'),
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
                _list.removeWhere((x) => x.id == k.id);
                _showSnackbar('Kategori dihapus', Colors.red);
              });
              _notifyParent();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
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
    final dipub = _list.where((k) => k.status == 'Dipublikasikan').length;
    final draft = _list.where((k) => k.status == 'Draft').length;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _list);
        return false;
      },
      child: Scaffold(
        drawer: const SidebarKader(),
        bottomNavigationBar: const BottomNavbarKader(selectedIndex: 0),
        backgroundColor: const Color(0xFFF7EEF1),
        appBar: AppBar(
          backgroundColor: const Color(0xFFD85F87),
          elevation: 0,
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
              padding: EdgeInsets.only(right: 15),
              child: Icon(Icons.notifications_none),
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ── Header ──
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kategori',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7A1635),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kelola kategori edukasi untuk orang tua',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD85F87),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () => _bukaForm(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        'Tambah',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Mini Stat ──
                Row(
                  children: [
                    _miniStat(
                      'Total',
                      '${_list.length}',
                      const Color(0xFF7B61FF),
                    ),
                    const SizedBox(width: 10),
                    _miniStat('Dipublikasikan', '$dipub', Colors.green),
                    const SizedBox(width: 10),
                    _miniStat('Draft', '$draft', Colors.orange),
                  ],
                ),

                const SizedBox(height: 16),

                // ── List ──
                Expanded(
                  child: _list.isEmpty
                      ? _emptyState()
                      : ListView.builder(
                          itemCount: _list.length,
                          itemBuilder: (_, i) => _itemKategori(_list[i]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              val,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemKategori(KategoriModel k) {
    final isPub = k.status == 'Dipublikasikan';
    final warna = isPub ? Colors.green : Colors.orange;

    return Dismissible(
      key: Key(k.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(18),
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
        _hapus(k);
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.grey.withOpacity(0.12),
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _bukaForm(edit: k),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon / Gambar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: warna.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    k.image,
                    width: 36,
                    height: 36,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.category, color: warna, size: 28),
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        k.nama,
                        style: TextStyle(
                          color: warna,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        k.deskripsi,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Badge Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: warna.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    k.status,
                    style: TextStyle(
                      color: warna,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Menu
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
                    if (v == 'edit') _bukaForm(edit: k);
                    if (v == 'hapus') _hapus(k);
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

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Belum ada kategori',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD85F87),
            ),
            onPressed: () => _bukaForm(),
            child: const Text('+ Tambah Kategori'),
          ),
        ],
      ),
    );
  }
}
