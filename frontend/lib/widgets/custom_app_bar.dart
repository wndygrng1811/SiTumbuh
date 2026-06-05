import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;
  final bool showBackButton;
  final List<Widget>? actions;
  final double elevation;
  final bool showDrawerIcon;
  final bool showNotificationIcon;

  const CustomAppBar({
    super.key,
    this.title,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.showBackButton = false,
    this.actions,
    this.elevation = 0,
    this.showDrawerIcon = true,
    this.showNotificationIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title ?? 'SiTumbuh',
        style: TextStyle(
          color: titleColor ?? const Color(0xFF76172D),
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      backgroundColor: backgroundColor ?? const Color(0xFFFFF5F7),
      elevation: elevation,
      leading: _buildLeading(context),
      actions: _buildActions(),
      automaticallyImplyLeading:
          false, // 🔥 Tambahkan ini untuk mencegah double leading
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (showBackButton) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: iconColor ?? const Color(0xFF76172D),
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      );
    } else if (showDrawerIcon) {
      return Builder(
        builder: (context) => IconButton(
          icon: Icon(
            Icons.menu,
            color: iconColor ?? const Color(0xFF76172D),
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

  List<Widget>? _buildActions() {
    if (actions != null) return actions;

    if (showNotificationIcon) {
      return [
        IconButton(
          icon: Icon(
            Icons.notifications_none,
            color: iconColor ?? const Color(0xFF76172D),
            size: 24,
          ),
          onPressed: () {
            // TODO: Navigasi ke halaman notifikasi
          },
        ),
        const SizedBox(width: 8),
      ];
    }
    return null;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
