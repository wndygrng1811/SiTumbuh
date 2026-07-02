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
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';

    setState(() {
      _userRole = role;
    });

    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 1;
      final role = prefs.getString('role') ?? '';

      final data = await ApiService.getNotifikasi(userId: userId, role: role);

      final count = data.where((n) => n['is_read'] == 0).length;

      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      debugPrint('Error load unread count: $e');
    }
  }

  Future<void> _refreshUnreadCount() async {
    await _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: const Text(
        'SiTumbuh',
        style: TextStyle(
          color: Color(0xFF76172D),
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: 0.4,
        ),
      ),
      leading: _buildLeading(context),
      actions: _buildActions(context),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (widget.showBackButton) {
      return IconButton(
        splashRadius: 22,
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Color(0xFF76172D),
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      );
    } else if (widget.showDrawerIcon) {
      return Builder(
        builder: (context) => IconButton(
          splashRadius: 22,
          icon: const Icon(
            Icons.menu_rounded,
            color: Color(0xFF76172D),
            size: 24,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (!widget.showNotificationIcon) return null;

    return [
      Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            splashRadius: 22,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF76172D),
              size: 24,
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotifikasiPage(role: _userRole),
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
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
}
