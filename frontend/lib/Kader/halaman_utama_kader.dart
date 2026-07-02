import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';
import '../widgets/custom_app_bar.dart';
import 'jadwal.dart';

class HalamanUtamaKader extends StatefulWidget {
  final bool fromNotification;
  final int? notificationId;

  const HalamanUtamaKader({
    super.key,
    this.fromNotification = false,
    this.notificationId,
  });

  @override
  State<HalamanUtamaKader> createState() => _HalamanUtamaKaderState();
}

class _HalamanUtamaKaderState extends State<HalamanUtamaKader> {
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

    if (widget.fromNotification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifikasi kader diterima'),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
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
      print("Error load nama kader: $e");
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
      print("Error load statistik: $e");
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
      print("Error load jadwal: $e");
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
                    _buildGreetingSection(),
                    const SizedBox(height: 24),
                    _buildSectionLabel("Ringkasan Pemantauan"),
                    const SizedBox(height: 12),
                    _buildRingkasanCard(),
                    const SizedBox(height: 24),
                    _buildSectionLabel("Jadwal Terdekat"),
                    const SizedBox(height: 12),
                    _buildJadwalCard(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE85D75), Color(0xFFD94A64)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE85D75).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_getGreeting()},",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _namaKader,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _jadwalTanggal != "Memuat..." &&
                                  _jadwalTanggal != "Belum ada jadwal"
                              ? "Jadwal: $_jadwalTanggal"
                              : "Belum ada jadwal",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

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
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            letterSpacing: 0.3,
          ),
        ),
        const Spacer(),
        Text(
          "Lihat Semua",
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFFE85D75),
            fontWeight: FontWeight.w500,
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: const Color(0xFFE85D75),
        ),
      ],
    );
  }

  Widget _buildRingkasanCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFDE2E7), Color(0xFFFCD5DC)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE85D75).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.analytics_rounded,
                              size: 16,
                              color: Color(0xFFE85D75),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Total",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "$_jumlahPemantauan",
                            style: const TextStyle(
                              color: Color(0xFFE85D75),
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              height: 0.9,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "pemantauan",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE8F0FE), Color(0xFFD6E4FD)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A9BFF).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.people_rounded,
                              size: 16,
                              color: Color(0xFF4A9BFF),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Anak",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "$_jumlahAnak",
                            style: const TextStyle(
                              color: Color(0xFF4A9BFF),
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              height: 0.9,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "terdaftar",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF0FFF7), Color(0xFFE0F7EE)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF20C997).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.checklist_rounded,
                        size: 20,
                        color: Color(0xFF20C997),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kehadiran",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "$_jumlahKehadiran",
                              style: const TextStyle(
                                color: Color(0xFF20C997),
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 0.9,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "kali",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF20C997).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF20C997).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        color: const Color(0xFF20C997),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Bulan Ini",
                        style: TextStyle(
                          color: const Color(0xFF20C997),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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

  Widget _buildJadwalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE85D75).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  size: 20,
                  color: Color(0xFFE85D75),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Jadwal Posyandu Terdekat",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildJadwalRow(
            icon: Icons.access_time_rounded,
            label: "Waktu",
            value: _jadwalWaktu,
            color: const Color(0xFFFF6B6B),
          ),
          const SizedBox(height: 12),
          _buildJadwalRow(
            icon: Icons.location_on_rounded,
            label: "Lokasi",
            value: _jadwalLokasi,
            color: const Color(0xFF4A9BFF),
          ),
          const SizedBox(height: 12),
          _buildJadwalRow(
            icon: Icons.event_note_rounded,
            label: "Kegiatan",
            value: _jadwalKegiatan,
            color: const Color(0xFF20C997),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE85D75),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Jadwal()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Lihat Detail Jadwal",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
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
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w500,
                  height: 1.2,
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
