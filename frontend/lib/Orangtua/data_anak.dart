import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/services/api_service.dart';

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

  Future<void> _loadDataAnak() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int orangtuaId = prefs.getInt('user_id') ?? 0;

      if (orangtuaId == 0) {
        setState(() {
          _errorMessage = 'Session tidak valid, silakan login ulang';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/orangtua/$orangtuaId/anak'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List<dynamic> anakList = data['data'];

          setState(() {
            dataAnak = anakList.map((item) {
              return {
                'anak_id': item['anak_id'],
                'nama': item['nama'] ?? '',
                'jk': item['jenis_kelamin'] ?? '',
                'tgl': item['tanggal_lahir'] ?? '',
                'berat_lahir': item['berat_badan']?.toString() ?? '-',
                'tinggi_lahir': item['tinggi_badan']?.toString() ?? '-',
                'lk_lahir': item['lingkar_kepala']?.toString() ?? '-',
                'status': item['status_gizi'] ?? 'Normal',
              };
            }).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
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
          _isLoading = false;
          _errorMessage = 'Gagal memuat data anak';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createAnak(Map<String, dynamic> data) async {
    setState(() {
      _isSaving = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int orangtuaId = prefs.getInt('user_id') ?? 0;

      final requestBody = {
        'orangtua_id': orangtuaId,
        'nama': data['nama'] ?? '',
        'jenis_kelamin': data['jk'] ?? 'Laki-laki',
        'tanggal_lahir': data['tgl'] ?? '',
        'berat_badan': double.tryParse(data['berat'] ?? '0') ?? 0,
        'tinggi_badan': double.tryParse(data['tinggi'] ?? '0') ?? 0,
        'lingkar_kepala': double.tryParse(data['lk'] ?? '0') ?? 0,
        'status_gizi': data['status'] ?? 'Normal',
      };

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/anak'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _loadDataAnak();
        if (widget.onDataChanged != null) {
          widget.onDataChanged!();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anak berhasil ditambahkan')),
          );
        }
      } else {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Gagal menambahkan anak');
      }
    } catch (e) {
      debugPrint('Error create anak: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _updateAnak(int anakId, Map<String, dynamic> data) async {
    setState(() {
      _isSaving = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan, silakan login ulang');
      }

      final requestBody = {
        'nama': data['nama'] ?? '',
        'jenis_kelamin': data['jk'] ?? 'Laki-laki',
        'tanggal_lahir': data['tgl'] ?? '',
        'berat_badan': double.tryParse(data['berat'] ?? '0') ?? 0,
        'tinggi_badan': double.tryParse(data['tinggi'] ?? '0') ?? 0,
        'lingkar_kepala': double.tryParse(data['lk'] ?? '0') ?? 0,
        'status_gizi': data['status'] ?? 'Normal',
      };

      final url = '${ApiService.baseUrl}/anak/$anakId';

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          await _loadDataAnak();
          if (widget.onDataChanged != null) {
            widget.onDataChanged!();
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data anak berhasil diupdate')),
            );
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
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data anak berhasil dihapus')),
          );
        }
        if (anakId == widget.anakId && mounted) {
          Navigator.pop(context);
        }
      } else {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Gagal menghapus data anak');
      }
    } catch (e) {
      debugPrint('Error delete anak: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showTambahAnakForm() async {
    TextEditingController namaController = TextEditingController();
    TextEditingController tglController = TextEditingController();
    TextEditingController beratController = TextEditingController();
    TextEditingController tinggiController = TextEditingController();
    TextEditingController lkController = TextEditingController();
    String selectedJk = 'Laki-laki';
    String selectedStatus = 'Normal';

    final List<String> statusOptions = [
      'Normal',
      'Stunting',
      'Kurang',
      'Gizi Buruk',
      'Overweight',
    ];

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
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(
                            const Duration(days: 365 * 5),
                          ),
                          firstDate: DateTime(2015),
                          lastDate: DateTime.now(),
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
                        hintText: "Contoh: 3.5",
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
                        hintText: "Contoh: 50",
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
                        hintText: "Contoh: 34",
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
                      "Status Gizi",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedStatus,
                          isExpanded: true,
                          items: statusOptions.map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedStatus = value!;
                            });
                          },
                        ),
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
                        const SnackBar(content: Text('Nama anak wajib diisi')),
                      );
                      return;
                    }
                    if (tglController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tanggal lahir wajib diisi'),
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
                      'status': selectedStatus,
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

  void _showEditAnakForm(int index) async {
    final anak = dataAnak[index];
    TextEditingController tglController = TextEditingController(
      text: anak['tgl'] ?? '',
    );

    // Data yang hanya bisa DILIHAT (read only) - tidak bisa diubah
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
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusGizi == 'Normal'
                              ? Colors.green.shade200
                              : statusGizi == 'Stunting'
                              ? Colors.red.shade200
                              : Colors.orange.shade200,
                        ),
                      ),
                      child: Text(
                        statusGizi,
                        style: TextStyle(
                          color: statusGizi == 'Normal'
                              ? Colors.green.shade700
                              : statusGizi == 'Stunting'
                              ? Colors.red.shade700
                              : Colors.orange.shade700,
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
                        DateTime initialDate = DateTime.now().subtract(
                          const Duration(days: 365 * 5),
                        );
                        if (tglController.text.isNotEmpty) {
                          try {
                            initialDate = DateTime.parse(tglController.text);
                          } catch (_) {}
                        }

                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(2015),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          tglController.text =
                              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                          setStateDialog(() {});
                        }
                      },
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
                    if (tglController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tanggal lahir wajib diisi'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);

                    // Hanya update tanggal lahir, karena hanya itu yang boleh diubah
                    await _updateAnak(anak['anak_id'], {
                      'nama': anak['nama'] ?? '',
                      'jk': anak['jk'] ?? 'Laki-laki',
                      'tgl': tglController.text,
                      'berat':
                          anak['berat_lahir'] != '-' &&
                              anak['berat_lahir'] != null
                          ? anak['berat_lahir']
                          : '0',
                      'tinggi':
                          anak['tinggi_lahir'] != '-' &&
                              anak['tinggi_lahir'] != null
                          ? anak['tinggi_lahir']
                          : '0',
                      'lk': anak['lk_lahir'] != '-' && anak['lk_lahir'] != null
                          ? anak['lk_lahir']
                          : '0',
                      'status': anak['status'] ?? 'Normal',
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
          onPressed: () {
            if (widget.onDataChanged != null) {
              widget.onDataChanged!();
            }
            Navigator.pop(context);
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
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    child: const Text('Login Ulang'),
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
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
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
                                  const SizedBox(height: 8),
                                  _buildDetail(
                                    "Status gizi",
                                    anak["status"] ?? 'Normal',
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
