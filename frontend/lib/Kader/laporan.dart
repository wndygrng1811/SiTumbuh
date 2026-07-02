import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';
import '../widgets/custom_app_bar.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  static const Color _pink = Color(0xFFE85D75);
  static const Color _bg = Color(0xFFF5F7FA);

  String _selectedBulan = 'Juni';
  String _selectedTahun = '2026';
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isExporting = false;
  bool _isLoading = true;
  String _errorMessage = '';

  List<Map<String, dynamic>> _dataPertumbuhan = [];
  List<Map<String, dynamic>> _filteredData = [];

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
  final List<String> _listTahun = ['2024', '2025', '2026', '2027'];

  final Map<String, String> _bulanMap = {
    'Januari': '01',
    'Februari': '02',
    'Maret': '03',
    'April': '04',
    'Mei': '05',
    'Juni': '06',
    'Juli': '07',
    'Agustus': '08',
    'September': '09',
    'Oktober': '10',
    'November': '11',
    'Desember': '12',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filterData() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredData = _dataPertumbuhan.where((item) {
        final nama = item['nama_anak']?.toLowerCase() ?? '';
        return nama.contains(query);
      }).toList();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      String bulanAngka = _bulanMap[_selectedBulan] ?? '06';
      final response = await ApiService.get(
        '/kader/semua-pertumbuhan?bulan=$bulanAngka&tahun=$_selectedTahun',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> pertumbuhanList = data['data'] ?? [];

          setState(() {
            _dataPertumbuhan = pertumbuhanList.map((item) {
              return {
                'anak_id': item['anak_id'],
                'nama_anak': item['nama_anak'] ?? 'Tidak diketahui',
                'jenis_kelamin': item['jenis_kelamin'] == 'L' ? 'L' : 'P',
                'tinggi_badan': item['tinggi_badan'] ?? 0,
                'berat_badan': item['berat_badan'] ?? 0,
                'lingkar_kepala': item['lingkar_kepala'] ?? 0,
                'status_gizi': item['status_gizi'] ?? 'Normal',
                'nama_ortu': item['nama_ortu'] ?? '-',
              };
            }).toList();
            _filteredData = List.from(_dataPertumbuhan);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Gagal memuat data';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Gagal terhubung ke server (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  int get _totalAnak => _filteredData.length;
  int get _totalNormal =>
      _filteredData.where((a) => a['status_gizi'] == 'Normal').length;
  int get _totalKurang => _filteredData
      .where(
        (a) =>
            a['status_gizi'] == 'Kurang' || a['status_gizi'] == 'Underweight',
      )
      .length;
  int get _totalObesitas => _filteredData
      .where(
        (a) => a['status_gizi'] == 'Obese' || a['status_gizi'] == 'Obesitas',
      )
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      drawer: const SidebarKader(),
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 0),
      appBar: CustomAppBar(
        backgroundColor: _pink,
        iconColor: Colors.white,
        showBackButton: false,
        showDrawerIcon: true,
        showNotificationIcon: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _pink))
          : _errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : _buildMainContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.red.shade300,
            ),
          ),
          const SizedBox(height: 16),
          Text(_errorMessage, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: _pink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildStatCards(),
                const SizedBox(height: 20),
                _buildFilterSection(),
                const SizedBox(height: 16),
                _buildTableHeader(),
                const SizedBox(height: 10),
                _buildDataTable(),
                const SizedBox(height: 20),
                _buildCetakButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_pink, _pink.withOpacity(0.85)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: _pink.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.insert_chart_rounded,
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
                  'Laporan Posyandu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_selectedBulan $_selectedTahun',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.location_on_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Posyandu Melati',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Column(
      children: [
        Row(
          children: [
            _StatCard(
              icon: Icons.child_care_rounded,
              label: 'Total Anak',
              value: '$_totalAnak',
              color: const Color(0xFFE85D75),
            ),
            const SizedBox(width: 10),
            _StatCard(
              icon: Icons.verified_rounded,
              label: 'Gizi Normal',
              value: '$_totalNormal',
              color: const Color(0xFF4CAF50),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _StatCard(
              icon: Icons.warning_rounded,
              label: 'Gizi Kurang',
              value: '$_totalKurang',
              color: const Color(0xFFFF9800),
            ),
            const SizedBox(width: 10),
            _StatCard(
              icon: Icons.error_rounded,
              label: 'Obesitas',
              value: '$_totalObesitas',
              color: const Color(0xFFF44336),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  icon: Icons.calendar_month_rounded,
                  value: _selectedBulan,
                  items: _listBulan,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedBulan = val);
                      _loadData();
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 110,
                child: _buildDropdown(
                  icon: Icons.date_range_rounded,
                  value: _selectedTahun,
                  items: _listTahun,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedTahun = val);
                      _loadData();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 0.5),
            ),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
              decoration: InputDecoration(
                hintText: 'Cari nama anak...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: Colors.grey.shade400,
                        onPressed: () {
                          _searchCtrl.clear();
                          _filterData();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _pink, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _pink.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: _pink,
            ),
          ),
          iconEnabledColor: _pink,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Icon(icon, size: 16, color: _pink),
                  const SizedBox(width: 8),
                  Text(item, style: const TextStyle(fontSize: 13)),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: _pink,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Data Pertumbuhan Anak',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _pink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_filteredData.length} data',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _pink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    if (_filteredData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Tidak ada data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Untuk bulan $_selectedBulan $_selectedTahun',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFFCE4EC)),
            headingRowHeight: 48,
            dataRowMinHeight: 56,
            dataRowMaxHeight: 60,
            columnSpacing: 20,
            horizontalMargin: 16,
            dividerThickness: 0.5,
            border: TableBorder(
              horizontalInside: BorderSide(
                color: Colors.grey.shade100,
                width: 0.5,
              ),
            ),
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
                  'TB',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _pink,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'BB',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _pink,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'LK',
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
              DataColumn(
                label: Text(
                  'Ortu',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _pink,
                  ),
                ),
              ),
            ],
            rows: List.generate(_filteredData.length, (index) {
              final item = _filteredData[index];
              final bool isNormal = item['status_gizi'] == 'Normal';
              final Color statusColor = isNormal
                  ? Colors.green
                  : (item['status_gizi'] == 'Obese' ||
                            item['status_gizi'] == 'Obesitas'
                        ? Colors.red
                        : Colors.orange);
              final Color statusBg = isNormal
                  ? Colors.green.shade50
                  : (item['status_gizi'] == 'Obese' ||
                            item['status_gizi'] == 'Obesitas'
                        ? Colors.red.shade50
                        : Colors.orange.shade50);

              return DataRow(
                color: WidgetStateProperty.resolveWith<Color>(
                  (states) => index.isOdd ? Colors.grey.shade50 : Colors.white,
                ),
                cells: [
                  DataCell(
                    Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: item['jenis_kelamin'] == 'P'
                                  ? [Colors.pink.shade100, Colors.pink.shade50]
                                  : [Colors.blue.shade100, Colors.blue.shade50],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (item['nama_anak'] as String)[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: item['jenis_kelamin'] == 'P'
                                    ? Colors.pink.shade700
                                    : Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          item['nama_anak'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: item['jenis_kelamin'] == 'P'
                            ? Colors.pink.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['jenis_kelamin'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: item['jenis_kelamin'] == 'P'
                              ? Colors.pink.shade700
                              : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${item['tinggi_badan']}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${item['berat_badan']}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${item['lingkar_kepala']}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isNormal ? Icons.check_circle : Icons.warning,
                            size: 12,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['status_gizi'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      item['nama_ortu'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildCetakButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_pink, _pink.withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _pink.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: _isExporting ? null : _handleCetak,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.file_download_rounded, size: 22),
            const SizedBox(width: 10),
            Text(
              _isExporting ? 'Membuat file...' : 'Cetak Laporan Excel',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCetak() async {
    setState(() => _isExporting = true);

    try {
      var excelFile = excel.Excel.createExcel();
      excel.Sheet sheet = excelFile['Laporan Posyandu'];

      sheet.appendRow([
        excel.TextCellValue('No'),
        excel.TextCellValue('Nama Anak'),
        excel.TextCellValue('Jenis Kelamin'),
        excel.TextCellValue('Tinggi Badan (cm)'),
        excel.TextCellValue('Berat Badan (kg)'),
        excel.TextCellValue('Lingkar Kepala (cm)'),
        excel.TextCellValue('Status Gizi'),
        excel.TextCellValue('Orang Tua'),
      ]);

      if (_filteredData.isEmpty) {
        sheet.appendRow([excel.TextCellValue('Tidak ada data')]);
      } else {
        for (int i = 0; i < _filteredData.length; i++) {
          final item = _filteredData[i];
          sheet.appendRow([
            excel.TextCellValue((i + 1).toString()),
            excel.TextCellValue(item['nama_anak'] ?? '-'),
            excel.TextCellValue(
              item['jenis_kelamin'] == 'L' ? 'Laki-laki' : 'Perempuan',
            ),
            excel.TextCellValue((item['tinggi_badan'] ?? 0).toString()),
            excel.TextCellValue((item['berat_badan'] ?? 0).toString()),
            excel.TextCellValue((item['lingkar_kepala'] ?? 0).toString()),
            excel.TextCellValue(item['status_gizi'] ?? 'Normal'),
            excel.TextCellValue(item['nama_ortu'] ?? '-'),
          ]);
        }
      }

      final bytes = excelFile.encode();
      if (bytes == null) throw Exception('Gagal membuat file Excel');

      String fileName =
          'laporan_posyandu_${_selectedBulan}_$_selectedTahun.xlsx';

      if (Platform.isAndroid) {
        PermissionStatus status = await Permission.storage.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Izin penyimpanan diperlukan untuk menyimpan file',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
          setState(() => _isExporting = false);
          return;
        }
      }

      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fileName';
      final File file = File(filePath);
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'Laporan Posyandu $_selectedBulan $_selectedTahun');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '✓ Laporan berhasil dibuat: $fileName',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error export: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gagal membuat laporan: $e',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
              spreadRadius: 1,
            ),
          ],
          border: Border.all(color: color.withOpacity(0.15), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
