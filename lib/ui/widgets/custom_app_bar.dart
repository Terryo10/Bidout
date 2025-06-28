import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: foregroundColor ?? AppColors.textPrimary,
            ),
      ),
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: foregroundColor ?? AppColors.textPrimary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
      actions: actions,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? AppColors.textPrimary,
      elevation: elevation,
      centerTitle: true,
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
