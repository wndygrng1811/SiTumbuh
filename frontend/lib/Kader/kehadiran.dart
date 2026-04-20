import 'package:flutter/material.dart';
import '../widgets/sidebar_kader.dart';

class Kehadiran extends StatefulWidget {
  const Kehadiran({super.key});

  @override
  State<Kehadiran> createState() => _KehadiranState();
}

class _KehadiranState extends State<Kehadiran>
    with SingleTickerProviderStateMixin {
  int selectedTab = 0;
  String filter = "semua";
  String search = "";

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  final _searchCtrl = TextEditingController();

  // ─── Warna tema ───
  static const _primary = Color(0xFFE85D75);
  static const _primaryLight = Color(0xFFFFF0F3);
  static const _bg = Color(0xFFF8F9FC);

  List<Map<String, dynamic>> dataAnak = [
    {"nama": "Jesica Kristina", "hadir": true},
    {"nama": "Grace Anastasya", "hadir": true},
    {"nama": "Ameylia Sandi", "hadir": false},
    {"nama": "Karina Jakti", "hadir": true},
  ];

  List<Map<String, dynamic>> dataOrtu = [
    {"nama": "Ibu Jesica", "hadir": true},
    {"nama": "Ibu Grace", "hadir": false},
  ];

  List<Map<String, dynamic>> get data => selectedTab == 0 ? dataAnak : dataOrtu;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void toggleAll(bool value) {
    setState(() {
      for (var item in data) {
        item["hadir"] = value;
      }
    });
  }

  void simpanData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text("Data kehadiran berhasil disimpan"),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = data.where((item) {
      final cocokNama = (item["nama"] as String).toLowerCase().contains(
        search.toLowerCase(),
      );
      if (filter == "hadir") return (item["hadir"] as bool) && cocokNama;
      if (filter == "tidak") return !(item["hadir"] as bool) && cocokNama;
      return cocokNama;
    }).toList();

    final hadir = data.where((e) => e["hadir"] as bool).length;
    final tidak = data.where((e) => !(e["hadir"] as bool)).length;
    final total = data.length;
    final persen = total == 0 ? 0.0 : hadir / total;

    return Scaffold(
      drawer: const SidebarKader(),
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // ── Header gradient card ──
            _buildHeaderCard(hadir, tidak, total, persen),

            // ── Body ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // ── Search + Filter ──
                    _buildSearchRow(),

                    const SizedBox(height: 12),

                    // ── Tab ──
                    _buildTab(),

                    const SizedBox(height: 14),

                    // ── Action buttons ──
                    _buildActionRow(),

                    const SizedBox(height: 14),

                    // ── List ──
                    Expanded(
                      child: filtered.isEmpty
                          ? _buildEmpty()
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (_, i) =>
                                  _buildItemCard(filtered, i),
                            ),
                    ),

                    const SizedBox(height: 12),

                    // ── Simpan ──
                    _buildSimpanButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primary,
      elevation: 0,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: const Text(
        "Kehadiran Posyandu",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
          letterSpacing: 0.3,
        ),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 14),
          child: Icon(Icons.notifications_none),
        ),
      ],
    );
  }

  // ── Header Card dengan gradient + progress ──
  Widget _buildHeaderCard(int hadir, int tidak, int total, double persen) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE85D75), Color(0xFFC23F5E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          // Tanggal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 13),
                const SizedBox(width: 6),
                Text(
                  _todayLabel(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stat row
          Row(
            children: [
              _headerStat("$hadir", "Hadir", Icons.check_circle_outline),
              _headerDivider(),
              _headerStat("$tidak", "Tidak Hadir", Icons.cancel_outlined),
              _headerDivider(),
              _headerStat("$total", "Total", Icons.people_outline),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tingkat Kehadiran",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    "${(persen * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: persen,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String val, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 4),
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _headerDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  // ── Search + Filter Row ──
  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => search = v),
            decoration: InputDecoration(
              hintText: "Cari nama...",
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => search = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButton<String>(
            value: filter,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            items: const [
              DropdownMenuItem(value: "semua", child: Text("Semua")),
              DropdownMenuItem(value: "hadir", child: Text("Hadir")),
              DropdownMenuItem(value: "tidak", child: Text("Tidak Hadir")),
            ],
            onChanged: (v) => setState(() => filter = v!),
          ),
        ),
      ],
    );
  }

  // ── Tab ──
  Widget _buildTab() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _tabBtn("Anak", 0, Icons.child_care),
          _tabBtn("Orang Tua", 1, Icons.people),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, int idx, IconData icon) {
    final active = selectedTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? _primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: active ? Colors.white : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Action Row ──
  Widget _buildActionRow() {
    return Row(
      children: [
        Expanded(
          child: _actionBtn(
            label: "Semua Hadir",
            icon: Icons.check_circle_outline,
            color: Colors.green.shade600,
            onTap: () => toggleAll(true),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionBtn(
            label: "Reset Semua",
            icon: Icons.refresh_rounded,
            color: Colors.orange.shade600,
            onTap: () => toggleAll(false),
          ),
        ),
      ],
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Item Card ──
  Widget _buildItemCard(List<Map<String, dynamic>> list, int i) {
    final item = list[i];
    final hadir = item["hadir"] as bool;
    final initial = (item["nama"] as String)[0].toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hadir
              ? Colors.green.withOpacity(0.25)
              : Colors.red.withOpacity(0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: hadir
              ? Colors.green.withOpacity(0.15)
              : Colors.red.withOpacity(0.12),
          child: Text(
            initial,
            style: TextStyle(
              color: hadir ? Colors.green.shade700 : Colors.red.shade400,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          item["nama"] as String,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          hadir ? "Hadir" : "Tidak Hadir",
          style: TextStyle(
            fontSize: 12,
            color: hadir ? Colors.green.shade600 : Colors.red.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Transform.scale(
          scale: 1.1,
          child: Checkbox(
            activeColor: _primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            side: BorderSide(color: Colors.grey.shade300),
            value: hadir,
            onChanged: (val) {
              setState(() {
                item["hadir"] = val;
              });
            },
          ),
        ),
      ),
    );
  }

  // ── Empty State ──
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(
            "Tidak ada data ditemukan",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Simpan Button ──
  Widget _buildSimpanButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: simpanData,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          elevation: 3,
          shadowColor: _primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_outlined, size: 20),
            SizedBox(width: 8),
            Text(
              "Simpan Kehadiran",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const bulan = [
      '',
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
    return "${now.day} ${bulan[now.month]} ${now.year}";
  }
}
