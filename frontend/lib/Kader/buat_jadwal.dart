import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';
import '../widgets/custom_app_bar.dart';
import 'preview_poster.dart';
import '../services/api_service.dart';

class BuatJadwalPage extends StatefulWidget {
  final String template;
  const BuatJadwalPage({super.key, required this.template});

  @override
  State<BuatJadwalPage> createState() => _BuatJadwalPageState();
}

class _BuatJadwalPageState extends State<BuatJadwalPage> {
  final namaController = TextEditingController();
  final alamatController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool _isSaving = false;

  String get formattedDate {
    if (selectedDate == null) return '';
    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final months = [
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
    final dayName = days[selectedDate!.weekday - 1];
    return '$dayName, ${selectedDate!.day} ${months[selectedDate!.month - 1]} ${selectedDate!.year}';
  }

  String get formattedTime {
    if (selectedTime == null) return '';
    final hour = selectedTime!.hour.toString().padLeft(2, '0');
    final minute = selectedTime!.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Pilih Tanggal Posyandu',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE85D75),
              onPrimary: Colors.white,
              onSurface: Color(0xFFE85D75),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE85D75),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Pilih Jam Pelaksanaan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE85D75),
              onPrimary: Colors.white,
            ),
            timePickerTheme: const TimePickerThemeData(
              hourMinuteTextColor: Color(0xFFE85D75),
              dayPeriodTextColor: Color(0xFFE85D75),
              dialHandColor: Color(0xFFE85D75),
              dialBackgroundColor: Color(0xFFFFE4E8),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _clearDate() {
    setState(() {
      selectedDate = null;
    });
  }

  void _clearTime() {
    setState(() {
      selectedTime = null;
    });
  }

  Future<void> _saveJadwalToDatabase() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih tanggal posyandu")),
      );
      return;
    }

    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih jam pelaksanaan")),
      );
      return;
    }

    if (namaController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Masukkan nama posyandu")));
      return;
    }

    if (alamatController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Masukkan alamat lengkap")));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      String dbDate =
          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
      String dbTime =
          "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00";

      final requestBody = {
        'nama_posyandu': namaController.text,
        'tanggal': dbDate,
        'waktu': dbTime,
        'alamat': alamatController.text,
        'template': widget.template,
      };

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/jadwal'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          if (mounted) {
            _navigateToPreview();
          }
        } else {
          throw Exception(responseData['message'] ?? 'Gagal menyimpan jadwal');
        }
      } else {
        throw Exception(
          'Gagal menyimpan jadwal (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      print('Error saving jadwal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _navigateToPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewPosterPage(
          template: widget.template,
          tanggal: formattedDate,
          jam: formattedTime,
          nama: namaController.text,
          alamat: alamatController.text,
        ),
      ),
    );
  }

  void handleSubmit() {
    _saveJadwalToDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarKader(),
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 2),
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          const CustomAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTemplatePreviewCard(),
                  const SizedBox(height: 24),
                  _buildFormCard(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatePreviewCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE85D75).withOpacity(0.1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.photo_library, color: Color(0xFFE85D75)),
                  const SizedBox(width: 8),
                  const Text(
                    "Template Dipilih",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE85D75),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: "Tema ",
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: "Kuning",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              widget.template,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE85D75).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit_note,
                    color: Color(0xFFE85D75),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Informasi Posyandu",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDatePickerField(),
            const SizedBox(height: 16),
            _buildTimePickerField(),
            const SizedBox(height: 16),
            _buildFormField(
              icon: Icons.health_and_safety,
              label: "Nama Posyandu",
              hint: "Masukkan nama posyandu",
              controller: namaController,
            ),
            const SizedBox(height: 16),
            _buildFormField(
              icon: Icons.location_on,
              label: "Alamat Lengkap",
              hint: "Masukkan alamat lengkap",
              controller: alamatController,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tanggal Pelaksanaan",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedDate != null
                    ? const Color(0xFFE85D75)
                    : Colors.grey.shade300,
                width: selectedDate != null ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: selectedDate != null
                      ? const Color(0xFFE85D75)
                      : Colors.grey.shade500,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDate != null ? formattedDate : 'Pilih Tanggal',
                    style: TextStyle(
                      color: selectedDate != null
                          ? Colors.black87
                          : Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: _clearDate,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Jam Pelaksanaan",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectTime(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedTime != null
                    ? const Color(0xFFE85D75)
                    : Colors.grey.shade300,
                width: selectedTime != null ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: selectedTime != null
                      ? const Color(0xFFE85D75)
                      : Colors.grey.shade500,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedTime != null ? formattedTime : 'Pilih Jam',
                    style: TextStyle(
                      color: selectedTime != null
                          ? Colors.black87
                          : Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (selectedTime != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: _clearTime,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            textInputAction: maxLines == 1
                ? TextInputAction.next
                : TextInputAction.done,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(
                icon,
                color: const Color(0xFFE85D75).withOpacity(0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE85D75),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text("Kembali"),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE85D75),
              side: const BorderSide(color: Color(0xFFE85D75)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : handleSubmit,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.post_add),
            label: Text(
              _isSaving ? "Menyimpan..." : "Buat Poster",
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85D75),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    alamatController.dispose();
    super.dispose();
  }
}
