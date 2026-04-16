import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class PreviewPosterPage extends StatefulWidget {
  final String template;
  final String? tanggal;
  final String? jam;
  final String? nama;
  final String? alamat;
  final String? telepon;

  const PreviewPosterPage({
    super.key,
    required this.template,
    this.tanggal,
    this.jam,
    this.nama,
    this.alamat,
    this.telepon,
  });

  @override
  State<PreviewPosterPage> createState() => _PreviewPosterPageState();
}

class _PreviewPosterPageState extends State<PreviewPosterPage> {
  final GlobalKey _globalKey = GlobalKey();
  File? imageFile;
  bool isGenerating = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () => generateImage());
    });
  }

  Future<void> generateImage() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/poster_posyandu.png');
      await file.writeAsBytes(pngBytes);

      setState(() {
        imageFile = file;
        isGenerating = false;
      });
    } catch (e) {
      setState(() => isGenerating = false);
      debugPrint("ERROR generateImage: $e");
    }
  }

  Future<void> shareToWhatsApp() async {
    if (imageFile == null) return;

    final String namaPos = widget.nama ?? 'Posyandu';
    final String tgl = widget.tanggal ?? '';
    final String caption =
        'Jadwal Posyandu $namaPos\n$tgl\n\nYuk hadir dan jaga kesehatan si kecil!';

    try {
      await Share.shareXFiles([XFile(imageFile!.path)], text: caption);
    } catch (e) {
      final Uri waUri = Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(caption)}',
      );
      if (await canLaunchUrl(waUri)) {
        await launchUrl(waUri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String namaPos = widget.nama ?? 'Posyandu Melati';
    final String tglDisplay = widget.tanggal ?? 'Rabu, 05 Juli 2024';

    return Scaffold(
      backgroundColor: const Color(0xFFF5EDEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD86487),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Buat Jadwal Posyandu',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ─── POSTER (sumber gambar) ───────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  RepaintBoundary(
                    key: _globalKey,
                    child: _buildPosterContent(),
                  ),
                ],
              ),
            ),
          ),

          // ─── INFO BAWAH ───────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaPos,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  tglDisplay,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),

                // Tombol Bagikan ke WhatsApp
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isGenerating ? null : shareToWhatsApp,
                    icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                    label: Text(
                      isGenerating
                          ? 'Membuat poster...'
                          : 'Bagikan ke WhatsApp',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Tombol Edit Ulang
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD86487)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Edit Ulang',
                      style: TextStyle(
                        color: Color(0xFFD86487),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterContent() {
    return Stack(
      children: [
        // Template image FULL (sudah include judul, ilustrasi, footer)
        Image.asset(widget.template, width: double.infinity, fit: BoxFit.cover),

        // Overlay hanya info box dinamis
        Positioned(
          top: 155, // sesuaikan dengan posisi info box di template kamu
          left: 18,
          right: 18,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.93),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF0D98A), width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tanggal
                _posterInfoRow(
                  iconBg: const Color(0xFFEEF0FF),
                  iconColor: const Color(0xFF5C6BC0),
                  icon: Icons.calendar_month_rounded,
                  label: 'Hari & Tanggal',
                  labelColor: const Color(0xFF5C6BC0),
                  value: widget.tanggal ?? 'Rabu, 5 Juni 2024',
                ),

                _dashedDivider(),

                // Jam
                _posterInfoRow(
                  iconBg: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFF57C00),
                  icon: Icons.access_time_rounded,
                  label: 'Jam',
                  labelColor: const Color(0xFFF57C00),
                  value: '${widget.jam ?? '08.00 - 11.00'} WIB',
                ),

                _dashedDivider(),

                // Tempat & Alamat
                _posterInfoRow(
                  iconBg: const Color(0xFFFFEBEE),
                  iconColor: const Color(0xFFE53935),
                  icon: Icons.location_on,
                  label: 'Tempat',
                  labelColor: const Color(0xFFE53935),
                  value: widget.nama ?? 'Posyandu Melati',
                  subtitle: widget.alamat ?? 'Jl Sejahtera RT 03 RW 06',
                ),

                _dashedDivider(),

                // Nomor telepon
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF25D366).withOpacity(0.35),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Color(0xFF1a7a42),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.telepon ?? '0812-5678-910',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
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
    );
  }

  Widget _posterInfoRow({
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
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2D2D),
                  height: 1.3,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
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

  Widget _dashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(
          40,
          (i) => Expanded(
            child: Container(
              height: 1,
              color: i.isEven ? const Color(0xFFEDD97A) : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  // _infoRow lama tetap dipertahankan
  Widget _infoRow(IconData icon, String text, {bool isBold = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFD86487)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
