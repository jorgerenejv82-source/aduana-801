import 'package:flutter/material.dart';
import '../../features/home/widgets/breadcrumb_nav.dart';
import '../theme/app_colors.dart';

class StandardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final List<BreadcrumbItem>? breadcrumbs;
  final Color? backgroundColor;

  const StandardAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.showBack = true,
    this.breadcrumbs,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.card,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: leading ??
          (showBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.gold),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.sub,
                fontSize: 12,
              ),
            ),
        ],
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize:
            Size.fromHeight((breadcrumbs != null ? 28.0 : 0.0) + 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (breadcrumbs != null)
              SizedBox(
                height: 28,
                child: BreadcrumbNav(items: breadcrumbs!),
              ),
            Container(
              height: 1.0,
              color: AppColors.border,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (breadcrumbs != null ? 28.0 : 0.0) + 1.0);
}
