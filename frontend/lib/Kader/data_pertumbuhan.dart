import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class _DataPertumbuhanPageState extends State<DataPertumbuhanPage>
    with SingleTickerProviderStateMixin {
  static const Color _pink = Color(0xFFE85D75);

  List<dynamic> _listAnak = [];
  List<dynamic> _listJadwal = [];
  int? _selectedAnakId;
  int? _selectedJadwalId;
  String _namaAnak = 'Pilih Anak';
  String _jkAnak = 'L';
  String _namaOrtu = '';
  List<DataPengukuran> _riwayat = [];
  bool _isLoading = true;

  late TabController _tabController;
  int _tabGrafik = 0;

  final _formKey = GlobalKey<FormState>();
  final _ctrlTanggal = TextEditingController();
  final _ctrlUsia = TextEditingController();
  final _ctrlBb = TextEditingController();
  final _ctrlTb = TextEditingController();
  final _ctrlLk = TextEditingController();
  DateTime? _selectedDate;
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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(
      () => setState(() => _tabGrafik = _tabController.index),
    );
    _loadData();
    _loadJadwal();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ctrlTanggal.dispose();
    _ctrlUsia.dispose();
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    print('Role user: $role');
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
      _riwayat = [];
      _statusGizi = null;
      _pengukuranTerbaru = null;
    });
    await _loadRiwayat();
  }

  String _bulanStr(int m) => [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ][m];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _pink,
            onPrimary: Colors.white,
            onSurface: Color(0xFF2D2D2D),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _ctrlTanggal.text =
            '${picked.day.toString().padLeft(2, '0')} ${_bulanStr(picked.month)} ${picked.year}';
      });
    }
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
    final usia = int.parse(_ctrlUsia.text.trim());
    final bb = double.parse(_ctrlBb.text.trim());
    final tb = double.parse(_ctrlTb.text.trim());
    final lk = _ctrlLk.text.trim().isNotEmpty
        ? double.tryParse(_ctrlLk.text.trim())
        : null;
    final status = WHOZScore.kalkulasi(
      usiaBulan: usia,
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
        'tanggal_pengukuran': _selectedDate?.toIso8601String().split('T').first,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final pengukuran = DataPengukuran(
            tanggal: _selectedDate ?? DateTime.now(),
            usiaBulan: usia,
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
          _ctrlUsia.clear();
          _ctrlBb.clear();
          _ctrlTb.clear();
          _ctrlLk.clear();
          _ctrlTanggal.clear();
          setState(() => _selectedDate = null);
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      drawer: const SidebarKader(),
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _pink))
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSectionLabel('Pilih Anak dan Jadwal'),
                      const SizedBox(height: 12),
                      _buildSelectionCard(),
                      const SizedBox(height: 24),
                      _buildSectionLabel('Input Pengukuran'),
                      const SizedBox(height: 12),
                      _buildFormCard(),
                      if (_statusGizi != null) ...[
                        const SizedBox(height: 24),
                        _buildSectionLabel('Hasil Analisis Z-Score'),
                        const SizedBox(height: 12),
                        _buildStatusGiziCard(),
                      ],
                      const SizedBox(height: 24),
                      _buildSectionLabel('Grafik Pertumbuhan'),
                      const SizedBox(height: 12),
                      _buildGrafikCard(),
                      const SizedBox(height: 24),
                      _buildSectionLabel('Riwayat Pengukuran'),
                      const SizedBox(height: 12),
                      _buildRiwayatCard(),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      backgroundColor: _pink,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'SiTumbuh',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 22),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(color: _pink),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Catat Pertumbuhan Anak',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Input pengukuran dan pantau status gizi',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _pink,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dropdownLabel('Anak', Icons.child_care_rounded),
          const SizedBox(height: 8),
          _dropdownContainer(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: _selectedAnakId,
                hint: const Text('Pilih anak'),
                dropdownColor: Colors.white,
                icon: const Icon(
                  Icons.expand_more_rounded,
                  color: _pink,
                  size: 20,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D2D2D),
                ),
                items: _listAnak.map((anak) {
                  return DropdownMenuItem<int>(
                    value: anak['anak_id'],
                    child: Row(
                      children: [
                        Icon(
                          anak['jenis_kelamin'] == 'L'
                              ? Icons.boy_rounded
                              : Icons.girl_rounded,
                          color: _pink,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${anak['nama_anak']}  •  ${anak['nama_ortu']}',
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
            ),
          ),
          if (_selectedAnakId != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _pink.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: _pink.withOpacity(0.15),
                    child: Icon(
                      _jkAnak == 'L' ? Icons.boy_rounded : Icons.girl_rounded,
                      color: _pink,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _namaAnak,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        Text(
                          '${_jkAnak == 'L' ? 'Laki-laki' : 'Perempuan'}  ·  Ortu: $_namaOrtu',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _pink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_riwayat.length} data',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 16),
          _dropdownLabel('Jadwal Posyandu', Icons.calendar_month_rounded),
          const SizedBox(height: 8),
          _dropdownContainer(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: _selectedJadwalId,
                hint: const Text('Pilih jadwal'),
                dropdownColor: Colors.white,
                icon: const Icon(
                  Icons.expand_more_rounded,
                  color: _pink,
                  size: 20,
                ),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D2D2D),
                ),
                items: _listJadwal.map((jadwal) {
                  return DropdownMenuItem<int>(
                    value: jadwal['jadwal_id'],
                    child: Text(
                      '${jadwal['tanggal']}  —  ${jadwal['nama_posyandu'] ?? 'Posyandu'}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedJadwalId = v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _pink),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555),
          ),
        ),
      ],
    );
  }

  Widget _dropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: child,
    );
  }

  Widget _buildFormCard() {
    return _card(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(
              label: 'Tanggal Pengukuran',
              hint: 'Pilih tanggal',
              ctrl: _ctrlTanggal,
              icon: Icons.calendar_month_rounded,
              readOnly: true,
              onTap: _pickDate,
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _inputField(
                    label: 'Usia (bulan)',
                    hint: 'contoh: 4',
                    ctrl: _ctrlUsia,
                    icon: Icons.cake_rounded,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      final n = int.tryParse(v);
                      if (n == null || n < 0 || n > 60) {
                        return 'Usia 0 sampai 60';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _inputField(
                    label: 'Berat Badan (kg)',
                    hint: 'contoh: 7.5',
                    ctrl: _ctrlBb,
                    icon: Icons.monitor_weight_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
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
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _inputField(
                    label: 'Tinggi Badan (cm)',
                    hint: 'contoh: 63.5',
                    ctrl: _ctrlTb,
                    icon: Icons.height_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
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
                const SizedBox(width: 12),
                Expanded(
                  child: _inputField(
                    label: 'Lingkar Kepala (cm)',
                    hint: 'contoh: 40.5',
                    ctrl: _ctrlLk,
                    icon: Icons.radio_button_checked_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSaving ? null : _simpan,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded, size: 18),
                label: Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan Data',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required String hint,
    required TextEditingController ctrl,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
            prefixIcon: Icon(icon, color: _pink, size: 16),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _pink, width: 1.5),
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

  Widget _buildStatusGiziCard() {
    final s = _statusGizi!;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                color: Color(0xFF2E7D32),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'WHO Z-Score',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ZScoreChip(
                  title: 'BB/TB',
                  subtitle: 'Wasting',
                  label: s.labelBbTb,
                  zScore: s.zScoreBbTb,
                  warna: s.warnaBbTb,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ZScoreChip(
                  title: 'TB/U',
                  subtitle: 'Stunting',
                  label: s.labelTbU,
                  zScore: s.zScoreTbU,
                  warna: s.warnaTbU,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ZScoreChip(
                  title: 'BB/U',
                  subtitle: 'Underweight',
                  label: s.labelBbU,
                  zScore: s.zScoreBbU,
                  warna: s.warnaBbU,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrafikCard() {
    return _card(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: _pink,
                borderRadius: BorderRadius.circular(7),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              tabs: const [
                Tab(text: 'Berat'),
                Tab(text: 'Tinggi'),
                Tab(text: 'L. Kepala'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _GrafikPertumbuhan(
              riwayat: _riwayat,
              mode: _tabGrafik,
              jk: _jkAnak,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard() {
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              '${_riwayat.length} Catatan',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Container(
            color: const Color(0xFFFAFAFA),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _thCell('Tanggal', flex: 3),
                _thCell('Usia\n(bln)', flex: 2),
                _thCell('BB\n(kg)', flex: 2),
                _thCell('TB\n(cm)', flex: 2),
                _thCell('LK\n(cm)', flex: 2),
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
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    child: Row(
                      children: [
                        _tdCell(
                          '${item.tanggal.day}/${item.tanggal.month}/${item.tanggal.year}',
                          flex: 3,
                        ),
                        _tdCell('${item.usiaBulan}', flex: 2),
                        _tdCell(
                          '${item.beratBadan.toStringAsFixed(1)}',
                          flex: 2,
                        ),
                        _tdCell(
                          '${item.tinggiBadan.toStringAsFixed(1)}',
                          flex: 2,
                        ),
                        _tdCell(
                          item.lingkarKepala != null
                              ? '${item.lingkarKepala!.toStringAsFixed(1)}'
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

  Widget _thCell(String text, {required int flex}) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Color(0xFF888888),
      ),
      textAlign: TextAlign.center,
    ),
  );

  Widget _tdCell(String text, {required int flex}) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
      textAlign: TextAlign.center,
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ZScoreChip extends StatelessWidget {
  final String title;
  final String subtitle;
  final String label;
  final double zScore;
  final Color warna;

  const _ZScoreChip({
    required this.title,
    required this.subtitle,
    required this.label,
    required this.zScore,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: warna.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: warna.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: warna,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 9, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            'Z ${zScore > 0 ? '+' : ''}${zScore.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: warna,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: warna,
              borderRadius: BorderRadius.circular(20),
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
    );
  }
}

class _GrafikPertumbuhan extends StatelessWidget {
  final List<DataPengukuran> riwayat;
  final int mode;
  final String jk;

  const _GrafikPertumbuhan({
    required this.riwayat,
    required this.mode,
    required this.jk,
  });

  @override
  Widget build(BuildContext context) {
    if (riwayat.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 40, color: Colors.grey[300]),
            const SizedBox(height: 8),
            const Text(
              'Belum ada data',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }
    return CustomPaint(
      painter: _GrafikPainter(riwayat: riwayat, mode: mode, jk: jk),
      child: const SizedBox.expand(),
    );
  }
}

class _GrafikPainter extends CustomPainter {
  final List<DataPengukuran> riwayat;
  final int mode;
  final String jk;

  _GrafikPainter({required this.riwayat, required this.mode, required this.jk});

  List<double> get _median {
    if (mode == 0) {
      return jk == 'L'
          ? [
              3.3,
              5.6,
              7.0,
              7.9,
              8.6,
              9.2,
              9.6,
              10.1,
              10.5,
              10.9,
              11.3,
              11.8,
              12.2,
            ]
          : [
              3.2,
              5.1,
              6.4,
              7.3,
              7.9,
              8.5,
              8.9,
              9.4,
              9.8,
              10.2,
              10.6,
              11.1,
              11.5,
            ];
    } else if (mode == 1) {
      return jk == 'L'
          ? [
              49.9,
              58.4,
              63.9,
              67.6,
              70.6,
              73.3,
              75.7,
              78.0,
              80.2,
              82.3,
              84.2,
              86.0,
              88.0,
            ]
          : [
              49.1,
              57.1,
              62.1,
              65.7,
              68.7,
              71.5,
              74.0,
              76.4,
              78.6,
              80.7,
              82.7,
              84.6,
              86.4,
            ];
    } else {
      return [
        34.5,
        39.0,
        41.0,
        42.5,
        43.5,
        44.5,
        45.0,
        45.5,
        46.0,
        46.5,
        47.0,
        47.3,
        47.5,
      ];
    }
  }

  double get _sd => mode == 0 ? 1.2 : (mode == 1 ? 2.5 : 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final median = _median;
    final sd = _sd;
    final vals = riwayat.map((r) {
      if (mode == 0) return r.beratBadan;
      if (mode == 1) return r.tinggiBadan;
      return r.lingkarKepala ?? 0.0;
    }).toList();

    final allY = [
      ...vals.where((v) => v > 0),
      ...median.map((m) => m - 2.5 * sd),
      ...median.map((m) => m + 2.5 * sd),
    ];
    final minY = allY.reduce(min) * 0.94;
    final maxY = allY.reduce(max) * 1.06;
    const pad = EdgeInsets.fromLTRB(36, 10, 12, 28);
    final w = size.width - pad.left - pad.right;
    final h = size.height - pad.top - pad.bottom;

    double px(double x) => pad.left + x / 24.0 * w;
    double py(double y) => pad.top + h - (y - minY) / (maxY - minY) * h;

    final gridPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = pad.top + h * i / 4;
      canvas.drawLine(Offset(pad.left, y), Offset(pad.left + w, y), gridPaint);
      final val = maxY - (maxY - minY) * i / 4;
      final tp = TextPainter(
        text: TextSpan(
          text: val.toStringAsFixed(1),
          style: const TextStyle(fontSize: 9, color: Color(0xFFAAAAAA)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - 5));
    }

    final refXs = List.generate(13, (i) => (i * 2).toDouble());
    final bandPath = Path();
    bandPath.moveTo(px(refXs[0]), py(median[0] + 2 * sd));
    for (int i = 1; i < 13; i++) {
      bandPath.lineTo(px(refXs[i]), py(median[i] + 2 * sd));
    }
    for (int i = 12; i >= 0; i--) {
      bandPath.lineTo(px(refXs[i]), py(median[i] - 2 * sd));
    }
    bandPath.close();
    canvas.drawPath(
      bandPath,
      Paint()..color = const Color(0xFFE85D75).withOpacity(0.07),
    );

    final medPaint = Paint()
      ..color = const Color(0xFFE85D75).withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final medPath = Path();
    medPath.moveTo(px(refXs[0]), py(median[0]));
    for (int i = 1; i < 13; i++) {
      medPath.lineTo(px(refXs[i]), py(median[i]));
    }
    canvas.drawPath(medPath, medPaint);

    final xs = riwayat.map((r) => r.usiaBulan.toDouble()).toList();
    final ys = vals;
    final validPoints = <Offset>[];
    for (int i = 0; i < riwayat.length; i++) {
      if (mode == 2 && riwayat[i].lingkarKepala == null) continue;
      validPoints.add(Offset(px(xs[i]), py(ys[i])));
    }

    if (validPoints.length > 1) {
      final linePath = Path()..moveTo(validPoints[0].dx, validPoints[0].dy);
      for (int i = 1; i < validPoints.length; i++) {
        linePath.lineTo(validPoints[i].dx, validPoints[i].dy);
      }
      canvas.drawPath(
        linePath,
        Paint()
          ..color = const Color(0xFFE85D75)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    for (final pt in validPoints) {
      canvas.drawCircle(pt, 5, Paint()..color = Colors.white);
      canvas.drawCircle(
        pt,
        5,
        Paint()
          ..color = const Color(0xFFE85D75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GrafikPainter old) =>
      old.riwayat != riwayat || old.mode != mode || old.jk != jk;
}
