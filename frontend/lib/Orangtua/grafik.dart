import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:si_tumbuh/services/api_service.dart';
import 'package:si_tumbuh/widgets/custom_app_bar.dart';
import 'package:si_tumbuh/widgets/bottom_nav.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GrafikPage extends StatefulWidget {
  final int anakId;
  final String namaAnak;
  final String jenisKelamin;

  const GrafikPage({
    super.key,
    required this.anakId,
    required this.namaAnak,
    required this.jenisKelamin,
  });

  @override
  State<GrafikPage> createState() => _GrafikPageState();
}

class _GrafikPageState extends State<GrafikPage> {
  List<RiwayatPertumbuhan> _riwayat = [];
  bool _isLoading = true;
  String _errorMessage = '';

  String _selectedFilter = "Berat Badan";
  final List<String> _filterOptions = [
    "Berat Badan",
    "Tinggi Badan",
    "Lingkar Kepala",
  ];

  @override
  void initState() {
    super.initState();
    _loadRiwayatPertumbuhan();
  }

  Future<void> _loadRiwayatPertumbuhan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final List<dynamic> data = await ApiService.getRiwayatPertumbuhan(
        widget.anakId,
      );

      if (data.isNotEmpty) {
        setState(() {
          _riwayat = data
              .map((json) => RiwayatPertumbuhan.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Belum ada data pertumbuhan';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal terhubung ke server';
        _isLoading = false;
      });
    }
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

  double _getMaxY() {
    if (_riwayat.isEmpty) return 20;
    double maxValue = 0;
    for (var data in _riwayat) {
      double value = _getNilai(data);
      if (value > maxValue) maxValue = value;
    }
    switch (_selectedFilter) {
      case "Tinggi Badan":
        return (maxValue + 10).ceilToDouble();
      case "Lingkar Kepala":
        return (maxValue + 5).ceilToDouble();
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
    if (maxY <= 20) return 5;
    if (maxY <= 50) return 10;
    return 20;
  }

  String _getMonthName(int month) {
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: CustomAppBar(
        title: 'Grafik Pertumbuhan ${widget.namaAnak}',
        backgroundColor: const Color(0xFFD86487),
        titleColor: Colors.white,
        iconColor: Colors.white,
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
          : _riwayat.isEmpty
          ? const Center(child: Text('Belum ada data pertumbuhan'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoAnak(),
                  const SizedBox(height: 16),
                  _buildDataTerbaru(),
                  const SizedBox(height: 20),
                  _buildDropdownFilter(),
                  const SizedBox(height: 10),
                  _buildGrafik(),
                  const SizedBox(height: 8),
                  _buildStatusKeterangan(),
                  const SizedBox(height: 24),
                  _buildRiwayatHeader(),
                  const SizedBox(height: 10),
                  _buildRiwayatList(),
                  const SizedBox(height: 16),
                  _buildCatatan(),
                ],
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE2E7),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.child_care,
              color: Color(0xFF8B1E3F),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.namaAnak,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF8B1E3F),
                  ),
                ),
                Text(
                  widget.jenisKelamin,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Normal",
              style: TextStyle(color: Colors.green.shade700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTerbaru() {
    final dataTerbaru = _riwayat.last;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE2E7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Data Pertumbuhan Terbaru",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF8B1E3F),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetrikItem("Berat", "${dataTerbaru.berat} kg", "Normal"),
              _buildMetrikItem("Tinggi", "${dataTerbaru.tinggi} cm", "Normal"),
              _buildMetrikItem(
                "L. Kepala",
                "${dataTerbaru.lKepala} cm",
                "Normal",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetrikItem(String label, String value, String status) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF8B1E3F),
          ),
        ),
        Text(status, style: const TextStyle(fontSize: 10, color: Colors.green)),
      ],
    );
  }

  Widget _buildDropdownFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0C4D0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF8B1E3F)),
          isExpanded: true,
          items: _filterOptions.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                option,
                style: const TextStyle(color: Color(0xFF8B1E3F)),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedFilter = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildGrafik() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: _getMaxY(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
            },
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: Text(
                _getLabelY(),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              axisNameSize: 25,
              sideTitles: SideTitles(
                showTitles: true,
                interval: _getInterval(),
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 9),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < _riwayat.length) {
                    return Text(
                      '${_riwayat[index].tanggal.day}/${_riwayat[index].tanggal.month}',
                      style: const TextStyle(fontSize: 8),
                      textAlign: TextAlign.center,
                    );
                  }
                  return const Text('');
                },
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
            LineChartBarData(
              spots: List.generate(
                _riwayat.length,
                (index) => FlSpot(index.toDouble(), _getNilai(_riwayat[index])),
              ),
              isCurved: true,
              color: const Color(0xFF8B1E3F),
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF8B1E3F).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusKeterangan() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0C4D0)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "Status: Normal - Sesuai usia anak",
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          "Riwayat Pertumbuhan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF8B1E3F),
          ),
        ),
        Text(
          "Lihat semua",
          style: TextStyle(fontSize: 12, color: Color(0xFF8B1E3F)),
        ),
      ],
    );
  }

  Widget _buildRiwayatList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _riwayat.length > 3 ? 3 : _riwayat.length,
      itemBuilder: (context, index) {
        final data = _riwayat.reversed.toList()[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${data.tanggal.day} ${_getMonthName(data.tanggal.month)} ${data.tanggal.year}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRiwayatDetail("Berat", "${data.berat} kg", "Normal"),
                  _buildRiwayatDetail("Tinggi", "${data.tinggi} cm", "Normal"),
                  _buildRiwayatDetail(
                    "L. Kepala",
                    "${data.lKepala} cm",
                    "Normal",
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiwayatDetail(String label, String value, String status) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(status, style: const TextStyle(fontSize: 10, color: Colors.green)),
      ],
    );
  }

  Widget _buildCatatan() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE2E7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.info_outline, size: 14, color: Color(0xFF8B1E3F)),
          SizedBox(width: 8),
          Text(
            "Data diinput oleh kader Posyandu",
            style: TextStyle(fontSize: 11, color: Color(0xFF8B1E3F)),
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
    return RiwayatPertumbuhan(
      id: json['id'].toString(),
      tanggal: json['tanggal'] != null
          ? DateTime.parse(json['tanggal'].toString())
          : DateTime.now(),
      berat: (json['berat'] ?? 0).toDouble(),
      tinggi: (json['tinggi'] ?? 0).toDouble(),
      lKepala: (json['l_kepala'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'Normal',
    );
  }
}
