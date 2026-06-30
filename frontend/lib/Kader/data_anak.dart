import 'package:flutter/material.dart';
import 'dart:convert';
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
      final requestBody = {
        'orangtua_id': _selectedOrangTuaId,
        'nama': _namaCtrl.text,
        'jenis_kelamin': jenisKelamin,
        'tanggal_lahir': _tglCtrl.text,
        'berat_badan': double.tryParse(_bbCtrl.text) ?? 0,
        'tinggi_badan': double.tryParse(_tbCtrl.text) ?? 0,
        'lingkar_kepala': double.tryParse(_lkCtrl.text) ?? 0,
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

  void _showTambahForm() {
    _resetForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildFormBottomSheet(),
    );
  }

  Widget _buildFormBottomSheet() {
    final formKey = GlobalKey<FormState>();

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Container(
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
                const SizedBox(height: 16),
                const Text(
                  'Tambah Data Anak',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Isi data anak untuk pemantauan tumbuh kembang',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          // ===== DROPDOWN ORANG TUA PROFESIONAL =====
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 0.5,
                              ),
                            ),
                            child: DropdownButtonFormField<int>(
                              initialValue: _selectedOrangTuaId,
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
                                          ).withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.person_rounded,
                                          size: 16,
                                          color: const Color(0xFFE85D75),
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
                                  ).withValues(alpha: 0.1),
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
                          const SizedBox(height: 14),

                          // ===== NAMA ANAK =====
                          _buildFormField(
                            label: 'Nama Anak',
                            hint: 'Masukkan nama anak',
                            icon: Icons.person_outline_rounded,
                            controller: _namaCtrl,
                            validator: (v) => v?.isEmpty ?? true
                                ? 'Nama anak harus diisi'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          // ===== JENIS KELAMIN (TOMBOOL) =====
                          _buildGenderSelector(setSheetState),
                          const SizedBox(height: 14),

                          // ===== TANGGAL LAHIR =====
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
                          const SizedBox(height: 14),

                          // ===== BERAT & TINGGI =====
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  label: 'Berat Lahir',
                                  hint: 'kg',
                                  icon: Icons.monitor_weight_rounded,
                                  controller: _bbCtrl,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFormField(
                                  label: 'Tinggi Lahir',
                                  hint: 'cm',
                                  icon: Icons.height_rounded,
                                  controller: _tbCtrl,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // ===== LINGKAR KEPALA =====
                          _buildFormField(
                            label: 'Lingkar Kepala Lahir',
                            hint: 'cm',
                            icon: Icons.face_6_rounded,
                            controller: _lkCtrl,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),

                          // ===== TOMBOL =====
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
        );
      },
    );
  }

  // ===== GENDER SELECTOR (TOMBOOL) =====
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
                child: Container(
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
                      if (_selectedJk == 'Laki-laki')
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                            size: 16,
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
                child: Container(
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
                      if (_selectedJk == 'Perempuan')
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.pink,
                            size: 16,
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
                  ? const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.grey,
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

                // ===== HEADER + SEARCH + TAMBAH =====
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Data Anak',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              '${filteredAnak.length} anak terdaftar',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 150,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 0.5,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Cari...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 11,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.grey.shade400,
                              size: 16,
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
                      GestureDetector(
                        onTap: _showTambahForm,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE85D75),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== FILTER - DIPERBAIKI OVERFLOW =====
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Filter chips dengan Expanded
                      Expanded(
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
                      const SizedBox(width: 8),
                      // Badge jumlah
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
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
                            const SizedBox(width: 8),
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

                // ===== LIST =====
                Expanded(
                  child: filteredAnak.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.child_care_rounded,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
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
                                'Klik + untuk menambahkan',
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
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterGender = value;
          _applyFilters();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE85D75) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE85D75) : Colors.grey.shade300,
            width: 0.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFE85D75).withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 10,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnakCard(Map<String, dynamic> anak) {
    final isMale = anak['jenis_kelamin'] == 'Laki-laki';
    final color = isMale ? Colors.blue : Colors.pink;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMale ? Icons.male_rounded : Icons.female_rounded,
              color: color,
              size: 28,
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
                Row(
                  children: [
                    Icon(
                      Icons.family_restroom_rounded,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      anak['nama_ortu'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _showDetailAnak(anak),
                icon: const Icon(Icons.visibility_rounded, size: 20),
                color: const Color(0xFFE85D75),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(
                    0xFFE85D75,
                  ).withValues(alpha: 0.08),
                  padding: const EdgeInsets.all(6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                onPressed: () => _hapusAnak(anak['anak_id'], anak['nama']),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: Colors.red.shade300,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  padding: const EdgeInsets.all(6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDetailAnak(Map<String, dynamic> anak) {
    final isMale = anak['jenis_kelamin'] == 'Laki-laki';
    final color = isMale ? Colors.blue : Colors.pink;

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
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.5)],
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
                            fontSize: 14,
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
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      anak['jenis_kelamin'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow(
                icon: Icons.calendar_today_rounded,
                label: 'Tanggal Lahir',
                value: anak['tanggal_lahir'],
              ),
              _buildDetailRow(
                icon: Icons.monitor_weight_rounded,
                label: 'Berat Lahir',
                value: '${anak['berat_badan']} kg',
              ),
              _buildDetailRow(
                icon: Icons.height_rounded,
                label: 'Tinggi Lahir',
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
                value: anak['status_gizi'] ?? 'Normal',
                color: _getStatusColor(anak['status_gizi']),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
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
              color: const Color(0xFFE85D75).withValues(alpha: 0.08),
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
    if (status.contains('Normal')) return Colors.green;
    if (status.contains('Stunting') || status.contains('Kurus')) {
      return Colors.orange;
    }
    if (status.contains('Severe') || status.contains('Buruk')) {
      return Colors.red;
    }
    if (status.contains('Overweight') || status.contains('Obesitas')) {
      return Colors.redAccent;
    }
    return Colors.grey;
  }
}
