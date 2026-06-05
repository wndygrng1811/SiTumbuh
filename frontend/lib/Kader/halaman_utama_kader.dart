import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';

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
    print("📱 User ID dari SharedPreferences: $_userId");
    await _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (_userId == null) {
      print("❌ User ID tidak ditemukan!");
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
      print("ERROR LOAD DASHBOARD: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProfilKader() async {
    try {
      final response = await ApiService.get('/kader/profil/$_userId');
      print("📡 Profil Kader Response: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            _namaKader = data['data']['nama'] ?? "Kader";
          });
          print("✅ Nama kader: $_namaKader");
        }
      } else {
        print("❌ Gagal load profil kader: ${response.body}");
      }
    } catch (e) {
      print("❌ Error load nama kader: $e");
    }
  }

  Future<void> _loadStatistik() async {
    try {
      final response = await ApiService.get('/kader/statistik');
      print("📡 Statistik Response: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _jumlahAnak = data['data']['jumlah_anak'] ?? 0;
            _jumlahOrangTua = data['data']['jumlah_orang_tua'] ?? 0;
            _jumlahPemantauan = data['data']['jumlah_pemantauan'] ?? 0;
            _jumlahKehadiran = data['data']['jumlah_kehadiran'] ?? 0;
          });
          print(
            "✅ Statistik: Anak=$_jumlahAnak, Orang Tua=$_jumlahOrangTua, Pemantauan=$_jumlahPemantauan",
          );
        }
      }
    } catch (e) {
      print("❌ Error load statistik: $e");
    }
  }

  Future<void> _loadJadwalPosyandu() async {
    try {
      final response = await ApiService.get('/kader/jadwal-terdekat');
      print("📡 Jadwal Response: ${response.statusCode}");
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
          print("✅ Jadwal: $_jadwalTanggal");
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

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "🌤️";
    if (hour < 15) return "☀️";
    if (hour < 18) return "🌇";
    return "🌙";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 0),
      drawer: const SidebarKader(),
      backgroundColor: const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        color: const Color(0xFFE85D75),
        onRefresh: _loadDashboardData,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFE85D75)),
              )
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  /// ── HEADER ──
                  SliverToBoxAdapter(child: _buildHeader()),

                  /// ── CONTENT ──
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        /// Seksi statistik
                        _buildSectionLabel("Statistik Posyandu"),
                        const SizedBox(height: 12),
                        _buildStatGrid(),
                        const SizedBox(height: 24),

                        /// Seksi jadwal
                        _buildSectionLabel("Jadwal Terdekat"),
                        const SizedBox(height: 12),
                        _buildJadwalCard(),
                        const SizedBox(height: 24),

                        /// Seksi ringkasan
                        _buildSectionLabel("Ringkasan Pemantauan"),
                        const SizedBox(height: 12),
                        _buildRingkasanCard(),
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE85D75),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              // Top bar
              Row(
                children: [
                  Builder(
                    builder: (ctx) => _HeaderIconButton(
                      icon: Icons.menu_rounded,
                      onTap: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "SiTumbuh",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _HeaderIconButton(
                        icon: Icons.notifications_outlined,
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white.withOpacity(0.25),
                        child: Text(
                          _namaKader.isNotEmpty
                              ? _namaKader[0].toUpperCase()
                              : "K",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Greeting section
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_getGreeting()} ${_getGreetingEmoji()}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _namaKader,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Kader sehat, anak sehat! 💪",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Quick summary badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "$_jumlahAnak",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          "Anak\nTerdaftar",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 10,
                            height: 1.3,
                          ),
                        ),
                      ],
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

  // ─────────────────────────────────────────────────────────────
  //  SECTION LABEL
  // ─────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFE85D75),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  STAT GRID (2 × 2)
  // ─────────────────────────────────────────────────────────────
  Widget _buildStatGrid() {
    final stats = [
      _StatItem(
        value: "$_jumlahAnak",
        label: "Anak Terdaftar",
        icon: Icons.child_care_rounded,
        color: Colors.orange,
      ),
      _StatItem(
        value: "$_jumlahOrangTua",
        label: "Orang Tua",
        icon: Icons.family_restroom_rounded,
        color: Colors.blue,
      ),
      _StatItem(
        value: "$_jumlahPemantauan",
        label: "Total Pemantauan",
        icon: Icons.favorite_rounded,
        color: Colors.teal,
      ),
      _StatItem(
        value: "$_jumlahKehadiran",
        label: "Kehadiran Bulan Ini",
        icon: Icons.assignment_turned_in_rounded,
        color: Colors.indigo,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (_, i) => _buildStatCard(stats[i]),
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: item.color,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  JADWAL CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildJadwalCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFE85D75),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Jadwal Posyandu Terdekat",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _jadwalTanggal,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
              ],
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
            color: const Color(0xFFE85D75).withOpacity(0.1),
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
                  color: Colors.grey[500],
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

  // ─────────────────────────────────────────────────────────────
  //  RINGKASAN CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildRingkasanCard() {
    final persen = _jumlahAnak > 0
        ? (_jumlahPemantauan / _jumlahAnak).clamp(0.0, 1.0)
        : 0.0;
    final persenText = _jumlahAnak > 0
        ? "${(persen * 100).toStringAsFixed(0)}%"
        : "0%";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$_jumlahPemantauan",
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE85D75),
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Total Pemantauan",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF555555),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Dari $_jumlahAnak anak terdaftar",
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              // Donut-like percentage circle
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: persen.toDouble(),
                      strokeWidth: 7,
                      backgroundColor: const Color(
                        0xFFE85D75,
                      ).withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFE85D75),
                      ),
                    ),
                    Text(
                      persenText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE85D75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: persen.toDouble(),
              minHeight: 6,
              backgroundColor: const Color(0xFFE85D75).withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFE85D75),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Cakupan pemantauan",
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              Text(
                persenText,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE85D75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HELPER WIDGETS
// ─────────────────────────────────────────────────────────────

class _StatItem {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

/// INFO CARD (kept for backward compatibility if used elsewhere)
class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
