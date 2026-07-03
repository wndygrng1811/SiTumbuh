import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/sidebar_menu.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/custom_app_bar.dart';
import 'grafik.dart';
import 'profil.dart';
import 'edukasi.dart';
import '../widgets/youtube_player_page.dart';
import '../services/api_service.dart';

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  final int _selectedIndex = 0;
  int anakId = 0;
  String namaAnak = '';
  String jenisKelamin = '';
  String namaOrangTua = '';
  bool _isDataLoaded = false;

  List<Widget> get _pages => [
    DashboardContent(
      anakId: anakId,
      namaAnak: namaAnak,
      jenisKelamin: jenisKelamin,
      namaOrangTua: namaOrangTua,
      onChildChanged: _refreshChildData,
    ),
    GrafikPage(
      anakId: anakId,
      namaAnak: namaAnak,
      jenisKelamin: jenisKelamin,
      onChildChanged: _refreshChildData,
    ),
    const EdukasiPage(),
    ProfilePage(
      anakId: anakId,
      namaAnak: namaAnak,
      jenisKelamin: jenisKelamin,
      onChildChanged: _refreshChildData,
    ),
  ];

  void _refreshChildData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int newAnakId = prefs.getInt('anak_id') ?? 0;
    String newNamaAnak = prefs.getString('nama_anak') ?? '';
    String newJenisKelamin = prefs.getString('jenis_kelamin') ?? '';

    if (mounted) {
      setState(() {
        anakId = newAnakId;
        namaAnak = newNamaAnak;
        jenisKelamin = newJenisKelamin;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('user_id') ?? 0;
    String? token = prefs.getString('token');

    if (userId == 0) return;

    try {
      final responseUser = await http.get(
        Uri.parse('${ApiService.baseUrl}/orangtua/profile/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (responseUser.statusCode == 200) {
        final dataUser = json.decode(responseUser.body);
        if (dataUser['success'] == true) {
          setState(() {
            namaOrangTua =
                dataUser['data']['nama_lengkap'] ??
                dataUser['data']['nama'] ??
                'Bunda';
          });
        }
      }

      int savedAnakId = prefs.getInt('anak_id') ?? 0;
      String savedNamaAnak = prefs.getString('nama_anak') ?? '';
      String savedJenisKelamin = prefs.getString('jenis_kelamin') ?? '';

      if (savedAnakId != 0 && savedNamaAnak.isNotEmpty) {
        setState(() {
          anakId = savedAnakId;
          namaAnak = savedNamaAnak;
          jenisKelamin = savedJenisKelamin;
        });
      } else {
        final responseAnak = await http.get(
          Uri.parse('${ApiService.baseUrl}/orangtua/$userId/anak'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (responseAnak.statusCode == 200) {
          final dataAnak = json.decode(responseAnak.body);
          if (dataAnak['success'] == true &&
              dataAnak['data'] != null &&
              dataAnak['data'].isNotEmpty) {
            var anak = dataAnak['data'][0];
            String jk = anak['jenis_kelamin'] ?? '';
            if (jk == 'L') jk = 'Laki-laki';
            if (jk == 'P') jk = 'Perempuan';

            setState(() {
              anakId = anak['anak_id'];
              namaAnak = anak['nama'] ?? 'Anak';
              jenisKelamin = jk;
            });

            await prefs.setInt('anak_id', anakId);
            await prefs.setString('nama_anak', namaAnak);
            await prefs.setString('jenis_kelamin', jenisKelamin);
          }
        }
      }

      setState(() {
        _isDataLoaded = true;
      });
    } catch (e) {
      debugPrint('Error load data: $e');
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDataLoaded) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF5F7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      drawer: const SidebarMenu(),
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: CustomAppBar(
        backgroundColor: const Color(0xFFE85D75),
        iconColor: Colors.white,
        showBackButton: false,
        showDrawerIcon: true,
        showNotificationIcon: true,
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNav(currentIndex: _selectedIndex),
    );
  }
}

// ==================== DASHBOARD CONTENT ====================
class DashboardContent extends StatefulWidget {
  final int anakId;
  final String namaAnak;
  final String jenisKelamin;
  final String namaOrangTua;
  final VoidCallback? onChildChanged;

  const DashboardContent({
    super.key,
    required this.anakId,
    required this.namaAnak,
    required this.jenisKelamin,
    required this.namaOrangTua,
    this.onChildChanged,
  });

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _bannerImages = [
    'assets/images/stunting.jpg',
    'assets/images/stunting1.png',
    'assets/images/stunting3.png',
  ];

  double beratTerbaru = 0;
  double tinggiTerbaru = 0;
  double lingkarKepalaTerbaru = 0;
  String statusGizi = '';
  String tglPemeriksaan = '';
  bool _isLoading = false;
  bool _hasData = false;

  List<Map<String, dynamic>> _dataPertumbuhan = [];
  DateTime? _tanggalLahir;

  int _currentAnakId = 0;
  String _currentNamaAnak = '';
  String _currentJenisKelamin = '';

  List<Map<String, dynamic>> _jadwalList = [];
  bool _isLoadingJadwal = true;

  List<Map<String, dynamic>> _edukasiList = [];
  bool _isLoadingEdukasi = true;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    _updateChildData();
  }

  @override
  void didUpdateWidget(DashboardContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.anakId != widget.anakId ||
        oldWidget.namaAnak != widget.namaAnak) {
      _updateChildData();
    }
  }

  void _updateChildData() {
    setState(() {
      _currentAnakId = widget.anakId;
      _currentNamaAnak = widget.namaAnak;
      _currentJenisKelamin = widget.jenisKelamin;
      _hasData = false;
      _dataPertumbuhan = [];
      _tanggalLahir = null;
    });

    _loadDataAnak();
    _loadDataFromDatabase();
    _loadJadwalTerdekat();
    _loadEdukasi();
  }

  Future<void> _loadDataAnak() async {
    if (_currentAnakId == 0) return;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/anak/$_currentAnakId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final anakData = data['data'];
          if (anakData['tanggal_lahir'] != null) {
            try {
              setState(() {
                _tanggalLahir = DateTime.parse(anakData['tanggal_lahir']);
              });
            } catch (e) {
              print('Error parsing tanggal lahir: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error load data anak: $e');
    }
  }

  Future<void> _loadDataFromDatabase() async {
    if (_currentAnakId == 0) {
      setState(() {
        _isLoading = false;
        _hasData = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/pertumbuhan/$_currentAnakId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true &&
            data['data'] != null &&
            data['data'].isNotEmpty) {
          List<dynamic> dataList = data['data'];

          dataList.sort((a, b) => b['tanggal'].compareTo(a['tanggal']));

          var terbaru = dataList[0];

          setState(() {
            beratTerbaru = (terbaru['berat'] ?? 0).toDouble();
            tinggiTerbaru = (terbaru['tinggi'] ?? 0).toDouble();
            lingkarKepalaTerbaru = (terbaru['l_kepala'] ?? 0).toDouble();
            statusGizi = terbaru['status'] ?? '';
            tglPemeriksaan = terbaru['tanggal']?.toString() ?? '';
            _hasData = true;
            _isLoading = false;

            _dataPertumbuhan = dataList.map((item) {
              DateTime tanggal;
              try {
                tanggal = DateTime.parse(item['tanggal'].toString());
              } catch (e) {
                tanggal = DateTime.now();
              }
              return {
                'berat': (item['berat'] ?? 0).toDouble(),
                'tinggi': (item['tinggi'] ?? 0).toDouble(),
                'lk': (item['l_kepala'] ?? 0).toDouble(),
                'tanggal': tanggal,
                'status': item['status'] ?? 'Normal',
              };
            }).toList();

            _dataPertumbuhan.sort(
              (a, b) => (a['tanggal'] as DateTime).compareTo(
                b['tanggal'] as DateTime,
              ),
            );
          });
        } else {
          setState(() {
            _isLoading = false;
            _hasData = false;
            _dataPertumbuhan = [];
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _hasData = false;
          _dataPertumbuhan = [];
        });
      }
    } catch (e) {
      debugPrint('Error load data: $e');
      setState(() {
        _isLoading = false;
        _hasData = false;
      });
    }
  }

  Future<void> _loadJadwalTerdekat() async {
    setState(() => _isLoadingJadwal = true);
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

      if (response.statusCode == 200 && mounted) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List<dynamic> jadwalList = data['data'];

          DateTime now = DateTime.now();
          List<Map<String, dynamic>> jadwalAkanDatang = [];

          for (var j in jadwalList) {
            try {
              DateTime tglJadwal = DateTime.parse(j['tanggal']);
              String waktuStr = j['waktu'] ?? '00:00:00';
              List<String> waktuParts = waktuStr.split(':');
              int jam = int.parse(waktuParts[0]);
              int menit = int.parse(waktuParts[1]);

              DateTime fullDateTime = DateTime(
                tglJadwal.year,
                tglJadwal.month,
                tglJadwal.day,
                jam,
                menit,
              );

              if (fullDateTime.isAfter(now) ||
                  fullDateTime.isAtSameMomentAs(now)) {
                jadwalAkanDatang.add(j);
              }
            } catch (e) {
              print('Error parsing jadwal: $e');
            }
          }

          jadwalAkanDatang.sort((a, b) {
            try {
              DateTime tglA = DateTime.parse(a['tanggal']);
              String waktuA = a['waktu'] ?? '00:00:00';
              List<String> partsA = waktuA.split(':');

              DateTime tglB = DateTime.parse(b['tanggal']);
              String waktuB = b['waktu'] ?? '00:00:00';
              List<String> partsB = waktuB.split(':');

              DateTime fullA = DateTime(
                tglA.year,
                tglA.month,
                tglA.day,
                int.parse(partsA[0]),
                int.parse(partsA[1]),
              );
              DateTime fullB = DateTime(
                tglB.year,
                tglB.month,
                tglB.day,
                int.parse(partsB[0]),
                int.parse(partsB[1]),
              );

              return fullA.compareTo(fullB);
            } catch (e) {
              return 0;
            }
          });

          setState(() {
            _jadwalList = jadwalAkanDatang.cast<Map<String, dynamic>>();
            _isLoadingJadwal = false;
          });
        } else {
          setState(() => _isLoadingJadwal = false);
        }
      } else {
        setState(() => _isLoadingJadwal = false);
      }
    } catch (e) {
      debugPrint('Error load jadwal: $e');
      setState(() => _isLoadingJadwal = false);
    }
  }

  Future<void> _loadEdukasi() async {
    setState(() => _isLoadingEdukasi = true);
    try {
      final data = await ApiService.getEdukasi();

      final filteredData = data.where((item) {
        final desc = item['desc']?.toString() ?? '';
        final status = item['status']?.toString() ?? '';
        final hasYoutube = _isYoutubeUrl(desc);
        return hasYoutube && status == 'Dipublikasikan';
      }).toList();

      filteredData.sort((a, b) {
        final idA = a['id'] ?? 0;
        final idB = b['id'] ?? 0;
        return idB.compareTo(idA);
      });

      final top3 = filteredData.take(3).toList();

      setState(() {
        _edukasiList = top3.map((item) {
          final desc = item['desc']?.toString() ?? '';
          final youtubeUrl = _extractYoutubeUrl(desc);
          final thumbnail = _getYoutubeThumbnail(youtubeUrl);
          return {
            'id': item['id'] ?? 0,
            'judul': item['title'] ?? item['judul'] ?? 'Video Edukasi',
            'youtube_url': youtubeUrl,
            'thumbnail': thumbnail,
            'kategori': item['kategori'] ?? 'Edukasi',
          };
        }).toList();
        _isLoadingEdukasi = false;
      });
    } catch (e) {
      debugPrint('Error load edukasi: $e');
      setState(() => _isLoadingEdukasi = false);
    }
  }

  bool _isYoutubeUrl(String text) {
    final youtubePatterns = [
      r'youtube\.com/watch\?v=',
      r'youtu\.be/',
      r'youtube\.com/embed/',
      r'youtube\.com/shorts/',
    ];
    for (var pattern in youtubePatterns) {
      if (RegExp(pattern).hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  String _extractYoutubeUrl(String text) {
    final patterns = [
      r'https?://(?:www\.)?youtube\.com/watch\?v=[^\s&]+',
      r'https?://(?:www\.)?youtu\.be/[^\s?]+',
      r'https?://(?:www\.)?youtube\.com/embed/[^\s?]+',
      r'https?://(?:www\.)?youtube\.com/shorts/[^\s?]+',
    ];

    for (var pattern in patterns) {
      final match = RegExp(pattern).firstMatch(text);
      if (match != null) {
        return match.group(0) ?? '';
      }
    }
    return '';
  }

  String _getYoutubeThumbnail(String youtubeUrl) {
    String videoId = '';
    if (youtubeUrl.contains('watch?v=')) {
      videoId = youtubeUrl.split('watch?v=')[1].split('&')[0];
    } else if (youtubeUrl.contains('youtu.be/')) {
      videoId = youtubeUrl.split('youtu.be/')[1].split('?')[0];
    } else if (youtubeUrl.contains('embed/')) {
      videoId = youtubeUrl.split('embed/')[1].split('?')[0];
    } else if (youtubeUrl.contains('shorts/')) {
      videoId = youtubeUrl.split('shorts/')[1].split('?')[0];
    } else {
      videoId = youtubeUrl;
    }
    videoId = videoId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');

    if (videoId.isNotEmpty) {
      return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    }
    return 'assets/images/stunting.jpg';
  }

  String _getTemplateImage(String? template) {
    if (template == null || template.isEmpty) {
      return 'assets/templatekuning.jpg';
    }
    return template;
  }

  String _formatTanggalForDisplay(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
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
      final days = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu',
      ];
      return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _currentPage = (_currentPage + 1) % _bannerImages.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoSlide();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static const Map<int, double> _beratLaki = {
    0: 3.3,
    1: 4.5,
    2: 5.6,
    3: 6.4,
    4: 7.0,
    5: 7.5,
    6: 7.9,
    7: 8.3,
    8: 8.6,
    9: 8.9,
    10: 9.2,
    11: 9.4,
    12: 9.6,
    13: 9.9,
    14: 10.1,
    15: 10.3,
    16: 10.5,
    17: 10.7,
    18: 10.9,
    19: 11.1,
    20: 11.3,
    21: 11.5,
    22: 11.7,
    23: 11.9,
    24: 12.1,
    27: 12.5,
    30: 12.9,
    33: 13.3,
    36: 13.7,
    39: 14.1,
    42: 14.5,
    45: 14.9,
    48: 15.3,
    51: 15.7,
    54: 16.1,
    57: 16.5,
    60: 16.9,
  };

  static const Map<int, double> _beratPerempuan = {
    0: 3.2,
    1: 4.2,
    2: 5.1,
    3: 5.8,
    4: 6.4,
    5: 6.9,
    6: 7.3,
    7: 7.6,
    8: 7.9,
    9: 8.2,
    10: 8.5,
    11: 8.7,
    12: 8.9,
    13: 9.2,
    14: 9.4,
    15: 9.6,
    16: 9.8,
    17: 10.0,
    18: 10.2,
    19: 10.4,
    20: 10.6,
    21: 10.8,
    22: 11.0,
    23: 11.2,
    24: 11.4,
    27: 11.8,
    30: 12.2,
    33: 12.6,
    36: 13.0,
    39: 13.4,
    42: 13.8,
    45: 14.2,
    48: 14.6,
    51: 15.0,
    54: 15.4,
    57: 15.8,
    60: 16.2,
  };

  double _getStandardValue(int umurBulan, String gender) {
    Map<int, double> data = gender == 'Laki-laki'
        ? _beratLaki
        : _beratPerempuan;
    List<int> ages = data.keys.toList()..sort();

    if (umurBulan <= ages.first) return data[ages.first] ?? 0;
    if (umurBulan >= ages.last) return data[ages.last] ?? 0;

    for (int i = 0; i < ages.length - 1; i++) {
      if (umurBulan >= ages[i] && umurBulan <= ages[i + 1]) {
        double t = (umurBulan - ages[i]) / (ages[i + 1] - ages[i]);
        double val1 = data[ages[i]] ?? 0;
        double val2 = data[ages[i + 1]] ?? 0;
        return val1 + t * (val2 - val1);
      }
    }
    return 0;
  }

  List<FlSpot> _buildStandarMedian() {
    String gender = _currentJenisKelamin == 'Perempuan'
        ? 'Perempuan'
        : 'Laki-laki';
    List<FlSpot> spots = [];
    for (int umur = 0; umur <= 24; umur++) {
      double nilai = _getStandardValue(umur, gender);
      if (nilai > 0) spots.add(FlSpot(umur.toDouble(), nilai));
    }
    return spots;
  }

  List<FlSpot> _buildStandarPlus2() {
    String gender = _currentJenisKelamin == 'Perempuan'
        ? 'Perempuan'
        : 'Laki-laki';
    List<FlSpot> spots = [];
    for (int umur = 0; umur <= 24; umur++) {
      double nilai = _getStandardValue(umur, gender) * 1.15;
      if (nilai > 0) spots.add(FlSpot(umur.toDouble(), nilai));
    }
    return spots;
  }

  List<FlSpot> _buildStandarPlus1() {
    String gender = _currentJenisKelamin == 'Perempuan'
        ? 'Perempuan'
        : 'Laki-laki';
    List<FlSpot> spots = [];
    for (int umur = 0; umur <= 24; umur++) {
      double nilai = _getStandardValue(umur, gender) * 1.07;
      if (nilai > 0) spots.add(FlSpot(umur.toDouble(), nilai));
    }
    return spots;
  }

  List<FlSpot> _buildStandarMinus1() {
    String gender = _currentJenisKelamin == 'Perempuan'
        ? 'Perempuan'
        : 'Laki-laki';
    List<FlSpot> spots = [];
    for (int umur = 0; umur <= 24; umur++) {
      double nilai = _getStandardValue(umur, gender) * 0.93;
      if (nilai > 0) spots.add(FlSpot(umur.toDouble(), nilai));
    }
    return spots;
  }

  List<FlSpot> _buildStandarMinus2() {
    String gender = _currentJenisKelamin == 'Perempuan'
        ? 'Perempuan'
        : 'Laki-laki';
    List<FlSpot> spots = [];
    for (int umur = 0; umur <= 24; umur++) {
      double nilai = _getStandardValue(umur, gender) * 0.85;
      if (nilai > 0) spots.add(FlSpot(umur.toDouble(), nilai));
    }
    return spots;
  }

  List<FlSpot> _buildDataAnakSpotsKMS() {
    List<FlSpot> spots = [];
    if (_tanggalLahir == null) return spots;

    for (var data in _dataPertumbuhan) {
      DateTime tanggal = data['tanggal'] as DateTime;
      double berat = data['berat'] as double;

      int bulan = (tanggal.year - _tanggalLahir!.year) * 12;
      bulan += tanggal.month - _tanggalLahir!.month;
      int hari = tanggal.day - _tanggalLahir!.day;
      double umurBulan = bulan.toDouble() + (hari / 30.0);
      if (umurBulan < 0) umurBulan = 0;

      if (berat > 0 && umurBulan >= 0 && umurBulan <= 24) {
        spots.add(FlSpot(umurBulan, berat));
      }
    }
    spots.sort((a, b) => a.x.compareTo(b.x));
    return spots;
  }

  // ============ BUILD POSTER MINI DENGAN TEKS ============
  Widget _buildPosterMiniWidget(Map<String, dynamic> jadwal) {
    String templatePath = _getTemplateImage(jadwal['template']);
    String formattedDate = _formatTanggalForDisplay(jadwal['tanggal']);
    String waktu = jadwal['waktu'] ?? '';
    String namaPos = jadwal['nama_posyandu'] ?? 'Posyandu';

    return SizedBox(
      width: 80,
      height: 95,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(templatePath, width: 80, height: 95, fit: BoxFit.cover),
          Positioned(
            top: 8,
            left: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFF0D98A), width: 0.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 7,
                        color: const Color(0xFF5C6BC0),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          formattedDate.length > 10
                              ? formattedDate.substring(0, 10) + '..'
                              : formattedDate,
                          style: const TextStyle(
                            fontSize: 6,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 7,
                        color: const Color(0xFFF57C00),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        waktu,
                        style: const TextStyle(
                          fontSize: 6,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 7,
                        color: const Color(0xFFE53935),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          namaPos.length > 8
                              ? namaPos.substring(0, 8) + '..'
                              : namaPos,
                          style: const TextStyle(
                            fontSize: 6,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayNama = _currentNamaAnak.isNotEmpty
        ? _currentNamaAnak
        : widget.namaAnak.isNotEmpty
        ? widget.namaAnak
        : "Anak";

    return RefreshIndicator(
      onRefresh: () async {
        await _loadDataAnak();
        await _loadDataFromDatabase();
        await _loadJadwalTerdekat();
        await _loadEdukasi();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBannerCarousel(),
            const SizedBox(height: 16),
            _buildGreetingSection(),
            const SizedBox(height: 14),
            _buildAnakDataCard(displayNama),
            const SizedBox(height: 18),
            _buildGrowthChartSection(),
            const SizedBox(height: 18),
            _buildJadwalCard(),
            const SizedBox(height: 18),
            _buildEdukasiSection(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ============ BANNER CAROUSEL ============
  Widget _buildBannerCarousel() {
    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _bannerImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                _bannerImages[index],
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFD86487).withOpacity(0.2),
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreetingSection() {
    final displayName = widget.namaOrangTua.isNotEmpty
        ? widget.namaOrangTua
        : 'Bunda';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hallo, $displayName! 👋",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B1E3F),
          ),
        ),
        const Text(
          "Pantau pertumbuhan anak anda",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildAnakDataCard(String displayNama) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDE2E7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasData && beratTerbaru > 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDE2E7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayNama,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B1E3F),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InfoItem("Berat", "${beratTerbaru.toStringAsFixed(1)} kg"),
                  const VerticalDivider(color: Color(0xFF8B1E3F), thickness: 1),
                  InfoItem("Tinggi", "${tinggiTerbaru.toStringAsFixed(1)} cm"),
                  const VerticalDivider(color: Color(0xFF8B1E3F), thickness: 1),
                  InfoItem(
                    "L. Kepala",
                    "${lingkarKepalaTerbaru.toStringAsFixed(1)} cm",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pemeriksaan Terakhir",
                  style: TextStyle(fontSize: 13),
                ),
                Text(tglPemeriksaan, style: const TextStyle(fontSize: 13)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Cek Pertumbuhan",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B1E3F),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB5C7A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () => _navigateToGrafik(),
                  child: const Text(
                    "Lihat Grafik",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE2E7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayNama,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B1E3F),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Column(
              children: [
                Icon(Icons.child_care, size: 48, color: Color(0xFFDB5C7A)),
                SizedBox(height: 8),
                Text(
                  "Belum ada data pertumbuhan",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  "Lakukan pemeriksaan di Posyandu terdekat",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDB5C7A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size(double.infinity, 40),
            ),
            onPressed: () => _navigateToGrafik(),
            child: const Text(
              "Mulai Pemeriksaan",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChartSection() {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Grafik Pertumbuhan",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF8B1E3F),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (_dataPertumbuhan.isEmpty || !_hasData) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Grafik Pertumbuhan",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF8B1E3F),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _navigateToGrafik(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Belum ada data pertumbuhan'),
                    SizedBox(height: 4),
                    Text(
                      'Lakukan pemeriksaan di Posyandu',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _navigateToGrafik(),
              child: const Text(
                "Lihat selengkapnya",
                style: TextStyle(color: Color(0xFF8B1E3F), fontSize: 13),
              ),
            ),
          ),
        ],
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final double chartWidth = screenWidth - 48;
    final double chartHeight = chartWidth / (811 / 1146);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Grafik Pertumbuhan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF8B1E3F),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _navigateToGrafik(),
          child: Container(
            width: double.infinity,
            height: chartHeight,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/tabel.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  CustomPaint(
                    size: Size.infinite,
                    painter: GrafikKMSPainter(
                      dataAnakSpots: _buildDataAnakSpotsKMS(),
                      standarPlus2: _buildStandarPlus2(),
                      standarPlus1: _buildStandarPlus1(),
                      standarMedian: _buildStandarMedian(),
                      standarMinus1: _buildStandarMinus1(),
                      standarMinus2: _buildStandarMinus2(),
                      maxUmur: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              _buildLegend(Colors.green, 'Standar'),
              const SizedBox(width: 12),
              _buildLegend(Colors.orange, 'Batas Normal'),
              const SizedBox(width: 12),
              _buildLegend(const Color(0xFFDB5C7A), 'Anak'),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _navigateToGrafik(),
            child: const Text(
              "Lihat selengkapnya",
              style: TextStyle(color: Color(0xFF8B1E3F), fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 20, height: 3, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  // ============ JADWAL DENGAN POSTER DIGENERATE ============
  Widget _buildJadwalCard() {
    if (_isLoadingJadwal) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDE2E7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.calendar_today, color: Color(0xFF8B1E3F)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Memuat jadwal...",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    if (_jadwalList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDE2E7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.calendar_today, color: Color(0xFF8B1E3F)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Belum ada jadwal posyandu",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Jadwal Posyandu Terdekat",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF8B1E3F),
          ),
        ),
        const SizedBox(height: 10),
        ..._jadwalList.take(2).map((jadwal) => _buildJadwalItem(jadwal)),
        if (_jadwalList.length > 2)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "Lihat semua →",
                style: TextStyle(color: Color(0xFF8B1E3F), fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildJadwalItem(Map<String, dynamic> jadwal) {
    final namaPosyandu = jadwal['nama_posyandu'] ?? 'Posyandu';
    final waktu = jadwal['waktu'] ?? '';
    final alamat = jadwal['alamat'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          // POSTER YANG SUDAH DIGENERATE (DENGAN TEKS)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildPosterMiniWidget(jadwal),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaPosyandu,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF2D2D2D),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTanggalForDisplay(jadwal['tanggal']),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                if (waktu.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        waktu,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                if (alamat.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          alamat,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD86487).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Akan Datang',
              style: TextStyle(
                fontSize: 9,
                color: Color(0xFFD86487),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEdukasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Edukasi Orang Tua",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF8B1E3F),
          ),
        ),
        const SizedBox(height: 10),
        if (_isLoadingEdukasi)
          const Center(child: CircularProgressIndicator())
        else if (_edukasiList.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'Belum ada video edukasi',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _edukasiList.length,
              itemBuilder: (context, index) {
                final item = _edukasiList[index];
                return _buildEdukasiCard(
                  thumbnail: item['thumbnail'] ?? 'assets/images/stunting.jpg',
                  judul: item['judul'] ?? 'Video Edukasi',
                  youtubeUrl: item['youtube_url'] ?? '',
                );
              },
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _navigateToEdukasi(),
            child: const Text(
              "Lihat selengkapnya",
              style: TextStyle(color: Color(0xFF8B1E3F), fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEdukasiCard({
    required String thumbnail,
    required String judul,
    required String youtubeUrl,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                YoutubePlayerPage(title: judul, videoUrl: youtubeUrl),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  Image.network(
                    thumbnail,
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/stunting.jpg',
                      height: 80,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.play_arrow, color: Colors.white, size: 10),
                          SizedBox(width: 2),
                          Text(
                            'Tonton',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Text(
                judul,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGrafik() {
    if (_currentAnakId != 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GrafikPage(
            anakId: _currentAnakId,
            namaAnak: _currentNamaAnak,
            jenisKelamin: _currentJenisKelamin,
            onChildChanged: widget.onChildChanged,
          ),
        ),
      );
    }
  }

  void _navigateToEdukasi() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EdukasiPage()),
    );
  }
}

// ==================== GRAFIK KMS PAINTER ====================
class GrafikKMSPainter extends CustomPainter {
  final List<FlSpot> dataAnakSpots;
  final List<FlSpot> standarPlus2;
  final List<FlSpot> standarPlus1;
  final List<FlSpot> standarMedian;
  final List<FlSpot> standarMinus1;
  final List<FlSpot> standarMinus2;
  final int maxUmur;

  const GrafikKMSPainter({
    required this.dataAnakSpots,
    required this.standarPlus2,
    required this.standarPlus1,
    required this.standarMedian,
    required this.standarMinus1,
    required this.standarMinus2,
    required this.maxUmur,
  });

  static const double refWidth = 811;
  static const double refHeight = 1146;
  static const double gridLeft = 114;
  static const double gridTop = 114;
  static const double gridWidth = 636;
  static const double gridHeight = 944;
  static const double minBerat = 1;
  static const double maxBerat = 18;

  double xPos(int month, double canvasWidth, double canvasHeight) {
    final scaleX = canvasWidth / refWidth;
    final left = gridLeft * scaleX;
    final width = gridWidth * scaleX;
    return left + ((month + 0.5) / (maxUmur + 1)) * width;
  }

  double yPos(double value, double canvasWidth, double canvasHeight) {
    final scaleY = canvasHeight / refHeight;
    final top = gridTop * scaleY;
    final height = gridHeight * scaleY;
    return top + height - ((value - minBerat) / (maxBerat - minBerat)) * height;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double canvasWidth = size.width;
    final double canvasHeight = size.height;

    _drawBand(
      canvas,
      standarMinus1,
      standarMinus2,
      const Color(0xFFFFD54F),
      canvasWidth,
      canvasHeight,
    );
    _drawBand(
      canvas,
      standarMedian,
      standarMinus1,
      const Color(0xFF81C784),
      canvasWidth,
      canvasHeight,
    );
    _drawBand(
      canvas,
      standarPlus1,
      standarMedian,
      const Color(0xFF388E3C),
      canvasWidth,
      canvasHeight,
    );
    _drawBand(
      canvas,
      standarPlus2,
      standarPlus1,
      const Color(0xFFFFD54F),
      canvasWidth,
      canvasHeight,
    );

    _drawCurve(
      canvas,
      standarPlus2,
      Colors.grey.shade600,
      1.5,
      canvasWidth,
      canvasHeight,
    );
    _drawCurve(
      canvas,
      standarPlus1,
      Colors.grey.shade600,
      1.5,
      canvasWidth,
      canvasHeight,
    );
    _drawCurve(
      canvas,
      standarMedian,
      Colors.black87,
      2,
      canvasWidth,
      canvasHeight,
    );
    _drawCurve(
      canvas,
      standarMinus1,
      Colors.grey.shade600,
      1.5,
      canvasWidth,
      canvasHeight,
    );
    _drawCurve(
      canvas,
      standarMinus2,
      Colors.grey.shade600,
      1.5,
      canvasWidth,
      canvasHeight,
    );

    _drawDataAnak(canvas, canvasWidth, canvasHeight);
  }

  void _drawBand(
    Canvas canvas,
    List<FlSpot> topCurve,
    List<FlSpot> bottomCurve,
    Color color,
    double canvasWidth,
    double canvasHeight,
  ) {
    if (topCurve.isEmpty || bottomCurve.isEmpty) return;

    final Path path = Path();
    bool hasStarted = false;

    for (int i = 0; i < topCurve.length; i++) {
      final double x = xPos(topCurve[i].x.toInt(), canvasWidth, canvasHeight);
      final double y = yPos(topCurve[i].y, canvasWidth, canvasHeight);
      if (!hasStarted) {
        path.moveTo(x, y);
        hasStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }

    for (int i = bottomCurve.length - 1; i >= 0; i--) {
      final double x = xPos(
        bottomCurve[i].x.toInt(),
        canvasWidth,
        canvasHeight,
      );
      final double y = yPos(bottomCurve[i].y, canvasWidth, canvasHeight);
      path.lineTo(x, y);
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  void _drawCurve(
    Canvas canvas,
    List<FlSpot> data,
    Color color,
    double width,
    double canvasWidth,
    double canvasHeight,
  ) {
    if (data.isEmpty) return;

    final Path path = Path();
    bool hasStarted = false;
    for (int i = 0; i < data.length; i++) {
      final double x = xPos(data[i].x.toInt(), canvasWidth, canvasHeight);
      final double y = yPos(data[i].y, canvasWidth, canvasHeight);
      if (!hasStarted) {
        path.moveTo(x, y);
        hasStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }
    if (!hasStarted) return;

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawDataAnak(Canvas canvas, double canvasWidth, double canvasHeight) {
    if (dataAnakSpots.isEmpty) return;

    List<Offset> validPoints = [];
    for (var spot in dataAnakSpots) {
      if (spot.x < 0 || spot.x > maxUmur) continue;
      if (spot.y <= 0) continue;
      double x = xPos(spot.x.toInt(), canvasWidth, canvasHeight);
      double y = yPos(spot.y, canvasWidth, canvasHeight);
      validPoints.add(Offset(x, y));
    }
    if (validPoints.isEmpty) return;

    if (validPoints.length >= 2) {
      final Path path = Path();
      path.moveTo(validPoints.first.dx, validPoints.first.dy);
      for (int i = 1; i < validPoints.length; i++) {
        path.lineTo(validPoints[i].dx, validPoints[i].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.red.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    final Paint dotPaint = Paint()
      ..color = Colors.red.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    for (var point in validPoints) {
      canvas.drawCircle(point, 6, dotPaint);
      canvas.drawCircle(
        point,
        6,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class InfoItem extends StatelessWidget {
  final String title;
  final String value;
  const InfoItem(this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF8B1E3F),
          ),
        ),
      ],
    );
  }
}
