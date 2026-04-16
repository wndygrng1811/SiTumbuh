import 'package:flutter/material.dart';
import 'package:si_tumbuh/orangtua/profil.dart';

class DataAnakPage extends StatefulWidget {
  const DataAnakPage({super.key});

  @override
  State<DataAnakPage> createState() => _DataAnakPageState();
}

class _DataAnakPageState extends State<DataAnakPage> {
  List<Map<String, String>> dataAnak = [
    {
      "nama": "Raffi Ahmad",
      "jk": "Laki-laki",
      "tgl": "18 April 2026",
      "bb": "3.8 kg",
      "tb": "52 cm",
      "lk": "46 cm",
    },
  ];

  void showForm({int? index}) {
    TextEditingController nama = TextEditingController();
    TextEditingController jk = TextEditingController();
    TextEditingController tgl = TextEditingController();
    TextEditingController bb = TextEditingController();
    TextEditingController tb = TextEditingController();
    TextEditingController lk = TextEditingController();

    if (index != null) {
      nama.text = dataAnak[index]["nama"]!;
      jk.text = dataAnak[index]["jk"]!;
      tgl.text = dataAnak[index]["tgl"]!;
      bb.text = dataAnak[index]["bb"]!;
      tb.text = dataAnak[index]["tb"]!;
      lk.text = dataAnak[index]["lk"]!;
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(index == null ? "Tambah Anak" : "Edit Data Anak"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                buildInput(nama, "Nama Anak"),
                buildInput(jk, "Jenis Kelamin"),
                buildInput(tgl, "Tanggal Lahir"),
                buildInput(bb, "Berat Lahir"),
                buildInput(tb, "Tinggi Lahir"),
                buildInput(lk, "Lingkar Kepala"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE85D75),
              ),
              onPressed: () {
                if (index == null) {
                  setState(() {
                    dataAnak.add({
                      "nama": nama.text,
                      "jk": jk.text,
                      "tgl": tgl.text,
                      "bb": bb.text,
                      "tb": tb.text,
                      "lk": lk.text,
                    });
                  });
                } else {
                  setState(() {
                    dataAnak[index] = {
                      "nama": nama.text,
                      "jk": jk.text,
                      "tgl": tgl.text,
                      "bb": bb.text,
                      "tb": tb.text,
                      "lk": lk.text,
                    };
                  });
                }

                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Widget buildInput(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  void hapusData(int index) {
    setState(() {
      dataAnak.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      body: Column(
        children: [
          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 25,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFE85D75),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    /// PANAH KEMBALI KE PROFIL
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 10),

                    const Text(
                      "Data anak",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                const Text(
                  "Kelola informasi data anak anda",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// LIST DATA
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: dataAnak.length,
              itemBuilder: (context, index) {
                final anak = dataAnak[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(blurRadius: 6, color: Colors.black12),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                anak["nama"]!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(anak["jk"]!),
                            ],
                          ),

                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.pink,
                                ),
                                onPressed: () {
                                  showForm(index: index);
                                },
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  hapusData(index);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      buildInfo("Tanggal lahir", anak["tgl"]!),
                      buildInfo("Berat badan ketika lahir", anak["bb"]!),
                      buildInfo("Tinggi badan ketika lahir", anak["tb"]!),
                      buildInfo("Lingkar kepala ketika lahir", anak["lk"]!),
                    ],
                  ),
                );
              },
            ),
          ),

          /// BUTTON TAMBAH
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE85D75),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                showForm();
              },
              icon: const Icon(Icons.add),
              label: const Text("Tambah anak"),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
