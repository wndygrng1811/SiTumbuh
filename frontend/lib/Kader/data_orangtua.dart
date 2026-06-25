import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';
import '../widgets/custom_app_bar.dart';

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
  final int _selectedIndex = 0;

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
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

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

  void _tambahOrangTua() {
    final formKey = GlobalKey<FormState>();
    final namaCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final teleponCtrl = TextEditingController();
    final alamatCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

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
                const SizedBox(height: 12),
                _buildTextField(
                  passwordCtrl,
                  'Password',
                  Icons.lock,
                  obscure: true,
                ),
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
                      if (passwordCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password harus diisi!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      if (passwordCtrl.text.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password minimal 6 karakter!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                      await _simpanOrangTua({
                        'nama': namaCtrl.text,
                        'email': emailCtrl.text,
                        'telepon': teleponCtrl.text,
                        'alamat': alamatCtrl.text,
                        'password': passwordCtrl.text,
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
      final response = await ApiService.post('/kader/tambah-orangtua', data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _loadData();
        _showSuccessSnackbar(
          '✓ Data orang tua berhasil ditambahkan! Email notifikasi telah dikirim.',
        );
      } else {
        final error = json.decode(response.body);
        _showErrorDialog(
          'Gagal Menambah',
          error['message'] ?? 'Terjadi kesalahan',
        );
      }
    } catch (e) {
      _showErrorDialog(
        'Error Koneksi',
        'Tidak dapat terhubung ke server.\n\nError: $e',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _updateOrangTua(int id, Map<String, dynamic> data) async {
    setState(() => _isSubmitting = true);

    try {
      final response = await ApiService.put('/kader/orangtua/$id', data);

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
      _showErrorDialog(
        'Error Koneksi',
        'Tidak dapat terhubung ke server.\n\nError: $e',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _hapusOrangTua(int id, String nama) async {
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

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Yakin ingin menghapus数据 "$nama"?'),
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
      final response = await ApiService.delete('/kader/orangtua/$id');

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
      _showErrorDialog(
        'Error Koneksi',
        'Tidak dapat terhubung ke server.\n\nError: $e',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

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
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFE85D75)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '$label harus diisi';
        if (label == 'Email' && !value.contains('@')) {
          return 'Email tidak valid';
        }
        if (label == 'No Telepon' && value.length < 10) {
          return 'Nomor telepon minimal 10 digit';
        }
        if (label == 'Password' && value.length < 6) {
          return 'Password minimal 6 karakter';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarKader(),
      backgroundColor: const Color(0xFFF5EDEE),
      appBar: CustomAppBar(
        backgroundColor: const Color(0xFFE85D75),
        iconColor: Colors.white,
        showBackButton: false,
        showDrawerIcon: true,
        showNotificationIcon: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Kelola Data Orang Tua",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A2A2A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total: ${_allData.length} orang tua terdaftar",
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      // 🔥 TOMBOL TAMBAH YANG DIPERKECIL (TANPA IKON)
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _tambahOrangTua,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE85D75),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            '+Tambah',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari nama orang tua...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
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
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'Belum ada数据 orang tua'
                                    : 'Tidak ditemukan hasil untuk "$_searchQuery"',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                              const SizedBox(height: 16),
                              if (_searchQuery.isEmpty)
                                SizedBox(
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: _tambahOrangTua,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE85D75),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                    ),
                                    child: const Text('Tambah Orang Tua'),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final data = _filtered[index];
                              return _buildCard(data);
                            },
                          ),
                        ),
                ),
              ],
            ),
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 0),
    );
  }

  Widget _buildCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Text(
            data['nama'] ?? '-',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A2A2A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.email, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data['email'] ?? '-',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data['no_telp'] ?? '-',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data['alamat'] ?? '-',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _detailOrangTua(data),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Detail', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _isSubmitting ? null : () => _editOrangTua(data, 0),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE85D75),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Ubah', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () => _hapusOrangTua(data['orangtua_id'], data['nama']),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Hapus', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
