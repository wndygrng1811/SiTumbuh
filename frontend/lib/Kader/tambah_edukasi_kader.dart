import 'package:flutter/material.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';
import 'edukasi_kader.dart'; // import EdukasiModel & KategoriModel

class TambahEdukasiPage extends StatefulWidget {
  final bool isEdit;
  final EdukasiModel? data;
  final List<KategoriModel> kategoriList;

  const TambahEdukasiPage({
    super.key,
    this.isEdit = false,
    this.data,
    required this.kategoriList,
  });

  @override
  State<TambahEdukasiPage> createState() => _TambahEdukasiPageState();
}

class _TambahEdukasiPageState extends State<TambahEdukasiPage>
    with SingleTickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedKategoriId;
  String _image = 'assets/edu1.jpg';
  String _status = 'Draft';
  bool _isLoading = false;

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    if (widget.isEdit && widget.data != null) {
      final d = widget.data!;
      _titleCtrl.text = d.title;
      _descCtrl.text = d.desc;
      _selectedKategoriId = d.kategoriId;
      _image = d.image;
      _status = d.status;
    } else if (widget.kategoriList.isNotEmpty) {
      _selectedKategoriId = widget.kategoriList.first.id;
    }
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKategoriId == null) {
      _showSnackbar('Pilih kategori terlebih dahulu', Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500)); // simulasi loading

    final result = EdukasiModel(
      id: widget.data?.id ?? 'e_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      kategoriId: _selectedKategoriId!,
      desc: _descCtrl.text.trim(),
      image: _image,
      status: _status,
    );

    if (!mounted) return;
    Navigator.pop(context, result);
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarKader(),
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 0),
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD05A7E),
        title: const Text(
          'SiTumbuh',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SlideTransition(
        position: _slideAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isEdit ? 'Edit Edukasi' : 'Tambah Edukasi',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7A1635),
                          ),
                        ),
                        const Text(
                          'Buat konten edukasi untuk orang tua',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD05A7E)),
                        foregroundColor: const Color(0xFFD05A7E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        setState(() => _status = 'Draft');
                        _simpan();
                      },
                      child: const Text('Simpan Draft'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Form Card ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─ Informasi Utama ─
                      _sectionHeader('Informasi Utama', Icons.info_outline),
                      const SizedBox(height: 14),

                      _label('Judul Edukasi *'),
                      _inputField(
                        controller: _titleCtrl,
                        hint: 'Contoh: Pentingnya Gizi Seimbang',
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Judul tidak boleh kosong';
                          }
                          if (v.trim().length < 5) {
                            return 'Judul minimal 5 karakter';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 4),
                      _label('Kategori *'),
                      const SizedBox(height: 6),
                      _dropdownKategori(),

                      const SizedBox(height: 14),
                      _label('Isi Konten *'),
                      _inputField(
                        controller: _descCtrl,
                        hint:
                            'Tuliskan isi edukasi secara lengkap dan jelas...',
                        maxLines: 5,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Isi konten tidak boleh kosong';
                          }
                          if (v.trim().length < 20) {
                            return 'Isi konten minimal 20 karakter';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // ─ Media ─
                      _sectionHeader('Media Pendukung', Icons.image_outlined),
                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: () {
                          // TODO: image picker
                          _showSnackbar(
                            'Fitur upload gambar akan tersedia segera',
                            Colors.blue,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFD05A7E,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.cloud_upload_outlined,
                                  color: Color(0xFFD05A7E),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Unggah Gambar Sampul',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'PNG, JPG maksimum 10 MB',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Gambar ini akan menjadi sampul edukasi yang tampil di daftar.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),

                      const SizedBox(height: 20),

                      // ─ Status ─
                      _sectionHeader(
                        'Status Publikasi',
                        Icons.toggle_on_outlined,
                      ),
                      const SizedBox(height: 8),

                      _statusOption(
                        value: 'Draft',
                        title: 'Draft',
                        subtitle:
                            'Simpan sementara, belum bisa dilihat orang tua.',
                        icon: Icons.edit_note,
                        color: Colors.orange,
                      ),
                      _statusOption(
                        value: 'Dipublikasikan',
                        title: 'Dipublikasikan',
                        subtitle: 'Langsung bisa dilihat oleh orang tua.',
                        icon: Icons.public,
                        color: Colors.green,
                      ),

                      const SizedBox(height: 24),

                      // ─ Buttons ─
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD05A7E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(
                                        () => _status = 'Dipublikasikan',
                                      );
                                      _simpan();
                                    },
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.public, size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          'Publikasikan',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Widgets Helper ──

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFD05A7E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFD05A7E), size: 18),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF444444),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
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
          borderSide: const BorderSide(color: Color(0xFFD05A7E), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _dropdownKategori() {
    if (widget.kategoriList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 18),
            SizedBox(width: 8),
            Text(
              'Belum ada kategori. Tambah kategori dulu.',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedKategoriId,
      validator: (v) => v == null ? 'Pilih kategori' : null,
      onChanged: (v) => setState(() => _selectedKategoriId = v),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
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
          borderSide: const BorderSide(color: Color(0xFFD05A7E), width: 1.5),
        ),
      ),
      items: widget.kategoriList
          .map(
            (k) => DropdownMenuItem(
              value: k.id,
              child: Text(k.nama, style: const TextStyle(fontSize: 13)),
            ),
          )
          .toList(),
    );
  }

  Widget _statusOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final selected = _status == value;
    return GestureDetector(
      onTap: () => setState(() => _status = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.07) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? color : Colors.grey, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selected ? color : Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: color, size: 20)
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey.shade400,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
