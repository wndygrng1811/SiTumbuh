import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';
import '../widgets/custom_app_bar.dart';

class Kehadiran extends StatefulWidget {
  const Kehadiran({super.key});

  @override
  State<Kehadiran> createState() => _KehadiranState();
}

class _KehadiranState extends State<Kehadiran> {
  int selectedTab = 0;
  String filter = "semua";
  String search = "";

  final _searchCtrl = TextEditingController();

  static const Color _primary = Color(0xFFE85D75);
  static const Color _bg = Color(0xFFF5F7FA);

  List<Map<String, dynamic>> _listJadwal = [];
  List<Map<String, dynamic>> _kehadiranList = [];

  int? _selectedJadwalId;
  String _selectedTanggal = '';

  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(() {
      setState(() {
        search = _searchCtrl.text;
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _loadSemuaJadwal();

      if (_listJadwal.isNotEmpty && _selectedJadwalId != null) {
        await _loadKehadiranByJadwal(_selectedJadwalId!);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error load data: $e');
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSemuaJadwal() async {
    try {
      final response = await ApiService.get('/kader/semua-jadwal');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          _listJadwal = List<Map<String, dynamic>>.from(data['data'] ?? []);

          if (_listJadwal.isNotEmpty) {
            _selectedJadwalId = _listJadwal.first['jadwal_id'];
            _selectedTanggal = _listJadwal.first['tanggal'] ?? '';
          }
        }
      }
    } catch (e) {
      print('Error load jadwal: $e');
    }
  }

  Future<void> _loadKehadiranByJadwal(int jadwalId) async {
    try {
      final response = await ApiService.get('/kehadiran/jadwal/$jadwalId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _kehadiranList = List<Map<String, dynamic>>.from(
              data['data'] ?? [],
            );
          });
        }
      }
    } catch (e) {
      print('Error load kehadiran: $e');
    }
  }

  Future<void> _simpanSemuaKehadiran() async {
    if (_selectedJadwalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jadwal terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final List<Map<String, dynamic>> dataKehadiran = _kehadiranList.map((
        item,
      ) {
        return {
          'anak_id': item['anak_id'],
          'status': item['hadir'] ? 'hadir' : 'tidak_hadir',
        };
      }).toList();

      final response = await ApiService.post('/kehadiran/simpan-semua', {
        'jadwal_id': _selectedJadwalId,
        'kehadiran': dataKehadiran,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data kehadiran berhasil disimpan'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Gagal menyimpan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error simpan kehadiran: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  List<Map<String, dynamic>> get _dataAnak {
    return _kehadiranList.map((item) {
      return {
        'anak_id': item['anak_id'],
        'nama': item['nama_anak'] ?? 'Unknown',
        'hadir': item['hadir'] ?? false,
        'nama_ortu': item['nama_ortu'] ?? '-',
        'no_telp_ortu': item['no_telp_ortu'] ?? '',
      };
    }).toList();
  }

  List<Map<String, dynamic>> get _dataOrangTua {
    Map<String, Map<String, dynamic>> orangTuaMap = {};

    for (var item in _kehadiranList) {
      final String namaOrtu = item['nama_ortu'] ?? '-';
      final String noTelp = item['no_telp_ortu'] ?? '';
      final bool hadir = item['hadir'] ?? false;
      final String namaAnak = item['nama_anak'] ?? 'Unknown';

      if (namaOrtu != '-') {
        if (!orangTuaMap.containsKey(namaOrtu)) {
          orangTuaMap[namaOrtu] = {
            'nama_ortu': namaOrtu,
            'no_telp': noTelp,
            'anak_tidak_hadir': <String>[],
          };
        }

        if (!hadir) {
          (orangTuaMap[namaOrtu]!['anak_tidak_hadir'] as List<String>).add(
            namaAnak,
          );
        }
      }
    }

    return orangTuaMap.values
        .where((o) => (o['anak_tidak_hadir'] as List).isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> get _currentData {
    return selectedTab == 0 ? _dataAnak : _dataOrangTua;
  }

  List<Map<String, dynamic>> get _filteredData {
    final data = _currentData;
    return data.where((item) {
      final String nama = selectedTab == 0
          ? (item['nama'] as String)
          : (item['nama_ortu'] as String);
      final bool cocokNama = nama.toLowerCase().contains(search.toLowerCase());

      if (filter == 'hadir' && selectedTab == 0) {
        return (item['hadir'] as bool) && cocokNama;
      }
      if (filter == 'tidak' && selectedTab == 0) {
        return !(item['hadir'] as bool) && cocokNama;
      }
      return cocokNama;
    }).toList();
  }

  int get _totalHadir => _dataAnak.where((e) => e['hadir'] as bool).length;
  int get _totalTidak => _dataAnak.where((e) => !(e['hadir'] as bool)).length;
  int get _total => _dataAnak.length;
  double get _persen => _total == 0 ? 0.0 : _totalHadir / _total;

  Future<void> _sendWhatsApp(
    String noTelp,
    String namaOrtu,
    List<String> anakTidakHadir,
  ) async {
    final String anakList = anakTidakHadir.join(', ');
    final String message =
        'Halo $namaOrtu,\n\nKami ingin mengingatkan bahwa anak Anda ($anakList) belum melakukan pengukuran pertumbuhan pada kegiatan Posyandu tanggal $_selectedTanggal.\n\nJangan lupa ya untuk hadir di kegiatan Posyandu berikutnya agar perkembangan buah hati tetap terpantau.\n\nTerima kasih.\n- Tim SiTumbuh';

    String formattedNumber = noTelp.replaceAll(RegExp(r'[^0-9]'), '');
    if (formattedNumber.startsWith('0')) {
      formattedNumber = '62${formattedNumber.substring(1)}';
    }
    if (!formattedNumber.startsWith('62')) {
      formattedNumber = '62$formattedNumber';
    }

    final Uri url = Uri.parse(
      'https://wa.me/$formattedNumber?text=${Uri.encodeComponent(message)}',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _onJadwalChanged(int? jadwalId) async {
    if (jadwalId == null) return;

    final selected = _listJadwal.firstWhere((j) => j['jadwal_id'] == jadwalId);

    setState(() {
      _selectedJadwalId = jadwalId;
      _selectedTanggal = selected['tanggal'] ?? '';
      _isLoading = true;
    });

    await _loadKehadiranByJadwal(jadwalId);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarKader(),
      backgroundColor: _bg,
      appBar: CustomAppBar(
        backgroundColor: _primary,
        iconColor: Colors.white,
        showBackButton: false,
        showDrawerIcon: true,
        showNotificationIcon: true,
      ),
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 4),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildJadwalDropdown(),
                  const SizedBox(height: 14),
                  _buildSearchRow(),
                  const SizedBox(height: 12),
                  _buildTab(),
                  const SizedBox(height: 12),
                  if (selectedTab == 0) _buildFilterRow(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _filteredData.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            itemCount: _filteredData.length,
                            itemBuilder: (_, i) =>
                                _buildItemCard(_filteredData[i]),
                          ),
                  ),
                  const SizedBox(height: 12),
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  // ===== DROPDOWN JADWAL =====
  Widget _buildJadwalDropdown() {
    if (_listJadwal.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            'Belum ada jadwal posyandu',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedJadwalId,
          isExpanded: true,
          hint: const Text('Pilih Jadwal Posyandu'),
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _primary,
            ),
          ),
          items: _listJadwal.map((jadwal) {
            return DropdownMenuItem<int>(
              value: jadwal['jadwal_id'],
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, size: 16, color: _primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${jadwal['tanggal']} - ${jadwal['nama_posyandu'] ?? 'Posyandu'}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: _onJadwalChanged,
        ),
      ),
    );
  }

  // ===== SEARCH =====
  Widget _buildSearchRow() {
    return TextField(
      controller: _searchCtrl,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: "Cari nama ${selectedTab == 0 ? 'anak' : 'orang tua'}...",
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
        suffixIcon: search.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => search = '');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  // ===== FILTER =====
  Widget _buildFilterRow() {
    return Row(
      children: [
        _filterChip("Semua", "semua"),
        const SizedBox(width: 8),
        _filterChip("Hadir", "hadir"),
        const SizedBox(width: 8),
        _filterChip("Tidak Hadir", "tidak"),
      ],
    );
  }

  Widget _filterChip(String label, String value) {
    final bool isActive = filter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => filter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? _primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? _primary : Colors.grey.shade200,
              width: isActive ? 1.5 : 0.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== TAB =====
  Widget _buildTab() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Row(
        children: [
          _tabBtn("Anak", 0, Icons.child_care_rounded),
          _tabBtn("Orang Tua", 1, Icons.people_rounded),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, int idx, IconData icon) {
    final bool active = selectedTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? _primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? Colors.white : Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : Colors.grey.shade600,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== ITEM CARD =====
  Widget _buildItemCard(Map<String, dynamic> item) {
    if (selectedTab == 0) {
      final bool hadir = item['hadir'] as bool;
      final String nama = item['nama'] as String;

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hadir ? Colors.green.shade100 : Colors.red.shade100,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: hadir ? Colors.green.shade50 : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: hadir ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
                    nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        hadir ? Icons.check_circle : Icons.cancel,
                        size: 12,
                        color: hadir ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hadir ? "Hadir" : "Tidak Hadir",
                        style: TextStyle(
                          color: hadir ? Colors.green : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!hadir)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Tidak Hadir",
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      final String namaOrtu = item['nama_ortu'] as String;
      final String noTelp = item['no_telp'] as String;
      final List<String> anakTidakHadir = (item['anak_tidak_hadir'] as List)
          .cast<String>();

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.orange.shade100, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  namaOrtu.isNotEmpty ? namaOrtu[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
                    namaOrtu,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Anak tidak hadir: ${anakTidakHadir.join(', ')}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (noTelp.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chat_rounded, color: Colors.green),
                  onPressed: () =>
                      _sendWhatsApp(noTelp, namaOrtu, anakTidakHadir),
                  iconSize: 22,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
          ],
        ),
      );
    }
  }

  // ===== SAVE BUTTON =====
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: _isSaving ? null : _simpanSemuaKehadiran,
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Simpan Data Kehadiran',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  // ===== EMPTY STATE =====
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            selectedTab == 0
                ? (search.isNotEmpty
                      ? "Tidak ada anak dengan nama '$search'"
                      : "Belum ada data kehadiran")
                : (search.isNotEmpty
                      ? "Tidak ada orang tua dengan nama '$search'"
                      : "Semua anak hadir ✅"),
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          const SizedBox(height: 4),
          if (search.isEmpty && selectedTab == 0)
            Text(
              "Silakan pilih jadwal posyandu",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
