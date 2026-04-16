import 'package:flutter/material.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';

class KelolaDaftarOrangTuaPage extends StatefulWidget {
  const KelolaDaftarOrangTuaPage({super.key});

  @override
  State<KelolaDaftarOrangTuaPage> createState() =>
      _KelolaDaftarOrangTuaPageState();
}

class _KelolaDaftarOrangTuaPageState extends State<KelolaDaftarOrangTuaPage> {
  final TextEditingController _searchController = TextEditingController();

  // Dummy data — ganti dengan data dari API/database
  List<Map<String, String>> _allData = [
    {
      'nama': 'Aisyah',
      'email': 'aisyah@gmail.com',
      'telepon': '08123456789',
      'alamat': 'Jln Mawar asri no 55',
    },
    {
      'nama': 'Rahmawati',
      'email': 'rahmawati2@gmail.com',
      'telepon': '086133652811',
      'alamat': 'Jln nusa biru A10 no 2',
    },
    {
      'nama': 'Gunawan',
      'email': 'nawangunawan@gmail.com',
      'telepon': '0838654237736',
      'alamat': 'Perum Garden 2 no 4',
    },
  ];

  List<Map<String, String>> _filtered = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_allData);
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = q;
      _filtered = _allData
          .where((o) => o['nama']!.toLowerCase().contains(q))
          .toList();
    });
  }

  void _hapus(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Data'),
        content: Text(
          'Yakin ingin menghapus data ${_filtered[index]['nama']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final item = _filtered[index];
                _allData.remove(item);
                _filtered.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD86487),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _ubah(int index) {
    final data = _filtered[index];
    final namaCtrl = TextEditingController(text: data['nama']);
    final emailCtrl = TextEditingController(text: data['email']);
    final teleponCtrl = TextEditingController(text: data['telepon']);
    final alamatCtrl = TextEditingController(text: data['alamat']);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFCECF1),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Data Orang Tua',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF888888),
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _dialogField('Nama Lengkap', namaCtrl),
              const SizedBox(height: 10),
              _dialogField(
                'Email',
                emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              _dialogField(
                'No Telepon',
                teleponCtrl,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              _dialogField('Alamat', alamatCtrl),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      final originalIndex = _allData.indexOf(data);
                      final updated = {
                        'nama': namaCtrl.text,
                        'email': emailCtrl.text,
                        'telepon': teleponCtrl.text,
                        'alamat': alamatCtrl.text,
                      };
                      _allData[originalIndex] = updated;
                      _filtered[index] = updated;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD86487),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _detail(Map<String, String> data) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFCECF1),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detail Orang Tua',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF888888),
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _detailRow(Icons.person_outline, data['nama']!),
              const SizedBox(height: 10),
              _detailRow(Icons.email_outlined, data['email']!),
              const SizedBox(height: 10),
              _detailRow(Icons.phone_outlined, data['telepon']!),
              const SizedBox(height: 10),
              _detailRow(Icons.location_on_outlined, data['alamat']!),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD86487),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFD86487)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
          ),
        ),
      ],
    );
  }

  Widget _dialogField(
    String label,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0C8D0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD86487),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _tambahOrangTua() {
    final namaCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final teleponCtrl = TextEditingController();
    final alamatCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFCECF1),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tambah Orang Tua',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF888888),
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _dialogField('Nama Lengkap', namaCtrl),
              const SizedBox(height: 10),
              _dialogField(
                'Email',
                emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              _dialogField(
                'No Telepon',
                teleponCtrl,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              _dialogField('Alamat', alamatCtrl),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    if (namaCtrl.text.isNotEmpty) {
                      setState(() {
                        final newData = {
                          'nama': namaCtrl.text,
                          'email': emailCtrl.text,
                          'telepon': teleponCtrl.text,
                          'alamat': alamatCtrl.text,
                        };
                        _allData.add(newData);
                        _filtered = List.from(_allData);
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD86487),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD86487),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        title: const Text(
          'SiTumbuh',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── HEADER ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kelola Data Orang Tua',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Total: ${_allData.length} orang tua terdaftar',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 14),

                // ─── TOMBOL TAMBAH ─────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _tambahOrangTua,
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    label: const Text(
                      'Tambah orang tua',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD86487),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ─── SEARCH BAR ────────────────────────
                TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'cari nama orang tua....',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Color(0xFFE0C8D0),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Color(0xFFD86487),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── LIST ORANG TUA ───────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Belum ada data orang tua'
                          : 'Tidak ditemukan hasil untuk "$_searchQuery"',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final data = _filtered[index];
                      return _orangTuaCard(data, index);
                    },
                  ),
          ),
        ],
      ),

      // ─── BOTTOM NAV ───────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _orangTuaCard(Map<String, String> data, int index) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama + ikon hapus
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data['nama']!,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
              GestureDetector(
                onTap: () => _hapus(index),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFD86487),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            data['email']!,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 10),

          // Telepon
          Row(
            children: [
              const Icon(Icons.phone, size: 14, color: Color(0xFFD86487)),
              const SizedBox(width: 6),
              Text(
                data['telepon']!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF444444)),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Alamat + tombol aksi
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Color(0xFFD86487)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data['alamat']!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF444444),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Tombol Detail
              OutlinedButton.icon(
                onPressed: () => _detail(data),
                icon: const Icon(Icons.search, size: 13),
                label: const Text('Detail', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF555555),
                  side: const BorderSide(color: Color(0xFFCCCCCC), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 6),
              // Tombol Ubah
              ElevatedButton.icon(
                onPressed: () => _ubah(index),
                icon: const Icon(Icons.edit, size: 13),
                label: const Text('Ubah', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD86487),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF7B1F3A)),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, 'Beranda', false),
          _navItem(Icons.people_outline, 'Data anak', false),
          _navItem(Icons.calendar_today_outlined, 'Posyandu', false),
          _navItem(Icons.person_outline, 'Profil', false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? Colors.white : Colors.white70, size: 24),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? Colors.white : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
