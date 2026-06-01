import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/services/api_service.dart';

class RiwayatKunjunganPage extends StatefulWidget {
  final int anakId;

  const RiwayatKunjunganPage({super.key, required this.anakId});

  @override
  State<RiwayatKunjunganPage> createState() => _RiwayatKunjunganPageState();
}

class _RiwayatKunjunganPageState extends State<RiwayatKunjunganPage> {
  List<Map<String, dynamic>> riwayatList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // 🔥 TAMBAHKAN INI
  String selectedFilter = "Terbaru";
  final List<String> filterList = ["Terbaru", "Terlama"];

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/anak/${widget.anakId}/riwayat'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Riwayat response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          List<dynamic> items = data['data'];
          setState(() {
            riwayatList = items.map((item) {
              return {
                'id': item['tumbuh_id'],
                'tanggal': item['created_at'] ?? '-',
                'berat': item['berat_badan'],
                'tinggi': item['tinggi_badan'],
                'l_kepala': item['lingkar_kepala'],
                'status': item['status_gizi'] ?? 'Normal',
              };
            }).toList();
            _applyFilter();
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
      print('Error: $e');
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (selectedFilter == "Terlama") {
      riwayatList.sort(
        (a, b) => (a['tanggal'] ?? '').compareTo(b['tanggal'] ?? ''),
      );
    } else {
      riwayatList.sort(
        (a, b) => (b['tanggal'] ?? '').compareTo(a['tanggal'] ?? ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFF1),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadRiwayat,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD86487),
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 100,
                    decoration: const BoxDecoration(color: Color(0xFFD86487)),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "Riwayat Kunjungan",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedFilter,
                            isExpanded: true,
                            items: filterList.map((String value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 8),
                                    Text(value),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedFilter = value;
                                  _applyFilter();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF6EFF1),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: riwayatList.isEmpty
                          ? const Center(
                              child: Text('Belum ada riwayat kunjungan'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: riwayatList.length,
                              itemBuilder: (context, index) {
                                return RiwayatCard(data: riwayatList[index]);
                              },
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class RiwayatCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const RiwayatCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF8B1E3F),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  data['tanggal'] ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B1E3F),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Data Pertumbuhan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: data['status'] == 'Normal'
                            ? Colors.green.shade200
                            : Colors.orange.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        data['status'] ?? 'Normal',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfo('Berat', '${data['berat']} kg'),
                    _buildInfo('Tinggi', '${data['tinggi']} cm'),
                    _buildInfo('L. Kepala', '${data['l_kepala']} cm'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
