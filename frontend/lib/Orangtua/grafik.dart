import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:si_tumbuh/services/api_service.dart';
import 'package:http/http.dart' as http;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: AppBar(
        title: Text(
          'Grafik Pertumbuhan ${widget.namaAnak}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF8B1E3F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                  // Ringkasan data terbaru
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE2E7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Data Pertumbuhan Terbaru',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF8B1E3F),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoCard(
                              'Berat Badan',
                              '${_riwayat.last.berat} kg',
                              'Normal',
                            ),
                            _buildInfoCard(
                              'Tinggi Badan',
                              '${_riwayat.last.tinggi} cm',
                              'Normal',
                            ),
                            _buildInfoCard(
                              'Lingkar Kepala',
                              '${_riwayat.last.lKepala} cm',
                              'Normal',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Grafik Berat Badan
                  const Text(
                    'Grafik Berat Badan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF8B1E3F),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 250,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 20,
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            axisNameWidget: const Text(
                              'Berat (kg)',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            axisNameSize: 20,
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 2,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 9),
                              ),
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
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              _riwayat.length,
                              (index) => FlSpot(
                                index.toDouble(),
                                _riwayat[index].berat,
                              ),
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
                  ),
                  const SizedBox(height: 20),

                  // Grafik Tinggi Badan
                  const Text(
                    'Grafik Tinggi Badan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF8B1E3F),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 250,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 120,
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            axisNameWidget: const Text(
                              'Tinggi (cm)',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            axisNameSize: 20,
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 20,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 9),
                              ),
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
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              _riwayat.length,
                              (index) => FlSpot(
                                index.toDouble(),
                                _riwayat[index].tinggi,
                              ),
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
                  ),

                  // Tabel Riwayat
                  const SizedBox(height: 20),
                  const Text(
                    'Riwayat Pertumbuhan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF8B1E3F),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 16,
                        columns: const [
                          DataColumn(label: Text('Tanggal')),
                          DataColumn(label: Text('Berat (kg)')),
                          DataColumn(label: Text('Tinggi (cm)')),
                          DataColumn(label: Text('L. Kepala (cm)')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: _riwayat.reversed.map((data) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  '${data.tanggal.day}/${data.tanggal.month}/${data.tanggal.year}',
                                ),
                              ),
                              DataCell(Text(data.berat.toString())),
                              DataCell(Text(data.tinggi.toString())),
                              DataCell(Text(data.lKepala.toString())),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: data.status == 'Normal'
                                        ? Colors.green
                                        : Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    data.status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, String value, String status) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF8B1E3F),
          ),
        ),
        Text(status, style: const TextStyle(fontSize: 11, color: Colors.green)),
      ],
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
