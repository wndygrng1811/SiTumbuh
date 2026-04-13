import 'package:flutter/material.dart';
import '../widgets/sidebar_kader.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  String nama = "Kader Siti";
  String email = "kader@email.com";
  String telp = "08123456789";
  String alamat = "Batam";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarKader(),
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFE85D75),
        elevation: 0,
        title: const Text("Profil"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// HEADER PROFIL
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE85D75),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFFE85D75),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(email, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// DATA CARD
            infoCard(Icons.person, "Nama", nama),
            infoCard(Icons.email, "Email", email),
            infoCard(Icons.phone, "No Telepon", telp),
            infoCard(Icons.location_on, "Alamat", alamat),

            const SizedBox(height: 20),

            /// BUTTON EDIT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => showEditDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE85D75),
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Edit Profil"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= POPUP =================
  void showEditDialog(BuildContext context) {
    final namaC = TextEditingController(text: nama);
    final emailC = TextEditingController(text: email);
    final telpC = TextEditingController(text: telp);
    final alamatC = TextEditingController(text: alamat);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Edit Profil"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              input(namaC, "Nama"),
              input(emailC, "Email"),
              input(telpC, "No Telepon"),
              input(alamatC, "Alamat"),
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
              setState(() {
                nama = namaC.text;
                email = emailC.text;
                telp = telpC.text;
                alamat = alamatC.text;
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profil berhasil diupdate")),
              );
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  /// ================= UI =================
  Widget infoCard(IconData icon, String title, String value) {
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
          Icon(icon, color: const Color(0xFFE85D75)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget input(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
