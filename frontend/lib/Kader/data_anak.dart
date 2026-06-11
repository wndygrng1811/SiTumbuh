import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';

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
  final int _selectedIndex = 1;
  final TextEditingController _searchController = TextEditingController();

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
    super.dispose();
  }

  void _filterAnak() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      if (_searchQuery.isEmpty) {
        filteredAnak = List.from(dataAnak);
      } else {
        filteredAnak = dataAnak.where((anak) {
          return anak['nama'].toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
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

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          List<dynamic> anakList = data['data'] ?? [];

          if (mounted) {
            setState(() {
              dataAnak = anakList.map((item) {
                return {
                  'anak_id': item['anak_id'],
                  'nama': item['nama_anak'] ?? item['nama'] ?? '',
                  'jenis_kelamin': _getJenisKelaminText(item['jenis_kelamin']),
                  'tanggal_lahir': item['tanggal_lahir'] ?? '',
                  'berat_badan': _formatAngka(item['berat_badan']),
                  'tinggi_badan': _formatAngka(item['tinggi_badan']),
                  'lingkar_kepala': _formatAngka(item['lingkar_kepala']),
                  'status_gizi': item['status_gizi'] ?? 'Normal',
                  'nama_ortu': item['nama_ortu'] ?? '-',
                };
              }).toList();
              filteredAnak = List.from(dataAnak);
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
          print('✅ Loaded ${orangTuaList.length} orang tua');
        }
      }
    } catch (e) {
      print('Error load orang tua dropdown: $e');
    }
  }

  Future<void> _tambahAnak(Map<String, dynamic> data) async {
    if (_isSubmitting) return;

    if (data['orangtua_id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih orang tua terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String jenisKelamin = data['jenis_kelamin'] == 'Laki-laki' ? 'L' : 'P';

      final requestBody = {
        'orangtua_id': data['orangtua_id'],
        'nama': data['nama'],
        'jenis_kelamin': jenisKelamin,
        'tanggal_lahir': data['tanggal_lahir'],
        'berat_badan': double.tryParse(data['berat_badan']) ?? 0,
        'tinggi_badan': double.tryParse(data['tinggi_badan']) ?? 0,
        'lingkar_kepala': double.tryParse(data['lingkar_kepala']) ?? 0,
      };

      final response = await ApiService.post('/kader/anak', requestBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
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
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _hapusAnak(int anakId, String namaAnak) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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

    setState(() {
      _isSubmitting = true;
    });

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
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showTambahForm() {
    final formKey = GlobalKey<FormState>();
    final namaCtrl = TextEditingController();
    final tglCtrl = TextEditingController();
    final bbCtrl = TextEditingController();
    final tbCtrl = TextEditingController();
    final lkCtrl = TextEditingController();

    String? selectedJk;
    int? selectedOrangTuaId;
    DateTime? selectedTanggal;

    Future<void> pickTanggal(
      BuildContext context,
      Function setDialogState,
    ) async {
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
          selectedTanggal = picked;
          tglCtrl.text = picked.toIso8601String().split('T').first;
        });
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Tambah Anak",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: "Pilih Orang Tua",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.family_restroom),
                        ),
                        items: orangTuaList.map((ortu) {
                          return DropdownMenuItem<int>(
                            value: ortu['orangtua_id'],
                            child: Text(ortu['nama']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedOrangTuaId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Pilih orang tua terlebih dahulu';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: namaCtrl,
                        decoration: InputDecoration(
                          labelText: "Nama Anak",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama anak harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Jenis Kelamin",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.female),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Laki-laki',
                            child: Text('Laki-laki'),
                          ),
                          DropdownMenuItem(
                            value: 'Perempuan',
                            child: Text('Perempuan'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedJk = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih jenis kelamin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => pickTanggal(context, setDialogState),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: tglCtrl,
                            decoration: InputDecoration(
                              labelText: "Tanggal Lahir",
                              hintText: 'Pilih tanggal lahir',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.calendar_today),
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Tanggal lahir harus diisi';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: bbCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Berat Badan Lahir (kg)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.monitor_weight),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: tbCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Tinggi Badan Lahir (cm)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.height),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: lkCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Lingkar Kepala Lahir (cm)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.timeline),
                        ),
                      ),
                    ],
                  ),
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
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      _tambahAnak({
                        'orangtua_id': selectedOrangTuaId,
                        'nama': namaCtrl.text,
                        'jenis_kelamin': selectedJk,
                        'tanggal_lahir': tglCtrl.text,
                        'berat_badan': bbCtrl.text.isEmpty ? '0' : bbCtrl.text,
                        'tinggi_badan': tbCtrl.text.isEmpty ? '0' : tbCtrl.text,
                        'lingkar_kepala': lkCtrl.text.isEmpty
                            ? '0'
                            : lkCtrl.text,
                      });
                    }
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openDrawer() {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      drawer: const SidebarKader(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: _openDrawer,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Data Anak",
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
                        "Kelola data anak yang terdaftar",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Cari berdasarkan nama anak...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredAnak.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.child_care,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'Belum ada data anak'
                                    : 'Tidak ada anak dengan nama "$_searchQuery"',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_searchQuery.isEmpty)
                                ElevatedButton.icon(
                                  onPressed: _showTambahForm,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Tambah Anak'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE85D75),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredAnak.length,
                            itemBuilder: (context, index) {
                              final anak = filteredAnak[index];
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
                                      offset: Offset(0, 2),
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
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                anak['nama'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Orang Tua: ${anak['nama_ortu']}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                anak['jenis_kelamin'] ==
                                                    'Laki-laki'
                                                ? Colors.blue[50]
                                                : Colors.pink[50],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            anak['jenis_kelamin'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  anak['jenis_kelamin'] ==
                                                      'Laki-laki'
                                                  ? Colors.blue[700]
                                                  : Colors.pink[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    _buildInfoRow(
                                      "📅 Tanggal Lahir",
                                      anak['tanggal_lahir'],
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      "⚖️ Berat Badan Lahir",
                                      "${anak['berat_badan']} kg",
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      "📏 Tinggi Badan Lahir",
                                      "${anak['tinggi_badan']} cm",
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      "📐 Lingkar Kepala Lahir",
                                      "${anak['lingkar_kepala']} cm",
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _hapusAnak(
                                          anak['anak_id'],
                                          anak['nama'],
                                        ),
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 18,
                                        ),
                                        label: const Text('Hapus Data'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade50,
                                          foregroundColor: Colors.red,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE85D75),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _showTambahForm,
                    icon: const Icon(Icons.add, size: 24),
                    label: const Text(
                      "Tambah Anak",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavbarKader(selectedIndex: _selectedIndex),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ],
    );
  }
}
