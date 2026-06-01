import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/Orangtua/profil.dart';
import 'package:si_tumbuh/services/api_service.dart';

class DataAnakPage extends StatefulWidget {
  final int anakId;

  const DataAnakPage({super.key, required this.anakId});

  @override
  State<DataAnakPage> createState() => _DataAnakPageState();
}

class _DataAnakPageState extends State<DataAnakPage> {
  List<Map<String, dynamic>> dataAnak = [];
  Map<String, dynamic> _pertumbuhanTerbaru = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDataAnak();
  }

  Future<void> _loadDataAnak() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int orangtuaId = prefs.getInt('user_id') ?? 0;

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/orangtua/$orangtuaId/anak'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          List<dynamic> anakList = data['data'];

          setState(() {
            dataAnak = anakList.map((item) {
              return {
                'anak_id': item['anak_id'],
                'nama': item['nama'],
                'jk': item['jenis_kelamin'],
                'tgl': item['tanggal_lahir'],
                'berat': '-',
                'tinggi': '-',
                'l_kepala': '-',
              };
            }).toList();
            _isLoading = false;
          });

          // Load pertumbuhan terbaru untuk setiap anak
          for (var anak in dataAnak) {
            await _loadPertumbuhanTerbaru(anak['anak_id']);
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPertumbuhanTerbaru(int anakId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/pertumbuhan/$anakId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true &&
            data['data'] != null &&
            data['data'].isNotEmpty) {
          var terbaru = data['data'].last;
          setState(() {
            int index = dataAnak.indexWhere((a) => a['anak_id'] == anakId);
            if (index != -1) {
              dataAnak[index]['berat'] = terbaru['berat']?.toString() ?? '-';
              dataAnak[index]['tinggi'] = terbaru['tinggi']?.toString() ?? '-';
              dataAnak[index]['l_kepala'] =
                  terbaru['l_kepala']?.toString() ?? '-';
            }
          });
        }
      }
    } catch (e) {
      print('Error load pertumbuhan: $e');
    }
  }

  Future<void> _createAnak(Map<String, dynamic> data) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int orangtuaId = prefs.getInt('user_id') ?? 0;

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/anak'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'orangtua_id': orangtuaId,
          'nama': data['nama'],
          'jenis_kelamin': data['jk'],
          'tanggal_lahir': data['tgl'],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _loadDataAnak();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anak berhasil ditambahkan')),
        );
      }
    } catch (e) {
      print('Error create anak: $e');
    }
  }

  Future<void> _updateAnak(int anakId, Map<String, dynamic> data) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/anak/$anakId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nama': data['nama'],
          'jenis_kelamin': data['jk'],
          'tanggal_lahir': data['tgl'],
        }),
      );

      if (response.statusCode == 200) {
        _loadDataAnak();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data anak berhasil diupdate')),
        );
      }
    } catch (e) {
      print('Error update anak: $e');
    }
  }

  Future<void> _deleteAnak(int anakId, int index) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/anak/$anakId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          dataAnak.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data anak berhasil dihapus')),
        );
      }
    } catch (e) {
      print('Error delete anak: $e');
    }
  }

  void showForm({int? index}) async {
    Map<String, dynamic>? existingData;
    Map<String, dynamic> pertumbuhanData = {
      'berat': '-',
      'tinggi': '-',
      'l_kepala': '-',
    };

    if (index != null) {
      existingData = dataAnak[index];
      pertumbuhanData['berat'] = existingData['berat'];
      pertumbuhanData['tinggi'] = existingData['tinggi'];
      pertumbuhanData['l_kepala'] = existingData['l_kepala'];
    }

    TextEditingController tglController = TextEditingController(
      text: existingData?['tgl'] ?? '',
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Center(
            child: Text(
              "Edit Data Anak",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tanggal Lahir
                const Text(
                  "Tanggal Lahir",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: tglController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    hintText: "18/04/2026",
                  ),
                ),
                const SizedBox(height: 16),

                // Berat Badan Ketika Lahir (READ ONLY)
                const Text(
                  "Berat Badan Ketika Lahir (kg)",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    pertumbuhanData['berat'] != '-' &&
                            pertumbuhanData['berat'] != ''
                        ? "${pertumbuhanData['berat']} kg"
                        : "3.8 kg",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 16),

                // Tinggi Badan Ketika Lahir (READ ONLY)
                const Text(
                  "Tinggi Badan Ketika Lahir (cm)",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    pertumbuhanData['tinggi'] != '-' &&
                            pertumbuhanData['tinggi'] != ''
                        ? "${pertumbuhanData['tinggi']} cm"
                        : "52 cm",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 16),

                // Lingkar Kepala Ketika Lahir (READ ONLY)
                const Text(
                  "Lingkar Kepala Ketika Lahir (cm)",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    pertumbuhanData['l_kepala'] != '-' &&
                            pertumbuhanData['l_kepala'] != ''
                        ? "${pertumbuhanData['l_kepala']} cm"
                        : "46 cm",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD86487),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                if (index == null) {
                  _createAnak({
                    'nama': existingData?['nama'] ?? '',
                    'jk': existingData?['jk'] ?? '',
                    'tgl': tglController.text,
                  });
                } else {
                  _updateAnak(existingData!['anak_id'], {
                    'nama': existingData['nama'],
                    'jk': existingData['jk'],
                    'tgl': tglController.text,
                  });
                }
              },
              child: const Text(
                "Simpan",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          "Data Anak",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFD86487),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const ProfilePage(anakId: 0, namaAnak: '', jenisKelamin: ''),
            ),
          ),
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
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDataAnak,
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
                const SizedBox(height: 16),
                Expanded(
                  child: dataAnak.isEmpty
                      ? const Center(child: Text('Belum ada data anak'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: dataAnak.length,
                          itemBuilder: (context, index) {
                            final anak = dataAnak[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 6,
                                    color: Colors.black12,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            anak["nama"]!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Color(0xFFD86487),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            anak["jk"]!,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Color(0xFFD86487),
                                            ),
                                            onPressed: () =>
                                                showForm(index: index),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () => _deleteAnak(
                                              anak['anak_id'],
                                              index,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 12),
                                  _buildDetail("Tanggal lahir", anak["tgl"]!),
                                  const SizedBox(height: 8),
                                  _buildDetail(
                                    "Berat badan",
                                    "${anak["berat"]} kg",
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDetail(
                                    "Tinggi badan",
                                    "${anak["tinggi"]} cm",
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDetail(
                                    "Lingkar kepala",
                                    "${anak["l_kepala"]} cm",
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD86487),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => showForm(),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Tambah anak",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(
          value.isNotEmpty ? value : "-",
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
