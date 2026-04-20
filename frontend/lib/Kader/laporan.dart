import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  // ── Konstanta warna ──
  static const Color _pink = Color(0xFFE85D75);
  static const Color _pinkLight = Color(0xFFE85D75);
  static const Color _pinkMid = Color(0xFFE85D75);
  static const Color _bg = Color(0xFFF8F9FA);

  // ── State filter ──
  String _selectedBulan = 'April';
  String _selectedTahun = '2026';
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isExporting = false;

  // ── Data dummy ──
  final List<Map<String, dynamic>> _dataAnak = [
    {
      "nama": "Ayu Lestari",
      "jk": "P",
      "usia": 12,
      "tb": 70,
      "bb": 8,
      "status": "Normal",
    },
    {
      "nama": "Dhea Cantika",
      "jk": "P",
      "usia": 5,
      "tb": 65,
      "bb": 7,
      "status": "Normal",
    },
    {
      "nama": "Dimas Pratama",
      "jk": "L",
      "usia": 8,
      "tb": 68,
      "bb": 8,
      "status": "Normal",
    },
    {
      "nama": "Sekar Arum",
      "jk": "P",
      "usia": 10,
      "tb": 72,
      "bb": 9,
      "status": "Normal",
    },
    {
      "nama": "Justin Arya",
      "jk": "L",
      "usia": 9,
      "tb": 71,
      "bb": 8,
      "status": "Normal",
    },
    {
      "nama": "Kesya Putri",
      "jk": "P",
      "usia": 7,
      "tb": 69,
      "bb": 7,
      "status": "Normal",
    },
    {
      "nama": "Rafi Akbar",
      "jk": "L",
      "usia": 11,
      "tb": 73,
      "bb": 9,
      "status": "Kurang",
    },
    {
      "nama": "Nayla Sari",
      "jk": "P",
      "usia": 6,
      "tb": 64,
      "bb": 6,
      "status": "Normal",
    },
  ];

  // ── Daftar opsi filter ──
  final List<String> _listBulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  final List<String> _listTahun = ['2024', '2025', '2026'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Hitung statistik ringkasan ──
  int get _totalAnak => _dataAnak.length;
  int get _totalHadir => _dataAnak.length - 1; // dummy: semua hadir kecuali 1
  int get _totalNormal =>
      _dataAnak.where((a) => a['status'] == 'Normal').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      drawer: const SidebarKader(),
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 1),

      // APP BAR
      appBar: AppBar(
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
          // Tombol notifikasi
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
                      border: Border.all(
                        color: const Color(0xFFE85D75),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),

      // BODY
      body: Column(
        children: [
          // ── Header gradient melengkung ──
          _buildHeader(),

          // ── Konten scrollable ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ── Card statistik ──
                  _buildStatCards(),

                  const SizedBox(height: 20),

                  // ── Filter & search ──
                  _buildFilterSection(),

                  const SizedBox(height: 16),

                  // ── Judul tabel ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Data Pertumbuhan Anak',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      Text(
                        '${_dataAnak.length} anak',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── Tabel data ──
                  _buildDataTable(),

                  const SizedBox(height: 20),

                  // ── Tombol cetak ──
                  _buildCetakButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════
  //  WIDGET: Header gradient dengan judul halaman
  // ════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE85D75), Color(0xFFF06292)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(
            children: [
              const Icon(
                Icons.grid_view_rounded,
                color: Colors.white70,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Laporan Bulanan',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Judul
          const Text(
            'Laporan Posyandu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Posyandu Melati · RW 03 · $_selectedBulan $_selectedTahun',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // CARD STATISTIK
  Widget _buildStatCards() {
    return Row(
      children: [
        // Card: Data Anak
        Expanded(
          child: _StatCard(
            icon: Icons.child_care_rounded,
            label: 'Data Anak',
            value: '$_totalAnak',
            iconBg: const Color(0xFFE91E8C),
            valueSuffix: 'anak',
          ),
        ),
        const SizedBox(width: 10),
        // Card: Hadir
        Expanded(
          child: _StatCard(
            icon: Icons.how_to_reg_rounded,
            label: 'Hadir',
            value: '$_totalHadir',
            iconBg: const Color(0xFF42A5F5),
            valueSuffix: 'anak',
          ),
        ),
        const SizedBox(width: 10),
        // Card: Anak Normal
        Expanded(
          child: _StatCard(
            icon: Icons.verified_rounded,
            label: 'Normal',
            value: '$_totalNormal',
            iconBg: const Color(0xFF66BB6A),
            valueSuffix: 'anak',
          ),
        ),
      ],
    );
  }

  // FILTER
  Widget _buildFilterSection() {
    return Column(
      children: [
        // Row filter dropdown
        Row(
          children: [
            // Dropdown Bulan
            Expanded(
              child: _buildDropdown(
                icon: Icons.calendar_month_rounded,
                hint: 'Bulan',
                value: _selectedBulan,
                items: _listBulan,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBulan = val);
                },
              ),
            ),
            const SizedBox(width: 10),
            // Dropdown Tahun
            SizedBox(
              width: 110,
              child: _buildDropdown(
                icon: Icons.date_range_rounded,
                hint: 'Tahun',
                value: _selectedTahun,
                items: _listTahun,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTahun = val);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Search bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Cari nama anak...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: Colors.grey[400],
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper: dropdown dengan styling custom
  Widget _buildDropdown({
    required IconData icon,
    required String hint,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          iconEnabledColor: _pink,
          style: const TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Icon(icon, size: 15, color: _pink),
                  const SizedBox(width: 6),
                  Text(item),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // TABEL DATA ANAK
  Widget _buildDataTable() {
    // Filter berdasarkan search (opsional, UI saja)
    final filtered = _searchCtrl.text.isEmpty
        ? _dataAnak
        : _dataAnak
              .where(
                (a) => (a['nama'] as String).toLowerCase().contains(
                  _searchCtrl.text.toLowerCase(),
                ),
              )
              .toList();

    return Container(
      width: double.infinity,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFFCE4EC)),
            headingRowHeight: 44,
            dataRowMinHeight: 52,
            dataRowMaxHeight: 56,
            columnSpacing: 16,
            horizontalMargin: 16,
            dividerThickness: 0.5,
            columns: const [
              DataColumn(
                label: Text(
                  'No',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _pink,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Nama',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _pink,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'JK',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _pink,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Usia\n(bln)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _pink,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'TB\n(cm)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _pink,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'BB\n(kg)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _pink,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _pink,
                  ),
                ),
              ),
            ],
            rows: List.generate(filtered.length, (index) {
              final item = filtered[index];
              final isNormal = item['status'] == 'Normal';

              return DataRow(
                // Warna baris selang-seling untuk readability
                color: WidgetStateProperty.resolveWith<Color>((states) {
                  if (index.isOdd) return Colors.grey.shade50;
                  return Colors.white;
                }),
                cells: [
                  // No
                  DataCell(
                    Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Nama + avatar awal nama
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar kecil
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: item['jk'] == 'P'
                              ? const Color(0xFFFCE4EC)
                              : const Color(0xFFE3F2FD),
                          child: Text(
                            (item['nama'] as String)[0],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: item['jk'] == 'P'
                                  ? _pink
                                  : const Color(0xFF1565C0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item['nama'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // JK dengan icon
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: item['jk'] == 'P'
                            ? const Color(0xFFFCE4EC)
                            : const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['jk'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: item['jk'] == 'P'
                              ? _pink
                              : const Color(0xFF1565C0),
                        ),
                      ),
                    ),
                  ),

                  // Usia
                  DataCell(
                    Text(
                      '${item["usia"]}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                  ),

                  // TB
                  DataCell(
                    Text(
                      '${item["tb"]}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                  ),

                  // BB
                  DataCell(
                    Text(
                      '${item["bb"]}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                  ),

                  // Status badge
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isNormal
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isNormal
                                ? Icons.check_circle_rounded
                                : Icons.warning_amber_rounded,
                            size: 11,
                            color: isNormal
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFE65100),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['status'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isNormal
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFE65100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════
  //  WIDGET: Tombol Cetak Laporan
  // ════════════════════════════════════════════════
  Widget _buildCetakButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: _pink,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: _pink.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: _isExporting ? null : _handleCetak,
        icon: _isExporting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.file_download_rounded, size: 20),
        label: Text(
          _isExporting ? 'Membuat file...' : 'Cetak Laporan Excel',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // ── Handler tombol cetak ──
  Future<void> _handleCetak() async {
    setState(() => _isExporting = true);

    try {
      final path = await exportToExcel(_dataAnak);

      if (!mounted) return;

      // Tampilkan SnackBar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Excel berhasil dibuat!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      path ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text('Gagal membuat file: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}

// STATISTIK KECIL
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconBg;
  final String valueSuffix;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconBg,
    required this.valueSuffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconBg, size: 18),
          ),
          const SizedBox(height: 10),
          // Nilai
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: iconBg,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// EXPORT EXCELL
Future<String?> exportToExcel(List<Map<String, dynamic>> data) async {
  // Minta izin penyimpanan
  var status = await Permission.storage.request();
  if (!status.isGranted) return null;

  // Buat workbook Excel baru
  var excel = Excel.createExcel();
  Sheet sheet = excel['Laporan Posyandu'];

  // ── HEADER ROW ──
  sheet.appendRow([
    'No',
    'Nama',
    'JK',
    'Usia (bulan)',
    'TB (cm)',
    'BB (kg)',
    'Status',
  ]);

  // ── DATA ROWS ──
  for (int i = 0; i < data.length; i++) {
    final item = data[i];
    sheet.appendRow([
      i + 1,
      item['nama'],
      item['jk'],
      item['usia'],
      item['tb'],
      item['bb'],
      item['status'],
    ]);
  }

  // ── Simpan ke direktori dokumen aplikasi ──
  final Directory dir = await getApplicationDocumentsDirectory();
  final String path = '${dir.path}/laporan_anak.xlsx';

  // Tulis file
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(excel.encode()!);

  return path;
}
