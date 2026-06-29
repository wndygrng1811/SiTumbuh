import 'package:flutter/material.dart';
import 'package:si_tumbuh/screens/splash/splash_screen.dart';
import 'package:si_tumbuh/Orangtua/halaman_utama.dart';
import 'package:si_tumbuh/Kader/halaman_utama_kader.dart';
import 'package:si_tumbuh/Kader/jadwal.dart';
import 'package:si_tumbuh/Orangtua/edukasi.dart';
import 'package:si_tumbuh/Orangtua/grafik.dart';
import 'package:si_tumbuh/widgets/notifikasi_page.dart';
import 'package:si_tumbuh/login.dart';
import 'package:si_tumbuh/daftar_akun.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SiTumbuh',
      theme: ThemeData(fontFamily: 'Inter', primarySwatch: Colors.pink),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map?;

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());

          case '/daftar':
            return MaterialPageRoute(builder: (_) => const DaftarAkunPage());

          case '/orangtua/home':
            return MaterialPageRoute(builder: (_) => const HalamanUtama());

          case '/kader/home':
            return MaterialPageRoute(builder: (_) => const HalamanUtamaKader());

          case '/kader/dashboard':
            return MaterialPageRoute(
              builder: (_) => HalamanUtamaKader(
                fromNotification: args?['fromNotification'] ?? false,
                notificationId: args?['notificationId'],
              ),
            );

          case '/jadwal':
            return MaterialPageRoute(
              builder: (_) => Jadwal(
                fromNotification: args?['fromNotification'] ?? false,
                notificationId: args?['notificationId'],
              ),
            );

          case '/edukasi':
            return MaterialPageRoute(
              builder: (_) => EdukasiPage(
                edukasiId: args?['edukasiId']?.toString(),
                fromNotification: args?['fromNotification'] ?? false,
                notificationId: args?['notificationId'],
              ),
            );

          case '/grafik':
            return MaterialPageRoute(
              builder: (_) => GrafikPage(
                anakId: args?['anakId'] ?? 0,
                namaAnak: args?['namaAnak'] ?? '',
                jenisKelamin: args?['jenisKelamin'] ?? '',
                fromNotification: args?['fromNotification'] ?? false,
                notificationId: args?['notificationId'],
                onChildChanged: args?['onChildChanged'],
              ),
            );

          case '/notifikasi':
            return MaterialPageRoute(
              builder: (_) => NotifikasiPage(role: args?['role'] ?? ''),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text(
                    'Halaman tidak ditemukan',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            );
        }
      },
      home: const SplashScreen(),
    );
  }
}
