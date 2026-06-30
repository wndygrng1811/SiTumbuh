import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';
import '../widgets/custom_app_bar.dart';

class DataPengukuran {
  final DateTime tanggal;
  final int usiaBulan;
  final double beratBadan;
  final double tinggiBadan;
  final double? lingkarKepala;

  const DataPengukuran({
    required this.tanggal,
    required this.usiaBulan,
    required this.beratBadan,
    required this.tinggiBadan,
    this.lingkarKepala,
  });
}

class StatusGizi {
  final String labelBbTb;
  final String labelTbU;
  final String labelBbU;
  final double zScoreBbTb;
  final double zScoreTbU;
  final double zScoreBbU;
  final Color warnaBbTb;
  final Color warnaTbU;
  final Color warnaBbU;

  const StatusGizi({
    required this.labelBbTb,
    required this.labelTbU,
    required this.labelBbU,
    required this.zScoreBbTb,
    required this.zScoreTbU,
    required this.zScoreBbU,
    required this.warnaBbTb,
    required this.warnaTbU,
    required this.warnaBbU,
  });
}

class WHOZScore {
  static const List<double> _medTbUL = [
    49.9,
    54.7,
    58.4,
    61.4,
    63.9,
    65.9,
    67.6,
    69.2,
    70.6,
    72.0,
    73.3,
    74.5,
    75.7,
    76.9,
    78.0,
    79.1,
    80.2,
    81.2,
    82.3,
    83.2,
    84.2,
    85.1,
    86.0,
    87.1,
    88.0,
  ];
  static const List<double> _medTbUP = [
    49.1,
    53.7,
    57.1,
    59.8,
    62.1,
    64.0,
    65.7,
    67.3,
    68.7,
    70.1,
    71.5,
    72.8,
    74.0,
    75.2,
    76.4,
    77.5,
    78.6,
    79.7,
    80.7,
    81.7,
    82.7,
    83.7,
    84.6,
    85.5,
    86.4,
  ];
  static const double _sdTbU = 2.5;

  static const List<double> _medBbUL = [
    3.3,
    4.5,
    5.6,
    6.4,
    7.0,
    7.5,
    7.9,
    8.3,
    8.6,
    8.9,
    9.2,
    9.4,
    9.6,
    9.9,
    10.1,
    10.3,
    10.5,
    10.7,
    10.9,
    11.1,
    11.3,
    11.5,
    11.8,
    12.0,
    12.2,
  ];
  static const List<double> _medBbUP = [
    3.2,
    4.2,
    5.1,
    5.8,
    6.4,
    6.9,
    7.3,
    7.6,
    7.9,
    8.2,
    8.5,
    8.7,
    8.9,
    9.2,
    9.4,
    9.6,
    9.8,
    10.0,
    10.2,
    10.4,
    10.6,
    10.9,
    11.1,
    11.3,
    11.5,
  ];
  static const double _sdBbU = 1.2;

  static double _z(double val, double median, double sd) => (val - median) / sd;
  static double _medTbU(int bln, String jk) =>
      (jk == 'L' ? _medTbUL : _medTbUP)[bln.clamp(0, 24)];
  static double _medBbU(int bln, String jk) =>
      (jk == 'L' ? _medBbUL : _medBbUP)[bln.clamp(0, 24)];
  static double _medBbTb(double tb) {
    if (tb < 65) return tb * 0.115;
    if (tb < 85) return tb * 0.12;
    return (tb - 100) * 0.9 + 10;
  }

  static StatusGizi kalkulasi({
    required int usiaBulan,
    required double bb,
    required double tb,
    required String jk,
  }) {
    final zTbU = _z(tb, _medTbU(usiaBulan, jk), _sdTbU);
    final zBbU = _z(bb, _medBbU(usiaBulan, jk), _sdBbU);
    final zBbTb = _z(bb, _medBbTb(tb), 1.0);

    String labelTbU;
    Color warnaTbU;
    if (zTbU < -3) {
      labelTbU = 'Severely Stunted';
      warnaTbU = const Color(0xFFB71C1C);
    } else if (zTbU < -2) {
      labelTbU = 'Stunted';
      warnaTbU = const Color(0xFFE53935);
    } else if (zTbU > 3) {
      labelTbU = 'Tinggi';
      warnaTbU = const Color(0xFF1565C0);
    } else {
      labelTbU = 'Normal';
      warnaTbU = const Color(0xFF2E7D32);
    }

    String labelBbU;
    Color warnaBbU;
    if (zBbU < -3) {
      labelBbU = 'Severely Underweight';
      warnaBbU = const Color(0xFFB71C1C);
    } else if (zBbU < -2) {
      labelBbU = 'Underweight';
      warnaBbU = const Color(0xFFE53935);
    } else if (zBbU > 2) {
      labelBbU = 'Overweight';
      warnaBbU = const Color(0xFFE65100);
    } else {
      labelBbU = 'Normal';
      warnaBbU = const Color(0xFF2E7D32);
    }

    String labelBbTb;
    Color warnaBbTb;
    if (zBbTb < -3) {
      labelBbTb = 'Severely Wasted';
      warnaBbTb = const Color(0xFFB71C1C);
    } else if (zBbTb < -2) {
      labelBbTb = 'Wasted';
      warnaBbTb = const Color(0xFFE53935);
    } else if (zBbTb > 2) {
      labelBbTb = 'Obese';
      warnaBbTb = const Color(0xFFE65100);
    } else if (zBbTb > 1) {
      labelBbTb = 'Berisiko Gemuk';
      warnaBbTb = const Color(0xFFF57C00);
    } else {
      labelBbTb = 'Normal';
      warnaBbTb = const Color(0xFF2E7D32);
    }

    return StatusGizi(
      labelBbTb: labelBbTb,
      labelTbU: labelTbU,
      labelBbU: labelBbU,
      zScoreBbTb: double.parse(zBbTb.toStringAsFixed(2)),
      zScoreTbU: double.parse(zTbU.toStringAsFixed(2)),
      zScoreBbU: double.parse(zBbU.toStringAsFixed(2)),
      warnaBbTb: warnaBbTb,
      warnaTbU: warnaTbU,
      warnaBbU: warnaBbU,
    );
  }
}

class DataPertumbuhanPage extends StatefulWidget {
  const DataPertumbuhanPage({super.key});

  @override
  State<DataPertumbuhanPage> createState() => _DataPertumbuhanPageState();
}

class _DataPertumbuhanPageState extends State<DataPertumbuhanPage> {
  static const Color _primary = Color(0xFFE85D75);
  static const Color _bg = Color(0xFFF5F7FA);

  List<dynamic> _listAnak = [];
  List<dynamic> _listJadwal = [];
  int? _selectedAnakId;
  int? _selectedJadwalId;
  String _namaAnak = 'Pilih Anak';
  String _jkAnak = 'L';
  String _namaOrtu = '';
  String _tanggalLahir = '';
  List<DataPengukuran> _riwayat = [];
  bool _isLoading = true;
  int _usiaOtomatis = 0;

  final _formKey = GlobalKey<FormState>();
  final _ctrlBb = TextEditingController();
  final _ctrlTb = TextEditingController();
  final _ctrlLk = TextEditingController();
  bool _isSaving = false;

  StatusGizi? _statusGizi;
  DataPengukuran? _pengukuranTerbaru;

  double _safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadJadwal();
  }

  @override
  void dispose() {
    _ctrlBb.dispose();
    _ctrlTb.dispose();
    _ctrlLk.dispose();
    super.dispose();
  }

  Future<void> _loadJadwal() async {
    try {
      final response = await ApiService.get('/kader/semua-jadwal');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _listJadwal = data['data'] ?? [];
            if (_listJadwal.isNotEmpty) {
              _selectedJadwalId = _listJadwal.first['jadwal_id'];
            }
          });
        }
      }
    } catch (e) {
      print('Error load jadwal: $e');
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/kader/semua-anak');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _listAnak = data['data'] ?? [];
            if (_listAnak.isNotEmpty) {
              _selectedAnakId = _listAnak[0]['anak_id'];
              _namaAnak = _listAnak[0]['nama_anak'] ?? 'Anak';
              _jkAnak = _listAnak[0]['jenis_kelamin'] ?? 'L';
              _namaOrtu = _listAnak[0]['nama_ortu'] ?? '';
              _tanggalLahir = _listAnak[0]['tanggal_lahir'] ?? '';
              _hitungUsiaOtomatis();
            }
            _isLoading = false;
          });
          if (_selectedAnakId != null) await _loadRiwayat();
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error load data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _hitungUsiaOtomatis() {
    if (_tanggalLahir.isEmpty) {
      _usiaOtomatis = 12;
      return;
    }
    try {
      final lahir = DateTime.parse(_tanggalLahir);
      final now = DateTime.now();
      int bulan = (now.year - lahir.year) * 12 + now.month - lahir.month;
      if (bulan < 0) bulan = 0;
      if (bulan > 60) bulan = 60;
      setState(() => _usiaOtomatis = bulan);
    } catch (e) {
      _usiaOtomatis = 12;
    }
  }

  Future<void> _loadRiwayat() async {
    if (_selectedAnakId == null) return;
    try {
      final response = await ApiService.get('/pertumbuhan/$_selectedAnakId');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> riwayatData = data['data'] ?? [];
          final riwayatList = riwayatData.map((item) {
            double berat = _safeParseDouble(item['berat_badan']);
            double tinggi = _safeParseDouble(item['tinggi_badan']);
            double? lk = item['lingkar_kepala'] != null
                ? _safeParseDouble(item['lingkar_kepala'])
                : null;
            DateTime tanggal;
            try {
              tanggal = DateTime.parse(
                item['created_at'] ?? DateTime.now().toString(),
              );
            } catch (e) {
              tanggal = DateTime.now();
            }
            return DataPengukuran(
              tanggal: tanggal,
              usiaBulan: _hitungUsiaBulan(item['created_at']),
              beratBadan: berat,
              tinggiBadan: tinggi,
              lingkarKepala: lk,
            );
          }).toList();
          setState(() {
            _riwayat = riwayatList;
          });
        }
      }
    } catch (e) {
      print('Error load riwayat: $e');
    }
  }

  int _hitungUsiaBulan(String? tanggalPengukuran) {
    if (tanggalPengukuran == null) return 12;
    try {
      final selectedAnak = _listAnak.firstWhere(
        (a) => a['anak_id'] == _selectedAnakId,
        orElse: () => {},
      );
      final tanggalLahirStr = selectedAnak['tanggal_lahir'];
      if (tanggalLahirStr == null) return 12;
      final lahir = DateTime.parse(tanggalLahirStr);
      final pengukuran = DateTime.parse(tanggalPengukuran);
      int bulan =
          (pengukuran.year - lahir.year) * 12 + pengukuran.month - lahir.month;
      if (bulan < 0) bulan = 0;
      return bulan;
    } catch (e) {
      return 12;
    }
  }

  Future<void> _onAnakChanged(int? anakId) async {
    if (anakId == null) return;
    setState(() {
      _selectedAnakId = anakId;
      final selectedAnak = _listAnak.firstWhere((a) => a['anak_id'] == anakId);
      _namaAnak = selectedAnak['nama_anak'] ?? 'Anak';
      _jkAnak = selectedAnak['jenis_kelamin'] ?? 'L';
      _namaOrtu = selectedAnak['nama_ortu'] ?? '';
      _tanggalLahir = selectedAnak['tanggal_lahir'] ?? '';
      _riwayat = [];
      _statusGizi = null;
      _pengukuranTerbaru = null;
      _hitungUsiaOtomatis();
    });
    await _loadRiwayat();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAnakId == null) {
      _showSnack('Silakan pilih anak terlebih dahulu', Colors.orange);
      return;
    }
    if (_selectedJadwalId == null) {
      _showSnack(
        'Silakan pilih jadwal posyandu terlebih dahulu',
        Colors.orange,
      );
      return;
    }
    setState(() => _isSaving = true);
    final bb = double.parse(_ctrlBb.text.trim());
    final tb = double.parse(_ctrlTb.text.trim());
    final lk = _ctrlLk.text.trim().isNotEmpty
        ? double.tryParse(_ctrlLk.text.trim())
        : null;
    final status = WHOZScore.kalkulasi(
      usiaBulan: _usiaOtomatis,
      bb: bb,
      tb: tb,
      jk: _jkAnak,
    );
    try {
      final selectedAnak = _listAnak.firstWhere(
        (a) => a['anak_id'] == _selectedAnakId,
      );
      final int orangtuaId = selectedAnak['orangtua_id'] ?? 0;
      final response = await ApiService.post('/pertumbuhan', {
        'anak_id': _selectedAnakId,
        'orangtua_id': orangtuaId,
        'jadwal_id': _selectedJadwalId,
        'berat_badan': bb,
        'tinggi_badan': tb,
        'lingkar_kepala': lk ?? 0,
        'status_gizi': status.labelBbTb,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final pengukuran = DataPengukuran(
            tanggal: DateTime.now(),
            usiaBulan: _usiaOtomatis,
            beratBadan: bb,
            tinggiBadan: tb,
            lingkarKepala: lk,
          );
          setState(() {
            _riwayat.insert(0, pengukuran);
            _pengukuranTerbaru = pengukuran;
            _statusGizi = status;
            _isSaving = false;
          });
          _showSnack('Data berhasil disimpan', Colors.green);
          _ctrlBb.clear();
          _ctrlTb.clear();
          _ctrlLk.clear();
        } else {
          throw Exception(data['message'] ?? 'Gagal menyimpan');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isSaving = false);
      _showSnack('Error: $e', Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 3),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== HEADER =====
                  _buildHeader(),
                  const SizedBox(height: 20),

                  // ===== PILIH ANAK & JADWAL =====
                  _buildSectionLabel('Pilih Anak & Jadwal'),
                  const SizedBox(height: 10),
                  _buildSelectionCard(),
                  const SizedBox(height: 20),

                  // ===== INPUT PENGUKURAN =====
                  _buildSectionLabel('Input Pengukuran'),
                  const SizedBox(height: 10),
                  _buildFormCard(),
                  const SizedBox(height: 20),

                  // ===== STATUS GIZI =====
                  if (_statusGizi != null) ...[
                    _buildSectionLabel('Hasil Analisis Z-Score'),
                    const SizedBox(height: 10),
                    _buildStatusGiziCard(),
                    const SizedBox(height: 20),
                  ],

                  // ===== RIWAYAT =====
                  _buildSectionLabel('Riwayat Pengukuran'),
                  const SizedBox(height: 10),
                  _buildRiwayatCard(),
                ],
              ),
            ),
    );
  }

  // ===== HEADER =====
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE85D75), Color(0xFFD44B66)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monitor_heart_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catat Pertumbuhan Anak',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Input pengukuran dan pantau status gizi',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_riwayat.length} data',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== SECTION LABEL =====
  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  // ===== SELECTION CARD =====
  Widget _buildSelectionCard() {
    return _card(
      child: Column(
        children: [
          // Dropdown Anak
          _buildDropdown(
            label: 'Pilih Anak',
            icon: Icons.child_care_rounded,
            value: _selectedAnakId,
            items: _listAnak.map((anak) {
              return DropdownMenuItem<int>(
                value: anak['anak_id'],
                child: Row(
                  children: [
                    Icon(
                      anak['jenis_kelamin'] == 'L'
                          ? Icons.boy_rounded
                          : Icons.girl_rounded,
                      color: _primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${anak['nama_anak']} (${anak['nama_ortu']})',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: _onAnakChanged,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 12),
          // Dropdown Jadwal
          _buildDropdown(
            label: 'Pilih Jadwal Posyandu',
            icon: Icons.calendar_month_rounded,
            value: _selectedJadwalId,
            items: _listJadwal.map((jadwal) {
              return DropdownMenuItem<int>(
                value: jadwal['jadwal_id'],
                child: Text(
                  '${jadwal['tanggal']} - ${jadwal['nama_posyandu'] ?? 'Posyandu'}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: (v) => setState(() => _selectedJadwalId = v),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: _primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: Text(
                'Pilih $label',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
              dropdownColor: Colors.white,
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _primary,
                  size: 18,
                ),
              ),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ===== FORM CARD =====
  Widget _buildFormCard() {
    return _card(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Info Usia Otomatis
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFE85D75),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Usia: $_usiaOtomatis bulan (otomatis dari tanggal lahir)',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildFormField(
                    label: 'Berat Badan (kg)',
                    hint: '0.5 - 50',
                    controller: _ctrlBb,
                    icon: Icons.monitor_weight_rounded,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      final n = double.tryParse(v);
                      if (n == null || n <= 0 || n > 50) {
                        return 'Nilai tidak valid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFormField(
                    label: 'Tinggi Badan (cm)',
                    hint: '30 - 120',
                    controller: _ctrlTb,
                    icon: Icons.height_rounded,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      final n = double.tryParse(v);
                      if (n == null || n <= 0 || n > 200) {
                        return 'Nilai tidak valid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFormField(
              label: 'Lingkar Kepala (cm)',
              hint: 'Opsional',
              controller: _ctrlLk,
              icon: Icons.face_6_rounded,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSaving ? null : _simpan,
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
                            'Simpan Data',
                            style: TextStyle(
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
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            prefixIcon: Icon(icon, color: _primary, size: 18),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
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
            errorStyle: const TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  // ===== STATUS GIZI CARD =====
  Widget _buildStatusGiziCard() {
    final s = _statusGizi!;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF2E7D32),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Status Gizi (WHO Z-Score)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildZScoreChip(
                title: 'BB/TB',
                subtitle: 'Wasting',
                label: s.labelBbTb,
                zScore: s.zScoreBbTb,
                warna: s.warnaBbTb,
              ),
              const SizedBox(width: 8),
              _buildZScoreChip(
                title: 'TB/U',
                subtitle: 'Stunting',
                label: s.labelTbU,
                zScore: s.zScoreTbU,
                warna: s.warnaTbU,
              ),
              const SizedBox(width: 8),
              _buildZScoreChip(
                title: 'BB/U',
                subtitle: 'Underweight',
                label: s.labelBbU,
                zScore: s.zScoreBbU,
                warna: s.warnaBbU,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZScoreChip({
    required String title,
    required String subtitle,
    required String label,
    required double zScore,
    required Color warna,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: warna.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: warna.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: warna,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 8, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 4),
            Text(
              'Z ${zScore > 0 ? '+' : ''}${zScore.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: warna,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: warna,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== RIWAYAT CARD =====
  Widget _buildRiwayatCard() {
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_riwayat.length} Catatan',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Terbaru',
                    style: TextStyle(
                      fontSize: 10,
                      color: _primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _tableHeader('Tanggal', flex: 3),
                _tableHeader('Usia', flex: 2),
                _tableHeader('BB', flex: 2),
                _tableHeader('TB', flex: 2),
                _tableHeader('LK', flex: 2),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          if (_riwayat.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Belum ada data pengukuran',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ...List.generate(_riwayat.length, (i) {
              final item = _riwayat[i];
              final isEven = i % 2 == 0;
              return Column(
                children: [
                  Container(
                    color: isEven ? Colors.white : Colors.grey.shade50,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    child: Row(
                      children: [
                        _tableCell(
                          '${item.tanggal.day}/${item.tanggal.month}/${item.tanggal.year}',
                          flex: 3,
                        ),
                        _tableCell('${item.usiaBulan}', flex: 2),
                        _tableCell(item.beratBadan.toStringAsFixed(1), flex: 2),
                        _tableCell(
                          item.tinggiBadan.toStringAsFixed(1),
                          flex: 2,
                        ),
                        _tableCell(
                          item.lingkarKepala != null
                              ? item.lingkarKepala!.toStringAsFixed(1)
                              : '-',
                          flex: 2,
                        ),
                      ],
                    ),
                  ),
                  if (i < _riwayat.length - 1)
                    const Divider(
                      height: 1,
                      color: Color(0xFFF5F5F5),
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _tableHeader(String text, {required int flex}) => Expanded(
    flex: flex,
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Color(0xFF888888),
      ),
    ),
  );

  Widget _tableCell(String text, {required int flex}) => Expanded(
    flex: flex,
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFF333333),
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: child,
    );
  }
}
