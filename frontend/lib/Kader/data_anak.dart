import 'package:flutter/material.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';

// ══════════════════════════════════════════════
//  CONSTANTS
// ══════════════════════════════════════════════
class AppColors {
  static const primary = Color(0xFFD86487);
  static const primaryLight = Color(0xFFEC9EAB);
  static const primaryBg = Color(0xFFFFF5F7);
  static const deleteRed = Color(0xFF76172D);
  static const textDark = Color(0xFF4A202A);
  static const textMid = Color(0xFF666666);
  static const textLight = Color(0xFF999999);
  static const cardBg = Colors.white;
  static const chipBg = Color(0xFFFFECF1);
  static const footerBg = Color(0xFFFAFAFA);
  static const appBarDark = Color(0xFF5C1A2E);
}

// ══════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════
class DataAnakPage extends StatefulWidget {
  const DataAnakPage({super.key});

  @override
  State<DataAnakPage> createState() => _DataAnakPageState();
}

class _DataAnakPageState extends State<DataAnakPage> {
  // ── Data ──────────────────────────────────
  List<Map<String, String>> anakList = [
    {
      "nama": "Rizky Febian",
      "jk": "Laki-laki",
      "tanggal": "30 Maret 2026",
      "tb": "32",
      "bb": "42",
      "lk": "34",
      "ortu": "Aisyah",
    },
    {
      "nama": "Alex Setiawan",
      "jk": "Laki-laki",
      "tanggal": "15 Desember 2025",
      "tb": "30",
      "bb": "39",
      "lk": "32",
      "ortu": "Aisyah",
    },
    {
      "nama": "Diana Veroz",
      "jk": "Laki-laki",
      "tanggal": "22 Oktober 2025",
      "tb": "40",
      "bb": "56",
      "lk": "35",
      "ortu": "Aisyah",
    },
  ];

  final List<String> listOrtu = ["Aisyah", "Rahmawati", "Gunawan"];
  final List<String> listJK = ["Laki-laki", "Perempuan"];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ── Computed ──────────────────────────────
  List<Map<String, String>> get _filteredList {
    if (_searchQuery.isEmpty) return anakList;
    return anakList
        .where(
          (a) => a["nama"]!.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  // ══════════════════════════════════════════
  //  DIALOGS
  // ══════════════════════════════════════════

  /// Detail popup
  void _showDetail(Map<String, String> data) {
    showDialog(
      context: context,
      builder: (_) => _DetailDialog(data: data),
    );
  }

  /// Edit popup
  void _showEdit(Map<String, String> data) {
    showDialog(
      context: context,
      builder: (_) => _EditDialog(
        data: data,
        onSave: (updated) => setState(() {
          data
            ..["tanggal"] = updated["tanggal"]!
            ..["bb"] = updated["bb"]!
            ..["tb"] = updated["tb"]!
            ..["lk"] = updated["lk"]!;
        }),
      ),
    );
  }

  /// Tambah popup
  void _showTambah() {
    showDialog(
      context: context,
      builder: (_) => _TambahDialog(
        listJK: listJK,
        listOrtu: listOrtu,
        onSave: (newData) => setState(() => anakList.add(newData)),
      ),
    );
  }

  /// Delete confirmation
  void _deleteAnak(Map<String, String> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Data"),
        content: Text("Apakah Anda yakin ingin menghapus ${data["nama"]}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batal",
              style: TextStyle(color: AppColors.textMid),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(
                () => anakList.removeWhere((e) => e["nama"] == data["nama"]),
              );
              Navigator.pop(context);
            },
            child: const Text(
              "Hapus",
              style: TextStyle(color: AppColors.deleteRed),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarKader(),
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 1),
      backgroundColor: AppColors.primaryBg,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopSection(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: const Text(
        "SiTumbuh",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  // ── Top Section ───────────────────────────
  Widget _buildTopSection() {
    return Container(
      color: AppColors.primaryBg,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Kelola Data Anak",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Total: ${_filteredList.length} anak terdaftar",
            style: const TextStyle(fontSize: 13, color: AppColors.textMid),
          ),
          const SizedBox(height: 14),

          // ── Tambah button (full-width) ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showTambah,
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                "Tambah anak",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Search bar ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.black.withOpacity(0.15),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: "cari nama anak....",
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.4),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.black.withOpacity(0.4),
                  size: 22,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 13,
                  horizontal: 8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── List ──────────────────────────────────
  Widget _buildList() {
    final list = _filteredList;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.child_care,
              size: 56,
              color: AppColors.primaryLight.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              "Tidak ada data anak",
              style: TextStyle(color: AppColors.textMid, fontSize: 15),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: list.length,
      itemBuilder: (_, i) => _AnakCard(
        data: list[i],
        onDetail: () => _showDetail(list[i]),
        onEdit: () => _showEdit(list[i]),
        onDelete: () => _deleteAnak(list[i]),
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  ANAK CARD WIDGET
// ══════════════════════════════════════════════
class _AnakCard extends StatelessWidget {
  final Map<String, String> data;
  final VoidCallback onDetail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AnakCard({
    required this.data,
    required this.onDetail,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Card body ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data["nama"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "${data["jk"]}  •  ${data["tanggal"]}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMid,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Delete icon top-right
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.delete_outline,
                          color: AppColors.deleteRed,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // ── Measurement chips ──
                Row(
                  children: [
                    _MeasurementChip(label: "TB", value: "${data["tb"]} cm"),
                    const SizedBox(width: 8),
                    _MeasurementChip(label: "BB", value: "${data["bb"]} kg"),
                    const SizedBox(width: 8),
                    _MeasurementChip(label: "LK", value: "${data["lk"]} cm"),
                  ],
                ),
                const SizedBox(height: 8),
                // ── Orang Tua row with buttons aligned to right ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: AppColors.textMid,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Orang tua: ${data["ortu"]}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMid,
                          ),
                        ),
                      ],
                    ),
                    // Buttons next to Orang Tua text
                    Row(
                      children: [
                        _SmallActionButton(
                          label: "Detail",
                          onTap: onDetail,
                          isPrimary: false,
                        ),
                        const SizedBox(width: 8),
                        _SmallActionButton(
                          label: "Ubah",
                          onTap: onEdit,
                          isPrimary: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small Action Button (for inline with Orang Tua) ──
class _SmallActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _SmallActionButton({
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: isPrimary ? null : Border.all(color: const Color(0xFFDDDDDD)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isPrimary ? Colors.white : AppColors.textMid,
          ),
        ),
      ),
    );
  }
}

// ── Measurement Chip ──────────────────────────
class _MeasurementChip extends StatelessWidget {
  final String label;
  final String value;
  const _MeasurementChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMid,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  DETAIL DIALOG
// ══════════════════════════════════════════════
class _DetailDialog extends StatelessWidget {
  final Map<String, String> data;
  const _DetailDialog({required this.data});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Detail Anak",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.textDark,
                  ),
                ),
                _CloseButton(onTap: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),

            // ── Name card ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data["nama"]!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${data["jk"]}  •  ${data["tanggal"]}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMid,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: "Tanggal lahir",
              value: data["tanggal"]!,
            ),
            _DetailRow(
              icon: Icons.person_outline,
              label: "Jenis kelamin",
              value: data["jk"]!,
            ),
            _DetailRow(
              icon: Icons.monitor_weight_outlined,
              label: "Berat lahir",
              value: "${data["bb"]} kg",
            ),
            _DetailRow(
              icon: Icons.straighten_outlined,
              label: "Tinggi lahir",
              value: "${data["tb"]} cm",
            ),
            _DetailRow(
              icon: Icons.radio_button_unchecked,
              label: "Lingkar kepala",
              value: "${data["lk"]} cm",
            ),
            _DetailRow(
              icon: Icons.people_outline,
              label: "Orang tua",
              value: data["ortu"]!,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMid),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  EDIT DIALOG (with smaller size and pink background card)
// ══════════════════════════════════════════════
class _EditDialog extends StatefulWidget {
  final Map<String, String> data;
  final Function(Map<String, String>) onSave;
  const _EditDialog({required this.data, required this.onSave});

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final TextEditingController _tanggal;
  late final TextEditingController _bb;
  late final TextEditingController _tb;
  late final TextEditingController _lk;

  @override
  void initState() {
    super.initState();
    _tanggal = TextEditingController(text: widget.data["tanggal"]);
    _bb = TextEditingController(text: widget.data["bb"]);
    _tb = TextEditingController(text: widget.data["tb"]);
    _lk = TextEditingController(text: widget.data["lk"]);
  }

  @override
  void dispose() {
    _tanggal.dispose();
    _bb.dispose();
    _tb.dispose();
    _lk.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      final formattedDate =
          "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
      setState(() {
        _tanggal.text = formattedDate;
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background pink card (visible behind)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Foreground white card
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Edit Data Anak",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      _CloseButton(onTap: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _DateFormField(
                    label: "Tanggal Lahir",
                    controller: _tanggal,
                    hint: "DD/MM/YYYY",
                    onDateTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 10),
                  _FormField(
                    label: "Berat Badan Ketika Lahir (kg)",
                    controller: _bb,
                    hint: "3.8",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  _FormField(
                    label: "Tinggi Badan Ketika Lahir (cm)",
                    controller: _tb,
                    hint: "52",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  _FormField(
                    label: "Lingkar Kepala Ketika Lahir (cm)",
                    controller: _lk,
                    hint: "46",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  _SaveButton(
                    onPressed: () {
                      widget.onSave({
                        "tanggal": _tanggal.text,
                        "bb": _bb.text,
                        "tb": _tb.text,
                        "lk": _lk.text,
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  TAMBAH DIALOG (with smaller size and pink background card)
// ══════════════════════════════════════════════
class _TambahDialog extends StatefulWidget {
  final List<String> listJK;
  final List<String> listOrtu;
  final Function(Map<String, String>) onSave;

  const _TambahDialog({
    required this.listJK,
    required this.listOrtu,
    required this.onSave,
  });

  @override
  State<_TambahDialog> createState() => _TambahDialogState();
}

class _TambahDialogState extends State<_TambahDialog> {
  final _nama = TextEditingController();
  final _tanggal = TextEditingController();
  final _bb = TextEditingController();
  final _tb = TextEditingController();
  final _lk = TextEditingController();
  late String _selectedJK;
  late String _selectedOrtu;

  @override
  void initState() {
    super.initState();
    _selectedJK = widget.listJK.first;
    _selectedOrtu = widget.listOrtu.first;
  }

  @override
  void dispose() {
    _nama.dispose();
    _tanggal.dispose();
    _bb.dispose();
    _tb.dispose();
    _lk.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      const months = [
        "Januari",
        "Februari",
        "Maret",
        "April",
        "Mei",
        "Juni",
        "Juli",
        "Agustus",
        "September",
        "Oktober",
        "November",
        "Desember",
      ];
      final formattedDate =
          "${picked.day} ${months[picked.month - 1]} ${picked.year}";
      setState(() {
        _tanggal.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background pink card (visible behind)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Foreground white card
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tambah Anak",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      _CloseButton(onTap: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _FormField(
                    label: "Nama Lengkap",
                    controller: _nama,
                    hint: "Masukkan nama lengkap",
                  ),
                  const SizedBox(height: 10),
                  _DateFormField(
                    label: "Tanggal Lahir",
                    controller: _tanggal,
                    hint: "DD/MM/YYYY",
                    onDateTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 10),
                  _DropdownField(
                    label: "Jenis Kelamin",
                    hint: "Pilih jenis kelamin",
                    value: _selectedJK,
                    items: widget.listJK,
                    onChanged: (v) => setState(() => _selectedJK = v),
                  ),
                  const SizedBox(height: 10),
                  _FormField(
                    label: "Berat Badan Ketika Lahir (kg)",
                    controller: _bb,
                    hint: "3.8",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  _FormField(
                    label: "Tinggi Badan Ketika Lahir (cm)",
                    controller: _tb,
                    hint: "52",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  _FormField(
                    label: "Lingkar Kepala Ketika Lahir (cm)",
                    controller: _lk,
                    hint: "46",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  _DropdownField(
                    label: "Nama Orang Tua",
                    hint: "Pilih Orang Tua",
                    value: _selectedOrtu,
                    items: widget.listOrtu,
                    onChanged: (v) => setState(() => _selectedOrtu = v),
                  ),
                  const SizedBox(height: 20),

                  _SaveButton(
                    onPressed: () {
                      widget.onSave({
                        "nama": _nama.text,
                        "tanggal": _tanggal.text,
                        "jk": _selectedJK,
                        "bb": _bb.text,
                        "tb": _tb.text,
                        "lk": _lk.text,
                        "ortu": _selectedOrtu,
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  SHARED SMALL WIDGETS
// ══════════════════════════════════════════════

/// Date Form Field with calendar icon
class _DateFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final VoidCallback onDateTap;

  const _DateFormField({
    required this.label,
    required this.controller,
    this.hint = '',
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: onDateTap,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 12),
            suffixIcon: Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 18,
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable text field
class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _FormField({
    required this.label,
    required this.controller,
    this.hint = '',
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 12),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable dropdown
class _DropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String value;
  final List<String> items;
  final Function(String) onChanged;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                hint,
                style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 12),
              ),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => onChanged(v!),
            ),
          ),
        ),
      ],
    );
  }
}

/// Save button
class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SaveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 1,
        ),
        child: const Text(
          "Simpan",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Close button (X circle)
class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFF0F0F0),
        ),
        child: const Icon(Icons.close, size: 16, color: AppColors.textLight),
      ),
    );
  }
}
