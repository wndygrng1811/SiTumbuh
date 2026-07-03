import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
  Map<int, int> _anakCountMap = {};
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isSubmitting = false;

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
      // Load orang tua
      final response = await ApiService.get('/kader/orangtua');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          final List<Map<String, dynamic>> orangTuaList =
              List<Map<String, dynamic>>.from(data['data'] ?? []);

          // Load data anak untuk hitung jumlah anak
          await _loadAnakCount(orangTuaList);

          setState(() {
            _allData = orangTuaList;
            _filtered = List.from(_allData);
            _isLoading = false;
          });
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
          'Server merespon dengan kode ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error Koneksi', 'Tidak dapat terhubung ke server.');
    }
  }

  Future<void> _loadAnakCount(List<Map<String, dynamic>> orangTuaList) async {
    try {
      final response = await ApiService.get('/kader/semua-anak');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> anakList = data['data'] ?? [];

          print('=== DATA ANAK DARI API ===');
          print('Jumlah anak: ${anakList.length}');
          for (var anak in anakList) {
            print(
              'Anak: ${anak['nama']} - orangtua_id: ${anak['orangtua_id']}',
            );
          }

          // Hitung jumlah anak per orang tua
          _anakCountMap = {};
          for (var anak in anakList) {
            // Coba beberapa kemungkinan nama field
            int orangtuaId =
                anak['orangtua_id'] ??
                anak['orang_tua_id'] ??
                anak['orangTuaId'] ??
                anak['user_id'] ??
                0;

            if (orangtuaId > 0) {
              _anakCountMap[orangtuaId] = (_anakCountMap[orangtuaId] ?? 0) + 1;
            }
          }

          print('=== MAP ANAK COUNT ===');
          print(_anakCountMap);

          // Update data dengan jumlah anak
          for (var orangTua in orangTuaList) {
            int id =
                orangTua['orangtua_id'] ??
                orangTua['id'] ??
                orangTua['user_id'] ??
                0;

            // Coba juga cek dari berbagai kemungkinan
            int count = _anakCountMap[id] ?? 0;

            // Jika masih 0, coba cek dengan field lain
            if (count == 0) {
              // Coba cek dengan user_id
              int userId = orangTua['user_id'] ?? 0;
              count = _anakCountMap[userId] ?? 0;
            }

            orangTua['anak_count'] = count;
            print('Orang Tua: ${orangTua['nama']} (id: $id) - Anak: $count');
          }
        }
      }
    } catch (e) {
      print('Error load anak count: $e');
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
                    'Solusi:',
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE85D75).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_add_alt_1,
                color: Color(0xFFE85D75),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Tambah Orang Tua',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF5A2A2A),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  namaCtrl,
                  'Nama Lengkap',
                  Icons.person,
                  'Masukkan nama lengkap',
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  emailCtrl,
                  'Email',
                  Icons.email,
                  'Masukkan alamat email',
                  keyboardType: TextInputType.emailAddress,
                  isEmail: true,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  teleponCtrl,
                  'No Telepon',
                  Icons.phone,
                  'Contoh: 081234567890',
                  keyboardType: TextInputType.phone,
                  isPhone: true,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  alamatCtrl,
                  'Alamat',
                  Icons.location_on,
                  'Masukkan alamat lengkap',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Password akan dikirim otomatis ke email orang tua.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85D75),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: _isSubmitting
                ? null
                : () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      await _simpanOrangTua({
                        'nama': namaCtrl.text.trim(),
                        'email': emailCtrl.text.trim(),
                        'telepon': teleponCtrl.text.trim(),
                        'alamat': alamatCtrl.text.trim(),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444),
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: const Color(0xFFE85D75), size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE85D75),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label harus diisi';
            }
            if (isEmail) {
              String email = value.trim();
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(email)) {
                return 'Format email tidak valid (contoh: nama@email.com)';
              }
            }
            if (isPhone) {
              String phone = value.trim();
              final phoneRegex = RegExp(r'^[0-9]{10,13}$');
              if (!phoneRegex.hasMatch(phone)) {
                return 'Format no HP tidak valid (10-13 digit angka)';
              }
              if (!phone.startsWith('08') &&
                  !phone.startsWith('62') &&
                  !phone.startsWith('+62')) {
                return 'No HP harus diawali 08, 62, atau +62';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _simpanOrangTua(Map<String, dynamic> data) async {
    setState(() => _isSubmitting = true);

    try {
      final response = await ApiService.post('/kader/tambah-orangtua', data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _loadData();
        _showSuccessSnackbar(
          'Data orang tua berhasil ditambahkan! Password dikirim ke email.',
        );
      } else {
        final error = json.decode(response.body);
        _showErrorDialog(
          'Gagal Menambah',
          error['message'] ?? 'Terjadi kesalahan',
        );
      }
    } catch (e) {
      _showErrorDialog('Error Koneksi', 'Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _hapusOrangTua(int id, String nama) async {
    // Cek apakah ada anak
    int anakCount = _anakCountMap[id] ?? 0;
    if (anakCount > 0) {
      _showDeleteErrorDialog(nama, anakCount);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red.shade600, size: 24),
            const SizedBox(width: 10),
            const Text(
              'Hapus Data?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text('Yakin ingin menghapus data "$nama"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
        _showSuccessSnackbar('Data orang tua berhasil dihapus!');
      } else {
        final error = json.decode(response.body);
        _showErrorDialog(
          'Gagal Hapus',
          error['message'] ?? 'Terjadi kesalahan',
        );
      }
    } catch (e) {
      _showErrorDialog('Error Koneksi', 'Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _detailOrangTua(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE85D75).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFFE85D75),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Detail Orang Tua',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF5A2A2A),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(Icons.person, 'Nama', data['nama'] ?? '-'),
            const Divider(height: 12),
            _detailRow(Icons.email, 'Email', data['email'] ?? '-'),
            const Divider(height: 12),
            _detailRow(Icons.phone, 'No Telepon', data['no_telp'] ?? '-'),
            const Divider(height: 12),
            _detailRow(Icons.location_on, 'Alamat', data['alamat'] ?? '-'),
            const Divider(height: 12),
            _detailRow(
              Icons.people,
              'Jumlah Anak',
              '${_anakCountMap[data['orangtua_id']] ?? 0} anak',
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE85D75),
            ),
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
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE85D75).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFFE85D75)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarKader(),
      backgroundColor: const Color(0xFFF5F5F5),
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
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Data Orang Tua",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A2A2A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Total: ${_allData.length} orang tua",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _tambahOrangTua,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE85D75),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text(
                            'Tambah',
                            style: TextStyle(
                              fontSize: 13,
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
                        borderSide: BorderSide(color: Colors.grey.shade300!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Color(0xFFE85D75),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
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
                                    ? 'Belum ada data orang tua'
                                    : 'Tidak ditemukan hasil untuk "$_searchQuery"',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                              if (_searchQuery.isEmpty) ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 40,
                                  child: ElevatedButton.icon(
                                    onPressed: _tambahOrangTua,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE85D75),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                    ),
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Tambah Orang Tua'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          cacheExtent: 500,
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 8,
                            bottom: 100,
                          ),
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final data = _filtered[index];
                            return _buildCard(data);
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 0),
    );
  }

  Widget _buildCard(Map<String, dynamic> data) {
    int anakCount = _anakCountMap[data['orangtua_id']] ?? 0;

    // Debug: print data
    print(
      'Card: ${data['nama']} - orangtua_id: ${data['orangtua_id']} - anak: $anakCount',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: const Color(0xFFE85D75).withOpacity(0.1),
                radius: 22,
                child: Text(
                  (data['nama'] ?? '?')[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFE85D75),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['nama'] ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data['email'] ?? '-',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Info chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(Icons.phone, data['no_telp'] ?? '-'),
              _buildChip(Icons.location_on, data['alamat'] ?? '-'),
              _buildChip(Icons.people, '$anakCount Anak'),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                icon: Icons.visibility_outlined,
                label: 'Detail',
                color: Colors.blue,
                onTap: () => _detailOrangTua(data),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete_outline,
                label: 'Hapus',
                color: Colors.red,
                onTap: _isSubmitting
                    ? null
                    : () => _hapusOrangTua(data['orangtua_id'], data['nama']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
