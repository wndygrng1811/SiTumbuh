import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/Orangtua/profil.dart';

class DataAnakPage extends StatefulWidget {
  final int anakId;

  const DataAnakPage({super.key, required this.anakId});

  @override
  State<DataAnakPage> createState() => _DataAnakPageState();
}

class _DataAnakPageState extends State<DataAnakPage> {
  List<Map<String, dynamic>> dataAnak = [];
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
        Uri.parse('http://your-api.com/api/orangtua/$orangtuaId/anak'),
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
                'nama': item['nama_anak'],
                'jk': item['jenis_kelamin'],
                'tgl': item['tanggal_lahir'],
                'bb': item['berat_lahir']?.toString() ?? '-',
                'tb': item['tinggi_lahir']?.toString() ?? '-',
                'lk': item['lingkar_kepala_lahir']?.toString() ?? '-',
              };
            }).toList();
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
          _errorMessage = 'Gagal terhubung ke server';
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

  Future<void> _saveAnak(Map<String, dynamic> data, {int? index}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int orangtuaId = prefs.getInt('user_id') ?? 0;

      final response = index == null
          ? await http.post(
              Uri.parse('http://your-api.com/api/anak'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'orangtua_id': orangtuaId,
                'nama_anak': data['nama'],
                'jenis_kelamin': data['jk'],
                'tanggal_lahir': data['tgl'],
                'berat_lahir': double.tryParse(data['bb']) ?? 0,
                'tinggi_lahir': double.tryParse(data['tb']) ?? 0,
                'lingkar_kepala_lahir': double.tryParse(data['lk']) ?? 0,
              }),
            )
          : await http.put(
              Uri.parse('http://your-api.com/api/anak/${data['anak_id']}'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'nama_anak': data['nama'],
                'jenis_kelamin': data['jk'],
                'tanggal_lahir': data['tgl'],
                'berat_lahir': double.tryParse(data['bb']) ?? 0,
                'tinggi_lahir': double.tryParse(data['tb']) ?? 0,
                'lingkar_kepala_lahir': double.tryParse(data['lk']) ?? 0,
              }),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _loadDataAnak(); // Refresh data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              index == null
                  ? 'Anak berhasil ditambahkan'
                  : 'Data berhasil diupdate',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan data')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteAnak(int anakId, int index) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('http://your-api.com/api/anak/$anakId'),
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
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal menghapus data')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void showForm({int? index}) {
    Map<String, dynamic>? existingData;
    if (index != null) {
      existingData = dataAnak[index];
    }

    TextEditingController nama = TextEditingController(
      text: existingData?['nama'] ?? '',
    );
    TextEditingController jk = TextEditingController(
      text: existingData?['jk'] ?? '',
    );
    TextEditingController tgl = TextEditingController(
      text: existingData?['tgl'] ?? '',
    );
    TextEditingController bb = TextEditingController(
      text: existingData?['bb'] ?? '',
    );
    TextEditingController tb = TextEditingController(
      text: existingData?['tb'] ?? '',
    );
    TextEditingController lk = TextEditingController(
      text: existingData?['lk'] ?? '',
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(index == null ? "Tambah Anak" : "Edit Data Anak"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                buildInput(nama, "Nama Anak"),
                buildInput(jk, "Jenis Kelamin (Laki-laki/Perempuan)"),
                buildInput(tgl, "Tanggal Lahir (YYYY-MM-DD)"),
                buildInput(bb, "Berat Lahir (kg)"),
                buildInput(tb, "Tinggi Lahir (cm)"),
                buildInput(lk, "Lingkar Kepala (cm)"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE85D75),
              ),
              onPressed: () {
                Navigator.pop(context);
                _saveAnak({
                  'anak_id': existingData?['anak_id'],
                  'nama': nama.text,
                  'jk': jk.text,
                  'tgl': tgl.text,
                  'bb': bb.text,
                  'tb': tb.text,
                  'lk': lk.text,
                }, index: index);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Widget buildInput(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
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
                      backgroundColor: const Color(0xFFE85D75),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                /// HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 50,
                    left: 20,
                    right: 20,
                    bottom: 25,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE85D75),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfilePage(
                                    anakId: 0,
                                    namaAnak: '',
                                    jenisKelamin: '',
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Data anak",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Kelola informasi data anak anda",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                /// LIST DATA
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
                                borderRadius: BorderRadius.circular(18),
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
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(anak["jk"]!),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.pink,
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
                                  const SizedBox(height: 10),
                                  buildInfo("Tanggal lahir", anak["tgl"]!),
                                  buildInfo(
                                    "Berat badan ketika lahir",
                                    "${anak["bb"]} kg",
                                  ),
                                  buildInfo(
                                    "Tinggi badan ketika lahir",
                                    "${anak["tb"]} cm",
                                  ),
                                  buildInfo(
                                    "Lingkar kepala ketika lahir",
                                    "${anak["lk"]} cm",
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                /// BUTTON TAMBAH
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE85D75),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => showForm(),
                    icon: const Icon(Icons.add),
                    label: const Text("Tambah anak"),
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
