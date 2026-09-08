import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aduana_801/core/theme/app_colors.dart';

class BreadcrumbItem {
  final String label;
  final String? route;
  BreadcrumbItem({required this.label, this.route});
}

class BreadcrumbNav extends StatelessWidget implements PreferredSizeWidget {
  final List<BreadcrumbItem> items;

  const BreadcrumbNav({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isLast = index == items.length - 1;

            final Widget textWidget = Text(
              item.label,
              style: TextStyle(
                color: isLast ? Colors.white : AppColors.blue,
                fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            );

            final Widget itemWidget = isLast
                ? textWidget
                : InkWell(
                    onTap: () {
                      if (item.route != null) {
                        context.go(item.route!);
                      }
                    },
                    child: textWidget,
                  );

            if (isLast) {
              return itemWidget;
            } else {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  itemWidget,
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.chevron_right,
                        size: 16, color: AppColors.sub),
                  ),
                ],
              );
            }
          }),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40.0);
}
