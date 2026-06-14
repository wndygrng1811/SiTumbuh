import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
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
  static const Color _bg = Color(0xFFF8F9FA);

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
          ? const Center(child: CircularProgressIndicator())
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
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(_errorMessage),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(backgroundColor: _pink),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Data Pertumbuhan Anak',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${_filteredData.length} data',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: _pink,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
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
                'Laporan Bulanan',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
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

  Widget _buildStatCards() {
    return Row(
      children: [
        _StatCard(
          icon: Icons.child_care_rounded,
          label: 'Total Anak',
          value: '$_totalAnak',
          iconBg: const Color(0xFFE91E8C),
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.verified_rounded,
          label: 'Gizi Normal',
          value: '$_totalNormal',
          iconBg: const Color(0xFF66BB6A),
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.warning_rounded,
          label: 'Gizi Kurang',
          value: '$_totalKurang',
          iconBg: const Color(0xFFFF9800),
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.error_rounded,
          label: 'Obesitas',
          value: '$_totalObesitas',
          iconBg: const Color(0xFFF44336),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Column(
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
        const SizedBox(height: 10),
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
                        _filterData();
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

  Widget _buildDropdown({
    required IconData icon,
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

  Widget _buildDataTable() {
    if (_filteredData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('Tidak ada data untuk bulan dan tahun yang dipilih'),
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
                  'LK\n(cm)',
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
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: item['jenis_kelamin'] == 'P'
                              ? Colors.pink.shade50
                              : Colors.blue.shade50,
                          child: Text(
                            (item['nama_anak'] as String)[0],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: item['jenis_kelamin'] == 'P'
                                  ? _pink
                                  : Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item['nama_anak'],
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Text(
                      item['jenis_kelamin'],
                      style: const TextStyle(fontSize: 13),
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
                        vertical: 4,
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
                            size: 11,
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
                      style: const TextStyle(
                        fontSize: 12,
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
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: _pink,
          foregroundColor: Colors.white,
          elevation: 4,
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
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }

  Future<void> _handleCetak() async {
    setState(() => _isExporting = true);

    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Laporan Posyandu'];

      sheet.appendRow([
        TextCellValue('No'),
        TextCellValue('Nama Anak'),
        TextCellValue('Jenis Kelamin'),
        TextCellValue('Tinggi Badan (cm)'),
        TextCellValue('Berat Badan (kg)'),
        TextCellValue('Lingkar Kepala (cm)'),
        TextCellValue('Status Gizi'),
        TextCellValue('Orang Tua'),
      ]);

      if (_filteredData.isEmpty) {
        sheet.appendRow([TextCellValue('Tidak ada data')]);
      } else {
        for (int i = 0; i < _filteredData.length; i++) {
          final item = _filteredData[i];
          sheet.appendRow([
            TextCellValue((i + 1).toString()),
            TextCellValue(item['nama_anak'] ?? '-'),
            TextCellValue(
              item['jenis_kelamin'] == 'L' ? 'Laki-laki' : 'Perempuan',
            ),
            TextCellValue((item['tinggi_badan'] ?? 0).toString()),
            TextCellValue((item['berat_badan'] ?? 0).toString()),
            TextCellValue((item['lingkar_kepala'] ?? 0).toString()),
            TextCellValue(item['status_gizi'] ?? 'Normal'),
            TextCellValue(item['nama_ortu'] ?? '-'),
          ]);
        }
      }

      final bytes = excel.encode();
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
            content: Text('✓ Laporan berhasil dibuat: $fileName'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error export: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat laporan: $e'),
            backgroundColor: Colors.red,
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
  final Color iconBg;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
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
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: iconBg,
              ),
            ),
            const SizedBox(height: 2),
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
      ),
    );
  }
}
