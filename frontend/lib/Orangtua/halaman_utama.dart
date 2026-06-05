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
import '../services/api_service.dart';

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _selectedIndex = 0;
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
  }

  Future<void> _loadDataAnak() async {
    if (_currentAnakId == 0) return;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/anak/${_currentAnakId}'),
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
            } catch (e) {}
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
        Uri.parse('${ApiService.baseUrl}/pertumbuhan/${_currentAnakId}'),
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

          // 🔥 URUTKAN BERDASARKAN TANGGAL (TERBARU DI ATAS)
          dataList.sort((a, b) => b['tanggal'].compareTo(a['tanggal']));

          // Ambil data terbaru (index 0 setelah diurutkan)
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
            beratTerbaru = 0;
            tinggiTerbaru = 0;
            lingkarKepalaTerbaru = 0;
            statusGizi = '';
            tglPemeriksaan = '';
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

  List<FlSpot> _buildStandarCurve(String gender) {
    List<FlSpot> spots = [];
    for (int umur = 0; umur <= 60; umur++) {
      double nilai = _getStandardValue(umur, gender);
      if (nilai > 0) {
        spots.add(FlSpot(umur.toDouble(), nilai));
      }
    }
    return spots;
  }

  List<FlSpot> _buildDataAnakSpots() {
    List<FlSpot> spots = [];
    for (int i = 0; i < _dataPertumbuhan.length; i++) {
      double berat = _dataPertumbuhan[i]['berat'] as double;
      if (berat > 0) {
        double x = i.toDouble() * 5;
        if (x > 60) x = 60;
        spots.add(FlSpot(x, berat));
      }
    }
    return spots;
  }

  double _getMaxY() {
    double maxValue = 0;
    for (var data in _dataPertumbuhan) {
      double berat = data['berat'] as double;
      if (berat > maxValue) maxValue = berat;
    }

    String gender = _currentJenisKelamin == 'Perempuan'
        ? 'Perempuan'
        : 'Laki-laki';
    for (int umur = 0; umur <= 60; umur++) {
      double std = _getStandardValue(umur, gender);
      if (std > maxValue) maxValue = std;
    }
    return (maxValue + 5).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final displayNama = _currentNamaAnak.isNotEmpty
        ? _currentNamaAnak
        : widget.namaAnak.isNotEmpty
        ? widget.namaAnak
        : "Anak";

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await _loadDataAnak();
          await _loadDataFromDatabase();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomAppBar(
                showDrawerIcon: true,
                showNotificationIcon: true,
                backgroundColor: Colors.transparent,
                titleColor: Color(0xFF8B1E3F),
                elevation: 0,
              ),
              const SizedBox(height: 8),
              _buildBannerCarousel(),
              const SizedBox(height: 20),
              _buildGreetingSection(),
              const SizedBox(height: 16),
              _buildAnakDataCard(displayNama),
              const SizedBox(height: 20),
              _buildGrowthChartSection(),
              const SizedBox(height: 20),
              _buildJadwalCard(),
              const SizedBox(height: 20),
              _buildEdukasiSection(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _bannerImages.length,
        itemBuilder: (context, index) {
          return _buildBannerCard(_bannerImages[index]);
        },
      ),
    );
  }

  Widget _buildBannerCard(String imagePath) {
    return GestureDetector(
      onTap: () => _navigateToEdukasi(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
        ),
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
          "Hallo, $displayName!",
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
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasData && beratTerbaru > 0) {
      final displayBerat = "${beratTerbaru.toStringAsFixed(1)} kg";
      final displayTinggi = "${tinggiTerbaru.toStringAsFixed(1)} cm";
      final displayLingkar = "${lingkarKepalaTerbaru.toStringAsFixed(1)} cm";
      final displayStatus = statusGizi;

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
                  InfoItem("Berat", displayBerat),
                  const VerticalDivider(color: Color(0xFF8B1E3F), thickness: 1),
                  InfoItem("Tinggi", displayTinggi),
                  const VerticalDivider(color: Color(0xFF8B1E3F), thickness: 1),
                  InfoItem("L. Kepala", displayLingkar),
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
                Text(
                  "Status pertumbuhan anak",
                  style: TextStyle(
                    fontSize: 13,
                    color: displayStatus == 'Normal'
                        ? Colors.green
                        : const Color(0xFFDB5C7A),
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
                    "Cek disini",
                    style: TextStyle(color: Colors.white, fontSize: 13),
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
            height: 220,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
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
              height: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
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

    String gender = _currentJenisKelamin == 'Perempuan'
        ? 'Perempuan'
        : 'Laki-laki';
    List<FlSpot> standarMedian = _buildStandarCurve(gender);
    List<FlSpot> standarMinus2 = [];
    List<FlSpot> standarPlus2 = [];
    List<FlSpot> dataAnakSpots = _buildDataAnakSpots();

    for (int i = 0; i < standarMedian.length; i++) {
      double median = standarMedian[i].y;
      standarMinus2.add(FlSpot(standarMedian[i].x, median * 0.85));
      standarPlus2.add(FlSpot(standarMedian[i].x, median * 1.15));
    }

    double maxY = _getMaxY();
    if (maxY < 20) maxY = 20;

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
            height: 220,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 60,
                minY: 0,
                maxY: maxY,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 0.5),
                  getDrawingVerticalLine: (value) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 0.5),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300, width: 0.5),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    axisNameWidget: const Text(
                      'Berat (kg)',
                      style: TextStyle(fontSize: 8, color: Colors.grey),
                    ),
                    axisNameSize: 15,
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxY <= 20 ? 5 : 10,
                      reservedSize: 25,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 7),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text(
                      'Umur (bulan)',
                      style: TextStyle(fontSize: 8, color: Colors.grey),
                    ),
                    axisNameSize: 15,
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 6,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 7),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: standarMinus2,
                    isCurved: true,
                    color: Colors.transparent,
                    barWidth: 0,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.orange.shade100.withOpacity(0.4),
                    ),
                  ),
                  LineChartBarData(
                    spots: standarMedian,
                    isCurved: true,
                    color: Colors.transparent,
                    barWidth: 0,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.25),
                    ),
                  ),
                  LineChartBarData(
                    spots: standarPlus2,
                    isCurved: true,
                    color: Colors.transparent,
                    barWidth: 0,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.orange.shade100.withOpacity(0.4),
                    ),
                  ),
                  LineChartBarData(
                    spots: standarMedian,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 1.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: standarPlus2,
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 1,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: standarMinus2,
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 1,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: dataAnakSpots,
                    isCurved: true,
                    color: const Color(0xFFDB5C7A),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFDB5C7A).withOpacity(0.15),
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

  Widget _buildJadwalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE2E7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Icon(Icons.calendar_today, color: Color(0xFF8B1E3F)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Jadwal Kegiatan Posyandu",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "Senin, 30 Maret 2026",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF8B1E3F)),
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
        Row(
          children: [
            Expanded(
              child: EduCard(
                imagePath: 'assets/images/stunting.jpg',
                caption:
                    'Cegah Hambatan Tumbuh Kembang Anak\ndengan Skrining Tumbuh Kembang!',
                onTap: () => _navigateToEdukasi(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: EduCard(
                imagePath: 'assets/images/stunting2.jpg',
                caption: 'Pelajari lebih lanjut tentang kesehatan anak',
                onTap: () => _navigateToEdukasi(),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _navigateToEdukasi(),
            child: const Text(
              "Baca selengkapnya",
              style: TextStyle(color: Color(0xFF8B1E3F), fontSize: 13),
            ),
          ),
        ),
      ],
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

class EduCard extends StatelessWidget {
  final String imagePath;
  final String caption;
  final VoidCallback? onTap;
  const EduCard({
    super.key,
    required this.imagePath,
    required this.caption,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            SizedBox(
              height: 130,
              width: double.infinity,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
            ),
            if (caption.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.65),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    caption,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
