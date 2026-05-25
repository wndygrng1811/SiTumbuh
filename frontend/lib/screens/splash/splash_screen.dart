import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/login.dart';
import 'package:si_tumbuh/Orangtua/halaman_utama.dart';
import 'package:si_tumbuh/kader/halaman_utama_kader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controller untuk logo (fade + scale + slide dari bawah)
  late AnimationController _logoController;

  // Controller untuk teks subtitle (muncul setelah logo)
  late AnimationController _textController;

  // Controller untuk dot bouncing (loop terus)
  late AnimationController _dotController;

  // Logo animations
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<Offset> _logoSlide;

  // Text animations
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;

  @override
  void initState() {
    super.initState();

    // Paksa status bar transparan agar tidak ada kedipan putih di atas
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // --- Logo Controller: 900ms ---
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 1.0, curve: Curves.elasticOut),
      ),
    );

    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _logoController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    // --- Text Controller: mulai setelah logo selesai ---
    _textController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // --- Dot Controller: smooth infinite loop ---
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    // Jalankan animasi logo, lalu teks
    _logoController.forward().then((_) {
      _textController.forward();
    });

    // Cek autentikasi setelah 3.5 detik
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(milliseconds: 3500));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');

    if (!mounted) return;

    if (role == 'orang_tua') {
      Navigator.pushReplacement(context, _buildPageRoute(HalamanUtama()));
    } else if (role == 'kader') {
      Navigator.pushReplacement(context, _buildPageRoute(HalamanUtamaKader()));
    } else {
      Navigator.pushReplacement(context, _buildPageRoute(const LoginPage()));
    }
  }

  /// Transisi halus saat pindah halaman
  PageRouteBuilder _buildPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Dot dengan animasi sin() untuk bounce yang benar-benar smooth
  Widget _animatedDot(int index) {
    final bool isCenter = index == 1;

    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, child) {
        // Setiap dot punya phase offset supaya berurutan
        final phase = _dotController.value * 2 * pi - (index * (2 * pi / 3));
        // sin menghasilkan nilai -1..1, kita pakai untuk bounce ke atas
        final bounce = sin(phase);
        // Hanya gerak ke atas (nilai positif = naik)
        final offset = bounce > 0 ? bounce * 10.0 : 0.0;

        // Opacity dot ikut animasi juga untuk efek "pulse"
        final opacity = 0.4 + (bounce > 0 ? bounce * 0.6 : 0.0);

        return Transform.translate(
          offset: Offset(0, -offset),
          child: Opacity(opacity: opacity.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        width: isCenter ? 14 : 12,
        height: isCenter ? 14 : 12,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isCenter ? const Color(0xFFD97A89) : const Color(0xFFE8B0BB),
          shape: BoxShape.circle,
          boxShadow: isCenter
              ? [
                  BoxShadow(
                    color: const Color(0xFFD97A89).withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background warna langsung (tanpa Material delay) agar tidak ada layar putih
      backgroundColor: const Color(0xFFEFBFC8),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE6B3BE), Color(0xFFF7F0F2), Color(0xFFE8C2CA)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Logo dengan animasi slide + scale + fade ──
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _logoFade,
                    child: SlideTransition(
                      position: _logoSlide,
                      child: ScaleTransition(scale: _logoScale, child: child),
                    ),
                  );
                },
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD97A89).withOpacity(0.25),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset('assets/logo.png'),
                ),
              ),

              const SizedBox(height: 28),

              // ── Judul & Subtitle ──
              SlideTransition(
                position: _titleSlide,
                child: FadeTransition(
                  opacity: _titleFade,
                  child: const Text(
                    'SiTumbuh',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFD95F82),
                      letterSpacing: 0.5,
                      height: 1.0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              FadeTransition(
                opacity: _subtitleFade,
                child: const Text(
                  'Pantau tumbuh kembang\nanak dengan mudah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFAA8890),
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // ── Tiga titik bouncing ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_animatedDot(0), _animatedDot(1), _animatedDot(2)],
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
