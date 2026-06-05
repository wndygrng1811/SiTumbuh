import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:si_tumbuh/services/api_service.dart';
import 'package:si_tumbuh/widgets/custom_app_bar.dart';
import 'package:si_tumbuh/widgets/bottom_nav.dart';
import 'package:si_tumbuh/widgets/sidebar_menu.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// DATA Z-SCORE WHO
class WHOData {
  static const Map<int, double> beratLaki = {
    0: 3.3,
    1: 4.5,
    2: 5.6,
    3: 6.4,
    4: 7.0,
    5: 7.5,
    6: 7.9,
    7: 8.3,
    8: 8.6,
    9: 8.9,
    10: 9.2,
    11: 9.4,
    12: 9.6,
    13: 9.9,
    14: 10.1,
    15: 10.3,
    16: 10.5,
    17: 10.7,
    18: 10.9,
    19: 11.1,
    20: 11.3,
    21: 11.5,
    22: 11.7,
    23: 11.9,
    24: 12.1,
    27: 12.5,
    30: 12.9,
    33: 13.3,
    36: 13.7,
    39: 14.1,
    42: 14.5,
    45: 14.9,
    48: 15.3,
    51: 15.7,
    54: 16.1,
    57: 16.5,
    60: 16.9,
  };

  static const Map<int, double> tinggiLaki = {
    0: 50.5,
    1: 54.5,
    2: 58.0,
    3: 61.0,
    4: 63.5,
    5: 65.5,
    6: 67.5,
    7: 69.0,
    8: 70.5,
    9: 72.0,
    10: 73.5,
    11: 74.5,
    12: 75.5,
    13: 77.0,
    14: 78.5,
    15: 79.5,
    16: 80.5,
    17: 81.5,
    18: 82.5,
    19: 83.5,
    20: 84.5,
    21: 85.5,
    22: 86.5,
    23: 87.5,
    24: 88.5,
    27: 91.5,
    30: 94.5,
    33: 97.0,
    36: 99.5,
    39: 101.5,
    42: 103.5,
    45: 105.5,
    48: 107.5,
    51: 109.5,
    54: 111.5,
    57: 113.5,
    60: 115.5,
  };

  static const Map<int, double> lkLaki = {
    0: 34.5,
    1: 37.0,
    2: 39.0,
    3: 40.5,
    4: 41.5,
    5: 42.5,
    6: 43.5,
    7: 44.0,
    8: 44.5,
    9: 45.0,
    10: 45.5,
    11: 46.0,
    12: 46.5,
    13: 46.8,
    14: 47.0,
    15: 47.2,
    16: 47.4,
    17: 47.6,
    18: 47.8,
    19: 48.0,
    20: 48.2,
    21: 48.4,
    22: 48.6,
    23: 48.8,
    24: 49.0,
    27: 49.5,
    30: 49.9,
    33: 50.3,
    36: 50.7,
    39: 51.0,
    42: 51.3,
    45: 51.6,
    48: 51.9,
    51: 52.2,
    54: 52.5,
    57: 52.8,
    60: 53.1,
  };

  static const Map<int, double> beratPerempuan = {
    0: 3.2,
    1: 4.2,
    2: 5.1,
    3: 5.8,
    4: 6.4,
    5: 6.9,
    6: 7.3,
    7: 7.6,
    8: 7.9,
    9: 8.2,
    10: 8.5,
    11: 8.7,
    12: 8.9,
    13: 9.2,
    14: 9.4,
    15: 9.6,
    16: 9.8,
    17: 10.0,
    18: 10.2,
    19: 10.4,
    20: 10.6,
    21: 10.8,
    22: 11.0,
    23: 11.2,
    24: 11.4,
    27: 11.8,
    30: 12.2,
    33: 12.6,
    36: 13.0,
    39: 13.4,
    42: 13.8,
    45: 14.2,
    48: 14.6,
    51: 15.0,
    54: 15.4,
    57: 15.8,
    60: 16.2,
  };

  static const Map<int, double> tinggiPerempuan = {
    0: 49.5,
    1: 53.5,
    2: 57.0,
    3: 59.5,
    4: 62.0,
    5: 64.0,
    6: 65.5,
    7: 67.0,
    8: 68.5,
    9: 70.0,
    10: 71.5,
    11: 72.5,
    12: 73.5,
    13: 75.0,
    14: 76.5,
    15: 77.5,
    16: 78.5,
    17: 79.5,
    18: 80.5,
    19: 81.5,
    20: 82.5,
    21: 83.5,
    22: 84.5,
    23: 85.5,
    24: 86.5,
    27: 89.5,
    30: 92.5,
    33: 95.0,
    36: 97.5,
    39: 100.0,
    42: 102.0,
    45: 104.0,
    48: 106.0,
    51: 108.0,
    54: 110.0,
    57: 112.0,
    60: 114.0,
  };

  static const Map<int, double> lkPerempuan = {
    0: 34.0,
    1: 36.5,
    2: 38.5,
    3: 39.5,
    4: 40.5,
    5: 41.5,
    6: 42.5,
    7: 43.0,
    8: 43.5,
    9: 44.0,
    10: 44.5,
    11: 45.0,
    12: 45.5,
    13: 45.8,
    14: 46.0,
    15: 46.2,
    16: 46.4,
    17: 46.6,
    18: 46.8,
    19: 47.0,
    20: 47.2,
    21: 47.4,
    22: 48.6,
    23: 47.8,
    24: 48.0,
    27: 48.5,
    30: 48.9,
    33: 49.3,
    36: 49.7,
    39: 50.0,
    42: 50.3,
    45: 50.6,
    48: 50.9,
    51: 51.2,
    54: 51.5,
    57: 51.8,
    60: 52.1,
  };
}

class GrafikPage extends StatefulWidget {
  final int anakId;
  final String namaAnak;
  final String jenisKelamin;
  final VoidCallback? onChildChanged;

  const GrafikPage({
    super.key,
    required this.anakId,
    required this.namaAnak,
    required this.jenisKelamin,
    this.onChildChanged,
  });

  @override
  State<GrafikPage> createState() => _GrafikPageState();
}

class _GrafikPageState extends State<GrafikPage> {
  List<RiwayatPertumbuhan> _riwayat = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _errorMessage = '';

  int _currentAnakId = 0;
  String _currentNamaAnak = '';
  String _currentJenisKelamin = '';
  DateTime? _tanggalLahir;

  String _selectedFilter = "Berat Badan";
  final List<String> _filterOptions = [
    "Berat Badan",
    "Tinggi Badan",
    "Lingkar Kepala",
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didUpdateWidget(GrafikPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika data anak berubah, reload semua data
    if (oldWidget.anakId != widget.anakId ||
        oldWidget.namaAnak != widget.namaAnak) {
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // PRIORITASKAN data dari widget (dari HalamanUtama)
    if (widget.anakId != 0) {
      _currentAnakId = widget.anakId;
      _currentNamaAnak = widget.namaAnak.isNotEmpty ? widget.namaAnak : 'Anak';
      _currentJenisKelamin = widget.jenisKelamin.isNotEmpty
          ? widget.jenisKelamin
          : 'Laki-laki';
    } else {
      // Fallback ke SharedPreferences
      int savedAnakId = prefs.getInt('anak_id') ?? 0;
      String savedNamaAnak = prefs.getString('nama_anak') ?? '';
      String savedJenisKelamin = prefs.getString('jenis_kelamin') ?? '';

      if (savedAnakId != 0) {
        _currentAnakId = savedAnakId;
        _currentNamaAnak = savedNamaAnak.isNotEmpty ? savedNamaAnak : 'Anak';
        _currentJenisKelamin = savedJenisKelamin.isNotEmpty
            ? savedJenisKelamin
            : 'Laki-laki';
      }
    }

    print('========== GRAFIK PAGE INIT ==========');
    print('Current Anak ID: $_currentAnakId');
    print('Current Nama: $_currentNamaAnak');

    await _loadDataAnak();
    await _loadRiwayatPertumbuhan();
  }

  Future<void> _loadDataAnak() async {
    if (_currentAnakId == 0) return;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/anak/$_currentAnakId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final anakData = data['data'];
          setState(() {
            _currentNamaAnak = anakData['nama_anak'] ?? _currentNamaAnak;
            _currentJenisKelamin =
                anakData['jenis_kelamin'] ?? _currentJenisKelamin;
            if (anakData['tanggal_lahir'] != null) {
              try {
                _tanggalLahir = DateTime.parse(anakData['tanggal_lahir']);
              } catch (e) {}
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error load data anak: $e');
    }
  }

  Future<void> _loadRiwayatPertumbuhan() async {
    if (_currentAnakId == 0) {
      setState(() {
        _errorMessage = 'ID Anak tidak valid';
        _isLoading = false;
      });
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/pertumbuhan/$_currentAnakId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          List<dynamic> dataList = data['data'];

          if (dataList.isNotEmpty) {
            // 🔥 URUTKAN BERDASARKAN TANGGAL (TERLAMA KE TERBARU)
            dataList.sort((a, b) => a['tanggal'].compareTo(b['tanggal']));

            setState(() {
              _riwayat = dataList
                  .map((json) => RiwayatPertumbuhan.fromJson(json))
                  .toList();
              _isLoading = false;
            });

            print('========== DATA PERTUMBUHAN ==========');
            for (var r in _riwayat) {
              print(
                'Tanggal: ${r.tanggal}, Berat: ${r.berat}, Status: ${r.status}',
              );
            }
          } else {
            setState(() {
              _errorMessage = 'Belum ada data pertumbuhan untuk anak ini';
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Data tidak ditemukan';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data pertumbuhan';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error load pertumbuhan: $e');
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  double _getStandardValue(int umurBulan, String jenis, String gender) {
    Map<int, double>? data;

    if (gender == 'Laki-laki') {
      if (jenis == 'berat')
        data = WHOData.beratLaki;
      else if (jenis == 'tinggi')
        data = WHOData.tinggiLaki;
      else
        data = WHOData.lkLaki;
    } else {
      if (jenis == 'berat')
        data = WHOData.beratPerempuan;
      else if (jenis == 'tinggi')
        data = WHOData.tinggiPerempuan;
      else
        data = WHOData.lkPerempuan;
    }

    if (data == null) return 0;

    List<int> ages = data.keys.toList()..sort();
    if (umurBulan <= ages.first) return data[ages.first] ?? 0;
    if (umurBulan >= ages.last) return data[ages.last] ?? 0;

    for (int i = 0; i < ages.length - 1; i++) {
      if (umurBulan >= ages[i] && umurBulan <= ages[i + 1]) {
        double t = (umurBulan - ages[i]) / (ages[i + 1] - ages[i]);
        double val1 = data[ages[i]] ?? 0;
        double val2 = data[ages[i + 1]] ?? 0;
        return val1 + t * (val2 - val1);
      }
    }
    return 0;
  }

  double _hitungUmurBulan(DateTime tanggalPemeriksaan) {
    if (_tanggalLahir == null) return 0;
    int bulan = (tanggalPemeriksaan.year - _tanggalLahir!.year) * 12;
    bulan += tanggalPemeriksaan.month - _tanggalLahir!.month;
    return bulan.toDouble();
  }

  double _getNilai(RiwayatPertumbuhan data) {
    switch (_selectedFilter) {
      case "Tinggi Badan":
        return data.tinggi;
      case "Lingkar Kepala":
        return data.lKepala;
      default:
        return data.berat;
    }
  }

  String _getJenisFilter() {
    switch (_selectedFilter) {
      case "Tinggi Badan":
        return 'tinggi';
      case "Lingkar Kepala":
        return 'lk';
      default:
        return 'berat';
    }
  }

  double _getMaxY() {
    if (_riwayat.isEmpty) return 25;
    double maxValue = 0;
    for (var data in _riwayat) {
      double value = _getNilai(data);
      if (value > maxValue) maxValue = value;
    }
    switch (_selectedFilter) {
      case "Tinggi Badan":
        return (maxValue + 20).ceilToDouble();
      case "Lingkar Kepala":
        return (maxValue + 10).ceilToDouble();
      default:
        return (maxValue + 5).ceilToDouble();
    }
  }

  String _getLabelY() {
    switch (_selectedFilter) {
      case "Tinggi Badan":
        return "Tinggi (cm)";
      case "Lingkar Kepala":
        return "L. Kepala (cm)";
      default:
        return "Berat (kg)";
    }
  }

  double _getInterval() {
    double maxY = _getMaxY();
    if (_selectedFilter == "Tinggi Badan") {
      if (maxY <= 60) return 10;
      if (maxY <= 100) return 20;
      return 25;
    } else if (_selectedFilter == "Lingkar Kepala") {
      if (maxY <= 40) return 5;
      if (maxY <= 60) return 10;
      return 15;
    } else {
      if (maxY <= 20) return 5;
      if (maxY <= 50) return 10;
      return 20;
    }
  }

  String _getMonthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];
    return months[month - 1];
  }

  String _formatTanggal(DateTime date) {
    return "${date.day} ${_getMonthName(date.month)} ${date.year}";
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadDataAnak();
    await _loadRiwayatPertumbuhan();
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String status = "Normal";
    if (_riwayat.isNotEmpty) {
      status = _riwayat.last.status;
    }
    bool isNormal = status == "Normal";

    return Scaffold(
      drawer: const SidebarMenu(),
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: CustomAppBar(
        title: 'Grafik Pertumbuhan',
        backgroundColor: const Color(0xFFD86487),
        titleColor: Colors.white,
        iconColor: Colors.white,
        showBackButton: false,
        showDrawerIcon: true,
        showNotificationIcon: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadRiwayatPertumbuhan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B1E3F),
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoAnak(),
                    const SizedBox(height: 20),
                    _buildFilterChips(),
                    const SizedBox(height: 16),
                    SizedBox(height: 300, child: _buildGrafikKMS()),
                    const SizedBox(height: 16),
                    _buildStatusInfo(isNormal),
                    const SizedBox(height: 24),
                    _buildRiwayatHeader(),
                    const SizedBox(height: 12),
                    _buildRiwayatList(),
                    const SizedBox(height: 20),
                    _buildCatatan(),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }

  Widget _buildInfoAnak() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        _currentNamaAnak.isNotEmpty ? _currentNamaAnak : "Anak",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xFF5A2A2A),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          _buildChip("Berat Badan"),
          const SizedBox(width: 8),
          _buildChip("Tinggi Badan"),
          const SizedBox(width: 8),
          _buildChip("Lingkar Kepala"),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    final active = _selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF8B1E3F) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.grey.shade600,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrafikKMS() {
    if (_riwayat.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('Belum ada data untuk ditampilkan')),
      );
    }

    List<FlSpot> titikData = [];
    List<FlSpot> standarMinus2 = [];
    List<FlSpot> standarMedian = [];
    List<FlSpot> standarPlus2 = [];

    String jenisFilter = _getJenisFilter();
    String gender = _currentJenisKelamin == 'Perempuan'
        ? 'Perempuan'
        : 'Laki-laki';

    // 🔥 BUAT TITIK DATA ANAK (berdasarkan umur dalam bulan)
    for (var data in _riwayat) {
      double umurBulan = _hitungUmurBulan(data.tanggal);
      double nilai = _getNilai(data);
      if (umurBulan >= 0 && umurBulan <= 60 && nilai > 0) {
        titikData.add(FlSpot(umurBulan, nilai));
        print('Titik data: umur=$umurBulan bulan, nilai=$nilai');
      }
    }

    // 🔥 BUAT KURVA STANDAR WHO
    for (int umur = 0; umur <= 60; umur++) {
      double median = _getStandardValue(umur, jenisFilter, gender);
      if (median > 0) {
        double minus2SD = median * 0.85;
        double plus2SD = median * 1.15;

        standarMedian.add(FlSpot(umur.toDouble(), median));
        standarMinus2.add(FlSpot(umur.toDouble(), minus2SD));
        standarPlus2.add(FlSpot(umur.toDouble(), plus2SD));
      }
    }

    double maxY = _getMaxY();
    if (maxY < 20) maxY = 25;
    if (maxY > 200) maxY = 210;

    return ClipRect(
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 60,
          minY: 0,
          maxY: maxY,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey.shade200, strokeWidth: 0.5);
            },
            getDrawingVerticalLine: (value) {
              return FlLine(color: Colors.grey.shade200, strokeWidth: 0.5);
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: Text(
                _getLabelY(),
                style: const TextStyle(fontSize: 8, color: Colors.grey),
              ),
              axisNameSize: 15,
              sideTitles: SideTitles(
                showTitles: true,
                interval: _getInterval(),
                reservedSize: 25,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 7),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: const Text(
                'Umur (bulan)',
                style: TextStyle(fontSize: 8, color: Colors.grey),
              ),
              axisNameSize: 15,
              sideTitles: SideTitles(
                showTitles: true,
                interval: 6,
                reservedSize: 20,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 7),
                ),
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            // Area bawah -2SD (oranye)
            LineChartBarData(
              spots: standarMinus2,
              isCurved: true,
              color: Colors.transparent,
              barWidth: 0,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.shade100.withOpacity(0.4),
              ),
            ),
            // Area tengah (hijau) - zona normal
            LineChartBarData(
              spots: standarMedian,
              isCurved: true,
              color: Colors.transparent,
              barWidth: 0,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.25),
              ),
            ),
            // Area atas +2SD (oranye)
            LineChartBarData(
              spots: standarPlus2,
              isCurved: true,
              color: Colors.transparent,
              barWidth: 0,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.shade100.withOpacity(0.4),
              ),
            ),
            // Garis median (hijau)
            LineChartBarData(
              spots: standarMedian,
              isCurved: true,
              color: Colors.green,
              barWidth: 1.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Garis +2SD (oranye)
            LineChartBarData(
              spots: standarPlus2,
              isCurved: true,
              color: Colors.orange,
              barWidth: 1,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Garis -2SD (oranye)
            LineChartBarData(
              spots: standarMinus2,
              isCurved: true,
              color: Colors.orange,
              barWidth: 1,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // 🔥 DATA ANAK (GARIS MERAH DENGAN TITIK)
            LineChartBarData(
              spots: titikData,
              isCurved: true,
              color: Colors.red,
              barWidth: 2.5,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusInfo(bool isNormal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isNormal ? Colors.green.shade50 : Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isNormal ? Icons.check_circle : Icons.warning,
              color: isNormal ? Colors.green : Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Status: ${isNormal ? "Normal" : "Perlu Perhatian"}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isNormal ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isNormal
                      ? "Sesuai usia anak"
                      : "Konsultasikan dengan kader posyandu",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatHeader() {
    return const Text(
      "Riwayat Pertumbuhan",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Color(0xFF8B1E3F),
      ),
    );
  }

  Widget _buildRiwayatList() {
    if (_riwayat.isEmpty) {
      return const Center(child: Text('Belum ada riwayat pertumbuhan'));
    }

    // Tampilkan dari yang terbaru ke terlama
    List<RiwayatPertumbuhan> riwayatTerbalik = List.from(_riwayat.reversed);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: riwayatTerbalik.length,
      itemBuilder: (context, index) {
        final data = riwayatTerbalik[index];
        bool isNormal = data.status == "Normal";
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTanggal(data.tanggal),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Berat: ${data.berat.toStringAsFixed(1)} kg",
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Tinggi: ${data.tinggi.toStringAsFixed(1)} cm",
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "L. Kepala: ${data.lKepala.toStringAsFixed(1)} cm",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isNormal
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isNormal ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCatatan() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE2E7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.info_outline, size: 12, color: Color(0xFF8B1E3F)),
          SizedBox(width: 6),
          Text(
            "Data diinput oleh kader Posyandu",
            style: TextStyle(fontSize: 10, color: Color(0xFF8B1E3F)),
          ),
        ],
      ),
    );
  }
}

class RiwayatPertumbuhan {
  final String id;
  final DateTime tanggal;
  final double berat;
  final double tinggi;
  final double lKepala;
  final String status;

  RiwayatPertumbuhan({
    required this.id,
    required this.tanggal,
    required this.berat,
    required this.tinggi,
    required this.lKepala,
    required this.status,
  });

  factory RiwayatPertumbuhan.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateTime.now();

    if (json['tanggal'] != null) {
      try {
        parsedDate = DateTime.parse(json['tanggal'].toString());
      } catch (e) {
        parsedDate = DateTime.now();
      }
    } else if (json['created_at'] != null) {
      try {
        parsedDate = DateTime.parse(json['created_at'].toString());
      } catch (e) {
        parsedDate = DateTime.now();
      }
    }

    return RiwayatPertumbuhan(
      id: json['id']?.toString() ?? '0',
      tanggal: parsedDate,
      berat: (json['berat'] ?? 0).toDouble(),
      tinggi: (json['tinggi'] ?? 0).toDouble(),
      lKepala: (json['l_kepala'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'Normal',
    );
  }
}
