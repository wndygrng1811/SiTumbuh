import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
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

  List<Map<String, dynamic>> _allData = [];
  List<Map<String, dynamic>> _filtered = [];
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isSubmitting = false;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============ LOAD DATA ORANG TUA ============
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('📡 Mengambil data orang tua...');

      final response = await ApiService.get('/kader/orangtua');

      print('📡 Status: ${response.statusCode}');
      print('📡 Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            _allData = List<Map<String, dynamic>>.from(data['data'] ?? []);
            _filtered = List.from(_allData);
            _isLoading = false;
          });
          print('✅ Berhasil memuat ${_allData.length} data orang tua');
        } else {
          setState(() => _isLoading = false);
          _showErrorDialog(
            'Gagal Memuat Data',
            data['message'] ?? 'Terjadi kesalahan saat memuat data',
          );
        }
      } else {
        setState(() => _isLoading = false);
        _showErrorDialog(
          'Koneksi Gagal',
          'Server merespon dengan kode ${response.statusCode}\nPastikan server berjalan.',
        );
      }
    } catch (e) {
      print('❌ Error load data: $e');
      setState(() => _isLoading = false);
      _showErrorDialog(
        'Error Koneksi',
        'Tidak dapat terhubung ke server.\nPeriksa koneksi internet dan pastikan server berjalan.\n\nError: $e',
      );
    }
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

  // ============ SNACKBAR NOTIFIKASI SUKSES ============
  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ============ DIALOG ERROR RAMAH USER ============
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ============ DIALOG ERROR HAPUS (KARENA PUNYA ANAK) ============
  void _showDeleteErrorDialog(String nama, int anakCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text('Tidak Bisa Dihapus!', style: TextStyle(fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data "$nama" tidak dapat dihapus karena memiliki $anakCount data anak yang terdaftar.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '💡 Solusi:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '1. Buka menu "Data Anak"',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '2. Hapus semua data anak dari orang tua ini',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '3. Kembali ke sini dan coba hapus lagi',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  // ============ TAMBAH ORANG TUA ============
  void _tambahOrangTua() {
    final formKey = GlobalKey<FormState>();
    final namaCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final teleponCtrl = TextEditingController();
    final alamatCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Tambah Orang Tua',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(namaCtrl, 'Nama Lengkap', Icons.person),
                const SizedBox(height: 12),
                _buildTextField(
                  emailCtrl,
                  'Email',
                  Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  teleponCtrl,
                  'No Telepon',
                  Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildTextField(alamatCtrl, 'Alamat', Icons.location_on),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85D75),
              foregroundColor: Colors.white,
            ),
            onPressed: _isSubmitting
                ? null
                : () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      await _simpanOrangTua({
                        'nama': namaCtrl.text,
                        'email': emailCtrl.text,
                        'telepon': teleponCtrl.text,
                        'alamat': alamatCtrl.text,
                      });
                    }
                  },
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _simpanOrangTua(Map<String, dynamic> data) async {
    setState(() => _isSubmitting = true);

    try {
      print('📤 Tambah orang tua: $data');

      final response = await ApiService.post('/kader/tambah-orangtua', data);

      print('📡 Response: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _loadData();
        _showSuccessSnackbar('✓ Data orang tua berhasil ditambahkan!');
      } else {
        final error = json.decode(response.body);
        _showErrorDialog(
          'Gagal Menambah',
          error['message'] ?? 'Terjadi kesalahan',
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      _showErrorDialog(
        'Error Koneksi',
        'Tidak dapat terhubung ke server.\n\nError: $e',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ============ UPDATE ORANG TUA ============
  Future<void> _updateOrangTua(int id, Map<String, dynamic> data) async {
    setState(() => _isSubmitting = true);

    try {
      print('📤 Update orang tua ID $id: $data');

      final response = await ApiService.put('/kader/orangtua/$id', data);

      print('📡 Response: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        await _loadData();
        _showSuccessSnackbar('✓ Data orang tua berhasil diupdate!');
      } else {
        final error = json.decode(response.body);
        _showErrorDialog(
          'Gagal Update',
          error['message'] ?? 'Terjadi kesalahan',
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      _showErrorDialog(
        'Error Koneksi',
        'Tidak dapat terhubung ke server.\n\nError: $e',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ============ HAPUS ORANG TUA (DENGAN CEK ANAK) ============
  Future<void> _hapusOrangTua(int id, String nama) async {
    // Cek apakah orang tua punya anak
    try {
      final responseAnak = await ApiService.get('/kader/semua-anak');
      if (responseAnak.statusCode == 200) {
        final dataAnak = json.decode(responseAnak.body);
        if (dataAnak['success'] == true) {
          final anakList = List<Map<String, dynamic>>.from(
            dataAnak['data'] ?? [],
          );
          final anakCount = anakList
              .where((a) => a['orangtua_id'] == id)
              .length;

          if (anakCount > 0) {
            _showDeleteErrorDialog(nama, anakCount);
            return;
          }
        }
      }
    } catch (e) {
      print('❌ Cek anak error: $e');
    }

    // Konfirmasi hapus jika tidak punya anak
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Yakin ingin menghapus data "$nama"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);

    try {
      print('🗑️ Hapus orang tua ID: $id');

      final response = await ApiService.delete('/kader/orangtua/$id');

      print('📡 Response: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        await _loadData();
        _showSuccessSnackbar('✓ Data orang tua berhasil dihapus!');
      } else {
        final error = json.decode(response.body);
        _showErrorDialog(
          'Gagal Hapus',
          error['message'] ?? 'Terjadi kesalahan',
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      _showErrorDialog(
        'Error Koneksi',
        'Tidak dapat terhubung ke server.\n\nError: $e',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ============ FORM EDIT ============
  void _editOrangTua(Map<String, dynamic> data, int index) {
    final formKey = GlobalKey<FormState>();
    final id = data['orangtua_id'];

    final namaCtrl = TextEditingController(text: data['nama']);
    final emailCtrl = TextEditingController(text: data['email']);
    final teleponCtrl = TextEditingController(text: data['no_telp']);
    final alamatCtrl = TextEditingController(text: data['alamat']);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Data Orang Tua',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(namaCtrl, 'Nama Lengkap', Icons.person),
                const SizedBox(height: 12),
                _buildTextField(
                  emailCtrl,
                  'Email',
                  Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  teleponCtrl,
                  'No Telepon',
                  Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildTextField(alamatCtrl, 'Alamat', Icons.location_on),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85D75),
              foregroundColor: Colors.white,
            ),
            onPressed: _isSubmitting
                ? null
                : () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      await _updateOrangTua(id, {
                        'nama': namaCtrl.text,
                        'email': emailCtrl.text,
                        'telepon': teleponCtrl.text,
                        'alamat': alamatCtrl.text,
                      });
                    }
                  },
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ============ DETAIL ORANG TUA ============
  void _detailOrangTua(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Detail Orang Tua',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(Icons.person, 'Nama', data['nama']),
            const Divider(),
            _detailRow(Icons.email, 'Email', data['email']),
            const Divider(),
            _detailRow(Icons.phone, 'No Telepon', data['no_telp']),
            const Divider(),
            _detailRow(Icons.location_on, 'Alamat', data['alamat']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFFE85D75)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFE85D75)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '$label harus diisi';
        if (label == 'Email' && !value.contains('@'))
          return 'Email tidak valid';
        if (label == 'No Telepon' && value.length < 10)
          return 'Nomor telepon minimal 10 digit';
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarKader(),
      backgroundColor: const Color(0xFFF5EDEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE85D75),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Data Orang Tua',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: ${_allData.length} orang tua',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : _tambahOrangTua,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Tambah'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE85D75),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari nama orang tua...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFFE85D75),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'Belum ada data orang tua'
                                : 'Tidak ditemukan hasil untuk "$_searchQuery"',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final data = _filtered[index];
                              return _buildCard(data, index);
                            },
                          ),
                        ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavbarKader(selectedIndex: _selectedIndex),
    );
  }

  // ============ CARD ORANG TUA (FIX OVERFLOW) ============
  Widget _buildCard(Map<String, dynamic> data, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 ROW NAMA + TOMBOL - FIX OVERFLOW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  data['nama'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.visibility,
                      size: 20,
                      color: Colors.blue,
                    ),
                    tooltip: 'Lihat detail',
                    onPressed: () => _detailOrangTua(data),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Color(0xFFE85D75),
                    ),
                    tooltip: 'Edit data',
                    onPressed: _isSubmitting
                        ? null
                        : () => _editOrangTua(data, index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    tooltip: 'Hapus data',
                    onPressed: _isSubmitting
                        ? null
                        : () =>
                              _hapusOrangTua(data['orangtua_id'], data['nama']),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Email Row
          Row(
            children: [
              const Icon(Icons.email, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data['email'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Phone Row
          Row(
            children: [
              const Icon(Icons.phone, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  data['no_telp'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Alamat Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data['alamat'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
