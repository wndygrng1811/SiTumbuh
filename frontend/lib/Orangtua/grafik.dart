import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────
// MODEL DATA
// ─────────────────────────────────────────────

/// Model untuk satu record riwayat pertumbuhan
class GrowthRecord {
  final DateTime date;
  final double weight; // kg
  final double height; // cm
  final double headCircumference; // cm
  final String status; // 'Normal', 'Kurang', 'Lebih'

  const GrowthRecord({
    required this.date,
    required this.weight,
    required this.height,
    required this.headCircumference,
    required this.status,
  });
}

/// Model untuk referensi kurva WHO (median, -2SD, +2SD, -3SD, +3SD)
class WhoReference {
  final int ageMonths;
  final double median;
  final double minus2SD;
  final double plus2SD;
  final double minus3SD;
  final double plus3SD;

  const WhoReference({
    required this.ageMonths,
    required this.median,
    required this.minus2SD,
    required this.plus2SD,
    required this.minus3SD,
    required this.plus3SD,
  });
}

// ─────────────────────────────────────────────
// DATA DUMMY REALISTIS
// ─────────────────────────────────────────────

/// Data riwayat pertumbuhan anak (mockup: Raffi Ahmad)
final List<GrowthRecord> _dummyRecords = [
  GrowthRecord(
    date: DateTime(2026, 3, 4),
    weight: 9.8,
    height: 74.2,
    headCircumference: 46.5,
    status: 'Normal',
  ),
  GrowthRecord(
    date: DateTime(2026, 2, 4),
    weight: 8.5,
    height: 72.0,
    headCircumference: 45.0,
    status: 'Normal',
  ),
  GrowthRecord(
    date: DateTime(2026, 1, 4),
    weight: 7.0,
    height: 68.0,
    headCircumference: 44.5,
    status: 'Normal',
  ),
  GrowthRecord(
    date: DateTime(2025, 12, 4),
    weight: 6.5,
    height: 65.0,
    headCircumference: 44.0,
    status: 'Normal',
  ),
  GrowthRecord(
    date: DateTime(2025, 11, 4),
    weight: 6.0,
    height: 62.5,
    headCircumference: 43.5,
    status: 'Normal',
  ),
  GrowthRecord(
    date: DateTime(2025, 10, 4),
    weight: 5.5,
    height: 60.0,
    headCircumference: 42.8,
    status: 'Normal',
  ),
];

/// Referensi kurva WHO Berat Badan (laki-laki, 0-24 bulan) — sampel
final List<WhoReference> _whoWeightRef = [
  WhoReference(
    ageMonths: 0,
    median: 3.3,
    minus2SD: 2.5,
    plus2SD: 4.3,
    minus3SD: 2.1,
    plus3SD: 5.0,
  ),
  WhoReference(
    ageMonths: 2,
    median: 5.6,
    minus2SD: 4.3,
    plus2SD: 7.1,
    minus3SD: 3.8,
    plus3SD: 8.0,
  ),
  WhoReference(
    ageMonths: 4,
    median: 6.7,
    minus2SD: 5.1,
    plus2SD: 8.6,
    minus3SD: 4.4,
    plus3SD: 9.7,
  ),
  WhoReference(
    ageMonths: 6,
    median: 7.9,
    minus2SD: 6.0,
    plus2SD: 9.8,
    minus3SD: 5.3,
    plus3SD: 10.9,
  ),
  WhoReference(
    ageMonths: 8,
    median: 8.6,
    minus2SD: 6.6,
    plus2SD: 10.7,
    minus3SD: 5.9,
    plus3SD: 11.9,
  ),
  WhoReference(
    ageMonths: 10,
    median: 9.2,
    minus2SD: 7.1,
    plus2SD: 11.4,
    minus3SD: 6.3,
    plus3SD: 12.6,
  ),
  WhoReference(
    ageMonths: 12,
    median: 9.6,
    minus2SD: 7.4,
    plus2SD: 11.9,
    minus3SD: 6.6,
    plus3SD: 13.2,
  ),
  WhoReference(
    ageMonths: 14,
    median: 10.0,
    minus2SD: 7.7,
    plus2SD: 12.4,
    minus3SD: 6.9,
    plus3SD: 13.7,
  ),
  WhoReference(
    ageMonths: 16,
    median: 10.3,
    minus2SD: 7.9,
    plus2SD: 12.8,
    minus3SD: 7.1,
    plus3SD: 14.2,
  ),
  WhoReference(
    ageMonths: 18,
    median: 10.6,
    minus2SD: 8.1,
    plus2SD: 13.2,
    minus3SD: 7.2,
    plus3SD: 14.7,
  ),
  WhoReference(
    ageMonths: 20,
    median: 10.9,
    minus2SD: 8.3,
    plus2SD: 13.6,
    minus3SD: 7.4,
    plus3SD: 15.1,
  ),
  WhoReference(
    ageMonths: 22,
    median: 11.1,
    minus2SD: 8.5,
    plus2SD: 13.9,
    minus3SD: 7.6,
    plus3SD: 15.5,
  ),
  WhoReference(
    ageMonths: 24,
    median: 11.5,
    minus2SD: 8.8,
    plus2SD: 14.3,
    minus3SD: 7.9,
    plus3SD: 15.9,
  ),
];

/// Referensi kurva WHO Tinggi Badan (laki-laki, 0-24 bulan) — sampel
final List<WhoReference> _whoHeightRef = [
  WhoReference(
    ageMonths: 0,
    median: 49.9,
    minus2SD: 46.3,
    plus2SD: 53.4,
    minus3SD: 44.2,
    plus3SD: 55.6,
  ),
  WhoReference(
    ageMonths: 2,
    median: 58.4,
    minus2SD: 54.4,
    plus2SD: 62.4,
    minus3SD: 52.4,
    plus3SD: 64.4,
  ),
  WhoReference(
    ageMonths: 4,
    median: 63.9,
    minus2SD: 59.7,
    plus2SD: 68.0,
    minus3SD: 57.6,
    plus3SD: 70.1,
  ),
  WhoReference(
    ageMonths: 6,
    median: 67.6,
    minus2SD: 63.3,
    plus2SD: 71.9,
    minus3SD: 61.2,
    plus3SD: 74.0,
  ),
  WhoReference(
    ageMonths: 8,
    median: 70.6,
    minus2SD: 66.2,
    plus2SD: 75.0,
    minus3SD: 64.0,
    plus3SD: 77.2,
  ),
  WhoReference(
    ageMonths: 10,
    median: 73.3,
    minus2SD: 68.7,
    plus2SD: 77.9,
    minus3SD: 66.4,
    plus3SD: 80.1,
  ),
  WhoReference(
    ageMonths: 12,
    median: 75.7,
    minus2SD: 71.0,
    plus2SD: 80.5,
    minus3SD: 68.6,
    plus3SD: 82.9,
  ),
  WhoReference(
    ageMonths: 14,
    median: 78.0,
    minus2SD: 73.1,
    plus2SD: 82.9,
    minus3SD: 70.6,
    plus3SD: 85.4,
  ),
  WhoReference(
    ageMonths: 16,
    median: 80.2,
    minus2SD: 75.0,
    plus2SD: 85.4,
    minus3SD: 72.5,
    plus3SD: 87.9,
  ),
  WhoReference(
    ageMonths: 18,
    median: 82.3,
    minus2SD: 76.9,
    plus2SD: 87.7,
    minus3SD: 74.2,
    plus3SD: 90.4,
  ),
  WhoReference(
    ageMonths: 20,
    median: 84.2,
    minus2SD: 78.6,
    plus2SD: 89.8,
    minus3SD: 75.9,
    plus3SD: 92.5,
  ),
  WhoReference(
    ageMonths: 22,
    median: 86.1,
    minus2SD: 80.3,
    plus2SD: 91.9,
    minus3SD: 77.5,
    plus3SD: 94.7,
  ),
  WhoReference(
    ageMonths: 24,
    median: 87.8,
    minus2SD: 81.7,
    plus2SD: 93.9,
    minus3SD: 78.7,
    plus3SD: 97.0,
  ),
];

/// Referensi kurva WHO Lingkar Kepala (laki-laki, 0-24 bulan) — sampel
final List<WhoReference> _whoHeadRef = [
  WhoReference(
    ageMonths: 0,
    median: 34.5,
    minus2SD: 32.1,
    plus2SD: 36.9,
    minus3SD: 30.7,
    plus3SD: 37.9,
  ),
  WhoReference(
    ageMonths: 2,
    median: 39.1,
    minus2SD: 36.7,
    plus2SD: 41.5,
    minus3SD: 35.6,
    plus3SD: 42.6,
  ),
  WhoReference(
    ageMonths: 4,
    median: 41.6,
    minus2SD: 39.2,
    plus2SD: 44.0,
    minus3SD: 38.0,
    plus3SD: 45.1,
  ),
  WhoReference(
    ageMonths: 6,
    median: 43.3,
    minus2SD: 40.9,
    plus2SD: 45.8,
    minus3SD: 39.7,
    plus3SD: 46.9,
  ),
  WhoReference(
    ageMonths: 8,
    median: 44.5,
    minus2SD: 42.1,
    plus2SD: 46.9,
    minus3SD: 40.9,
    plus3SD: 48.0,
  ),
  WhoReference(
    ageMonths: 10,
    median: 45.6,
    minus2SD: 43.1,
    plus2SD: 48.1,
    minus3SD: 41.8,
    plus3SD: 49.2,
  ),
  WhoReference(
    ageMonths: 12,
    median: 46.5,
    minus2SD: 44.0,
    plus2SD: 49.0,
    minus3SD: 42.6,
    plus3SD: 50.2,
  ),
  WhoReference(
    ageMonths: 14,
    median: 47.2,
    minus2SD: 44.7,
    plus2SD: 49.7,
    minus3SD: 43.3,
    plus3SD: 51.0,
  ),
  WhoReference(
    ageMonths: 16,
    median: 47.8,
    minus2SD: 45.3,
    plus2SD: 50.3,
    minus3SD: 43.9,
    plus3SD: 51.6,
  ),
  WhoReference(
    ageMonths: 18,
    median: 48.3,
    minus2SD: 45.8,
    plus2SD: 50.8,
    minus3SD: 44.4,
    plus3SD: 52.1,
  ),
  WhoReference(
    ageMonths: 20,
    median: 48.7,
    minus2SD: 46.2,
    plus2SD: 51.2,
    minus3SD: 44.8,
    plus3SD: 52.5,
  ),
  WhoReference(
    ageMonths: 22,
    median: 49.1,
    minus2SD: 46.6,
    plus2SD: 51.6,
    minus3SD: 45.1,
    plus3SD: 52.9,
  ),
  WhoReference(
    ageMonths: 24,
    median: 49.5,
    minus2SD: 46.9,
    plus2SD: 52.0,
    minus3SD: 45.5,
    plus3SD: 53.3,
  ),
];

// ─────────────────────────────────────────────
// KONSTANTA WARNA & STYLE
// ─────────────────────────────────────────────

const Color _primaryColor = Color(0xFF8B1A4A); // Marun utama
const Color _primaryLight = Color(0xFFFCE4EC); // Pink muda background
const Color _primaryMedium = Color(0xFFE91E63); // Pink accent
const Color _accentGreen = Color(0xFF4CAF50); // Hijau normal
const Color _cardBg = Colors.white;
const Color _textPrimary = Color(0xFF1A1A2E);
const Color _textSecondary = Color(0xFF6B7280);
const Color _divider = Color(0xFFE5E7EB);
const Color _whoGreenDark = Color(0xFF2E7D32);
const Color _whoGreenMid = Color(0xFF66BB6A);
const Color _whoGreenLight = Color(0xFFA5D6A7);
const Color _whoYellow = Color(0xFFFFF176);
const Color _whoYellowDark = Color(0xFFFFD54F);

// ─────────────────────────────────────────────
// DAFTAR NAMA ANAK (dummy)
// ─────────────────────────────────────────────

const List<String> _childNames = ['Raffi Ahmad', 'Aurel Hermansyah', 'Ameena'];

// ─────────────────────────────────────────────
// STATEFUL WIDGET UTAMA
// ─────────────────────────────────────────────

class GrafikPage extends StatefulWidget {
  const GrafikPage({super.key});

  @override
  State<GrafikPage> createState() => _GrafikPageState();
}

class _GrafikPageState extends State<GrafikPage>
    with SingleTickerProviderStateMixin {
  // ── State Variables ──
  String _selectedChild = _childNames[0];
  int _selectedTabIndex = 0; // 0=Berat, 1=Tinggi, 2=L.Kepala
  String _selectedPeriode = 'Bulan';
  List<GrowthRecord> _filteredRecords = List.from(_dummyRecords);
  late TabController _tabController;

  // Periode options untuk dropdown
  final List<String> _periodeOptions = ['Hari', 'Minggu', 'Bulan', 'Tahun'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // FUNGSI UPDATE DATA
  // ─────────────────────────────────────────────

  /// Memperbarui data grafik dan statistik berdasarkan periode yang dipilih.
  /// Dipanggil saat pengguna memilih periode dan menekan tombol Terapkan.
  void _updateData(String periode) {
    setState(() {
      _selectedPeriode = periode;

      final now = DateTime(2026, 3, 4); // tanggal referensi mockup

      switch (periode) {
        case 'Hari':
          // Tampilkan 7 hari terakhir — hanya record terbaru
          _filteredRecords = _dummyRecords
              .where((r) => now.difference(r.date).inDays <= 7)
              .toList();
          if (_filteredRecords.isEmpty)
            _filteredRecords = [_dummyRecords.first];
          break;

        case 'Minggu':
          // Tampilkan 4 minggu terakhir
          _filteredRecords = _dummyRecords
              .where((r) => now.difference(r.date).inDays <= 28)
              .toList();
          if (_filteredRecords.isEmpty)
            _filteredRecords = [_dummyRecords.first];
          break;

        case 'Bulan':
          // Tampilkan 6 bulan terakhir (default)
          _filteredRecords = List.from(_dummyRecords);
          break;

        case 'Tahun':
          // Tampilkan seluruh data (simulasi 1 tahun)
          _filteredRecords = List.from(_dummyRecords);
          break;
      }
    });
  }

  // ─────────────────────────────────────────────
  // GETTER HELPER
  // ─────────────────────────────────────────────

  /// Referensi WHO sesuai tab aktif
  List<WhoReference> get _currentWhoRef {
    switch (_selectedTabIndex) {
      case 0:
        return _whoWeightRef;
      case 1:
        return _whoHeightRef;
      case 2:
        return _whoHeadRef;
      default:
        return _whoWeightRef;
    }
  }

  /// Label sumbu Y sesuai tab aktif
  String get _yAxisLabel {
    switch (_selectedTabIndex) {
      case 0:
        return 'kg';
      case 1:
        return 'cm';
      case 2:
        return 'cm';
      default:
        return '';
    }
  }

  /// Nilai aktual anak sesuai tab
  double _getValueForTab(GrowthRecord r) {
    switch (_selectedTabIndex) {
      case 0:
        return r.weight;
      case 1:
        return r.height;
      case 2:
        return r.headCircumference;
      default:
        return r.weight;
    }
  }

  /// Status terakhir anak
  String get _latestStatus =>
      _filteredRecords.isNotEmpty ? _filteredRecords.first.status : 'Normal';

  // ─────────────────────────────────────────────
  // BUILD UTAMA
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;

    return Scaffold(
      backgroundColor: _primaryLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Dropdown nama anak
          _buildChildSelector(isSmall),
          // Tab: Berat / Tinggi / L.Kepala
          _buildTabBar(),
          // Konten scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card grafik pertumbuhan WHO
                  _buildGrowthChartCard(),
                  const SizedBox(height: 12),
                  // Card status
                  _buildStatusCard(),
                  const SizedBox(height: 20),
                  // Header riwayat + filter
                  _buildRiwayatHeader(),
                  const SizedBox(height: 12),
                  // List riwayat pertumbuhan
                  ..._filteredRecords.map((r) => _buildRiwayatCard(r)),
                  const SizedBox(height: 8),
                  // Keterangan bawah
                  _buildFooterNote(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─────────────────────────────────────────────
  // WIDGET: APP BAR
  // ─────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: _primaryColor),
        onPressed: () {},
      ),
      title: const Text(
        'SiTumbuh',
        style: TextStyle(
          color: _primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: _primaryColor),
          onPressed: () {},
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // WIDGET: CHILD SELECTOR DROPDOWN
  // ─────────────────────────────────────────────

  Widget _buildChildSelector(bool isSmall) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: _divider),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedChild,
                isDense: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: _primaryColor,
                  size: 18,
                ),
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                items: _childNames
                    .map(
                      (name) =>
                          DropdownMenuItem(value: name, child: Text(name)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedChild = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // WIDGET: TAB BAR (Berat / Tinggi / L.Kepala)
  // ─────────────────────────────────────────────

  Widget _buildTabBar() {
    final tabs = ['Berat', 'Tinggi', 'L. Kepala'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: _divider),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final isActive = _selectedTabIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  _tabController.animateTo(i);
                  setState(() => _selectedTabIndex = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? _primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? Colors.white : _textSecondary,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // WIDGET: GRAFIK PERTUMBUHAN (WHO Curve + Data Anak)
  // ─────────────────────────────────────────────

  Widget _buildGrowthChartCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Grafik Pertumbuhan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ),
          // Chart area
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
            child: SizedBox(height: 220, child: _buildWhoLineChart()),
          ),
          // Legenda
          _buildChartLegend(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Membangun WHO growth chart menggunakan fl_chart LineChart.
  /// Kurva area berlapis: 3SD (kuning gelap), 2SD (kuning), normal (hijau muda), median (hijau tua)
  Widget _buildWhoLineChart() {
    final whoRef = _currentWhoRef;

    // Helper: konversi WhoReference ke FlSpot
    List<FlSpot> toSpots(double Function(WhoReference) fn) =>
        whoRef.map((r) => FlSpot(r.ageMonths.toDouble(), fn(r))).toList();

    // Spots kurva WHO
    final medianSpots = toSpots((r) => r.median);
    final plus2Spots = toSpots((r) => r.plus2SD);
    final minus2Spots = toSpots((r) => r.minus2SD);
    final plus3Spots = toSpots((r) => r.plus3SD);
    final minus3Spots = toSpots((r) => r.minus3SD);

    // Spots data anak: x = umur bulan (estimasi dari urutan), y = nilai
    // Kita hitung umur dari tanggal lahir estimasi (rekam terakhir = 12 bulan)
    final childSpots = <FlSpot>[];
    for (int i = _filteredRecords.length - 1; i >= 0; i--) {
      final idx = _filteredRecords.length - 1 - i;
      final ageMonths = idx * 1.0; // simplifikasi: setiap record +1 bulan
      final actualAge = 12.0 + idx; // anak berumur ~12-17 bulan
      childSpots.add(FlSpot(actualAge, _getValueForTab(_filteredRecords[i])));
    }

    // Rentang Y
    final allY = [
      ...plus3Spots.map((s) => s.y),
      ...minus3Spots.map((s) => s.y),
    ];
    final minY = allY.reduce((a, b) => a < b ? a : b);
    final maxY = allY.reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 24,
        minY: (minY - 1).floorToDouble(),
        maxY: (maxY + 1).ceilToDouble(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: _selectedTabIndex == 0 ? 2 : 10,
          verticalInterval: 4,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: _divider, strokeWidth: 0.8),
          getDrawingVerticalLine: (_) =>
              FlLine(color: _divider, strokeWidth: 0.8),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: _divider),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 4,
              getTitlesWidget: (val, meta) => Text(
                '${val.toInt()}',
                style: const TextStyle(fontSize: 9, color: _textSecondary),
              ),
              reservedSize: 20,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _selectedTabIndex == 0 ? 2 : 10,
              getTitlesWidget: (val, meta) => Text(
                val.toInt().toString(),
                style: const TextStyle(fontSize: 9, color: _textSecondary),
              ),
              reservedSize: 28,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          // Area +3SD (luar, kuning gelap)
          _buildAreaLine(
            plus3Spots,
            _whoYellowDark,
            belowBarColor: _whoYellowDark.withOpacity(0.3),
          ),
          // Area +2SD (kuning)
          _buildAreaLine(
            plus2Spots,
            _whoGreenLight,
            belowBarColor: _whoGreenLight.withOpacity(0.5),
          ),
          // Area median (hijau tua)
          _buildAreaLine(
            medianSpots,
            _whoGreenMid,
            belowBarColor: _whoGreenMid.withOpacity(0.5),
          ),
          // Area -2SD (hijau muda)
          _buildAreaLine(
            minus2Spots,
            _whoGreenLight,
            belowBarColor: _whoGreenLight.withOpacity(0.3),
          ),
          // Area -3SD (kuning gelap)
          _buildAreaLine(
            minus3Spots,
            _whoYellowDark,
            belowBarColor: _whoYellowDark.withOpacity(0.2),
          ),
          // Garis data anak (merah/marun, dot di setiap titik)
          LineChartBarData(
            spots: childSpots,
            isCurved: true,
            color: _primaryColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 4,
                color: _primaryColor,
                strokeColor: Colors.white,
                strokeWidth: 1.5,
              ),
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                // hanya tooltip untuk garis data anak
                if (spot.barIndex != 5) {
                  return null;
                }

                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} $_yAxisLabel',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },

            // FIX fl_chart 0.68.0
            getTooltipColor: (touchedSpot) => _primaryColor,

            tooltipRoundedRadius: 8,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
          ),
        ),
      ),
    );
  }

  /// Helper membuat LineChartBarData untuk kurva area WHO
  LineChartBarData _buildAreaLine(
    List<FlSpot> spots,
    Color lineColor, {
    required Color belowBarColor,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: lineColor,
      barWidth: 1,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: belowBarColor),
    );
  }

  /// Legenda warna grafik WHO
  Widget _buildChartLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          _legendItem(_whoGreenMid, 'Normal'),
          _legendItem(_whoYellowDark, 'Berisiko'),
          _legendItem(_primaryColor, 'Data Anak', isDashed: true),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, {bool isDashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 20, height: 3, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: _textSecondary),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // WIDGET: STATUS CARD
  // ─────────────────────────────────────────────

  Widget _buildStatusCard() {
    final isNormal = _latestStatus == 'Normal';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Text(
            'Status: ',
            style: TextStyle(
              fontSize: 14,
              color: _textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            _latestStatus,
            style: const TextStyle(
              fontSize: 14,
              color: _textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            isNormal ? Icons.check_circle : Icons.warning_amber_rounded,
            color: isNormal ? _accentGreen : Colors.orange,
            size: 18,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isNormal ? 'Sesuai usia anak' : 'Perlu perhatian khusus',
              style: TextStyle(
                fontSize: 13,
                color: isNormal ? _accentGreen : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // WIDGET: RIWAYAT HEADER + FILTER
  // ─────────────────────────────────────────────

  Widget _buildRiwayatHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Riwayat Pertumbuhan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
        // Tombol Filter dengan bottom sheet
        GestureDetector(
          onTap: _showFilterSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: _divider),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 14, color: _textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Filter',
                  style: const TextStyle(fontSize: 12, color: _textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Bottom sheet filter periode
  void _showFilterSheet() {
    String tempPeriode = _selectedPeriode;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Periode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Pilihan periode
                  Wrap(
                    spacing: 8,
                    children: _periodeOptions.map((p) {
                      final isSelected = tempPeriode == p;
                      return GestureDetector(
                        onTap: () => setSheetState(() => tempPeriode = p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? _primaryColor : Colors.white,
                            border: Border.all(
                              color: isSelected ? _primaryColor : _divider,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            p,
                            style: TextStyle(
                              color: isSelected ? Colors.white : _textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Tombol Terapkan — memanggil _updateData dan menutup sheet
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        // Panggil _updateData agar grafik & list berubah via setState
                        _updateData(tempPeriode);
                      },
                      child: const Text(
                        'Terapkan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // WIDGET: RIWAYAT CARD (per record)
  // ─────────────────────────────────────────────

  Widget _buildRiwayatCard(GrowthRecord record) {
    final isNormal = record.status == 'Normal';
    final dateStr = DateFormat('dd MMMM yyyy', 'id_ID').format(record.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
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
          // Baris atas: tanggal + badge status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: _primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(record.status),
            ],
          ),
          const SizedBox(height: 8),
          // Baris data: Berat & Tinggi
          Row(
            children: [
              _measureItem('Berat:', '${record.weight} kg'),
              const SizedBox(width: 24),
              _measureItem('Tinggi:', '${record.height} cm'),
            ],
          ),
          const SizedBox(height: 4),
          // Lingkar kepala
          _measureItem('L. Kepala:', '${record.headCircumference} cm'),
        ],
      ),
    );
  }

  /// Badge status (Normal/Kurang/Lebih)
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'Kurang':
        bgColor = const Color(0xFFFFF3E0);
        textColor = Colors.orange;
        break;
      case 'Lebih':
        bgColor = const Color(0xFFFFEBEE);
        textColor = Colors.red;
        break;
      default:
        bgColor = const Color(0xFFE8F5E9);
        textColor = _accentGreen;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Item pengukuran kecil (label + nilai)
  Widget _measureItem(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: _textSecondary),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // WIDGET: FOOTER NOTE
  // ─────────────────────────────────────────────

  Widget _buildFooterNote() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 12, color: _textSecondary),
          const SizedBox(width: 4),
          Text(
            'Data diinput oleh kader Posyandu',
            style: const TextStyle(
              fontSize: 11,
              color: _textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // WIDGET: BOTTOM NAVIGATION BAR
  // ─────────────────────────────────────────────

  Widget _buildBottomNav() {
    const items = [
      {'icon': Icons.home_outlined, 'label': 'Beranda'},
      {'icon': Icons.show_chart, 'label': 'Pertumbuhan'},
      {'icon': Icons.calendar_today_outlined, 'label': 'Jadwal Posyandu'},
      {'icon': Icons.person_outline, 'label': 'Profil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = i == 1; // Pertumbuhan aktif
              return GestureDetector(
                onTap: () {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i]['icon'] as IconData,
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                      size: 22,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[i]['label'] as String,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
