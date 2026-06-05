import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/services/api_service.dart';
import '../widgets/custom_app_bar.dart';

class RiwayatKunjunganPage extends StatefulWidget {
  final int anakId;

  const RiwayatKunjunganPage({super.key, required this.anakId});

  @override
  State<RiwayatKunjunganPage> createState() => _RiwayatKunjunganPageState();
}

class _RiwayatKunjunganPageState extends State<RiwayatKunjunganPage> {
  List<Map<String, dynamic>> riwayatList = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _errorMessage = '';

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

      debugPrint('Loading riwayat for anakId: ${widget.anakId}');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/pertumbuhan/${widget.anakId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Riwayat response status: ${response.statusCode}');
      debugPrint('Riwayat response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List<dynamic> items = data['data'];

          setState(() {
            riwayatList = items.map((item) {
              // Ambil tanggal asli untuk sorting
              String tanggalAsli = item['tanggal'] ?? '';
              String tanggalDisplay = _formatTanggal(tanggalAsli);
              String hari = _getHari(tanggalAsli);
              String status = item['status'] ?? 'Normal';

              return {
                'id': item['id'],
                'tanggal': tanggalAsli, // untuk sorting
                'tanggal_display': tanggalDisplay,
                'hari': hari,
                'berat': item['berat']?.toString() ?? '0',
                'tinggi': item['tinggi']?.toString() ?? '0',
                'l_kepala': item['l_kepala']?.toString() ?? '0',
                'status': status,
                'posyandu': 'Posyandu Melati',
                'alamat': 'Jl. Sejahtera RT 03 RW 06',
                'keterangan': _getKeterangan(status),
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
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = 'Session habis, silakan login ulang';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error load riwayat: $e');
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  String _formatTanggal(String dateString) {
    if (dateString.isEmpty) return '1 Januari 2025';
    try {
      DateTime date = DateTime.parse(dateString);
      const months = [
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
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return '1 Januari 2025';
    }
  }

  String _getHari(String dateString) {
    if (dateString.isEmpty) return 'Senin';
    try {
      DateTime date = DateTime.parse(dateString);
      const hari = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu',
      ];
      return hari[date.weekday - 1];
    } catch (e) {
      return 'Senin';
    }
  }

  String _getKeterangan(String status) {
    if (status == 'Normal') {
      return 'Pertumbuhan sesuai usia anak, tetap lanjutkan pola makan dan kontrol rutin.';
    } else if (status == 'Stunting') {
      return 'Perhatikan asupan gizi anak, konsultasikan dengan kader posyandu.';
    } else if (status == 'Kurang') {
      return 'Perhatikan asupan gizi anak, konsultasikan dengan kader posyandu.';
    } else {
      return 'Konsultasikan dengan dokter untuk penanganan lebih lanjut.';
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadRiwayat();
    setState(() {
      _isRefreshing = false;
    });
  }

  void _applyFilter() {
    if (selectedFilter == "Terlama") {
      // Urutkan dari yang paling lama (ascending)
      riwayatList.sort(
        (a, b) => (a['tanggal'] ?? '').compareTo(b['tanggal'] ?? ''),
      );
    } else {
      // Urutkan dari yang paling baru (descending)
      riwayatList.sort(
        (a, b) => (b['tanggal'] ?? '').compareTo(a['tanggal'] ?? ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFF1),
      appBar: CustomAppBar(
        title: 'Riwayat Kunjungan',
        backgroundColor: const Color(0xFFD86487),
        titleColor: Colors.white,
        iconColor: Colors.white,
        showBackButton: true,
        showDrawerIcon: false,
        showNotificationIcon: false,
      ),
      body: _isLoading
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
                    onPressed: _loadRiwayat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD86487),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildFilterDropdown(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: riwayatList.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Belum ada riwayat kunjungan',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: riwayatList.length,
                            itemBuilder: (context, index) {
                              return RiwayatCard(data: riwayatList[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          const Text(
            'Semua',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8B1E3F),
            ),
          ),
          const SizedBox(width: 8),
          const Text('(', style: TextStyle(color: Colors.grey)),
          Text(
            selectedFilter,
            style: const TextStyle(color: Color(0xFFD86487)),
          ),
          const Text(')', style: TextStyle(color: Colors.grey)),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedFilter,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD86487)),
              dropdownColor: Colors.white,
              style: const TextStyle(fontSize: 14, color: Color(0xFF8B1E3F)),
              items: filterList.map((String value) {
                return DropdownMenuItem(value: value, child: Text(value));
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
        ],
      ),
    );
  }
}

class RiwayatCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const RiwayatCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    String status = data['status'] ?? 'Normal';
    String hari = data['hari'] ?? 'Senin';
    String tanggalDisplay = data['tanggal_display'] ?? '1 Januari 2025';
    String posyandu = data['posyandu'] ?? 'Posyandu Melati';
    String alamat = data['alamat'] ?? 'Jl. Sejahtera RT 03 RW 06';
    String keterangan =
        data['keterangan'] ??
        'Pertumbuhan sesuai usia anak, tetap lanjutkan pola makan dan kontrol rutin.';

    Color statusColor = status == 'Normal'
        ? Colors.green
        : status == 'Stunting'
        ? Colors.red
        : Colors.orange;

    Color statusBgColor = status == 'Normal'
        ? Colors.green.shade50
        : status == 'Stunting'
        ? Colors.red.shade50
        : Colors.orange.shade50;

    double berat = double.tryParse(data['berat']?.toString() ?? '0') ?? 0;
    double tinggi = double.tryParse(data['tinggi']?.toString() ?? '0') ?? 0;
    double lKepala = double.tryParse(data['l_kepala']?.toString() ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Hari, Tanggal, Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE2E7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF8B1E3F),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tanggalDisplay,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF8B1E3F),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hari,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Posyandu
                Text(
                  posyandu,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8B1E3F),
                  ),
                ),
                const SizedBox(height: 4),

                // Alamat
                Text(
                  alamat,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),

                // Keterangan
                Text(
                  keterangan,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Data pertumbuhan
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE2E7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildGrowthItem(
                        'Berat',
                        '${berat.toStringAsFixed(1)} kg',
                      ),
                      _buildGrowthItem(
                        'Tinggi',
                        '${tinggi.toStringAsFixed(1)} cm',
                      ),
                      _buildGrowthItem(
                        'L. Kepala',
                        '${lKepala.toStringAsFixed(1)} cm',
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

  Widget _buildGrowthItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF8B1E3F),
          ),
        ),
      ],
    );
  }
}
