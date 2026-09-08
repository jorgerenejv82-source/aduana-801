import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _card = AppColors.card;
const _gold = AppColors.gold;
const _text = AppColors.text;
const _sub = AppColors.sub;
const _border = AppColors.border;

class RecentActivityTracker {
  static final List<RecentItem> _items = [];

  static void record(String route, String title, IconData icon) {
    _items.removeWhere((e) => e.route == route);
    _items.insert(0, RecentItem(route: route, title: title, icon: icon));
    if (_items.length > 8) _items.removeLast();
  }

  static void remove(String route) {
    _items.removeWhere((e) => e.route == route);
  }

  static List<RecentItem> getRecents() => List.from(_items);
}

class RecentItem {
  final String route, title;
  final IconData icon;
  RecentItem({required this.route, required this.title, required this.icon});
}

class RecentChips extends StatefulWidget {
  const RecentChips({super.key});

  @override
  State<RecentChips> createState() => _RecentChipsState();
}

class _RecentChipsState extends State<RecentChips> {
  @override
  Widget build(BuildContext context) {
    final recents = RecentActivityTracker.getRecents();
    if (recents.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.access_time, color: _sub, size: 16),
            SizedBox(width: 8),
            Text(
              'Continúa donde quedaste',
              style: TextStyle(
                  color: _sub, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recents.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = recents[index];
              return _RecentChip(
                item: item,
                onTap: () {
                  RecentActivityTracker.record(
                      item.route, item.title, item.icon);
                  context.go(item.route);
                },
                onRemove: () {
                  setState(() {
                    RecentActivityTracker.remove(item.route);
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentChip extends StatefulWidget {
  final RecentItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentChip({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  @override
  State<_RecentChip> createState() => _RecentChipState();
}

class _RecentChipState extends State<_RecentChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? _gold : _border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.item.icon,
                  size: 16, color: _isHovered ? _gold : _sub),
              const SizedBox(width: 8),
              Text(
                widget.item.title,
                style: TextStyle(
                  color: _isHovered ? _text : _sub,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.onRemove,
                child: const Icon(Icons.close, size: 14, color: _sub),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
