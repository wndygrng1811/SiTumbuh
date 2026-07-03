import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';
import '../services/api_service.dart';
import 'edukasi_kader.dart';
import '../models/edukasi_model.dart';
import '../models/kategori_model.dart';

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
  final _urlCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedKategoriId;
  String _jenisKonten = 'artikel';
  String _status = 'Draft';
  bool _isLoading = false;
  String _errorMessage = '';

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
      _selectedKategoriId = d.kategoriId;
      _status = d.status;

      if (d.youtubeUrl.isNotEmpty) {
        _jenisKonten = 'video';
        _urlCtrl.text = d.youtubeUrl;
      } else {
        _jenisKonten = 'artikel';
        _urlCtrl.text = d.desc;
      }
    }
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  String _getYoutubeThumbnail(String url) {
    if (url.isEmpty) return '';

    String videoId = '';
    if (url.contains('watch?v=')) {
      videoId = url.split('watch?v=')[1].split('&')[0];
    } else if (url.contains('youtu.be/')) {
      videoId = url.split('youtu.be/')[1].split('?')[0];
    } else if (url.contains('embed/')) {
      videoId = url.split('embed/')[1].split('?')[0];
    } else {
      videoId = url;
    }

    return 'https://img.youtube.com/vi/$videoId/0.jpg';
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKategoriId == null) {
      _showSnackbar('Pilih kategori terlebih dahulu', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final Map<String, dynamic> data;

      if (_jenisKonten == 'video') {
        data = {
          'judul': _titleCtrl.text.trim(),
          'kategori_id': _selectedKategoriId,
          'isi': _urlCtrl.text.trim(),
          'youtube_url': _urlCtrl.text.trim(),
          'image': _getYoutubeThumbnail(_urlCtrl.text.trim()),
          'status': _status,
        };
      } else {
        data = {
          'judul': _titleCtrl.text.trim(),
          'kategori_id': _selectedKategoriId,
          'isi': _urlCtrl.text.trim(),
          'youtube_url': '',
          'image': '',
          'status': _status,
        };
      }

      http.Response response;
      if (widget.isEdit) {
        response = await ApiService.put('/edukasi/${widget.data!.id}', data);
      } else {
        response = await ApiService.post('/edukasi', data);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          if (!mounted) return;
          _showSnackbar(
            widget.isEdit
                ? 'Edukasi berhasil diperbarui'
                : 'Edukasi berhasil ditambahkan',
            Colors.green,
          );
          Navigator.pop(context, true);
        } else {
          throw Exception(result['message'] ?? 'Gagal menyimpan');
        }
      } else {
        throw Exception('Gagal menyimpan data (${response.statusCode})');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      _showSnackbar('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
    final isVideo = _jenisKonten == 'video';
    final youtubePreview = isVideo && _urlCtrl.text.isNotEmpty
        ? _getYoutubeThumbnail(_urlCtrl.text)
        : null;

    return Scaffold(
      drawer: const SidebarKader(),
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 0),
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD05A7E),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
            Text(
              widget.isEdit ? 'Edit Edukasi' : 'Tambah Edukasi',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
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
                _buildHeader(),
                const SizedBox(height: 16),

                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),

                Container(
                  padding: const EdgeInsets.all(16),
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
                      _sectionHeader('Informasi Utama', Icons.info_outline),
                      const SizedBox(height: 14),

                      _labelWithAsterisk('Judul Edukasi'),
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

                      const SizedBox(height: 12),

                      _labelWithAsterisk('Kategori'),
                      const SizedBox(height: 6),
                      _dropdownKategori(),

                      const SizedBox(height: 20),

                      _sectionHeader('Jenis Konten', Icons.play_circle_outline),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _jenisKontenOption(
                              value: 'artikel',
                              title: 'Artikel',
                              icon: Icons.article_outlined,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _jenisKontenOption(
                              value: 'video',
                              title: 'Video YouTube',
                              icon: Icons.play_circle_outline,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _labelWithAsterisk(
                        isVideo ? 'URL YouTube' : 'URL Artikel',
                      ),
                      _inputField(
                        controller: _urlCtrl,
                        hint: isVideo
                            ? 'https://youtube.com/watch?v=...'
                            : 'https://example.com/artikel',
                        helperText: isVideo
                            ? 'Masukkan URL YouTube, thumbnail akan otomatis diambil'
                            : 'Masukkan URL artikel, gambar akan otomatis diambil',
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return isVideo
                                ? 'URL YouTube tidak boleh kosong'
                                : 'URL Artikel tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      if (isVideo && youtubePreview != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  youtubePreview,
                                  width: 80,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 80,
                                    height: 60,
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.play_circle,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Preview Thumbnail',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Thumbnail akan diambil otomatis dari YouTube',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

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

                      _buildActionButtons(),
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

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEdit ? 'Edit Edukasi' : 'Tambah Edukasi',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A1635),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Buat konten edukasi',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 32,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD05A7E)),
              foregroundColor: const Color(0xFFD05A7E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() => _status = 'Draft');
                    await _simpan();
                  },
            child: const Text(
              'Simpan Draft',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _jenisKontenOption({
    required String value,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final selected = _jenisKonten == value;
    return GestureDetector(
      onTap: () => setState(() => _jenisKonten = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? color : Colors.grey, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? color : Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(0, 40),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(fontSize: 13)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD05A7E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(0, 40),
            ),
            onPressed: _isLoading ? null : _simpan,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.save, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Simpan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _labelWithAsterisk(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF444444),
          ),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        helperText: helperText,
        helperStyle: const TextStyle(fontSize: 10),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Belum ada kategori. Tambah kategori dulu.',
                style: TextStyle(fontSize: 11, color: Colors.orange),
              ),
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
          vertical: 10,
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
      items: widget.kategoriList.map((k) {
        return DropdownMenuItem<String>(
          value: k.id.toString(),
          child: Text(k.nama, style: const TextStyle(fontSize: 13)),
        );
      }).toList(),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            Icon(icon, color: selected ? color : Colors.grey, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selected ? color : Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: color, size: 18)
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey.shade400,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
