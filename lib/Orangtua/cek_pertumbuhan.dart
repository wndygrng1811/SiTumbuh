import 'package:flutter/material.dart';
import 'dart:math';

class CekPertumbuhanPage extends StatefulWidget {
  const CekPertumbuhanPage({super.key});

  @override
  State<CekPertumbuhanPage> createState() => _CekPertumbuhanPageState();
}

class _CekPertumbuhanPageState extends State<CekPertumbuhanPage> {
  final usia = TextEditingController();
  final bb = TextEditingController();
  final tb = TextEditingController();
  final lk = TextEditingController();

  String statusUtama = "";
  String deskripsi = "";

  String statusTB = "-";
  String statusBB = "-";
  String statusIMT = "-";
  String statusLK = "-";

  Color warnaUtama = Colors.pink;

  void cekPertumbuhan() {
    double usiaAnak = double.parse(usia.text);
    double berat = double.parse(bb.text);
    double tinggi = double.parse(tb.text);
    double kepala = double.parse(lk.text);

    /// IMT
    double meter = tinggi / 100;
    double imt = berat / pow(meter, 2);

    /// =============================
    /// TINGGI BADAN / USIA
    /// =============================

    if (tinggi < 85 && usiaAnak > 24) {
      statusTB = "Pendek";
    } else {
      statusTB = "Tinggi";
    }

    /// =============================
    /// BERAT BADAN / USIA
    /// =============================

    if (berat < 10) {
      statusBB = "Kurus";
    } else if (berat < 15) {
      statusBB = "Normal";
    } else {
      statusBB = "Obesitas";
    }

    /// =============================
    /// IMT
    /// =============================

    if (imt < 14) {
      statusIMT = "Kurus";
    } else if (imt < 18) {
      statusIMT = "Normal";
    } else {
      statusIMT = "Obesitas";
    }

    /// =============================
    /// LINGKAR KEPALA
    /// =============================

    if (kepala < 45) {
      statusLK = "Kecil";
    } else if (kepala <= 52) {
      statusLK = "Normal";
    } else {
      statusLK = "Makrosefali";
    }

    /// =============================
    /// STATUS UTAMA
    /// =============================

    if (statusBB == "Obesitas") {
      statusUtama = "Gizi lebih - Perlu diperhatikan";

      deskripsi =
          "Anak menunjukkan kelebihan gizi. Perhatikan pola makan dan konsultasikan ke ahli gizi.";

      warnaUtama = Colors.red;
    } else if (statusTB == "Pendek") {
      statusUtama = "Risiko Stunting";

      deskripsi = "Tinggi badan anak berada di bawah standar untuk usianya.";

      warnaUtama = Colors.orange;
    } else {
      statusUtama = "Pertumbuhan Normal";

      deskripsi = "Pertumbuhan anak berada dalam rentang normal.";

      warnaUtama = Colors.green;
    }

    setState(() {});
  }

  /// INPUT FIELD
  Widget inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,

        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  /// BADGE STATUS
  Widget badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  /// ROW DETAIL
  Widget detailRow(String title, String status, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title), badge(status, color)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("SiTumbuh", style: TextStyle(color: Colors.pink)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          const Text(
            "Hallo, Bunda!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const Text(
            "Pantau tumbuh kembang anak anda hari ini.",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 20),

          /// =============================
          /// CARD HASIL UTAMA
          /// =============================
          if (statusUtama != "")
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.pink[200],
                borderRadius: BorderRadius.circular(16),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.health_and_safety,
                    size: 50,
                    color: Colors.white,
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusUtama,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(deskripsi),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          /// =============================
          /// FORM INPUT
          /// =============================
          inputField("Usia Anak (bulan)", usia),
          inputField("Berat Badan (kg)", bb),
          inputField("Tinggi Badan (cm)", tb),
          inputField("Lingkar Kepala (cm)", lk),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              padding: const EdgeInsets.all(14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: cekPertumbuhan,
            child: const Text("Cek Pertumbuhan"),
          ),

          const SizedBox(height: 20),

          /// =============================
          /// DETAIL PEMERIKSAAN
          /// =============================
          if (statusTB != "-")
            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.pink[200],
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Detail Hasil Pemeriksaan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  detailRow("Tinggi badan / Usia", statusTB, Colors.orange),
                  detailRow("Berat badan / Usia", statusBB, Colors.red),
                  detailRow("IMT / Usia", statusIMT, Colors.pink),
                  detailRow("Lingkar kepala / Usia", statusLK, Colors.purple),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
