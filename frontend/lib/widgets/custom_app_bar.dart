import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;
  final bool showBackButton;
  final List<Widget>? actions;
  final double elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.showBackButton = true,
    this.actions,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? const Color(0xFF76172D),
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      backgroundColor: backgroundColor ?? const Color(0xFFFFF5F7),
      elevation: elevation,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: iconColor ?? const Color(0xFF76172D),
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
