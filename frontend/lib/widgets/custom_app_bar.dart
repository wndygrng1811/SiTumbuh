import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_tumbuh/services/api_service.dart';
import 'package:si_tumbuh/widgets/notifikasi_page.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Color? backgroundColor;
  final Color? iconColor;
  final bool showBackButton;
  final bool showDrawerIcon;
  final bool showNotificationIcon;

  const CustomAppBar({
    super.key,
    this.backgroundColor,
    this.iconColor,
    this.showBackButton = false,
    this.showDrawerIcon = true,
    this.showNotificationIcon = true,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  int _unreadCount = 0;
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String role = prefs.getString('role') ?? '';
    setState(() {
      _userRole = role;
    });

    // Load notifikasi untuk semua role (tapi kader akan dapat 0)
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final data = await ApiService.getNotifikasi();
      final count = data.where((n) => n['is_read'] == 0).length;
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      print('Error load unread count: $e');
    }
  }

  Future<void> _refreshUnreadCount() async {
    await _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Warna background TIDAK diubah, tetap dari parameter / default-nya
        color: widget.backgroundColor ?? const Color(0xFFE85D75),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AppBar(
        title: const Text(
          'SiTumbuh',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.4,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        leading: _buildLeading(context),
        actions: _buildActions(context),
        automaticallyImplyLeading: false,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (widget.showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        splashRadius: 22,
        onPressed: () => Navigator.pop(context),
      );
    } else if (widget.showDrawerIcon) {
      return Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
          splashRadius: 22,
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      );
    }
    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (widget.showNotificationIcon) {
      return [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 24,
              ),
              splashRadius: 22,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotifikasiPage(),
                  ),
                );
                if (result == true) {
                  _refreshUnreadCount();
                }
              },
            ),
            if (_unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.9),
                      width: 1.2,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    _unreadCount > 9 ? '9+' : '$_unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ];
    }
    return null;
  }
}
