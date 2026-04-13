import 'package:flutter/material.dart';

class ProfilLengkapPage extends StatelessWidget {
  const ProfilLengkapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFF1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6EFF1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF7A1C2E)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Profil lengkap",
          style: TextStyle(
            color: Color(0xFF7A1C2E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),

          // 🔥 AVATAR
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF7A1C2E),
            child: const Icon(Icons.person, color: Colors.white, size: 50),
          ),

          const SizedBox(height: 12),

          const Text(
            "Aisyah Ramadhani",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF5A2A2A),
            ),
          ),

          const Text(
            "Data diri & kontak anda",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 20),

          // 🔥 CARD INFO
          _item(Icons.email, "Email", "aisyah@gmail.com"),
          _item(Icons.phone, "Nomor HP", "081234567890"),
          _item(Icons.location_on, "Alamat", "Jl. Mawar No. 12, Jakarta"),
        ],
      ),
    );
  }

  static Widget _item(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE5E7),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD86487)),
          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A1C2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Color(0xFF5A2A2A))),
            ],
          ),
        ],
      ),
    );
  }
}
