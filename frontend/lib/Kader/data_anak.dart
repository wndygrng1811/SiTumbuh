import 'package:flutter/material.dart';
import '../widgets/sidebar_kader.dart';
import '../widgets/bottom_navbar_kader.dart';

class DataAnakPage extends StatefulWidget {
  const DataAnakPage({super.key});

  @override
  State<DataAnakPage> createState() => _DataAnakPageState();
}

class _DataAnakPageState extends State<DataAnakPage> {
  List<Map<String, String>> anakList = [
    {
      "nama": "Rizky Febian",
      "jk": "Laki-laki",
      "tanggal": "30 Maret 2026",
      "tb": "32",
      "bb": "42",
      "lk": "34",
      "ortu": "Aisyah",
    },
    {
      "nama": "Alex Setiawan",
      "jk": "Laki-laki",
      "tanggal": "15 Desember 2025",
      "tb": "30",
      "bb": "39",
      "lk": "32",
      "ortu": "Aisyah",
    },
    {
      "nama": "Diana Veroz",
      "jk": "Laki-laki",
      "tanggal": "22 Oktober 2025",
      "tb": "40",
      "bb": "56",
      "lk": "35",
      "ortu": "Aisyah",
    },
  ];

  List<String> listOrtu = ["Aisyah", "Rahmawati", "Gunawan"];
  List<String> listJK = ["Laki-laki", "Perempuan"];

  /// ================= FORM POPUP =================
  void showForm({Map<String, String>? data}) {
    TextEditingController nama = TextEditingController(text: data?["nama"]);
    TextEditingController tanggal = TextEditingController(
      text: data?["tanggal"],
    );
    TextEditingController tb = TextEditingController(text: data?["tb"]);
    TextEditingController bb = TextEditingController(text: data?["bb"]);
    TextEditingController lk = TextEditingController(text: data?["lk"]);

    String selectedJK = data?["jk"] ?? "Laki-laki";
    String selectedOrtu = data?["ortu"] ?? "Aisyah";

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC0CB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// TITLE + CLOSE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data == null ? "Tambah Anak" : "Edit Data Anak",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    field("Nama Lengkap", nama),
                    field("Tanggal Lahir", tanggal),

                    dropdown(
                      "Jenis Kelamin",
                      selectedJK,
                      listJK,
                      (val) => setStateDialog(() => selectedJK = val),
                    ),

                    field("Berat Badan (kg)", bb),
                    field("Tinggi Badan (cm)", tb),
                    field("Lingkar Kepala (cm)", lk),

                    dropdown(
                      "Nama Orang Tua",
                      selectedOrtu,
                      listOrtu,
                      (val) => setStateDialog(() => selectedOrtu = val),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (data == null) {
                            anakList.add({
                              "nama": nama.text,
                              "tanggal": tanggal.text,
                              "tb": tb.text,
                              "bb": bb.text,
                              "lk": lk.text,
                              "ortu": selectedOrtu,
                              "jk": selectedJK,
                            });
                          } else {
                            data["nama"] = nama.text;
                            data["tanggal"] = tanggal.text;
                            data["tb"] = tb.text;
                            data["bb"] = bb.text;
                            data["lk"] = lk.text;
                            data["ortu"] = selectedOrtu;
                            data["jk"] = selectedJK;
                          }
                        });

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD86487),
                        minimumSize: const Size(120, 40),
                      ),
                      child: const Text("Simpan"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ================= DETAIL =================
  void showDetail(Map<String, String> data) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC0CB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Detail Anak",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                data["nama"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text("${data["jk"]} • ${data["tanggal"]}"),

              const Divider(),

              Text("TB: ${data["tb"]} cm"),
              Text("BB: ${data["bb"]} kg"),
              Text("LK: ${data["lk"]} cm"),
              Text("Orang tua: ${data["ortu"]}"),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= WIDGET =================
  Widget field(String hint, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget dropdown(
    String hint,
    String value,
    List<String> list,
    Function(String) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        items: list
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) => onChanged(val!),
      ),
    );
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavbarKader(selectedIndex: 1),
      backgroundColor: const Color(0xFFF5EDEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD86487),
        title: const Text("Kelola Data Anak"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () => showForm(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD86487),
              minimumSize: const Size(220, 50),
            ),
            child: const Text("+Tambah anak"),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: anakList.length,
              itemBuilder: (context, i) {
                var d = anakList[i];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 5),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d["nama"]!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("${d["jk"]} • ${d["tanggal"]}"),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Text("TB: ${d["tb"]} cm"),
                          const SizedBox(width: 10),
                          Text("BB: ${d["bb"]} kg"),
                          const SizedBox(width: 10),
                          Text("LK: ${d["lk"]} cm"),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text("Orang tua: ${d["ortu"]}"),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => showDetail(d),
                            child: const Text("Detail"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => showForm(data: d),
                            child: const Text("Ubah"),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                anakList.removeAt(i);
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
