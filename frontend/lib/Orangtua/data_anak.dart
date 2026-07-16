import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/services/api_service.dart';
import 'dart:math';

class DataAnakPage extends StatefulWidget {
  final int anakId;
  final Function? onDataChanged;

  const DataAnakPage({super.key, required this.anakId, this.onDataChanged});

  @override
  State<DataAnakPage> createState() => _DataAnakPageState();
}

class _DataAnakPageState extends State<DataAnakPage> {
  List<Map<String, dynamic>> dataAnak = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDataAnak();
  }

  // ============ FUNGSI PERHITUNGAN STATUS GIZI ============
  String _hitungStatusGizi({
    required double beratBadan,
    required double tinggiBadan,
    required double lingkarKepala,
    required int usiaBulan,
    required String jenisKelamin,
  }) {
    // Jika semua data 0 atau null, kembalikan "Belum Diperiksa"
    if (beratBadan <= 0 || tinggiBadan <= 0 || lingkarKepala <= 0) {
      return 'Belum Diperiksa';
    }

    // ============ PERHITUNGAN Z-SCORE UNTUK BB/U (Berat Badan per Usia) ============
    double zScoreBB = _hitungZScoreBBU(beratBadan, usiaBulan, jenisKelamin);

    // ============ PERHITUNGAN Z-SCORE UNTUK TB/U (Tinggi Badan per Usia) ============
    double zScoreTB = _hitungZScoreTBU(tinggiBadan, usiaBulan, jenisKelamin);

    // ============ PERHITUNGAN Z-SCORE UNTUK BB/TB (Berat Badan per Tinggi Badan) ============
    double zScoreBBTB = _hitungZScoreBBTB(
      beratBadan,
      tinggiBadan,
      jenisKelamin,
    );

    // ============ DETERMINASI STATUS GIZI ============
    // Prioritas: Stunting -> Wasting -> Underweight -> Normal
    if (zScoreTB < -2.0) {
      return 'Stunting';
    } else if (zScoreBBTB < -2.0) {
      return 'Kurang (Wasting)';
    } else if (zScoreBBTB > 2.0) {
      return 'Obesitas';
    } else if (zScoreBB < -2.0) {
      return 'Underweight';
    } else if (zScoreBB > 2.0) {
      return 'Overweight';
    } else {
      return 'Normal';
    }
  }

  // ============ Z-SCORE BB/U (Berat Badan per Usia) ============
  double _hitungZScoreBBU(double berat, int usiaBulan, String jenisKelamin) {
    // Standar WHO untuk BB/U (0-60 bulan)
    // Menggunakan rumus LMS (Lambda-Mu-Sigma)

    Map<int, Map<String, List<double>>> dataBBU = {
      // Usia (bulan) -> [L, M, S] untuk Laki-laki dan Perempuan
      0: {
        'L': [1.0, 3.3, 0.12],
        'P': [1.0, 3.2, 0.12],
      },
      1: {
        'L': [1.0, 4.3, 0.13],
        'P': [1.0, 4.2, 0.13],
      },
      2: {
        'L': [1.0, 5.2, 0.13],
        'P': [1.0, 5.1, 0.13],
      },
      3: {
        'L': [1.0, 6.0, 0.13],
        'P': [1.0, 5.8, 0.13],
      },
      4: {
        'L': [1.0, 6.7, 0.13],
        'P': [1.0, 6.4, 0.13],
      },
      5: {
        'L': [1.0, 7.3, 0.13],
        'P': [1.0, 7.0, 0.13],
      },
      6: {
        'L': [1.0, 7.9, 0.13],
        'P': [1.0, 7.5, 0.13],
      },
      7: {
        'L': [1.0, 8.4, 0.13],
        'P': [1.0, 8.0, 0.13],
      },
      8: {
        'L': [1.0, 8.9, 0.13],
        'P': [1.0, 8.5, 0.13],
      },
      9: {
        'L': [1.0, 9.3, 0.13],
        'P': [1.0, 8.9, 0.13],
      },
      10: {
        'L': [1.0, 9.7, 0.13],
        'P': [1.0, 9.3, 0.13],
      },
      11: {
        'L': [1.0, 10.1, 0.13],
        'P': [1.0, 9.7, 0.13],
      },
      12: {
        'L': [1.0, 10.5, 0.13],
        'P': [1.0, 10.0, 0.13],
      },
      18: {
        'L': [1.0, 12.5, 0.12],
        'P': [1.0, 12.0, 0.12],
      },
      24: {
        'L': [1.0, 14.0, 0.12],
        'P': [1.0, 13.5, 0.12],
      },
      36: {
        'L': [1.0, 16.0, 0.11],
        'P': [1.0, 15.5, 0.11],
      },
      48: {
        'L': [1.0, 18.0, 0.11],
        'P': [1.0, 17.5, 0.11],
      },
      60: {
        'L': [1.0, 20.0, 0.11],
        'P': [1.0, 19.5, 0.11],
      },
    };

    // Cari usia terdekat
    List<int> ages = dataBBU.keys.toList()..sort();
    int nearestAge = ages.reduce((a, b) {
      return (a - usiaBulan).abs() < (b - usiaBulan).abs() ? a : b;
    });

    if (nearestAge < 0) nearestAge = 0;
    if (nearestAge > 60) nearestAge = 60;

    String genderKey = jenisKelamin.toLowerCase() == 'laki-laki' ? 'L' : 'P';
    if (genderKey == 'L' && !dataBBU.containsKey(nearestAge)) {
      genderKey = 'P';
    }
    if (genderKey == 'P' && !dataBBU.containsKey(nearestAge)) {
      genderKey = 'L';
    }

    List<double> lms = dataBBU[nearestAge]![genderKey]!;
    double L = lms[0];
    double M = lms[1];
    double S = lms[2];

    // Rumus Z-Score: ((berat/M)^L - 1) / (L * S)
    if (berat <= 0 || M <= 0) return 0;

    try {
      double zScore = (pow(berat / M, L).toDouble() - 1) / (L * S);
      return zScore;
    } catch (e) {
      return 0;
    }
  }

  // ============ Z-SCORE TB/U (Tinggi Badan per Usia) ============
  double _hitungZScoreTBU(double tinggi, int usiaBulan, String jenisKelamin) {
    // Standar WHO untuk TB/U (0-60 bulan)
    Map<int, Map<String, List<double>>> dataTBU = {
      0: {
        'L': [1.0, 49.9, 0.04],
        'P': [1.0, 49.1, 0.04],
      },
      1: {
        'L': [1.0, 53.5, 0.04],
        'P': [1.0, 52.7, 0.04],
      },
      2: {
        'L': [1.0, 56.9, 0.04],
        'P': [1.0, 56.0, 0.04],
      },
      3: {
        'L': [1.0, 59.9, 0.04],
        'P': [1.0, 58.9, 0.04],
      },
      4: {
        'L': [1.0, 62.6, 0.04],
        'P': [1.0, 61.5, 0.04],
      },
      5: {
        'L': [1.0, 65.0, 0.04],
        'P': [1.0, 63.8, 0.04],
      },
      6: {
        'L': [1.0, 67.2, 0.04],
        'P': [1.0, 65.9, 0.04],
      },
      7: {
        'L': [1.0, 69.3, 0.04],
        'P': [1.0, 67.9, 0.04],
      },
      8: {
        'L': [1.0, 71.2, 0.04],
        'P': [1.0, 69.8, 0.04],
      },
      9: {
        'L': [1.0, 73.0, 0.04],
        'P': [1.0, 71.5, 0.04],
      },
      10: {
        'L': [1.0, 74.8, 0.04],
        'P': [1.0, 73.2, 0.04],
      },
      11: {
        'L': [1.0, 76.5, 0.04],
        'P': [1.0, 74.8, 0.04],
      },
      12: {
        'L': [1.0, 78.1, 0.04],
        'P': [1.0, 76.4, 0.04],
      },
      18: {
        'L': [1.0, 86.0, 0.04],
        'P': [1.0, 84.0, 0.04],
      },
      24: {
        'L': [1.0, 93.0, 0.04],
        'P': [1.0, 91.0, 0.04],
      },
      36: {
        'L': [1.0, 104.0, 0.04],
        'P': [1.0, 102.0, 0.04],
      },
      48: {
        'L': [1.0, 112.0, 0.04],
        'P': [1.0, 110.0, 0.04],
      },
      60: {
        'L': [1.0, 119.0, 0.04],
        'P': [1.0, 117.0, 0.04],
      },
    };

    List<int> ages = dataTBU.keys.toList()..sort();
    int nearestAge = ages.reduce((a, b) {
      return (a - usiaBulan).abs() < (b - usiaBulan).abs() ? a : b;
    });

    if (nearestAge < 0) nearestAge = 0;
    if (nearestAge > 60) nearestAge = 60;

    String genderKey = jenisKelamin.toLowerCase() == 'laki-laki' ? 'L' : 'P';
    if (genderKey == 'L' && !dataTBU.containsKey(nearestAge)) {
      genderKey = 'P';
    }
    if (genderKey == 'P' && !dataTBU.containsKey(nearestAge)) {
      genderKey = 'L';
    }

    List<double> lms = dataTBU[nearestAge]![genderKey]!;
    double L = lms[0];
    double M = lms[1];
    double S = lms[2];

    if (tinggi <= 0 || M <= 0) return 0;

    try {
      double zScore = (pow(tinggi / M, L).toDouble() - 1) / (L * S);
      return zScore;
    } catch (e) {
      return 0;
    }
  }

  // ============ Z-SCORE BB/TB (Berat Badan per Tinggi Badan) ============
  double _hitungZScoreBBTB(double berat, double tinggi, String jenisKelamin) {
    // Standar WHO untuk BB/TB
    // Perhitungan sederhana menggunakan BMI
    if (tinggi <= 0) return 0;

    double bmi = berat / ((tinggi / 100) * (tinggi / 100));

    // Standar BMI berdasarkan jenis kelamin dan usia (approximasi)
    double medianBMI;
    double sdBMI;

    // Estimasi median dan SD berdasarkan jenis kelamin
    if (jenisKelamin.toLowerCase() == 'laki-laki') {
      if (tinggi < 70) {
        medianBMI = 13.0;
        sdBMI = 1.5;
      } else if (tinggi < 80) {
        medianBMI = 14.5;
        sdBMI = 1.5;
      } else if (tinggi < 100) {
        medianBMI = 16.0;
        sdBMI = 1.5;
      } else {
        medianBMI = 17.5;
        sdBMI = 1.5;
      }
    } else {
      if (tinggi < 70) {
        medianBMI = 12.5;
        sdBMI = 1.5;
      } else if (tinggi < 80) {
        medianBMI = 14.0;
        sdBMI = 1.5;
      } else if (tinggi < 100) {
        medianBMI = 15.5;
        sdBMI = 1.5;
      } else {
        medianBMI = 17.0;
        sdBMI = 1.5;
      }
    }

    if (sdBMI <= 0) return 0;

    double zScore = (bmi - medianBMI) / sdBMI;
    return zScore;
  }

  // ============ LOAD DATA ANAK ============
  Future<void> _loadDataAnak() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      int orangtuaId = prefs.getInt('orangtua_id') ?? 0;
      int userId = prefs.getInt('user_id') ?? 0;
      int idToUse = orangtuaId > 0 ? orangtuaId : userId;

      if (idToUse == 0) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Session tidak valid, silakan login ulang';
            _isLoading = false;
          });
        }
        return;
      }

      debugPrint('Loading data anak with orangtua_id: $idToUse');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/orangtua/$idToUse/anak'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('Data anak response status: ${response.statusCode}');
      debugPrint('Data anak response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List<dynamic> anakList = data['data'];

          if (mounted) {
            setState(() {
              dataAnak = anakList.map((item) {
                // Hitung status gizi berdasarkan data yang ada
                String statusGizi = item['status_gizi'] ?? 'Normal';

                // Cek apakah data lengkap untuk perhitungan
                double berat =
                    double.tryParse(item['berat_badan']?.toString() ?? '0') ??
                    0;
                double tinggi =
                    double.tryParse(item['tinggi_badan']?.toString() ?? '0') ??
                    0;
                double lk =
                    double.tryParse(
                      item['lingkar_kepala']?.toString() ?? '0',
                    ) ??
                    0;

                // Jika semua data 0, status = Belum Diperiksa
                if (berat == 0 && tinggi == 0 && lk == 0) {
                  statusGizi = 'Belum Diperiksa';
                } else if (berat == 0 || tinggi == 0 || lk == 0) {
                  statusGizi = 'Data Tidak Lengkap';
                }
                // Jika data ada tapi status dari API "Normal", tapi seharusnya tidak normal
                else if (statusGizi == 'Normal') {
                  // Hitung ulang dengan data yang ada
                  // Gunakan perhitungan sederhana sebagai fallback
                  if (tinggi > 0) {
                    double bmi = berat / ((tinggi / 100) * (tinggi / 100));
                    if (bmi < 14)
                      statusGizi = 'Kurang';
                    else if (bmi > 18)
                      statusGizi = 'Obesitas';
                    else
                      statusGizi = 'Normal';
                  }
                }

                return {
                  'anak_id': item['anak_id'],
                  'nama': item['nama_anak'] ?? '',
                  'jk': item['jenis_kelamin'] ?? '',
                  'tgl': item['tanggal_lahir'] ?? '',
                  'berat_lahir': item['berat_badan']?.toString() ?? '-',
                  'tinggi_lahir': item['tinggi_badan']?.toString() ?? '-',
                  'lk_lahir': item['lingkar_kepala']?.toString() ?? '-',
                  'status': statusGizi,
                };
              }).toList();
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } else if (response.statusCode == 401) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Session habis, silakan login ulang';
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Gagal memuat data anak';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  // ============ CREATE ANAK ============
  Future<void> _createAnak(Map<String, dynamic> data) async {
    if (!mounted) return;

    setState(() {
      _isSaving = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int orangtuaId = prefs.getInt('orangtua_id') ?? 0;
      int userId = prefs.getInt('user_id') ?? 0;
      int idToUse = orangtuaId > 0 ? orangtuaId : userId;

      // Parse data
      double beratBadan = double.tryParse(data['berat'] ?? '0') ?? 0;
      double tinggiBadan = double.tryParse(data['tinggi'] ?? '0') ?? 0;
      double lingkarKepala = double.tryParse(data['lk'] ?? '0') ?? 0;

      // Hitung status gizi berdasarkan data yang diinput
      String statusGizi = _hitungStatusGiziDariInput(
        beratBadan: beratBadan,
        tinggiBadan: tinggiBadan,
        lingkarKepala: lingkarKepala,
        tanggalLahir: data['tgl'] ?? '',
        jenisKelamin: data['jk'] ?? 'Laki-laki',
      );

      final requestBody = {
        'orangtua_id': idToUse,
        'nama': data['nama'] ?? '',
        'jenis_kelamin': data['jk'] ?? 'Laki-laki',
        'tanggal_lahir': data['tgl'] ?? '',
        'berat_badan': beratBadan,
        'tinggi_badan': tinggiBadan,
        'lingkar_kepala': lingkarKepala,
        'status_gizi': statusGizi, // Kirim status yang sudah dihitung
      };

      debugPrint('Create anak request: $requestBody');
      debugPrint('Status gizi yang dihitung: $statusGizi');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/anak'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      debugPrint('Create anak response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _loadDataAnak();

        if (widget.onDataChanged != null) {
          widget.onDataChanged!();
        }

        if (mounted) {
          final anakBaru = dataAnak.isNotEmpty ? dataAnak.last : null;
          Navigator.pop(context, {
            'success': true,
            'data': anakBaru,
            'action': 'add',
          });
        }
      } else {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Gagal menambahkan anak');
      }
    } catch (e) {
      debugPrint('Error create anak: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============ HITUNG STATUS GIZI DARI INPUT ============
  String _hitungStatusGiziDariInput({
    required double beratBadan,
    required double tinggiBadan,
    required double lingkarKepala,
    required String tanggalLahir,
    required String jenisKelamin,
  }) {
    // Jika semua data 0, status = "Belum Diperiksa"
    if (beratBadan <= 0 && tinggiBadan <= 0 && lingkarKepala <= 0) {
      return 'Belum Diperiksa';
    }

    // Jika ada data yang 0 tapi tidak semua
    if (beratBadan <= 0 || tinggiBadan <= 0 || lingkarKepala <= 0) {
      return 'Data Tidak Lengkap';
    }

    // Hitung usia dalam bulan dari tanggal lahir
    DateTime? tglLahir = DateTime.tryParse(tanggalLahir);
    if (tglLahir == null) {
      return 'Data Tidak Lengkap';
    }

    DateTime now = DateTime.now();
    int usiaBulan =
        (now.year - tglLahir.year) * 12 + (now.month - tglLahir.month);
    if (usiaBulan < 0) usiaBulan = 0;
    if (usiaBulan > 60) usiaBulan = 60; // Maksimal 60 bulan (5 tahun)

    // Hitung status gizi menggunakan Z-Score
    String status = _hitungStatusGizi(
      beratBadan: beratBadan,
      tinggiBadan: tinggiBadan,
      lingkarKepala: lingkarKepala,
      usiaBulan: usiaBulan,
      jenisKelamin: jenisKelamin,
    );

    return status;
  }

  // ============ UPDATE ANAK ============
  Future<void> _updateAnak(int anakId, Map<String, dynamic> data) async {
    if (!mounted) return;

    setState(() {
      _isSaving = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan, silakan login ulang');
      }

      // Parse data
      double beratBadan = double.tryParse(data['berat'] ?? '0') ?? 0;
      double tinggiBadan = double.tryParse(data['tinggi'] ?? '0') ?? 0;
      double lingkarKepala = double.tryParse(data['lk'] ?? '0') ?? 0;

      // Hitung status gizi berdasarkan data yang diinput
      String statusGizi = _hitungStatusGiziDariInput(
        beratBadan: beratBadan,
        tinggiBadan: tinggiBadan,
        lingkarKepala: lingkarKepala,
        tanggalLahir: data['tgl'] ?? '',
        jenisKelamin: data['jk'] ?? 'Laki-laki',
      );

      final requestBody = {
        'nama': data['nama'] ?? '',
        'jenis_kelamin': data['jk'] ?? 'Laki-laki',
        'tanggal_lahir': data['tgl'] ?? '',
        'berat_badan': beratBadan,
        'tinggi_badan': tinggiBadan,
        'lingkar_kepala': lingkarKepala,
        'status_gizi': statusGizi, // Kirim status yang sudah dihitung
      };

      debugPrint('Update anak request: $requestBody');
      debugPrint('Status gizi yang dihitung: $statusGizi');

      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/anak/$anakId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      debugPrint('Update anak response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          await _loadDataAnak();

          if (widget.onDataChanged != null) {
            widget.onDataChanged!();
          }

          if (mounted) {
            Navigator.pop(context, {
              'success': true,
              'data': requestBody,
              'anak_id': anakId,
              'action': 'update',
            });
          }
        } else {
          throw Exception(
            responseData['message'] ?? 'Gagal mengupdate data anak',
          );
        }
      } else {
        throw Exception(
          'Gagal mengupdate data anak (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('Error update anak: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============ DELETE ANAK ============
  Future<void> _deleteAnak(int anakId, int index) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Data Anak'),
        content: const Text('Apakah Anda yakin ingin menghapus data anak ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;

    setState(() {
      _isSaving = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/anak/$anakId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          dataAnak.removeAt(index);
        });

        if (widget.onDataChanged != null) {
          widget.onDataChanged!();
        }

        if (mounted) {
          Navigator.pop(context, {
            'success': true,
            'anak_id': anakId,
            'action': 'delete',
          });
        }
      } else {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Gagal menghapus data anak');
      }
    } catch (e) {
      debugPrint('Error delete anak: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============ TAMBAH ANAK FORM ============
  void _showTambahAnakForm() async {
    TextEditingController namaController = TextEditingController();
    TextEditingController tglController = TextEditingController();
    TextEditingController beratController = TextEditingController();
    TextEditingController tinggiController = TextEditingController();
    TextEditingController lkController = TextEditingController();
    String selectedJk = 'Laki-laki';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Center(
                child: Text(
                  "Tambah Data Anak",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Nama Anak",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: namaController,
                      decoration: InputDecoration(
                        hintText: "Masukkan nama anak",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Jenis Kelamin",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("Laki-laki"),
                            value: "Laki-laki",
                            groupValue: selectedJk,
                            onChanged: (value) {
                              setStateDialog(() {
                                selectedJk = value!;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("Perempuan"),
                            value: "Perempuan",
                            groupValue: selectedJk,
                            onChanged: (value) {
                              setStateDialog(() {
                                selectedJk = value!;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Tanggal Lahir",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: tglController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "Pilih tanggal lahir",
                        suffixIcon: const Icon(Icons.calendar_month),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onTap: () async {
                        DateTime maxDate = DateTime.now();
                        DateTime minDate = DateTime.now().subtract(
                          const Duration(days: 365 * 10),
                        );

                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: maxDate.subtract(
                            const Duration(days: 365 * 1),
                          ),
                          firstDate: minDate,
                          lastDate: maxDate,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFFD86487),
                                  onPrimary: Colors.white,
                                  onSurface: Color(0xFF333333),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedDate != null) {
                          tglController.text =
                              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                          setStateDialog(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Berat Badan Lahir (kg)",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: beratController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: "Contoh: 3.5 (isi 0 jika belum diketahui)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Tinggi Badan Lahir (cm)",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: tinggiController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: "Contoh: 50 (isi 0 jika belum diketahui)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Lingkar Kepala Lahir (cm)",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: lkController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: "Contoh: 34 (isi 0 jika belum diketahui)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Status gizi akan dihitung otomatis berdasarkan data yang diisi',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
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
                  onPressed: () async {
                    if (namaController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nama anak wajib diisi'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (tglController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tanggal lahir wajib diisi'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);

                    await _createAnak({
                      'nama': namaController.text.trim(),
                      'jk': selectedJk,
                      'tgl': tglController.text,
                      'berat': beratController.text.trim().isEmpty
                          ? '0'
                          : beratController.text.trim(),
                      'tinggi': tinggiController.text.trim().isEmpty
                          ? '0'
                          : tinggiController.text.trim(),
                      'lk': lkController.text.trim().isEmpty
                          ? '0'
                          : lkController.text.trim(),
                    });
                  },
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Simpan",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============ EDIT ANAK FORM (DETAIL) ============
  void _showEditAnakForm(int index) async {
    final anak = dataAnak[index];
    TextEditingController tglController = TextEditingController(
      text: anak['tgl'] ?? '',
    );

    final String beratLahir =
        anak['berat_lahir'] != '-' && anak['berat_lahir'] != null
        ? "${anak['berat_lahir']} kg"
        : "Belum ada data";
    final String tinggiLahir =
        anak['tinggi_lahir'] != '-' && anak['tinggi_lahir'] != null
        ? "${anak['tinggi_lahir']} cm"
        : "Belum ada data";
    final String lkLahir = anak['lk_lahir'] != '-' && anak['lk_lahir'] != null
        ? "${anak['lk_lahir']} cm"
        : "Belum ada data";
    final String statusGizi = anak['status'] ?? 'Normal';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Center(
                child: Text(
                  "Detail Data Anak",
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Nama Anak",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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
                        anak['nama'] ?? '',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Jenis Kelamin",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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
                        anak['jk'] ?? '',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Berat Badan Lahir",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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
                        beratLahir,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Tinggi Badan Lahir",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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
                        tinggiLahir,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Lingkar Kepala Lahir",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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
                        lkLahir,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Status Gizi",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: statusGizi == 'Normal'
                            ? Colors.green.shade50
                            : statusGizi == 'Stunting'
                            ? Colors.red.shade50
                            : statusGizi == 'Kurang' ||
                                  statusGizi == 'Kurang (Wasting)'
                            ? Colors.orange.shade50
                            : statusGizi == 'Obesitas' ||
                                  statusGizi == 'Overweight'
                            ? Colors.purple.shade50
                            : statusGizi == 'Belum Diperiksa'
                            ? Colors.grey.shade50
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusGizi == 'Normal'
                              ? Colors.green.shade200
                              : statusGizi == 'Stunting'
                              ? Colors.red.shade200
                              : statusGizi == 'Kurang' ||
                                    statusGizi == 'Kurang (Wasting)'
                              ? Colors.orange.shade200
                              : statusGizi == 'Obesitas' ||
                                    statusGizi == 'Overweight'
                              ? Colors.purple.shade200
                              : statusGizi == 'Belum Diperiksa'
                              ? Colors.grey.shade200
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Text(
                        statusGizi,
                        style: TextStyle(
                          color: statusGizi == 'Normal'
                              ? Colors.green.shade700
                              : statusGizi == 'Stunting'
                              ? Colors.red.shade700
                              : statusGizi == 'Kurang' ||
                                    statusGizi == 'Kurang (Wasting)'
                              ? Colors.orange.shade700
                              : statusGizi == 'Obesitas' ||
                                    statusGizi == 'Overweight'
                              ? Colors.purple.shade700
                              : statusGizi == 'Belum Diperiksa'
                              ? Colors.grey.shade700
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Tanggal Lahir",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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
                        tglController.text.isNotEmpty
                            ? tglController.text
                            : 'Belum ada data',
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
                    "Tutup",
                    style: TextStyle(color: Color(0xFFD86487), fontSize: 14),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, {'success': false});
        return false;
      },
      child: Scaffold(
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
            onPressed: () {
              Navigator.pop(context, {'success': false});
            },
          ),
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
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text('Belum ada data anak'),
                                SizedBox(height: 8),
                                Text('Tekan tombol + untuk menambahkan'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: dataAnak.length,
                            itemBuilder: (context, index) {
                              final anak = dataAnak[index];
                              final status = anak["status"] ?? 'Normal';

                              // Warna status
                              Color statusColor;
                              Color statusBgColor;
                              if (status == 'Normal') {
                                statusColor = Colors.green.shade700;
                                statusBgColor = Colors.green.shade50;
                              } else if (status == 'Stunting') {
                                statusColor = Colors.red.shade700;
                                statusBgColor = Colors.red.shade50;
                              } else if (status == 'Kurang' ||
                                  status == 'Kurang (Wasting)') {
                                statusColor = Colors.orange.shade700;
                                statusBgColor = Colors.orange.shade50;
                              } else if (status == 'Obesitas' ||
                                  status == 'Overweight') {
                                statusColor = Colors.purple.shade700;
                                statusBgColor = Colors.purple.shade50;
                              } else if (status == 'Belum Diperiksa') {
                                statusColor = Colors.grey.shade700;
                                statusBgColor = Colors.grey.shade50;
                              } else {
                                statusColor = Colors.grey.shade700;
                                statusBgColor = Colors.grey.shade50;
                              }

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
                                              anak["nama"] ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Color(0xFFD86487),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              anak["jk"] ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: statusBgColor,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: statusColor
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              child: Text(
                                                status,
                                                style: TextStyle(
                                                  color: statusColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.visibility,
                                                color: Color(0xFFD86487),
                                              ),
                                              onPressed: () =>
                                                  _showEditAnakForm(index),
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
                                    _buildDetail(
                                      "Tanggal lahir",
                                      anak["tgl"] ?? '',
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDetail(
                                      "Berat badan lahir",
                                      anak["berat_lahir"] != '-' &&
                                              anak["berat_lahir"] != null
                                          ? "${anak["berat_lahir"]} kg"
                                          : "Belum ada data",
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDetail(
                                      "Tinggi badan lahir",
                                      anak["tinggi_lahir"] != '-' &&
                                              anak["tinggi_lahir"] != null
                                          ? "${anak["tinggi_lahir"]} cm"
                                          : "Belum ada data",
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDetail(
                                      "Lingkar kepala lahir",
                                      anak["lk_lahir"] != '-' &&
                                              anak["lk_lahir"] != null
                                          ? "${anak["lk_lahir"]} cm"
                                          : "Belum ada data",
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
                        onPressed: () => _showTambahAnakForm(),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "Tambah Anak",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
