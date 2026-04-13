import 'package:flutter/material.dart';

class InputDataAnak extends StatelessWidget {
  const InputDataAnak({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 10),

            Text(
              "Input Data Anak",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(child: Text("Daftar Anak")),
            ),

            SizedBox(height: 30),

            /// Data Anak
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Data Anak",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 15),
                    dataRow("Nama Anak"),
                    dataRow("Tanggal Lahir"),
                    dataRow("Jenis Kelamin"),
                    dataRow("Nama Orang Tua"),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            Text("Riwayat Data Balita"),
          ],
        ),
      ),
    );
  }

  Widget dataRow(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [Text(title), SizedBox(width: 10), Text(":")]),
    );
  }
}
