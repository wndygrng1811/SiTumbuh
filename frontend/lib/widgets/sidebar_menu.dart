import 'package:flutter/material.dart';
import 'package:si_tumbuh/orangtua/profil.dart';
import 'package:si_tumbuh/orangtua/data_anak.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Color(0xFFE85D75)),
            accountName: Text("Aisyah Ramadhani"),
            accountEmail: Text("aisyah@gmail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.pink),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profil"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.child_care),
            title: const Text("Data Anak"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DataAnakPage()),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Keluar"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
