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
    return AppBar(
      title: const Text(
        'SiTumbuh',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      backgroundColor: widget.backgroundColor ?? const Color(0xFFE85D75),
      elevation: 0,
      leading: _buildLeading(context),
      actions: _buildActions(context),
      automaticallyImplyLeading: false,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (widget.showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      );
    } else if (widget.showDrawerIcon) {
      return Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 24),
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
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 24,
              ),
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
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
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
