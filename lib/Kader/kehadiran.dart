import 'package:flutter/material.dart';
import '../widgets/sidebar_kader.dart';

class Kehadiran extends StatefulWidget {
  const Kehadiran({super.key});

  @override
  State<Kehadiran> createState() => _KehadiranState();
}

class _KehadiranState extends State<Kehadiran> {
  int selectedTab = 0;
  String filter = "semua";
  String search = "";

  List<Map<String, dynamic>> dataAnak = [
    {"nama": "Jesica Kristina", "hadir": true},
    {"nama": "Grace Anastasya", "hadir": true},
    {"nama": "Ameylia Sandi", "hadir": false},
    {"nama": "Karina Jakti", "hadir": true},
  ];

  List<Map<String, dynamic>> dataOrtu = [
    {"nama": "Ibu Jesica", "hadir": true},
    {"nama": "Ibu Grace", "hadir": false},
  ];

  List<Map<String, dynamic>> get data => selectedTab == 0 ? dataAnak : dataOrtu;

  void toggleAll(bool value) {
    setState(() {
      for (var item in data) {
        item["hadir"] = value;
      }
    });
  }

  void simpanData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data kehadiran berhasil disimpan")),
    );
  }

  @override
  Widget build(BuildContext context) {
    var filtered = data.where((item) {
      bool cocokNama = item["nama"].toLowerCase().contains(
        search.toLowerCase(),
      );

      if (filter == "hadir") return item["hadir"] && cocokNama;
      if (filter == "tidak") return !item["hadir"] && cocokNama;

      return cocokNama;
    }).toList();

    int hadir = data.where((e) => e["hadir"]).length;
    int tidak = data.where((e) => !e["hadir"]).length;

    return Scaffold(
      drawer: const SidebarKader(),
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFE85D75),
        elevation: 0,
        title: const Text("Kehadiran Posyandu"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            /// SEARCH + FILTER DROPDOWN
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari nama...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        search = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),

                /// DROPDOWN FILTER
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: DropdownButton<String>(
                    value: filter,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: "semua", child: Text("Semua")),
                      DropdownMenuItem(value: "hadir", child: Text("Hadir")),
                      DropdownMenuItem(value: "tidak", child: Text("Tidak")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        filter = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            /// TAB
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [tabButton("Anak", 0), tabButton("Orang Tua", 1)],
              ),
            ),

            const SizedBox(height: 15),

            /// COUNT CARD
            Row(
              children: [
                countCard("Hadir", hadir, Colors.green),
                const SizedBox(width: 10),
                countCard("Tidak", tidak, Colors.red),
              ],
            ),

            const SizedBox(height: 15),

            /// BUTTON
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => toggleAll(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Semua Hadir"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => toggleAll(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Reset"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            /// LIST
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.pink.shade50,
                          child: Text("${i + 1}"),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            filtered[i]["nama"],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Checkbox(
                          activeColor: const Color(0xFFE85D75),
                          value: filtered[i]["hadir"],
                          onChanged: (val) {
                            setState(() {
                              filtered[i]["hadir"] = val;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// SIMPAN
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE85D75),
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Simpan"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tabButton(String text, int index) {
    bool active = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE85D75) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget countCard(String title, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Text(
              "$value",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
