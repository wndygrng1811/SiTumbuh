import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';

class DataPengukuran {
  final DateTime tanggal;
  final int usiaBulan;
  final double beratBadan; // kg
  final double tinggiBadan; // cm
  final double? lingkarKepala; // cm, opsional

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
  // TB/U median (cm), indeks = usia bulan 0-24
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

  // BB/U median (kg), indeks = usia bulan 0-24
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

  /// BB/TB median estimasi (berat ideal berdasar tinggi)
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

    // TB/U
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

    // BB/U
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

    // BB/TB
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
  static const Color _pinkLight = Color(0xFFE85D75);
  static const Color _pinkMid = Color(0xFFE85D75);
  static const Color _bg = Color.fromARGB(255, 255, 255, 255);

  // Info anak (dari navigasi / state management)
  final String _namaAnak = 'Bima Sakti';
  final String _jkAnak = 'L';
  final String _namaOrangtua = 'Siti Rohimah';

  // Tab grafik
  late TabController _tabController;
  int _tabGrafik = 0;

  // Form
  final _formKey = GlobalKey<FormState>();
  final _ctrlTanggal = TextEditingController();
  final _ctrlUsia = TextEditingController();
  final _ctrlBb = TextEditingController();
  final _ctrlTb = TextEditingController();
  final _ctrlLk = TextEditingController();
  DateTime? _selectedDate;
  bool _isSaving = false;

  // Hasil kalkulasi
  StatusGizi? _statusGizi;
  DataPengukuran? _pengukuranTerbaru;

  // Data historis (dummy — ganti dengan data dari API/DB)
  final List<DataPengukuran> _riwayat = [
    DataPengukuran(
      tanggal: DateTime(2025, 12, 4),
      usiaBulan: 1,
      beratBadan: 4.2,
      tinggiBadan: 54.0,
      lingkarKepala: 37.0,
    ),
    DataPengukuran(
      tanggal: DateTime(2026, 1, 4),
      usiaBulan: 2,
      beratBadan: 5.1,
      tinggiBadan: 57.0,
      lingkarKepala: 38.5,
    ),
    DataPengukuran(
      tanggal: DateTime(2026, 2, 4),
      usiaBulan: 3,
      beratBadan: 6.0,
      tinggiBadan: 60.5,
      lingkarKepala: 39.5,
    ),
    DataPengukuran(
      tanggal: DateTime(2026, 3, 4),
      usiaBulan: 4,
      beratBadan: 6.8,
      tinggiBadan: 63.2,
      lingkarKepala: 40.5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(
      () => setState(() => _tabGrafik = _tabController.index),
    );
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

  // ── Nama bulan singkat ──
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

  // ── Pilih tanggal ──
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

  // ── Simpan & hitung Z-Score ──
  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final usia = int.parse(_ctrlUsia.text.trim());
    final bb = double.parse(_ctrlBb.text.trim());
    final tb = double.parse(_ctrlTb.text.trim());
    final lk = _ctrlLk.text.trim().isNotEmpty
        ? double.tryParse(_ctrlLk.text.trim())
        : null;

    final pengukuran = DataPengukuran(
      tanggal: _selectedDate ?? DateTime.now(),
      usiaBulan: usia,
      beratBadan: bb,
      tinggiBadan: tb,
      lingkarKepala: lk,
    );

    final status = WHOZScore.kalkulasi(
      usiaBulan: usia,
      bb: bb,
      tb: tb,
      jk: _jkAnak,
    );

    setState(() {
      _riwayat.add(pengukuran);
      _pengukuranTerbaru = pengukuran;
      _statusGizi = status;
      _isSaving = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Data berhasil disimpan!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      drawer: const SidebarKader(),
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 1),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildInfoAnakCard(),
                  const SizedBox(height: 20),
                  _buildFormCard(),
                  const SizedBox(height: 20),
                  if (_statusGizi != null) ...[
                    _buildStatusGiziCard(),
                    const SizedBox(height: 20),
                  ],
                  _buildGrafikCard(),
                  const SizedBox(height: 20),
                  _buildRiwayatCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // APP BAR
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFE85D75),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          const Text(
            'SiTumbuh',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_rounded, size: 24),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE85D75)),
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFE85D75), Color(0xFFE85D75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.grid_view_rounded,
                color: Colors.white70,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Data Pertumbuhan',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Catat Pertumbuhan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Input data & pantau status gizi anak',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // CARD INFO ANAK
  Widget _buildInfoAnakCard() {
    final usiaTerakhir = _riwayat.isNotEmpty
        ? '${_riwayat.last.usiaBulan} bulan'
        : '-';
    final tglTerakhir = _riwayat.isNotEmpty
        ? '${_riwayat.last.tanggal.day.toString().padLeft(2, '0')} '
              '${_bulanStr(_riwayat.last.tanggal.month)} ${_riwayat.last.tanggal.year}'
        : '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE85D75),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE85D75).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.child_care_rounded,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _namaAnak,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Usia $usiaTerakhir  •  ${_jkAnak == 'L' ? 'Laki-laki' : 'Perempuan'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  'Orang Tua: $_namaOrangtua',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 11,
                      color: const Color(0xFFE85D75),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Terakhir diukur: $tglTerakhir',
                      style: const TextStyle(
                        fontSize: 11,
                        color: const Color(0xFFE85D75),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE85D75),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Color.fromARGB(255, 255, 255, 255),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FORM INPUT
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE85D75),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_chart_rounded,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Input Pengukuran Baru',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Tanggal
            _inputField(
              label: 'Catatan Tanggal',
              hint: 'Pilih tanggal',
              ctrl: _ctrlTanggal,
              icon: Icons.calendar_month_rounded,
              readOnly: true,
              onTap: _pickDate,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Tanggal wajib diisi' : null,
            ),
            const SizedBox(height: 12),

            // Usia
            _inputField(
              label: 'Usia (bulan)',
              hint: 'contoh: 4',
              ctrl: _ctrlUsia,
              icon: Icons.cake_rounded,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Usia wajib diisi';
                final n = int.tryParse(v);
                if (n == null || n < 0 || n > 60)
                  return 'Masukkan usia 0–60 bulan';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Berat Badan
            _inputField(
              label: 'Berat Badan (kg)',
              hint: 'contoh: 7.5',
              ctrl: _ctrlBb,
              icon: Icons.monitor_weight_rounded,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'BB wajib diisi';
                final n = double.tryParse(v);
                if (n == null || n <= 0 || n > 50)
                  return 'Masukkan nilai valid';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Tinggi Badan
            _inputField(
              label: 'Tinggi Badan (cm)',
              hint: 'contoh: 63.5',
              ctrl: _ctrlTb,
              icon: Icons.height_rounded,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'TB wajib diisi';
                final n = double.tryParse(v);
                if (n == null || n <= 0 || n > 200)
                  return 'Masukkan nilai valid';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Lingkar Kepala (opsional)
            _inputField(
              label: 'Lingkar Kepala (cm)',
              hint: 'contoh: 40.5  (opsional)',
              ctrl: _ctrlLk,
              icon: Icons.radio_button_checked_rounded,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE85D75),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFFE85D75).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
                    : const Icon(Icons.save_rounded, size: 20),
                label: Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.3,
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
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: const Color(0xFFE85D75),
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
          style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFFE85D75), size: 18),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: const Color(0xFFE85D75),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE53935),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // STATUS GIZI
  Widget _buildStatusGiziCard() {
    final s = _statusGizi!;
    final p = _pengukuranTerbaru!;
    final allNormal =
        s.labelBbTb == 'Normal' &&
        s.labelTbU == 'Normal' &&
        s.labelBbU == 'Normal';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: allNormal
              ? const Color(0xFF2E7D32).withOpacity(0.3)
              : const Color(0xFFE53935).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: allNormal
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  allNormal
                      ? Icons.verified_rounded
                      : Icons.warning_amber_rounded,
                  color: allNormal
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFE65100),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasil Analisis Z-Score WHO',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: allNormal
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFE65100),
                      ),
                    ),
                    Text(
                      'BB ${p.beratBadan} kg  •  TB ${p.tinggiBadan} cm  •  Usia ${p.usiaBulan} bln',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 3 chip Z-score
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
                const SizedBox(height: 12),

                // Legend
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Interpretasi Z-Score WHO',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: const [
                          _LegendItem(
                            warna: Color(0xFFB71C1C),
                            teks: 'Z < -3: Sangat Buruk',
                          ),
                          _LegendItem(
                            warna: Color(0xFFE53935),
                            teks: '-3 ≤ Z < -2: Buruk',
                          ),
                          _LegendItem(
                            warna: Color(0xFF2E7D32),
                            teks: '-2 ≤ Z ≤ +2: Normal',
                          ),
                          _LegendItem(
                            warna: Color(0xFFE65100),
                            teks: 'Z > +2: Lebih',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // GRAFIK
  Widget _buildGrafikCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE85D75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.show_chart_rounded,
                        color: Color.fromARGB(255, 255, 255, 255),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Grafik Pertumbuhan',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_riwayat.length} pengukuran',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Tab
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFFE85D75),
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                tabs: const [
                  Tab(text: 'Berat Badan'),
                  Tab(text: 'Tinggi Badan'),
                  Tab(text: 'Lingkar Kepala'),
                ],
              ),
            ),
          ),

          // Grafik
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 220,
              child: _GrafikPertumbuhan(
                riwayat: _riwayat,
                mode: _tabGrafik,
                jk: _jkAnak,
              ),
            ),
          ),

          // Legend grafik
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _legendGrafik(const Color(0xFFC8E6C9), 'Normal (WHO)'),
                _legendGrafik(const Color(0xFFFFF9C4), 'Kurang (-2SD)'),
                _legendGrafik(const Color(0xFFFFCDD2), 'Buruk (-3SD)'),
                _legendGrafik(
                  const Color(0xFFE85D75),
                  'Data Anak',
                  isLine: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendGrafik(Color warna, String teks, {bool isLine = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        isLine
            ? Container(
                width: 16,
                height: 3,
                color: warna,
                margin: const EdgeInsets.symmetric(vertical: 4),
              )
            : Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: warna,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
        const SizedBox(width: 4),
        Text(teks, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
      ],
    );
  }

  // RIWAYAT
  Widget _buildRiwayatCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE85D75),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Riwayat Pengukuran',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Header tabel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          const Divider(height: 1),

          // Baris data (terbaru di atas)
          ...List.generate(_riwayat.length, (i) {
            final item = _riwayat[_riwayat.length - 1 - i];
            final isLatest = i == 0;
            return Container(
              color: isLatest
                  ? const Color.fromARGB(255, 255, 255, 255).withOpacity(0.4)
                  : (i.isOdd ? Colors.grey.shade50 : Colors.white),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    _tdCell(
                      '${item.tanggal.day.toString().padLeft(2, '0')}/'
                      '${item.tanggal.month.toString().padLeft(2, '0')}/'
                      '${item.tanggal.year}',
                      flex: 3,
                      bold: isLatest,
                    ),
                    _tdCell('${item.usiaBulan}', flex: 2, bold: isLatest),
                    _tdCell('${item.beratBadan}', flex: 2, bold: isLatest),
                    _tdCell('${item.tinggiBadan}', flex: 2, bold: isLatest),
                    _tdCell(
                      item.lingkarKepala != null
                          ? '${item.lingkarKepala}'
                          : '-',
                      flex: 2,
                      bold: isLatest,
                    ),
                  ],
                ),
              ),
            );
          }),

          if (_riwayat.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE85D75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '↑ Terbaru',
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFFE85D75),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _thCell(String text, {required int flex}) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFE85D75),
      ),
      textAlign: TextAlign.center,
    ),
  );

  Widget _tdCell(String text, {required int flex, bool bold = false}) =>
      Expanded(
        flex: flex,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: bold ? const Color(0xFFE85D75) : const Color(0xFF2D2D2D),
          ),
          textAlign: TextAlign.center,
        ),
      );
}

// Z-SCORE
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: warna.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warna.withOpacity(0.25), width: 1),
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
          const SizedBox(height: 6),
          Text(
            'Z=${zScore > 0 ? '+' : ''}${zScore.toStringAsFixed(1)}',
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
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
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

class _LegendItem extends StatelessWidget {
  final Color warna;
  final String teks;

  const _LegendItem({required this.warna, required this.teks});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(teks, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
      ],
    );
  }
}

class _GrafikPertumbuhan extends StatelessWidget {
  final List<DataPengukuran> riwayat;
  final int mode; // 0=BB, 1=TB, 2=LK
  final String jk;

  const _GrafikPertumbuhan({
    required this.riwayat,
    required this.mode,
    required this.jk,
  });

  @override
  Widget build(BuildContext context) {
    if (riwayat.isEmpty) {
      return const Center(
        child: Text('Belum ada data', style: TextStyle(color: Colors.grey)),
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

  // Median WHO per 2 bulan (index 0=bln0, 1=bln2, ...12=bln24)
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
    final refXs = List.generate(13, (i) => i * 2.0); // 0,2,4,...24

    // Nilai aktual
    final vals = riwayat.map((r) {
      if (mode == 0) return r.beratBadan;
      if (mode == 1) return r.tinggiBadan;
      return r.lingkarKepala ?? 0.0;
    }).toList();

    // Range
    final allY = [
      ...vals.where((v) => v > 0),
      ...median.map((m) => m - 2.5 * sd),
      ...median.map((m) => m + 2.5 * sd),
    ];
    final minY = allY.reduce(min) * 0.94;
    final maxY = allY.reduce(max) * 1.06;
    const pad = EdgeInsets.fromLTRB(28, 10, 8, 24);
    final w = size.width - pad.left - pad.right;
    final h = size.height - pad.top - pad.bottom;
    final minX = 0.0;
    final maxX = 24.0;

    double px(double x) => pad.left + (x - minX) / (maxX - minX) * w;
    double py(double y) => pad.top + h - (y - minY) / (maxY - minY) * h;

    // ── Band merah: -3SD..-2SD ──
    _band(
      canvas,
      refXs,
      median.map((m) => m - 3 * sd).toList(),
      median.map((m) => m - 2 * sd).toList(),
      const Color(0xFFFFCDD2).withOpacity(0.7),
      px,
      py,
    );
    // ── Band kuning: -2SD..median ──
    _band(
      canvas,
      refXs,
      median.map((m) => m - 2 * sd).toList(),
      median,
      const Color(0xFFFFF9C4).withOpacity(0.9),
      px,
      py,
    );
    // ── Band hijau: median..+2SD ──
    _band(
      canvas,
      refXs,
      median,
      median.map((m) => m + 2 * sd).toList(),
      const Color(0xFFC8E6C9).withOpacity(0.9),
      px,
      py,
    );

    // ── Grid garis horizontal ──
    final gridP = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 4; i++) {
      final yv = minY + (maxY - minY) * i / 4;
      final y = py(yv);
      canvas.drawLine(
        Offset(pad.left, y),
        Offset(size.width - pad.right, y),
        gridP,
      );
      _label(
        canvas,
        yv.toStringAsFixed(1),
        Offset(0, y - 5),
        const TextStyle(fontSize: 9, color: Colors.grey),
      );
    }

    // ── Label X-axis ──
    for (final xl in [0, 6, 12, 18, 24]) {
      final x = px(xl.toDouble());
      _label(
        canvas,
        '$xl',
        Offset(x - 5, size.height - pad.bottom + 4),
        const TextStyle(fontSize: 9, color: Colors.grey),
      );
    }

    // ── Garis median (hijau putus-putus) ──
    final medP = Paint()
      ..color = const Color(0xFF66BB6A)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    _polyline(canvas, refXs, median, medP, px, py);

    // ── Garis data aktual ──
    final lineP = Paint()
      ..color = const Color(0xFFE91E8C)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final xs = riwayat.map((r) => r.usiaBulan.toDouble()).toList();
    final ys = vals;
    _polylinePairs(canvas, xs, ys, lineP, px, py);

    // ── Titik data ──
    final dotFill = Paint()..color = const Color(0xFFE91E8C);
    final dotBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (int i = 0; i < riwayat.length; i++) {
      if (mode == 2 && riwayat[i].lingkarKepala == null) continue;
      final x = px(xs[i]);
      final y = py(ys[i]);
      canvas.drawCircle(Offset(x, y), 5, dotFill);
      canvas.drawCircle(Offset(x, y), 5, dotBorder);
      _label(
        canvas,
        ys[i].toStringAsFixed(1),
        Offset(x - 10, y - 16),
        const TextStyle(
          fontSize: 9,
          color: Color(0xFFE91E8C),
          fontWeight: FontWeight.w700,
        ),
      );
    }
  }

  void _band(
    Canvas canvas,
    List<double> xs,
    List<double> lows,
    List<double> highs,
    Color color,
    double Function(double) px,
    double Function(double) py,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    for (int i = 0; i < xs.length; i++) {
      final x = px(xs[i]);
      final y = py(highs[i]);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    for (int i = xs.length - 1; i >= 0; i--) {
      path.lineTo(px(xs[i]), py(lows[i]));
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _polyline(
    Canvas canvas,
    List<double> xs,
    List<double> ys,
    Paint paint,
    double Function(double) px,
    double Function(double) py,
  ) {
    final path = Path();
    for (int i = 0; i < xs.length; i++) {
      final x = px(xs[i]);
      final y = py(ys[i]);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  void _polylinePairs(
    Canvas canvas,
    List<double> xs,
    List<double> ys,
    Paint paint,
    double Function(double) px,
    double Function(double) py,
  ) {
    if (xs.isEmpty) return;
    final path = Path();
    bool started = false;
    for (int i = 0; i < xs.length; i++) {
      if (ys[i] <= 0) continue;
      final x = px(xs[i]);
      final y = py(ys[i]);
      if (!started) {
        path.moveTo(x, y);
        started = true;
      } else
        path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  void _label(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _GrafikPainter old) =>
      old.riwayat != riwayat || old.mode != mode || old.jk != jk;
}
