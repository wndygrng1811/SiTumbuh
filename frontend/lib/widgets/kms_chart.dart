import 'dart:math';
import 'package:flutter/material.dart';
import 'package:si_tumbuh/models/pertumbuhan_model.dart';

class KmsChart extends StatelessWidget {
  final List<KmsDataPoint> kmsData;
  final List<RiwayatPertumbuhan> riwayat;
  final String metrik; // 'berat' | 'tinggi' | 'l_kepala'

  const KmsChart({
    super.key,
    required this.kmsData,
    required this.riwayat,
    required this.metrik,
  });

  // Ambil nilai metrik dari riwayat
  double _getMetrikValue(RiwayatPertumbuhan r) {
    switch (metrik) {
      case 'tinggi':
        return r.tinggi;
      case 'l_kepala':
        return r.lKepala;
      default:
        return r.berat;
    }
  }

  String get _labelY {
    switch (metrik) {
      case 'tinggi':
        return 'Tinggi (cm)';
      case 'l_kepala':
        return 'L. Kepala (cm)';
      default:
        return 'Berat Badan (kg)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: CustomPaint(
        painter: _KmsChartPainter(
          kmsData: kmsData,
          riwayat: riwayat,
          getMetrikValue: _getMetrikValue,
          labelY: _labelY,
        ),
      ),
    );
  }
}

class _KmsChartPainter extends CustomPainter {
  final List<KmsDataPoint> kmsData;
  final List<RiwayatPertumbuhan> riwayat;
  final double Function(RiwayatPertumbuhan) getMetrikValue;
  final String labelY;

  _KmsChartPainter({
    required this.kmsData,
    required this.riwayat,
    required this.getMetrikValue,
    required this.labelY,
  });

  // --- Margin area grafik ---
  static const double marginLeft = 48;
  static const double marginRight = 16;
  static const double marginTop = 16;
  static const double marginBottom = 36;

  // --- Range data ---
  int get maxUsia => kmsData.isNotEmpty ? kmsData.last.usia : 24;
  double get maxY {
    if (kmsData.isEmpty) return 20;
    return (kmsData.map((e) => e.sd3).reduce(max) * 1.05);
  }

  double get minY {
    if (kmsData.isEmpty) return 0;
    return (kmsData.map((e) => e.sd3Neg).reduce(min) * 0.95).clamp(
      0,
      double.infinity,
    );
  }

  // Konversi nilai data → koordinat piksel
  Offset toPixel(double usia, double nilai, Size size) {
    final chartW = size.width - marginLeft - marginRight;
    final chartH = size.height - marginTop - marginBottom;

    final x = marginLeft + (usia / maxUsia) * chartW;
    final y = marginTop + chartH - ((nilai - minY) / (maxY - minY)) * chartH;
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final chartW = size.width - marginLeft - marginRight;
    final chartH = size.height - marginTop - marginBottom;

    // ── 1. Background putih area grafik ──
    canvas.drawRect(
      Rect.fromLTWH(marginLeft, marginTop, chartW, chartH),
      Paint()..color = Colors.white,
    );

    // ── 2. Zona warna KMS ──
    _drawZones(canvas, size);

    // ── 3. Grid kotak kecil (seperti KMS asli) ──
    _drawGrid(canvas, size, chartW, chartH);

    // ── 4. Garis sumbu ──
    _drawAxes(canvas, size, chartW, chartH);

    // ── 5. Label sumbu X (usia dalam bulan) ──
    _drawXLabels(canvas, size, chartW, chartH);

    // ── 6. Label sumbu Y ──
    _drawYLabels(canvas, size, chartH);

    // ── 7. Garis & titik data anak ──
    _drawChildData(canvas, size);
  }

  void _drawZones(Canvas canvas, Size size) {
    if (kmsData.length < 2) return;

    // Zona Merah bawah: < -3SD (BGM)
    _drawBand(
      canvas,
      size,
      lower: kmsData.map((e) => e.sd3Neg * 0.0).toList(), // dasar 0
      upper: kmsData.map((e) => e.sd3Neg).toList(),
      color: const Color(0xFFE53935).withOpacity(0.75),
    );

    // Zona Kuning bawah: -3SD hingga -2SD
    _drawBand(
      canvas,
      size,
      lower: kmsData.map((e) => e.sd3Neg).toList(),
      upper: kmsData.map((e) => e.sd2Neg).toList(),
      color: const Color(0xFFFDD835).withOpacity(0.85),
    );

    // Zona Hijau muda: -2SD hingga -1SD (approx tengah bawah)
    _drawBand(
      canvas,
      size,
      lower: kmsData.map((e) => e.sd2Neg).toList(),
      upper: kmsData.map((e) => (e.sd2Neg + e.sd0) / 2).toList(),
      color: const Color(0xFF66BB6A).withOpacity(0.85),
    );

    // Zona Hijau tua (normal tengah): -1SD hingga +1SD (approx)
    _drawBand(
      canvas,
      size,
      lower: kmsData.map((e) => (e.sd2Neg + e.sd0) / 2).toList(),
      upper: kmsData.map((e) => (e.sd0 + e.sd2) / 2).toList(),
      color: const Color(0xFF2E7D32).withOpacity(0.85),
    );

    // Zona Hijau muda atas: +1SD hingga +2SD
    _drawBand(
      canvas,
      size,
      lower: kmsData.map((e) => (e.sd0 + e.sd2) / 2).toList(),
      upper: kmsData.map((e) => e.sd2).toList(),
      color: const Color(0xFF66BB6A).withOpacity(0.85),
    );

    // Zona Kuning atas: +2SD hingga +3SD
    _drawBand(
      canvas,
      size,
      lower: kmsData.map((e) => e.sd2).toList(),
      upper: kmsData.map((e) => e.sd3).toList(),
      color: const Color(0xFFFDD835).withOpacity(0.85),
    );
  }

  void _drawBand(
    Canvas canvas,
    Size size, {
    required List<double> lower,
    required List<double> upper,
    required Color color,
  }) {
    final path = Path();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < kmsData.length; i++) {
      final pt = toPixel(kmsData[i].usia.toDouble(), upper[i], size);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }

    for (int i = kmsData.length - 1; i >= 0; i--) {
      final pt = toPixel(kmsData[i].usia.toDouble(), lower[i], size);
      path.lineTo(pt.dx, pt.dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawGrid(Canvas canvas, Size size, double chartW, double chartH) {
    // Grid kotak kecil — setiap 1 bulan (x) dan per satuan kecil (y)
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.35)
      ..strokeWidth = 0.4;

    // Garis vertikal per bulan
    for (int usia = 0; usia <= maxUsia; usia++) {
      final x = marginLeft + (usia / maxUsia) * chartW;
      canvas.drawLine(
        Offset(x, marginTop),
        Offset(x, marginTop + chartH),
        gridPaint,
      );
    }

    // Garis horizontal per 1 unit (kg/cm)
    final range = maxY - minY;
    final step = range > 15 ? 2.0 : 1.0;
    double y = (minY / step).ceil() * step;
    while (y <= maxY) {
      final py = toPixel(0, y, size).dy;
      canvas.drawLine(
        Offset(marginLeft, py),
        Offset(marginLeft + chartW, py),
        gridPaint,
      );
      y += step;
    }
  }

  void _drawAxes(Canvas canvas, Size size, double chartW, double chartH) {
    final axisPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.5;

    // Sumbu X (bawah)
    canvas.drawLine(
      Offset(marginLeft, marginTop + chartH),
      Offset(marginLeft + chartW, marginTop + chartH),
      axisPaint,
    );

    // Sumbu Y (kiri)
    canvas.drawLine(
      Offset(marginLeft, marginTop),
      Offset(marginLeft, marginTop + chartH),
      axisPaint,
    );
  }

  void _drawXLabels(Canvas canvas, Size size, double chartW, double chartH) {
    // Label usia setiap 2 bulan
    for (int usia = 0; usia <= maxUsia; usia += 2) {
      final x = marginLeft + (usia / maxUsia) * chartW;
      final tp = TextPainter(
        text: TextSpan(
          text: '$usia',
          style: const TextStyle(fontSize: 9, color: Colors.black87),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(x - tp.width / 2, marginTop + chartH + 4));
    }

    // Label "Umur (Bulan)"
    final labelPainter = TextPainter(
      text: const TextSpan(
        text: 'Umur (Bulan)',
        style: TextStyle(fontSize: 9, color: Colors.black54),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    labelPainter.paint(
      canvas,
      Offset(
        marginLeft + chartW / 2 - labelPainter.width / 2,
        size.height - 12,
      ),
    );
  }

  void _drawYLabels(Canvas canvas, Size size, double chartH) {
    final range = maxY - minY;
    final step = range > 15 ? 2.0 : 1.0;
    double y = (minY / step).ceil() * step;

    while (y <= maxY) {
      final py = toPixel(0, y, size).dy;
      final label = y % 1 == 0 ? y.toInt().toString() : y.toStringAsFixed(1);

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(fontSize: 9, color: Colors.black87),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(marginLeft - tp.width - 4, py - tp.height / 2));
      y += step;
    }
  }

  void _drawChildData(Canvas canvas, Size size) {
    if (riwayat.isEmpty) return;

    final linePaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.fill;

    final sorted = [...riwayat]..sort((a, b) => a.tanggal.compareTo(b.tanggal));

    final path = Path();
    List<Offset> points = [];

    for (int i = 0; i < sorted.length; i++) {
      // Hitung usia dalam bulan (dari tanggal lahir yang harus tersedia)
      // Di sini diasumsikan usia dihitung di backend dan disimpan
      // Gunakan index sebagai fallback jika tidak ada field usia
      final usia = _estimasiUsia(sorted[i].tanggal);
      final nilai = getMetrikValue(sorted[i]);
      final pt = toPixel(usia.toDouble(), nilai, size);
      points.add(pt);

      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }

    canvas.drawPath(path, linePaint);

    for (final pt in points) {
      canvas.drawCircle(pt, 4, dotPaint);
      canvas.drawCircle(
        pt,
        4,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  // Estimasi usia bulan dari tanggal pengukuran
  // (dalam implementasi nyata, ambil dari tanggal lahir anak)
  double _estimasiUsia(DateTime tanggal) {
    final now = DateTime.now();
    return ((now.difference(tanggal).inDays) / 30).clamp(0, maxUsia.toDouble());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
