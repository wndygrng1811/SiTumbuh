import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sidebar_kader.dart';
import 'buat_jadwal.dart';
import '../widgets/bottom_navbar_kader.dart';
import '../services/api_service.dart';
import '../widgets/custom_app_bar.dart';

class Jadwal extends StatefulWidget {
  final bool fromNotification;
  final int? notificationId;

  const Jadwal({super.key, this.fromNotification = false, this.notificationId});

  @override
  State<Jadwal> createState() => _JadwalState();
}

class _JadwalState extends State<Jadwal> {
  int selectedTab = 0;
  List<Map<String, dynamic>> _listJadwal = [];
  bool _isLoading = true;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadJadwal();

    if (widget.fromNotification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifikasi jadwal diterima'),
            backgroundColor: Colors.blue,
          ),
        );
      });
    }
  }

  Future<void> _loadJadwal() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/jadwal'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            _listJadwal = List<Map<String, dynamic>>.from(data['data']);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error load jadwal: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<File?> _generatePosterWithText(Map<String, dynamic> jadwal) async {
    if (_isGenerating) return null;

    setState(() {
      _isGenerating = true;
    });

    try {
      final GlobalKey repaintKey = GlobalKey();

      final posterWidget = _buildPosterWidgetFromJadwal(jadwal);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.transparent,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                "Membuat poster...",
                style: TextStyle(color: Colors.white),
              ),
              RepaintBoundary(key: repaintKey, child: posterWidget),
            ],
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));

      RenderRepaintBoundary? boundary =
          repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        if (mounted) Navigator.pop(context);
        return null;
      }

      ui.Image image = await boundary.toImage(pixelRatio: 1.5);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (mounted) Navigator.pop(context);

      if (byteData == null) return null;

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/poster_${jadwal['jadwal_id']}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      return file;
    } catch (e) {
      print('Error generate poster: $e');
      if (mounted) Navigator.pop(context);
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Widget _buildPosterWidgetFromJadwal(Map<String, dynamic> jadwal) {
    String templatePath = _getTemplateImage(jadwal['template']);
    String formattedDate = _formatTanggalUntukPesan(jadwal['tanggal']);
    String waktu = jadwal['waktu'] ?? '';
    String alamat = jadwal['alamat'] ?? '';
    String namaPos = jadwal['nama_posyandu'] ?? 'Posyandu';

    return SizedBox(
      width: 280,
      child: Stack(
        children: [
          Image.asset(templatePath, width: 340, fit: BoxFit.cover),
          Positioned(
            top: 85,
            left: 15,
            right: 15,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.93),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF0D98A), width: 1.2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRowForPoster(
                    iconBg: const Color(0xFFEEF0FF),
                    iconColor: const Color(0xFF5C6BC0),
                    icon: Icons.calendar_month_rounded,
                    label: 'Hari & Tanggal',
                    labelColor: const Color(0xFF5C6BC0),
                    value: formattedDate,
                  ),
                  const SizedBox(height: 6),
                  _buildInfoRowForPoster(
                    iconBg: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFF57C00),
                    icon: Icons.access_time_rounded,
                    label: 'Jam',
                    labelColor: const Color(0xFFF57C00),
                    value: waktu,
                  ),
                  const SizedBox(height: 6),
                  _buildInfoRowForPoster(
                    iconBg: const Color(0xFFFFEBEE),
                    iconColor: const Color(0xFFE53935),
                    icon: Icons.location_on,
                    label: 'Tempat',
                    labelColor: const Color(0xFFE53935),
                    value: namaPos,
                    subtitle: alamat,
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF25D366).withOpacity(0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone,
                            color: Color(0xFF1a7a42),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '0812-3456-7890',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1a7a42),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowForPoster({
    required Color iconBg,
    required Color iconColor,
    required IconData icon,
    required String label,
    required Color labelColor,
    required String value,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 15),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2D2D),
                  height: 1.2,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF666666),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _shareToWhatsAppWithImage(
    Map<String, dynamic> jadwal, {
    bool isBusiness = false,
  }) async {
    try {
      File? posterFile = await _generatePosterWithText(jadwal);

      String formattedDate = _formatTanggalUntukPesan(jadwal['tanggal']);
      String caption =
          'Jadwal Posyandu ${jadwal['nama_posyandu']}\n$formattedDate\n\nYuk hadir dan jaga kesehatan si kecil!';

      if (posterFile == null) {
        String encodedMessage = Uri.encodeComponent(caption);
        String waUrl = isBusiness
            ? "https://api.whatsapp.com/send?text=$encodedMessage"
            : "https://wa.me/?text=$encodedMessage";

        if (await canLaunchUrl(Uri.parse(waUrl))) {
          await launchUrl(
            Uri.parse(waUrl),
            mode: LaunchMode.externalApplication,
          );
        }
        return;
      }

      if (isBusiness) {
        final whatsappUri = Uri.parse(
          "whatsapp://send?text=${Uri.encodeComponent(caption)}",
        );
        if (await canLaunchUrl(whatsappUri)) {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Tidak bisa membuka WhatsApp Business');
        }
      } else {
        await Share.shareXFiles([XFile(posterFile.path)], text: caption);
      }
    } catch (e) {
      print('Error sharing: $e');
      String formattedDate = _formatTanggalUntukPesan(jadwal['tanggal']);
      String caption =
          'Jadwal Posyandu ${jadwal['nama_posyandu']}\n$formattedDate\n\nYuk hadir dan jaga kesehatan si kecil!';
      String encodedMessage = Uri.encodeComponent(caption);
      String waUrl = isBusiness
          ? "https://api.whatsapp.com/send?text=$encodedMessage"
          : "https://wa.me/?text=$encodedMessage";

      if (await canLaunchUrl(Uri.parse(waUrl))) {
        await launchUrl(Uri.parse(waUrl), mode: LaunchMode.externalApplication);
      }
    }
  }

  void _showShareOptions(Map<String, dynamic> jadwal) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Bagikan ke WhatsApp",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF25D366),
                  child: Icon(Icons.chat, color: Colors.white),
                ),
                title: const Text("WhatsApp"),
                subtitle: const Text("Kirim poster ke WhatsApp biasa"),
                onTap: () {
                  Navigator.pop(context);
                  _shareToWhatsAppWithImage(jadwal, isBusiness: false);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF25D366),
                  child: Icon(Icons.business, color: Colors.white),
                ),
                title: const Text("WhatsApp Business"),
                subtitle: const Text("Kirim poster ke WhatsApp Business"),
                onTap: () {
                  Navigator.pop(context);
                  _shareToWhatsAppWithImage(jadwal, isBusiness: true);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  String _formatTanggalUntukPesan(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
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
      return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  List<Map<String, dynamic>> _getJadwalAkanDatang() {
    DateTime today = DateTime.now();
    DateTime todayDate = DateTime(today.year, today.month, today.day);

    return _listJadwal.where((j) {
      try {
        DateTime tgl = DateTime.parse(j['tanggal']);
        return tgl.isAfter(todayDate.subtract(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  List<Map<String, dynamic>> _getJadwalSelesai() {
    DateTime today = DateTime.now();
    DateTime todayDate = DateTime(today.year, today.month, today.day);

    return _listJadwal.where((j) {
      try {
        DateTime tgl = DateTime.parse(j['tanggal']);
        return tgl.isBefore(todayDate);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  List<Map<String, dynamic>> get filteredJadwal {
    return selectedTab == 0 ? _getJadwalAkanDatang() : _getJadwalSelesai();
  }

  String _formatTanggal(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
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
      return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getTemplateImage(String? template) {
    if (template == null || template.isEmpty) {
      return 'assets/templatekuning.jpg';
    }
    return template;
  }

  @override
  Widget build(BuildContext context) {
    int jumlahAkanDatang = _getJadwalAkanDatang().length;
    int jumlahSelesai = _getJadwalSelesai().length;

    return Scaffold(
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 2),
      drawer: const SidebarKader(),
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: CustomAppBar(
        backgroundColor: const Color(0xFFE85D75),
        iconColor: Colors.white,
        showBackButton: false,
        showDrawerIcon: true,
        showNotificationIcon: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFFE85D75),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Jadwal Posyandu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Kader dapat membuat dan membagikan jadwal posyandu menggunakan poster melalui WhatsApp",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildTemplateSection(),
          const SizedBox(height: 16),
          _buildTabFilter(jumlahAkanDatang, jumlahSelesai),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredJadwal.isEmpty
                ? const Center(
                    child: Text(
                      "Tidak ada jadwal",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredJadwal.length,
                    itemBuilder: (context, index) {
                      return _buildJadwalCard(filteredJadwal[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Template Poster Posyandu",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                "Lihat semua",
                style: TextStyle(color: Color(0xFFE85D75), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _templateCard(
                  "Tema Kuning",
                  "assets/templatekuning.jpg",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _templateCard("Tema Biru", "assets/templatebiru.jpg"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _templateCard(String title, String imagePath) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              height: 90,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuatJadwalPage(template: imagePath),
                ),
              ).then((_) {
                if (mounted) _loadJadwal();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85D75),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              "Pilih",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabFilter(int akanDatang, int selesai) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedTab = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedTab == 0
                        ? const Color(0xFFE85D75)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      "Akan datang ($akanDatang)",
                      style: TextStyle(
                        color: selectedTab == 0
                            ? Colors.white
                            : Colors.grey.shade700,
                        fontWeight: selectedTab == 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedTab = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedTab == 1
                        ? const Color(0xFFE85D75)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      "Selesai ($selesai)",
                      style: TextStyle(
                        color: selectedTab == 1
                            ? Colors.white
                            : Colors.grey.shade700,
                        fontWeight: selectedTab == 1
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJadwalCard(Map<String, dynamic> jadwal) {
    bool isSelesai = false;
    try {
      DateTime today = DateTime.now();
      DateTime todayDate = DateTime(today.year, today.month, today.day);
      DateTime tgl = DateTime.parse(jadwal['tanggal']);
      isSelesai = tgl.isBefore(todayDate);
    } catch (e) {}

    String templatePath = _getTemplateImage(jadwal['template']);
    String formattedDate = _formatTanggal(jadwal['tanggal']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                templatePath,
                width: 70,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE85D75).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jadwal['nama_posyandu'] ?? 'Posyandu',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        jadwal['waktu'] ?? '-',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          jadwal['alamat'] ?? '-',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isSelesai)
              Container(
                margin: const EdgeInsets.only(left: 8),
                child: ElevatedButton(
                  onPressed: () => _showShareOptions(jadwal),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(65, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Bagikan",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Selesai",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
