import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BreadcrumbItem {
  final String label;
  final String? route;
  const BreadcrumbItem({required this.label, this.route});
}

class BreadcrumbBar extends StatelessWidget {
  final List<BreadcrumbItem> items;
  const BreadcrumbBar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.home_outlined, size: 13, color: Color(0xFF6B7280)),
          const SizedBox(width: 4),
          ...List.generate(items.length, (i) {
            final item = items[i];
            final isLast = i == items.length - 1;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (i > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                _BreadcrumbLabel(item: item, isLast: isLast),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _BreadcrumbLabel extends StatelessWidget {
  final BreadcrumbItem item;
  final bool isLast;

  const _BreadcrumbLabel({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    if (isLast) {
      return Text(
        item.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    if (item.route != null) {
      return GestureDetector(
        onTap: () => context.go(item.route!),
        child: Text(
          item.label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dotted,
            decorationColor: Color(0xFF9CA3AF),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Text(
      item.label,
      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
      overflow: TextOverflow.ellipsis,
    );
  }
}
