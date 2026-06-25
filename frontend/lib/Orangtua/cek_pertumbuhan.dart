import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/sidebar_menu.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/custom_app_bar.dart';

class CekPertumbuhanPage extends StatefulWidget {
  const CekPertumbuhanPage({super.key});

  @override
  State<CekPertumbuhanPage> createState() => _CekPertumbuhanPageState();
}

class _CekPertumbuhanPageState extends State<CekPertumbuhanPage> {
  final usiaController = TextEditingController();
  final bbController = TextEditingController();
  final tbController = TextEditingController();
  final lkController = TextEditingController();

  // Status hasil
  String statusUtama = "";
  String deskripsi = "";
  Color warnaUtama = Colors.pink;
  IconData iconUtama = Icons.health_and_safety;

  // Kategori usia
  String kategoriUsia = "Anak (0-60 bulan)";

  // Detail per kategori
  Map<String, dynamic> statusDetail = {
    'tb_usia': {
      'label': 'TB / Usia',
      'status': '-',
      'color': Colors.grey,
      'icon': Icons.straighten,
    },
    'bb_usia': {
      'label': 'BB / Usia',
      'status': '-',
      'color': Colors.grey,
      'icon': Icons.monitor_weight_outlined,
    },
    'imt': {
      'label': 'IMT',
      'status': '-',
      'color': Colors.grey,
      'icon': Icons.calculate_outlined,
    },
    'lk_usia': {
      'label': 'LK / Usia',
      'status': '-',
      'color': Colors.grey,
      'icon': Icons.face_outlined,
    },
  };

  // ===== FUNGSI DETEKSI KATEGORI USIA =====
  String _getKategoriUsia(double usiaTahun) {
    if (usiaTahun < 5) return "Anak (0-60 bulan)";
    if (usiaTahun >= 5 && usiaTahun < 18) return "Remaja (5-17 tahun)";
    if (usiaTahun >= 18) return "Dewasa (≥18 tahun)";
    return "Usia tidak valid";
  }

  // ===== STANDAR WHO UNTUK ANAK 0-60 BULAN =====
  // Berdasarkan WHO Child Growth Standards

  // 1. TB/U - Height-for-age (Deteksi Stunting)
  String _getStatusTBUAnak(double usiaBulan, double tbCm) {
    if (tbCm <= 0 || usiaBulan < 0 || usiaBulan > 60) return 'Data tidak valid';

    if (usiaBulan >= 0 && usiaBulan < 6) {
      if (tbCm < 44.0) return 'Sangat Pendek (Severe Stunting)';
      if (tbCm < 48.0) return 'Pendek (Stunting)';
      if (tbCm < 58.0) return 'Normal';
      if (tbCm < 62.0) return 'Tinggi';
      return 'Tinggi';
    } else if (usiaBulan >= 6 && usiaBulan < 12) {
      if (tbCm < 56.0) return 'Sangat Pendek (Severe Stunting)';
      if (tbCm < 62.0) return 'Pendek (Stunting)';
      if (tbCm < 72.0) return 'Normal';
      if (tbCm < 76.0) return 'Tinggi';
      return 'Tinggi';
    } else if (usiaBulan >= 12 && usiaBulan < 24) {
      if (tbCm < 65.0) return 'Sangat Pendek (Severe Stunting)';
      if (tbCm < 72.0) return 'Pendek (Stunting)';
      if (tbCm < 85.0) return 'Normal';
      if (tbCm < 89.0) return 'Tinggi';
      return 'Tinggi';
    } else if (usiaBulan >= 24 && usiaBulan < 36) {
      if (tbCm < 76.0) return 'Sangat Pendek (Severe Stunting)';
      if (tbCm < 84.0) return 'Pendek (Stunting)';
      if (tbCm < 96.0) return 'Normal';
      if (tbCm < 100.0) return 'Tinggi';
      return 'Tinggi';
    } else if (usiaBulan >= 36 && usiaBulan < 48) {
      if (tbCm < 85.0) return 'Sangat Pendek (Severe Stunting)';
      if (tbCm < 92.0) return 'Pendek (Stunting)';
      if (tbCm < 103.0) return 'Normal';
      if (tbCm < 107.0) return 'Tinggi';
      return 'Tinggi';
    } else if (usiaBulan >= 48 && usiaBulan <= 60) {
      if (tbCm < 92.0) return 'Sangat Pendek (Severe Stunting)';
      if (tbCm < 98.0) return 'Pendek (Stunting)';
      if (tbCm < 110.0) return 'Normal';
      if (tbCm < 114.0) return 'Tinggi';
      return 'Tinggi';
    }
    return 'Usia tidak valid';
  }

  // 2. BB/U - Weight-for-age (Deteksi Underweight & Overweight) untuk anak
  String _getStatusBBUAnak(double usiaBulan, double bbKg) {
    if (bbKg <= 0 || usiaBulan < 0 || usiaBulan > 60) return 'Data tidak valid';

    if (usiaBulan >= 0 && usiaBulan < 6) {
      if (bbKg < 2.0) return 'Sangat Kurang (Severe Underweight)';
      if (bbKg < 3.0) return 'Kurang (Underweight)';
      if (bbKg < 6.0) return 'Normal';
      if (bbKg < 7.5) return 'Risiko Gizi Lebih';
      return 'Gizi Lebih (Overweight)';
    } else if (usiaBulan >= 6 && usiaBulan < 12) {
      if (bbKg < 4.5) return 'Sangat Kurang (Severe Underweight)';
      if (bbKg < 6.0) return 'Kurang (Underweight)';
      if (bbKg < 9.5) return 'Normal';
      if (bbKg < 11.0) return 'Risiko Gizi Lebih';
      return 'Gizi Lebih (Overweight)';
    } else if (usiaBulan >= 12 && usiaBulan < 24) {
      if (bbKg < 6.5) return 'Sangat Kurang (Severe Underweight)';
      if (bbKg < 8.0) return 'Kurang (Underweight)';
      if (bbKg < 12.5) return 'Normal';
      if (bbKg < 14.5) return 'Risiko Gizi Lebih';
      return 'Gizi Lebih (Overweight)';
    } else if (usiaBulan >= 24 && usiaBulan < 36) {
      if (bbKg < 8.5) return 'Sangat Kurang (Severe Underweight)';
      if (bbKg < 10.0) return 'Kurang (Underweight)';
      if (bbKg < 14.5) return 'Normal';
      if (bbKg < 16.5) return 'Risiko Gizi Lebih';
      return 'Gizi Lebih (Overweight)';
    } else if (usiaBulan >= 36 && usiaBulan < 48) {
      if (bbKg < 10.5) return 'Sangat Kurang (Severe Underweight)';
      if (bbKg < 12.0) return 'Kurang (Underweight)';
      if (bbKg < 16.5) return 'Normal';
      if (bbKg < 18.5) return 'Risiko Gizi Lebih';
      return 'Gizi Lebih (Overweight)';
    } else if (usiaBulan >= 48 && usiaBulan <= 60) {
      if (bbKg < 11.5) return 'Sangat Kurang (Severe Underweight)';
      if (bbKg < 13.0) return 'Kurang (Underweight)';
      if (bbKg < 18.0) return 'Normal';
      if (bbKg < 20.0) return 'Risiko Gizi Lebih';
      return 'Gizi Lebih (Overweight)';
    }
    return 'Usia tidak valid';
  }

  // 3. IMT/U - BMI-for-age untuk anak
  String _getStatusIMTUAnak(double usiaBulan, double imt) {
    if (imt <= 0 || usiaBulan < 0 || usiaBulan > 60) return 'Data tidak valid';

    if (usiaBulan >= 0 && usiaBulan < 6) {
      if (imt < 11.0) return 'Sangat Kurus (Severe Wasting)';
      if (imt < 13.0) return 'Kurus (Wasting)';
      if (imt < 17.0) return 'Normal';
      if (imt < 18.5) return 'Risiko Overweight';
      return 'Overweight';
    } else if (usiaBulan >= 6 && usiaBulan < 12) {
      if (imt < 12.0) return 'Sangat Kurus (Severe Wasting)';
      if (imt < 14.0) return 'Kurus (Wasting)';
      if (imt < 18.0) return 'Normal';
      if (imt < 19.5) return 'Risiko Overweight';
      return 'Overweight';
    } else if (usiaBulan >= 12 && usiaBulan < 24) {
      if (imt < 12.5) return 'Sangat Kurus (Severe Wasting)';
      if (imt < 14.5) return 'Kurus (Wasting)';
      if (imt < 18.0) return 'Normal';
      if (imt < 19.5) return 'Risiko Overweight';
      return 'Overweight';
    } else if (usiaBulan >= 24 && usiaBulan < 36) {
      if (imt < 12.5) return 'Sangat Kurus (Severe Wasting)';
      if (imt < 14.5) return 'Kurus (Wasting)';
      if (imt < 18.0) return 'Normal';
      if (imt < 19.5) return 'Risiko Overweight';
      return 'Overweight';
    } else if (usiaBulan >= 36 && usiaBulan < 48) {
      if (imt < 12.5) return 'Sangat Kurus (Severe Wasting)';
      if (imt < 14.5) return 'Kurus (Wasting)';
      if (imt < 18.0) return 'Normal';
      if (imt < 19.5) return 'Risiko Overweight';
      return 'Overweight';
    } else if (usiaBulan >= 48 && usiaBulan <= 60) {
      if (imt < 13.0) return 'Sangat Kurus (Severe Wasting)';
      if (imt < 15.0) return 'Kurus (Wasting)';
      if (imt < 18.5) return 'Normal';
      if (imt < 20.0) return 'Risiko Overweight';
      return 'Overweight';
    }
    return 'Usia tidak valid';
  }

  // 4. LK/U - Lingkar Kepala untuk anak
  String _getStatusLKUAnak(double usiaBulan, double lkCm) {
    if (lkCm <= 0 || usiaBulan < 0 || usiaBulan > 60) return 'Data tidak valid';

    if (usiaBulan >= 0 && usiaBulan < 6) {
      if (lkCm < 32) return 'Mikrosefali';
      if (lkCm < 37) return 'Normal';
      if (lkCm < 44) return 'Normal';
      return 'Makrosefali';
    } else if (usiaBulan >= 6 && usiaBulan < 12) {
      if (lkCm < 38) return 'Mikrosefali';
      if (lkCm < 42) return 'Normal';
      if (lkCm < 48) return 'Normal';
      return 'Makrosefali';
    } else if (usiaBulan >= 12 && usiaBulan < 24) {
      if (lkCm < 42) return 'Mikrosefali';
      if (lkCm < 45) return 'Normal';
      if (lkCm < 51) return 'Normal';
      return 'Makrosefali';
    } else if (usiaBulan >= 24 && usiaBulan < 36) {
      if (lkCm < 44) return 'Mikrosefali';
      if (lkCm < 47) return 'Normal';
      if (lkCm < 52) return 'Normal';
      return 'Makrosefali';
    } else if (usiaBulan >= 36 && usiaBulan < 48) {
      if (lkCm < 46) return 'Mikrosefali';
      if (lkCm < 48) return 'Normal';
      if (lkCm < 53) return 'Normal';
      return 'Makrosefali';
    } else if (usiaBulan >= 48 && usiaBulan <= 60) {
      if (lkCm < 47) return 'Mikrosefali';
      if (lkCm < 49) return 'Normal';
      if (lkCm < 54) return 'Normal';
      return 'Makrosefali';
    }
    return 'Usia tidak valid';
  }

  // ===== STANDAR WHO UNTUK REMAJA (5-17 TAHUN) =====
  // Menggunakan IMT berdasarkan persentil WHO (disederhanakan)
  String _getStatusIMTRemaja(double usiaTahun, double imt) {
    if (imt <= 0 || usiaTahun < 5 || usiaTahun >= 18) return 'Data tidak valid';

    // Nilai IMT berdasarkan persentil (disederhanakan)
    // -2SD: underweight, +1SD: overweight, +2SD: obesity
    if (usiaTahun >= 5 && usiaTahun < 8) {
      if (imt < 12.5) return 'Sangat Kurus (Severe Thinness)';
      if (imt < 13.5) return 'Kurus (Underweight)';
      if (imt < 18.0) return 'Normal';
      if (imt < 20.0) return 'Risiko Overweight';
      return 'Overweight';
    } else if (usiaTahun >= 8 && usiaTahun < 11) {
      if (imt < 13.0) return 'Sangat Kurus (Severe Thinness)';
      if (imt < 14.0) return 'Kurus (Underweight)';
      if (imt < 19.0) return 'Normal';
      if (imt < 21.0) return 'Risiko Overweight';
      return 'Overweight';
    } else if (usiaTahun >= 11 && usiaTahun < 14) {
      if (imt < 13.5) return 'Sangat Kurus (Severe Thinness)';
      if (imt < 15.0) return 'Kurus (Underweight)';
      if (imt < 21.0) return 'Normal';
      if (imt < 23.0) return 'Risiko Overweight';
      return 'Overweight';
    } else if (usiaTahun >= 14 && usiaTahun < 18) {
      if (imt < 14.5) return 'Sangat Kurus (Severe Thinness)';
      if (imt < 16.0) return 'Kurus (Underweight)';
      if (imt < 23.0) return 'Normal';
      if (imt < 25.0) return 'Risiko Overweight';
      return 'Overweight';
    }
    return 'Usia tidak valid';
  }

  // ===== STANDAR WHO UNTUK DEWASA (≥18 TAHUN) =====
  // Berdasarkan BMI WHO: https://apps.who.int/nutrition/landscape/help.aspx?menu=0&helpid=420
  String _getStatusIMTDewasa(double imt) {
    if (imt <= 0) return 'Data tidak valid';

    if (imt < 16.0) return 'Sangat Kurus (Severe Thinness)';
    if (imt < 17.0) return 'Kurus Sedang (Moderate Thinness)';
    if (imt < 18.5) return 'Kurus (Underweight)';
    if (imt < 25.0) return 'Normal';
    if (imt < 30.0) return 'Gemuk (Overweight)';
    if (imt < 35.0) return 'Obesitas I';
    if (imt < 40.0) return 'Obesitas II';
    return 'Obesitas III (Severe)';
  }

  // ===== STATUS UTAMA UNTUK ANAK =====
  Map<String, dynamic> _getStatusUtamaAnak(
    String statusTBU,
    String statusBBU,
    String statusIMTU,
    String statusLKU,
  ) {
    List<String> statuses = [statusTBU, statusBBU, statusIMTU, statusLKU];

    // Deteksi masalah berat
    bool severeStunting = statusTBU.contains('Severe Stunting');
    bool stunting = statusTBU.contains('Stunting');
    bool severeWasting = statusIMTU.contains('Severe Wasting');
    bool wasting = statusIMTU.contains('Wasting');
    bool severeUnderweight = statusBBU.contains('Severe Underweight');
    bool underweight = statusBBU.contains('Underweight');
    bool overweight =
        statusBBU.contains('Overweight') || statusIMTU.contains('Overweight');
    bool mikrosefali = statusLKU.contains('Mikrosefali');
    bool makrosefali = statusLKU.contains('Makrosefali');

    if (severeStunting || severeWasting || severeUnderweight) {
      return {
        'status': '⚠️ Gizi Buruk - Segera Konsultasi!',
        'deskripsi':
            'Anak menunjukkan tanda-tanda gizi buruk (stunting berat / wasting berat / underweight berat). Segera bawa ke posyandu atau puskesmas.',
        'warna': Colors.red,
        'icon': Icons.warning_amber_rounded,
      };
    } else if (stunting && (wasting || underweight)) {
      return {
        'status': '📏 Stunting + Wasting/Underweight',
        'deskripsi':
            'Anak mengalami stunting disertai masalah berat badan. Perlu penanganan gizi segera.',
        'warna': Colors.deepOrange,
        'icon': Icons.health_and_safety,
      };
    } else if (stunting) {
      return {
        'status': '📏 Stunting (Tinggi Badan di Bawah Standar)',
        'deskripsi':
            'Tinggi badan anak di bawah standar usianya. Perhatikan asupan gizi protein, vitamin, dan mineral.',
        'warna': Colors.orange,
        'icon': Icons.straighten,
      };
    } else if (wasting || underweight) {
      return {
        'status': '⚖️ Wasting / Underweight',
        'deskripsi':
            'Berat badan anak di bawah standar. Tingkatkan asupan makanan bergizi seimbang.',
        'warna': Colors.orange,
        'icon': Icons.monitor_weight_outlined,
      };
    } else if (overweight) {
      return {
        'status': '🍎 Gizi Lebih (Overweight)',
        'deskripsi':
            'Anak memiliki berat badan berlebih. Atur pola makan sehat dan tingkatkan aktivitas fisik.',
        'warna': Colors.blue,
        'icon': Icons.fitness_center,
      };
    } else if (mikrosefali || makrosefali) {
      return {
        'status': '🧠 Perkembangan Kepala Perlu Diperhatikan',
        'deskripsi':
            'Ukuran lingkar kepala tidak sesuai standar. Konsultasikan ke dokter anak.',
        'warna': Colors.purple,
        'icon': Icons.face_outlined,
      };
    } else {
      return {
        'status': '✅ Pertumbuhan Normal',
        'deskripsi':
            'Semua indikator tumbuh kembang anak berada dalam rentang normal. Pertahankan!',
        'warna': Colors.green,
        'icon': Icons.health_and_safety,
      };
    }
  }

  // ===== STATUS UTAMA UNTUK REMAJA & DEWASA =====
  Map<String, dynamic> _getStatusUtamaDewasa(String statusIMT) {
    if (statusIMT.contains('Severe Thinness') || statusIMT.contains('Severe')) {
      return {
        'status': '⚠️ Kurang Gizi Berat (Severe)',
        'deskripsi':
            'IMT menunjukkan kekurangan gizi berat. Segera konsultasikan ke dokter atau ahli gizi.',
        'warna': Colors.red,
        'icon': Icons.warning_amber_rounded,
      };
    } else if (statusIMT.contains('Underweight') ||
        statusIMT.contains('Kurus')) {
      return {
        'status': '⚖️ Kurang Gizi (Underweight)',
        'deskripsi':
            'Berat badan di bawah standar. Perhatikan asupan nutrisi dan konsultasikan ke ahli gizi.',
        'warna': Colors.orange,
        'icon': Icons.monitor_weight_outlined,
      };
    } else if (statusIMT.contains('Overweight')) {
      return {
        'status': '🍎 Gemuk (Overweight)',
        'deskripsi':
            'Berat badan berlebih. Jaga pola makan sehat dan rutin berolahraga.',
        'warna': Colors.blue,
        'icon': Icons.fitness_center,
      };
    } else if (statusIMT.contains('Obesitas')) {
      return {
        'status': '⚠️ Obesitas',
        'deskripsi':
            'IMT menunjukkan obesitas. Risiko penyakit tidak menular meningkat. Konsultasikan ke dokter.',
        'warna': Colors.redAccent,
        'icon': Icons.warning_rounded,
      };
    } else {
      return {
        'status': '✅ Berat Badan Normal',
        'deskripsi':
            'IMT berada dalam rentang normal. Pertahankan pola hidup sehat!',
        'warna': Colors.green,
        'icon': Icons.health_and_safety,
      };
    }
  }

  Color _getColorStatus(String status) {
    if (status.contains('Severe') || status.contains('Sangat'))
      return Colors.red;
    if (status.contains('Stunting') ||
        status.contains('Wasting') ||
        status.contains('Underweight') ||
        status.contains('Kurus'))
      return Colors.orange;
    if (status.contains('Overweight') || status.contains('Gemuk'))
      return Colors.blue;
    if (status.contains('Obesitas')) return Colors.redAccent;
    if (status.contains('Mikrosefali') || status.contains('Makrosefali'))
      return Colors.purple;
    if (status.contains('Risiko')) return Colors.amber;
    if (status.contains('Normal')) return Colors.green;
    if (status.contains('Tinggi')) return Colors.teal;
    return Colors.grey;
  }

  String _getStatusDisplay(String status) {
    if (status.contains(' - ')) {
      return status.split(' - ').first;
    }
    return status;
  }

  void cekPertumbuhan() {
    // Validasi input
    if (usiaController.text.isEmpty ||
        bbController.text.isEmpty ||
        tbController.text.isEmpty ||
        lkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi semua data dengan benar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double usiaTahun = double.tryParse(usiaController.text) ?? -1;
    double berat = double.tryParse(bbController.text) ?? -1;
    double tinggi = double.tryParse(tbController.text) ?? -1;
    double kepala = double.tryParse(lkController.text) ?? -1;

    // Validasi range
    if (usiaTahun < 0 || usiaTahun > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usia harus antara 0-100 tahun'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (berat < 0.5 || berat > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berat tidak valid (0.5-300 kg)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Hitung IMT
    double meter = tinggi / 100;
    double imt = berat / pow(meter, 2);

    // Tentukan kategori usia
    String kategori = _getKategoriUsia(usiaTahun);
    setState(() {
      kategoriUsia = kategori;
    });

    // Proses berdasarkan kategori
    if (kategori == "Anak (0-60 bulan)") {
      double usiaBulan = usiaTahun * 12;
      String statusTBU = _getStatusTBUAnak(usiaBulan, tinggi);
      String statusBBU = _getStatusBBUAnak(usiaBulan, berat);
      String statusIMTU = _getStatusIMTUAnak(usiaBulan, imt);
      String statusLKU = _getStatusLKUAnak(usiaBulan, kepala);

      setState(() {
        statusDetail['tb_usia'] = {
          'label': 'TB / Usia',
          'status': statusTBU,
          'color': _getColorStatus(statusTBU),
          'icon': Icons.straighten,
        };
        statusDetail['bb_usia'] = {
          'label': 'BB / Usia',
          'status': statusBBU,
          'color': _getColorStatus(statusBBU),
          'icon': Icons.monitor_weight_outlined,
        };
        statusDetail['imt'] = {
          'label': 'IMT / Usia',
          'status': statusIMTU,
          'color': _getColorStatus(statusIMTU),
          'icon': Icons.calculate_outlined,
        };
        statusDetail['lk_usia'] = {
          'label': 'LK / Usia',
          'status': statusLKU,
          'color': _getColorStatus(statusLKU),
          'icon': Icons.face_outlined,
        };

        var utama = _getStatusUtamaAnak(
          statusTBU,
          statusBBU,
          statusIMTU,
          statusLKU,
        );
        statusUtama = utama['status'];
        deskripsi = utama['deskripsi'];
        warnaUtama = utama['warna'];
        iconUtama = utama['icon'];
      });
    } else {
      // Remaja atau Dewasa - hanya gunakan IMT
      String statusIMT;
      if (kategori == "Remaja (5-17 tahun)") {
        statusIMT = _getStatusIMTRemaja(usiaTahun, imt);
      } else {
        statusIMT = _getStatusIMTDewasa(imt);
      }

      setState(() {
        statusDetail['tb_usia'] = {
          'label': 'TB / Usia',
          'status': '-',
          'color': Colors.grey,
          'icon': Icons.straighten,
        };
        statusDetail['bb_usia'] = {
          'label': 'BB / Usia',
          'status': '-',
          'color': Colors.grey,
          'icon': Icons.monitor_weight_outlined,
        };
        statusDetail['imt'] = {
          'label': 'IMT',
          'status': statusIMT,
          'color': _getColorStatus(statusIMT),
          'icon': Icons.calculate_outlined,
        };
        statusDetail['lk_usia'] = {
          'label': 'LK / Usia',
          'status': '-',
          'color': Colors.grey,
          'icon': Icons.face_outlined,
        };

        var utama = _getStatusUtamaDewasa(statusIMT);
        statusUtama = utama['status'];
        deskripsi = utama['deskripsi'];
        warnaUtama = utama['warna'];
        iconUtama = utama['icon'];
      });
    }
  }

  // ===== WIDGET =====
  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    IconData icon = Icons.edit_outlined,
    String? suffix,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 13),
          filled: true,
          fillColor: Colors.grey.shade50,
          prefixIcon: Icon(icon, color: const Color(0xFFE85D75), size: 20),
          suffixText: suffix,
          suffixStyle: const TextStyle(color: Colors.black45, fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE85D75), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ===== PERBAIKAN OVERFLOW: Menggunakan Expanded dan Flexible =====
  Widget _buildDetailRow(String title, Map<String, dynamic> data) {
    String status = data['status'] ?? '-';
    Color color = data['color'] ?? Colors.grey;
    IconData icon = data['icon'] ?? Icons.help_outline;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Row(
        children: [
          // Icon - FIXED SIZE
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          // Title - FLEXIBLE
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3A2A2D),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Badge - FLEXIBLE
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildBadge(_getStatusDisplay(status), color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarMenu(),
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: CustomAppBar(
        backgroundColor: const Color(0xFFE85D75),
        iconColor: Colors.white,
        showBackButton: false,
        showDrawerIcon: true,
        showNotificationIcon: true,
      ),
      body: Column(
        children: [
          // ===== HEADER =====
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE85D75), Color(0xFFC74A62)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monitor_heart_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Cek Pertumbuhan",
                        style: TextStyle(
                          color: Color(0xFF3A2A2D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Skrining tumbuh kembang 0-100 tahun",
                        style: TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE85D75).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'WHO',
                    style: TextStyle(
                      color: Color(0xFFE85D75),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0DDE2)),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // ===== Sapa =====
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE2E7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.favorite_outlined,
                          color: Color(0xFFE85D75),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Hallo, Bunda!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3A2A2D),
                          ),
                        ),
                        const Spacer(),
                        if (kategoriUsia.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE85D75).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              kategoriUsia,
                              style: const TextStyle(
                                color: Color(0xFFE85D75),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ===== STATUS UTAMA =====
                  if (statusUtama.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [warnaUtama, warnaUtama.withOpacity(0.85)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: warnaUtama.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              iconUtama,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  statusUtama,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  deskripsi,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (statusUtama.isNotEmpty) const SizedBox(height: 18),

                  // ===== FORM =====
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.edit_note_outlined,
                              size: 18,
                              color: Color(0xFFE85D75),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Data Pemeriksaan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3A2A2D),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildInputField(
                          'Usia',
                          usiaController,
                          icon: Icons.calendar_month_outlined,
                          suffix: 'tahun',
                          hint: '0-100',
                        ),
                        _buildInputField(
                          'Berat Badan',
                          bbController,
                          icon: Icons.monitor_weight_outlined,
                          suffix: 'kg',
                          hint: '0.5-300',
                        ),
                        _buildInputField(
                          'Tinggi Badan',
                          tbController,
                          icon: Icons.straighten,
                          suffix: 'cm',
                          hint: '45-250',
                        ),
                        if (kategoriUsia == "Anak (0-60 bulan)")
                          _buildInputField(
                            'Lingkar Kepala',
                            lkController,
                            icon: Icons.face_outlined,
                            suffix: 'cm',
                            hint: '30-55',
                          ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE85D75),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: cekPertumbuhan,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "Cek Pertumbuhan",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ===== DETAIL HASIL =====
                  if (statusDetail['imt']?['status'] != '-')
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE2E7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFF0C3CD),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.assessment_outlined,
                                size: 18,
                                color: Color(0xFF8B1E3F),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Detail Hasil Pemeriksaan',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B1E3F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Hanya tampilkan yang relevan
                          if (kategoriUsia == "Anak (0-60 bulan)") ...[
                            _buildDetailRow(
                              'TB / Usia',
                              statusDetail['tb_usia']!,
                            ),
                            _buildDetailRow(
                              'BB / Usia',
                              statusDetail['bb_usia']!,
                            ),
                            _buildDetailRow('IMT / Usia', statusDetail['imt']!),
                            _buildDetailRow(
                              'LK / Usia',
                              statusDetail['lk_usia']!,
                            ),
                          ] else ...[
                            _buildDetailRow('IMT', statusDetail['imt']!),
                          ],

                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    kategoriUsia == "Anak (0-60 bulan)"
                                        ? 'Berdasarkan WHO Child Growth Standards'
                                        : kategoriUsia == "Remaja (5-17 tahun)"
                                        ? 'Berdasarkan WHO BMI-for-age percentiles'
                                        : 'Berdasarkan WHO BMI classification for adults',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 11,
                                      height: 1.3,
                                    ),
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}
