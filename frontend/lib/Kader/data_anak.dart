import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import '../services/api_service.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';
import '../widgets/custom_app_bar.dart';

class DataAnakPage extends StatefulWidget {
  const DataAnakPage({super.key});

  @override
  State<DataAnakPage> createState() => _DataAnakPageState();
}

class _DataAnakPageState extends State<DataAnakPage> {
  List<Map<String, dynamic>> dataAnak = [];
  List<Map<String, dynamic>> filteredAnak = [];
  List<Map<String, dynamic>> orangTuaList = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _errorMessage = '';
  String _searchQuery = '';
  String _filterGender = 'Semua';
  final int _selectedIndex = 1;
  final TextEditingController _searchController = TextEditingController();

  // Controller untuk form tambah
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _tglCtrl = TextEditingController();
  final TextEditingController _bbCtrl = TextEditingController();
  final TextEditingController _tbCtrl = TextEditingController();
  final TextEditingController _lkCtrl = TextEditingController();
  String? _selectedJk;
  int? _selectedOrangTuaId;
  DateTime? _selectedTanggal;

  // Variable untuk edit (tanpa controller global)
  int? _editAnakId;
  String _editNama = '';
  String _editTgl = '';
  String _editBb = '';
  String _editTb = '';
  String _editLk = '';
  String _editJk = 'Laki-laki';
  int? _editOrangTuaId;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadOrangTuaDropdown();
    _searchController.addListener(_filterAnak);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _namaCtrl.dispose();
    _tglCtrl.dispose();
    _bbCtrl.dispose();
    _tbCtrl.dispose();
    _lkCtrl.dispose();
    super.dispose();
  }

  // ============ FUNGSI PERHITUNGAN STATUS GIZI ============
  String _hitungStatusGizi({
    required double beratBadan,
    required double tinggiBadan,
    required double lingkarKepala,
    required int usiaBulan,
    required String jenisKelamin,
  }) {
    if (beratBadan <= 0 && tinggiBadan <= 0 && lingkarKepala <= 0) {
      return 'Belum Diperiksa';
    }

    if (beratBadan <= 0 || tinggiBadan <= 0 || lingkarKepala <= 0) {
      return 'Data Tidak Lengkap';
    }

    double zScoreTB = _hitungZScoreTBU(tinggiBadan, usiaBulan, jenisKelamin);
    double zScoreBBTB = _hitungZScoreBBTB(
      beratBadan,
      tinggiBadan,
      jenisKelamin,
    );
    double zScoreBB = _hitungZScoreBBU(beratBadan, usiaBulan, jenisKelamin);

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

  double _hitungZScoreTBU(double tinggi, int usiaBulan, String jenisKelamin) {
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

  double _hitungZScoreBBTB(double berat, double tinggi, String jenisKelamin) {
    if (tinggi <= 0) return 0;

    double bmi = berat / ((tinggi / 100) * (tinggi / 100));

    double medianBMI;
    double sdBMI;

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

  double _hitungZScoreBBU(double berat, int usiaBulan, String jenisKelamin) {
    Map<int, Map<String, List<double>>> dataBBU = {
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

    if (berat <= 0 || M <= 0) return 0;

    try {
      double zScore = (pow(berat / M, L).toDouble() - 1) / (L * S);
      return zScore;
    } catch (e) {
      return 0;
    }
  }

  String _hitungStatusDariInput({
    required double beratBadan,
    required double tinggiBadan,
    required double lingkarKepala,
    required String tanggalLahir,
    required String jenisKelamin,
  }) {
    if (beratBadan <= 0 && tinggiBadan <= 0 && lingkarKepala <= 0) {
      return 'Belum Diperiksa';
    }

    if (beratBadan <= 0 || tinggiBadan <= 0 || lingkarKepala <= 0) {
      return 'Data Tidak Lengkap';
    }

    DateTime? tglLahir = DateTime.tryParse(tanggalLahir);
    if (tglLahir == null) {
      return 'Data Tidak Lengkap';
    }

    DateTime now = DateTime.now();
    int usiaBulan =
        (now.year - tglLahir.year) * 12 + (now.month - tglLahir.month);
    if (usiaBulan < 0) usiaBulan = 0;
    if (usiaBulan > 60) usiaBulan = 60;

    return _hitungStatusGizi(
      beratBadan: beratBadan,
      tinggiBadan: tinggiBadan,
      lingkarKepala: lingkarKepala,
      usiaBulan: usiaBulan,
      jenisKelamin: jenisKelamin,
    );
  }

  void _filterAnak() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    filteredAnak = dataAnak.where((anak) {
      final matchSearch =
          _searchQuery.isEmpty ||
          anak['nama'].toLowerCase().contains(_searchQuery);
      final matchGender =
          _filterGender == 'Semua' ||
          (_filterGender == 'Laki-laki' &&
              anak['jenis_kelamin'] == 'Laki-laki') ||
          (_filterGender == 'Perempuan' &&
              anak['jenis_kelamin'] == 'Perempuan');
      return matchSearch && matchGender;
    }).toList();
  }

  String _getJenisKelaminText(String? value) {
    if (value == null || value.isEmpty) return 'Tidak diketahui';
    if (value == 'L') return 'Laki-laki';
    if (value == 'P') return 'Perempuan';
    return value;
  }

  String _formatAngka(dynamic value) {
    if (value == null) return '0';
    if (value.toString().isEmpty) return '0';
    if (value == 0) return '0';
    return value.toString();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiService.get('/kader/semua-anak');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          List<dynamic> anakList = data['data'] ?? [];
          if (mounted) {
            setState(() {
              dataAnak = anakList.map((item) {
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

                String statusGizi = item['status_gizi'] ?? 'Normal';

                if (berat == 0 && tinggi == 0 && lk == 0) {
                  statusGizi = 'Belum Diperiksa';
                } else if (berat == 0 || tinggi == 0 || lk == 0) {
                  statusGizi = 'Data Tidak Lengkap';
                } else if (statusGizi == 'Normal' || statusGizi == '') {
                  String tglLahir = item['tanggal_lahir'] ?? '';
                  String jk = item['jenis_kelamin'] ?? 'L';
                  String jenisKelamin = jk == 'L' ? 'Laki-laki' : 'Perempuan';

                  statusGizi = _hitungStatusDariInput(
                    beratBadan: berat,
                    tinggiBadan: tinggi,
                    lingkarKepala: lk,
                    tanggalLahir: tglLahir,
                    jenisKelamin: jenisKelamin,
                  );
                }

                return {
                  'anak_id': item['anak_id'],
                  'nama': item['nama_anak'] ?? item['nama'] ?? '',
                  'jenis_kelamin': _getJenisKelaminText(item['jenis_kelamin']),
                  'tanggal_lahir': item['tanggal_lahir'] ?? '',
                  'berat_badan': _formatAngka(item['berat_badan']),
                  'tinggi_badan': _formatAngka(item['tinggi_badan']),
                  'lingkar_kepala': _formatAngka(item['lingkar_kepala']),
                  'status_gizi': statusGizi,
                  'nama_ortu': item['nama_ortu'] ?? '-',
                  'orangtua_id': item['orangtua_id'],
                };
              }).toList();
              _applyFilters();
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = data['message'] ?? 'Gagal memuat data';
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                'Gagal terhubung ke server (${response.statusCode})';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error loading data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadOrangTuaDropdown() async {
    try {
      final response = await ApiService.get('/kader/orangtua');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            orangTuaList = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      print('Error load orang tua dropdown: $e');
    }
  }

  Future<void> _tambahAnak() async {
    if (_isSubmitting) return;

    if (_selectedOrangTuaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih orang tua terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedJk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jenis kelamin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String jenisKelamin = _selectedJk == 'Laki-laki' ? 'L' : 'P';

      double berat = double.tryParse(_bbCtrl.text) ?? 0;
      double tinggi = double.tryParse(_tbCtrl.text) ?? 0;
      double lk = double.tryParse(_lkCtrl.text) ?? 0;

      String statusGizi = _hitungStatusDariInput(
        beratBadan: berat,
        tinggiBadan: tinggi,
        lingkarKepala: lk,
        tanggalLahir: _tglCtrl.text,
        jenisKelamin: _selectedJk!,
      );

      final requestBody = {
        'orangtua_id': _selectedOrangTuaId,
        'nama': _namaCtrl.text,
        'jenis_kelamin': jenisKelamin,
        'tanggal_lahir': _tglCtrl.text,
        'berat_badan': berat,
        'tinggi_badan': tinggi,
        'lingkar_kepala': lk,
        'status_gizi': statusGizi,
      };

      final response = await ApiService.post('/kader/anak', requestBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          _resetForm();
          await _loadData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Anak berhasil ditambahkan'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception(responseData['message'] ?? 'Gagal menyimpan');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ============ EDIT ANAK ============
  Future<void> _editAnak() async {
    if (_isSubmitting) return;
    if (_editAnakId == null) return;

    if (!mounted) return;

    setState(() => _isSubmitting = true);

    try {
      String jenisKelamin = _editJk == 'Laki-laki' ? 'L' : 'P';

      double berat = double.tryParse(_editBb) ?? 0;
      double tinggi = double.tryParse(_editTb) ?? 0;
      double lk = double.tryParse(_editLk) ?? 0;

      debugPrint('📝 Edit anak - Berat: $berat, Tinggi: $tinggi, LK: $lk');

      String statusGizi = _hitungStatusDariInput(
        beratBadan: berat,
        tinggiBadan: tinggi,
        lingkarKepala: lk,
        tanggalLahir: _editTgl,
        jenisKelamin: _editJk,
      );

      debugPrint('📝 Status gizi hasil perhitungan: $statusGizi');

      final requestBody = {
        'nama': _editNama,
        'jenis_kelamin': jenisKelamin,
        'tanggal_lahir': _editTgl,
        'berat_badan': berat,
        'tinggi_badan': tinggi,
        'lingkar_kepala': lk,
        'status_gizi': statusGizi,
      };

      debugPrint('📝 Request body: $requestBody');

      final response = await ApiService.put(
        '/kader/anak/${_editAnakId}',
        requestBody,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          _resetEditForm();
          await _loadData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Data anak berhasil diupdate'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception(responseData['message'] ?? 'Gagal mengupdate');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _resetEditForm() {
    if (!mounted) return;
    setState(() {
      _editAnakId = null;
      _editNama = '';
      _editTgl = '';
      _editBb = '';
      _editTb = '';
      _editLk = '';
      _editJk = 'Laki-laki';
      _editOrangTuaId = null;
    });
  }

  Future<void> _hapusAnak(int anakId, String namaAnak) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Data Anak'),
        content: Text('Yakin ingin menghapus data anak "$namaAnak"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await ApiService.delete('/kader/anak/$anakId');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          await _loadData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Data anak berhasil dihapus'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception(responseData['message'] ?? 'Gagal menghapus');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _namaCtrl.clear();
    _tglCtrl.clear();
    _bbCtrl.clear();
    _tbCtrl.clear();
    _lkCtrl.clear();
    setState(() {
      _selectedJk = null;
      _selectedOrangTuaId = null;
      _selectedTanggal = null;
    });
  }

  // ============ SHOW EDIT FORM ============
  void _showEditForm(Map<String, dynamic> anak) {
    // Reset dulu
    _resetEditForm();

    // Set data ke variable (bukan controller)
    setState(() {
      _editAnakId = anak['anak_id'];
      _editNama = anak['nama'] ?? '';
      _editTgl = anak['tanggal_lahir'] ?? '';
      _editBb = (anak['berat_badan'] == '0' || anak['berat_badan'] == '-')
          ? ''
          : anak['berat_badan'].toString();
      _editTb = (anak['tinggi_badan'] == '0' || anak['tinggi_badan'] == '-')
          ? ''
          : anak['tinggi_badan'].toString();
      _editLk = (anak['lingkar_kepala'] == '0' || anak['lingkar_kepala'] == '-')
          ? ''
          : anak['lingkar_kepala'].toString();
      _editJk = anak['jenis_kelamin'] ?? 'Laki-laki';
      _editOrangTuaId = anak['orangtua_id'];
    });

    // Buat controller baru setiap kali edit
    final TextEditingController namaCtrl = TextEditingController(
      text: _editNama,
    );
    final TextEditingController tglCtrl = TextEditingController(text: _editTgl);
    final TextEditingController bbCtrl = TextEditingController(text: _editBb);
    final TextEditingController tbCtrl = TextEditingController(text: _editTb);
    final TextEditingController lkCtrl = TextEditingController(text: _editLk);
    String selectedJk = _editJk;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE85D75).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Color(0xFFE85D75),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Edit Data Anak',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAMA ANAK
                  _buildEditField(
                    label: 'Nama Anak',
                    hint: 'Masukkan nama anak',
                    icon: Icons.person_outline_rounded,
                    controller: namaCtrl,
                  ),
                  const SizedBox(height: 12),

                  // JENIS KELAMIN
                  _buildEditGenderSelector2(
                    selectedJk: selectedJk,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedJk = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // TANGGAL LAHIR
                  _buildEditField(
                    label: 'Tanggal Lahir',
                    hint: 'Pilih tanggal lahir',
                    icon: Icons.calendar_today_rounded,
                    controller: tglCtrl,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2010),
                        lastDate: DateTime.now(),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFFE85D75),
                              onPrimary: Colors.white,
                              onSurface: Color(0xFF2D2D2D),
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          tglCtrl.text = picked
                              .toIso8601String()
                              .split('T')
                              .first;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // BERAT & TINGGI
                  Row(
                    children: [
                      Expanded(
                        child: _buildEditField(
                          label: 'Berat Badan',
                          hint: 'kg (0 jika belum diketahui)',
                          icon: Icons.monitor_weight_rounded,
                          controller: bbCtrl,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEditField(
                          label: 'Tinggi Badan',
                          hint: 'cm (0 jika belum diketahui)',
                          icon: Icons.height_rounded,
                          controller: tbCtrl,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // LINGKAR KEPALA
                  _buildEditField(
                    label: 'Lingkar Kepala',
                    hint: 'cm (0 jika belum diketahui)',
                    icon: Icons.face_6_rounded,
                    controller: lkCtrl,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
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
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Status gizi akan dihitung otomatis berdasarkan data yang diisi',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
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
                onPressed: () {
                  namaCtrl.dispose();
                  tglCtrl.dispose();
                  bbCtrl.dispose();
                  tbCtrl.dispose();
                  lkCtrl.dispose();
                  Navigator.pop(context);
                },
                child: const Text('Batal', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        // Ambil nilai dari controller
                        _editNama = namaCtrl.text;
                        _editTgl = tglCtrl.text;
                        _editBb = bbCtrl.text;
                        _editTb = tbCtrl.text;
                        _editLk = lkCtrl.text;
                        _editJk = selectedJk;

                        debugPrint('📝 Data yang akan diupdate:');
                        debugPrint('  Nama: $_editNama');
                        debugPrint('  Tgl: $_editTgl');
                        debugPrint('  BB: $_editBb');
                        debugPrint('  TB: $_editTb');
                        debugPrint('  LK: $_editLk');
                        debugPrint('  JK: $_editJk');

                        // Dispose controller
                        namaCtrl.dispose();
                        tglCtrl.dispose();
                        bbCtrl.dispose();
                        tbCtrl.dispose();
                        lkCtrl.dispose();

                        // ============ TUTUP DIALOG ============
                        Navigator.pop(context);

                        // ============ PANGGIL EDIT SETELAH DIALOG TUTUP ============
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            _editAnak();
                          }
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE85D75),
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEditField({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 0.5),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFFE85D75), size: 20),
              suffixIcon: readOnly
                  ? Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.grey.shade400,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditGenderSelector2({
    required String selectedJk,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Kelamin',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged('Laki-laki'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedJk == 'Laki-laki'
                        ? Colors.blue.shade50
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedJk == 'Laki-laki'
                          ? Colors.blue
                          : Colors.grey.shade200,
                      width: selectedJk == 'Laki-laki' ? 1.5 : 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.male_rounded,
                        color: selectedJk == 'Laki-laki'
                            ? Colors.blue
                            : Colors.grey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Laki-laki',
                        style: TextStyle(
                          color: selectedJk == 'Laki-laki'
                              ? Colors.blue
                              : Colors.grey.shade500,
                          fontWeight: selectedJk == 'Laki-laki'
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged('Perempuan'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedJk == 'Perempuan'
                        ? Colors.pink.shade50
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedJk == 'Perempuan'
                          ? Colors.pink
                          : Colors.grey.shade200,
                      width: selectedJk == 'Perempuan' ? 1.5 : 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.female_rounded,
                        color: selectedJk == 'Perempuan'
                            ? Colors.pink
                            : Colors.grey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Perempuan',
                        style: TextStyle(
                          color: selectedJk == 'Perempuan'
                              ? Colors.pink
                              : Colors.grey.shade500,
                          fontWeight: selectedJk == 'Perempuan'
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============ SHOW TAMBAH FORM ============
  void _showTambahForm() {
    _resetForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildFormBottomSheet(),
    );
  }

  // ============ BUILD FORM BOTTOM SHEET ============
  Widget _buildFormBottomSheet() {
    final formKey = GlobalKey<FormState>();

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return AnimatedPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.78,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE85D75).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.person_add_rounded,
                          color: Color(0xFFE85D75),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tambah Data Anak',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            'Isi data anak untuk pemantauan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            // DROPDOWN ORANG TUA
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 0.5,
                                ),
                              ),
                              child: DropdownButtonFormField<int>(
                                value: _selectedOrangTuaId,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Orang Tua',
                                  labelStyle: const TextStyle(
                                    color: Color(0xFF555555),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.family_restroom_rounded,
                                    color: Color(0xFFE85D75),
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  hintText: 'Pilih orang tua',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 14,
                                  ),
                                ),
                                items: orangTuaList.map((ortu) {
                                  return DropdownMenuItem<int>(
                                    value: ortu['orangtua_id'],
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFFE85D75,
                                            ).withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.person_rounded,
                                            size: 16,
                                            color: Color(0xFFE85D75),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            ortu['nama'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF1A1A1A),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setSheetState(() {
                                    _selectedOrangTuaId = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Pilih orang tua terlebih dahulu';
                                  }
                                  return null;
                                },
                                dropdownColor: Colors.white,
                                icon: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFE85D75,
                                    ).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Color(0xFFE85D75),
                                    size: 20,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // NAMA ANAK
                            _buildFormField(
                              label: 'Nama Anak',
                              hint: 'Masukkan nama anak',
                              icon: Icons.person_outline_rounded,
                              controller: _namaCtrl,
                              validator: (v) => v?.isEmpty ?? true
                                  ? 'Nama anak harus diisi'
                                  : null,
                            ),
                            const SizedBox(height: 12),

                            // JENIS KELAMIN
                            _buildGenderSelector(setSheetState),
                            const SizedBox(height: 12),

                            // TANGGAL LAHIR
                            _buildFormField(
                              label: 'Tanggal Lahir',
                              hint: 'Pilih tanggal lahir',
                              icon: Icons.calendar_today_rounded,
                              controller: _tglCtrl,
                              readOnly: true,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2010),
                                  lastDate: DateTime.now(),
                                  builder: (ctx, child) => Theme(
                                    data: Theme.of(ctx).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFFE85D75),
                                        onPrimary: Colors.white,
                                        onSurface: Color(0xFF2D2D2D),
                                      ),
                                    ),
                                    child: child!,
                                  ),
                                );
                                if (picked != null) {
                                  setSheetState(() {
                                    _selectedTanggal = picked;
                                    _tglCtrl.text = picked
                                        .toIso8601String()
                                        .split('T')
                                        .first;
                                  });
                                }
                              },
                              validator: (v) => v?.isEmpty ?? true
                                  ? 'Tanggal lahir harus diisi'
                                  : null,
                            ),
                            const SizedBox(height: 12),

                            // BERAT & TINGGI
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormField(
                                    label: 'Berat Badan',
                                    hint: 'kg (0 jika belum diketahui)',
                                    icon: Icons.monitor_weight_rounded,
                                    controller: _bbCtrl,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildFormField(
                                    label: 'Tinggi Badan',
                                    hint: 'cm (0 jika belum diketahui)',
                                    icon: Icons.height_rounded,
                                    controller: _tbCtrl,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // LINGKAR KEPALA
                            _buildFormField(
                              label: 'Lingkar Kepala',
                              hint: 'cm (0 jika belum diketahui)',
                              icon: Icons.face_6_rounded,
                              controller: _lkCtrl,
                              keyboardType: TextInputType.number,
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
                            const SizedBox(height: 24),

                            // TOMBOL
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: const Text(
                                      'Batal',
                                      style: TextStyle(
                                        color: Color(0xFF555555),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : () {
                                            if (formKey.currentState!
                                                .validate()) {
                                              Navigator.pop(context);
                                              _tambahAnak();
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE85D75),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Simpan',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenderSelector(StateSetter setSheetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Kelamin',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setSheetState(() {
                    _selectedJk = 'Laki-laki';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedJk == 'Laki-laki'
                        ? Colors.blue.shade50
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedJk == 'Laki-laki'
                          ? Colors.blue
                          : Colors.grey.shade200,
                      width: _selectedJk == 'Laki-laki' ? 1.5 : 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.male_rounded,
                        color: _selectedJk == 'Laki-laki'
                            ? Colors.blue
                            : Colors.grey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Laki-laki',
                        style: TextStyle(
                          color: _selectedJk == 'Laki-laki'
                              ? Colors.blue
                              : Colors.grey.shade500,
                          fontWeight: _selectedJk == 'Laki-laki'
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setSheetState(() {
                    _selectedJk = 'Perempuan';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedJk == 'Perempuan'
                        ? Colors.pink.shade50
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedJk == 'Perempuan'
                          ? Colors.pink
                          : Colors.grey.shade200,
                      width: _selectedJk == 'Perempuan' ? 1.5 : 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.female_rounded,
                        color: _selectedJk == 'Perempuan'
                            ? Colors.pink
                            : Colors.grey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Perempuan',
                        style: TextStyle(
                          color: _selectedJk == 'Perempuan'
                              ? Colors.pink
                              : Colors.grey.shade500,
                          fontWeight: _selectedJk == 'Perempuan'
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 0.5),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFFE85D75), size: 20),
              suffixIcon: readOnly
                  ? Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.grey.shade400,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const SidebarKader(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE85D75)),
            )
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE85D75),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                CustomAppBar(
                  backgroundColor: const Color(0xFFE85D75),
                  iconColor: Colors.white,
                  showBackButton: false,
                  showDrawerIcon: true,
                  showNotificationIcon: true,
                ),
                const SizedBox(height: 8),

                // HEADER SECTION
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Data Anak',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFE85D75,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${filteredAnak.length} anak',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFE85D75),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 140,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 0.5,
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Cari anak...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: Colors.grey.shade400,
                                  size: 18,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Material(
                            color: const Color(0xFFE85D75),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: _showTambahForm,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // FILTER CHIPS
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildFilterChip(
                                'Semua',
                                'Semua',
                                Icons.people_rounded,
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                'Laki-laki',
                                'Laki-laki',
                                Icons.male_rounded,
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                'Perempuan',
                                'Perempuan',
                                Icons.female_rounded,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_list_rounded,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${filteredAnak.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // LIST ANAK
                Expanded(
                  child: filteredAnak.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.child_care_rounded,
                                  size: 50,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'Belum ada data anak'
                                    : 'Tidak ada anak dengan "$_searchQuery"',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'Klik + untuk menambahkan'
                                    : 'Coba dengan kata kunci lain',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: const Color(0xFFE85D75),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            itemCount: filteredAnak.length,
                            itemBuilder: (context, index) {
                              final anak = filteredAnak[index];
                              return _buildAnakCard(anak);
                            },
                          ),
                        ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavbarKader(selectedIndex: _selectedIndex),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _filterGender == value;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE85D75) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFFE85D75) : Colors.grey.shade200,
          width: 0.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFFE85D75).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filterGender = value;
            _applyFilters();
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ BUILD CARD ANAK ============
  Widget _buildAnakCard(Map<String, dynamic> anak) {
    final isMale = anak['jenis_kelamin'] == 'Laki-laki';
    final color = isMale ? Colors.blue : Colors.pink;
    final status = anak['status_gizi'] ?? 'Normal';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMale ? Icons.male_rounded : Icons.female_rounded,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  anak['nama'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.family_restroom_rounded,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        anak['nama_ortu'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ============ TOMBOL EDIT, DETAIL, HAPUS ============
          Row(
            children: [
              // TOMBOL EDIT (PENSIK)
              Material(
                color: const Color(0xFFE85D75).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => _showEditForm(anak),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 20,
                      color: Color(0xFFE85D75),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // TOMBOL DETAIL (MATA)
              Material(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => _showDetailAnak(anak),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.visibility_rounded,
                      size: 20,
                      color: Colors.blue.shade400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // TOMBOL HAPUS (TONG SAMPAH)
              Material(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => _hapusAnak(anak['anak_id'], anak['nama']),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: Colors.red.shade300,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ SHOW DETAIL ANAK ============
  void _showDetailAnak(Map<String, dynamic> anak) {
    final isMale = anak['jenis_kelamin'] == 'Laki-laki';
    final color = isMale ? Colors.blue : Colors.pink;
    final status = anak['status_gizi'] ?? 'Normal';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isMale ? Icons.male_rounded : Icons.female_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          anak['nama'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Orang Tua: ${anak['nama_ortu']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      anak['jenis_kelamin'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              _buildDetailRow(
                icon: Icons.calendar_today_rounded,
                label: 'Tanggal Lahir',
                value: anak['tanggal_lahir'],
              ),
              _buildDetailRow(
                icon: Icons.monitor_weight_rounded,
                label: 'Berat Badan',
                value: '${anak['berat_badan']} kg',
              ),
              _buildDetailRow(
                icon: Icons.height_rounded,
                label: 'Tinggi Badan',
                value: '${anak['tinggi_badan']} cm',
              ),
              _buildDetailRow(
                icon: Icons.face_6_rounded,
                label: 'Lingkar Kepala',
                value: '${anak['lingkar_kepala']} cm',
              ),
              _buildDetailRow(
                icon: Icons.favorite_rounded,
                label: 'Status Gizi',
                value: status,
                color: _getStatusColor(status),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditForm(anak);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFE85D75)),
                      ),
                      child: const Text(
                        'Edit Data',
                        style: TextStyle(
                          color: Color(0xFFE85D75),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          color: Color(0xFF555555),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFE85D75).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFFE85D75)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color ?? const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    if (status == 'Normal') return Colors.green;
    if (status == 'Stunting') return Colors.orange;
    if (status == 'Kurang (Wasting)' || status == 'Underweight')
      return Colors.orange;
    if (status == 'Obesitas' || status == 'Overweight') return Colors.redAccent;
    if (status == 'Belum Diperiksa') return Colors.grey;
    if (status == 'Data Tidak Lengkap') return Colors.grey;
    return Colors.grey;
  }
}
