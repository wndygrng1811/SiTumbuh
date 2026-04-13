import 'package:flutter/material.dart';

class GrafikKMS extends StatelessWidget {
  final double umur;
  final double berat;

  const GrafikKMS({super.key, required this.umur, required this.berat});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GrafikPainter(umur, berat),
      size: Size.infinite,
    );
  }
}

class GrafikPainter extends CustomPainter {
  final double umur;
  final double berat;

  GrafikPainter(this.umur, this.berat);

  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;

    /// ==============================
    /// GRID
    /// ==============================

    Paint gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    for (int i = 0; i <= 6; i++) {
      double y = height / 6 * i;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    for (int i = 0; i <= 10; i++) {
      double x = width / 10 * i;
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }

    /// ==============================
    /// AREA KUNING ATAS
    /// ==============================

    Paint yellowPaint = Paint()
      ..color = Colors.yellow.shade600.withOpacity(0.6);

    Path yellowPath = Path();

    yellowPath.moveTo(0, height * 0.5);

    yellowPath.quadraticBezierTo(
      width * 0.5,
      height * 0.2,
      width,
      height * 0.1,
    );

    yellowPath.lineTo(width, height * 0.35);

    yellowPath.quadraticBezierTo(width * 0.5, height * 0.45, 0, height * 0.65);

    yellowPath.close();

    canvas.drawPath(yellowPath, yellowPaint);

    /// ==============================
    /// AREA HIJAU (NORMAL)
    /// ==============================

    Paint greenPaint = Paint()..color = Colors.green.withOpacity(0.6);

    Path greenPath = Path();

    greenPath.moveTo(0, height * 0.65);

    greenPath.quadraticBezierTo(
      width * 0.5,
      height * 0.45,
      width,
      height * 0.35,
    );

    greenPath.lineTo(width, height * 0.6);

    greenPath.quadraticBezierTo(width * 0.5, height * 0.75, 0, height * 0.85);

    greenPath.close();

    canvas.drawPath(greenPath, greenPaint);

    /// ==============================
    /// AREA KUNING BAWAH
    /// ==============================

    Paint yellowPaint2 = Paint()
      ..color = Colors.yellow.shade600.withOpacity(0.6);

    Path yellowPath2 = Path();

    yellowPath2.moveTo(0, height * 0.85);

    yellowPath2.quadraticBezierTo(
      width * 0.5,
      height * 0.75,
      width,
      height * 0.6,
    );

    yellowPath2.lineTo(width, height);

    yellowPath2.lineTo(0, height);

    yellowPath2.close();

    canvas.drawPath(yellowPath2, yellowPaint2);

    /// ==============================
    /// HITUNG POSISI DATA ANAK
    /// ==============================

    double maxUmur = 60;
    double maxBerat = 20;

    double x = (umur / maxUmur) * width;
    double y = height - (berat / maxBerat) * height;

    /// ==============================
    /// TITIK DATA ANAK
    /// ==============================

    Paint pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), 6, pointPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
