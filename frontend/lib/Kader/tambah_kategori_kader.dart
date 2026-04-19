import 'package:flutter/material.dart';
import 'edukasi_kader.dart'; // import KategoriModel

class TambahKategoriKaderPage extends StatefulWidget {
  final bool isEdit;
  final KategoriModel? data;

  const TambahKategoriKaderPage({super.key, this.isEdit = false, this.data});

  @override
  State<TambahKategoriKaderPage> createState() =>
      _TambahKategoriKaderPageState();
}

class _TambahKategoriKaderPageState extends State<TambahKategoriKaderPage>
    with SingleTickerProviderStateMixin {
  final _namaCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _status = 'Draft';
  String _image = 'assets/images/ikon_edu1.jpg';
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
      _namaCtrl.text = widget.data!.nama;
      _descCtrl.text = widget.data!.deskripsi;
      _status = widget.data!.status;
      _image = widget.data!.image;
    }
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _namaCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final result = KategoriModel(
      id: widget.data?.id ?? 'k_${DateTime.now().millisecondsSinceEpoch}',
      nama: _namaCtrl.text.trim(),
      deskripsi: _descCtrl.text.trim(),
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
      backgroundColor: const Color(0xFFF7EEF1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD85F87),
        elevation: 0,
        title: const Text(
          'SiTumbuh',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.notifications_none),
          ),
        ],
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
                          widget.isEdit ? 'Edit Kategori' : 'Tambah Kategori',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7A1635),
                          ),
                        ),
                        const Text(
                          'Kelola kategori konten edukasi',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD85F87)),
                        foregroundColor: const Color(0xFFD85F87),
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
                      // ─ Nama Kategori ─
                      _sectionHeader(
                        'Informasi Kategori',
                        Icons.category_outlined,
                      ),
                      const SizedBox(height: 14),

                      _label('Nama Kategori *'),
                      TextFormField(
                        controller: _namaCtrl,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nama kategori tidak boleh kosong';
                          }
                          if (v.trim().length < 3) {
                            return 'Nama minimal 3 karakter';
                          }
                          return null;
                        },
                        decoration: _inputDeco(
                          'Contoh: Gizi, Kesehatan, Tumbuh Kembang',
                        ),
                      ),

                      const SizedBox(height: 14),

                      _label('Deskripsi Singkat *'),
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 4,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Deskripsi tidak boleh kosong';
                          }
                          if (v.trim().length < 10) {
                            return 'Deskripsi minimal 10 karakter';
                          }
                          return null;
                        },
                        decoration: _inputDeco(
                          'Jelaskan secara singkat isi dari kategori ini...',
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ─ Media ─
                      _sectionHeader('Media Pendukung', Icons.image_outlined),
                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: () {
                          _showSnackbar(
                            'Fitur upload gambar akan tersedia segera',
                            Colors.blue,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFD85F87,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.cloud_upload_outlined,
                                  color: Color(0xFFD85F87),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Unggah Ikon Kategori',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'PNG, JPG maksimum 5 MB',
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

                      const SizedBox(height: 20),

                      // ─ Status ─
                      _sectionHeader(
                        'Status Publikasi',
                        Icons.toggle_on_outlined,
                      ),
                      const SizedBox(height: 10),

                      _statusOption(
                        value: 'Draft',
                        title: 'Draft',
                        subtitle:
                            'Belum dipublikasikan, hanya terlihat oleh kader.',
                        icon: Icons.edit_note,
                        color: Colors.orange,
                      ),
                      _statusOption(
                        value: 'Dipublikasikan',
                        title: 'Dipublikasikan',
                        subtitle:
                            'Kategori aktif dan bisa digunakan pada edukasi.',
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
                                backgroundColor: const Color(0xFFD85F87),
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

  // ── Widget Helpers ──

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFD85F87).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFD85F87), size: 18),
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

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        borderSide: const BorderSide(color: Color(0xFFD85F87), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
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
