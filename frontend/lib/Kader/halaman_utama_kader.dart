import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';
import '../widgets/custom_app_bar.dart';
import '../Kader/jadwal.dart';

class HalamanUtamaKader extends StatefulWidget {
  const HalamanUtamaKader({super.key});

  @override
  State<HalamanUtamaKader> createState() => _HalamanUtamaKaderState();
}

class _HalamanUtamaKaderState extends State<HalamanUtamaKader> {
  // Data dari database
  int _jumlahAnak = 0;
  int _jumlahOrangTua = 0;
  int _jumlahPemantauan = 0;
  int _jumlahKehadiran = 0;
  String _namaKader = "Kader";
  String _jadwalTanggal = "Memuat...";
  String _jadwalWaktu = "08:00 - 12:00 WIB";
  String _jadwalLokasi = "Memuat...";
  String _jadwalKegiatan = "Memuat...";
  bool _isLoading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id');
    });
    await _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (_userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadStatistik(),
        _loadJadwalPosyandu(),
        _loadProfilKader(),
      ]);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProfilKader() async {
    try {
      final response = await ApiService.get('/kader/profil/$_userId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            _namaKader = data['data']['nama'] ?? "Kader";
          });
        }
      }
    } catch (e) {
      print("❌ Error load nama kader: $e");
    }
  }

  Future<void> _loadStatistik() async {
    try {
      final response = await ApiService.get('/kader/statistik');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _jumlahAnak = data['data']['jumlah_anak'] ?? 0;
            _jumlahOrangTua = data['data']['jumlah_orang_tua'] ?? 0;
            _jumlahPemantauan = data['data']['jumlah_pemantauan'] ?? 0;
            _jumlahKehadiran = data['data']['jumlah_kehadiran'] ?? 0;
          });
        }
      }
    } catch (e) {
      print("❌ Error load statistik: $e");
    }
  }

  Future<void> _loadJadwalPosyandu() async {
    try {
      final response = await ApiService.get('/kader/jadwal-terdekat');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _jadwalTanggal = data['data']['tanggal'] ?? "Belum ada jadwal";
            _jadwalWaktu =
                "${data['data']['waktu_mulai']} - ${data['data']['waktu_selesai']} WIB";
            _jadwalLokasi = data['data']['lokasi'] ?? "Posyandu Mawar";
            _jadwalKegiatan =
                data['data']['kegiatan'] ?? "Penimbangan, Pengukuran";
          });
        }
      }
    } catch (e) {
      print("❌ Error load jadwal: $e");
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Selamat Pagi";
    if (hour < 15) return "Selamat Siang";
    if (hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarKader(),
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 0),
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(
        backgroundColor: const Color(0xFFE85D75),
        iconColor: Colors.white,
        showBackButton: false,
        showDrawerIcon: true,
        showNotificationIcon: true,
      ),
      body: RefreshIndicator(
        color: const Color(0xFFE85D75),
        onRefresh: _loadDashboardData,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFE85D75)),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== RINGKASAN PEMANTAUAN =====
                    _buildSectionLabel("Ringkasan Pemantauan"),
                    const SizedBox(height: 12),
                    _buildRingkasanCard(),
                    const SizedBox(height: 24),

                    // ===== JADWAL =====
                    _buildSectionLabel("Jadwal Terdekat"),
                    const SizedBox(height: 12),
                    _buildJadwalCard(),
                  ],
                ),
              ),
      ),
    );
  }

  // ===== SECTION LABEL =====
  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFE85D75),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ===== RINGKASAN PEMANTAUAN (PUTIH) =====
  Widget _buildRingkasanCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Statistik - 2 kolom
          Row(
            children: [
              // Kolom Kiri: Total Pemantauan
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE2E7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$_jumlahPemantauan",
                        style: const TextStyle(
                          color: Color(0xFFE85D75),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Pemantauan",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Kolom Kanan: Anak Terdaftar
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Anak",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$_jumlahAnak",
                        style: const TextStyle(
                          color: Color(0xFF4A9BFF),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Terdaftar",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Baris kedua: Kehadiran (full width)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FFF7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Kehadiran",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$_jumlahKehadiran",
                      style: const TextStyle(
                        color: Color(0xFF20C997),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF20C997).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: const Color(0xFF20C997),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Bulan Ini",
                        style: TextStyle(
                          color: const Color(0xFF20C997),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== JADWAL CARD =====
  Widget _buildJadwalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Body Jadwal
          _buildJadwalRow(
            icon: Icons.access_time_rounded,
            label: "Waktu",
            value: _jadwalWaktu,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF0F0F0)),
          ),
          _buildJadwalRow(
            icon: Icons.location_on_rounded,
            label: "Lokasi",
            value: _jadwalLokasi,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF0F0F0)),
          ),
          _buildJadwalRow(
            icon: Icons.event_note_rounded,
            label: "Kegiatan",
            value: _jadwalKegiatan,
          ),
          const SizedBox(height: 16),

          // Tombol Lihat Detail
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE85D75),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Jadwal()),
                );
              },
              child: const Text(
                "Lihat Detail Jadwal",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2D2D2D),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
