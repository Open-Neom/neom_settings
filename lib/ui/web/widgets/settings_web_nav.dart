import 'package:flutter/material.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/ui/widgets/web/web_hover_card.dart';

class SettingsNavItem {
  final IconData icon;
  final String label;
  final String key;

  const SettingsNavItem({
    required this.icon,
    required this.label,
    required this.key,
  });
}

class SettingsWebNav extends StatelessWidget {

  final List<SettingsNavItem> items;
  final String activeKey;
  final ValueChanged<String> onItemTap;

  const SettingsWebNav({
    super.key,
    required this.items,
    required this.activeKey,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          final isActive = item.key == activeKey;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: WebHoverCard(
              onTap: () => onItemTap(item.key),
              borderRadius: BorderRadius.circular(8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              builder: (isHovered) => Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: isActive ? AppColor.bondiBlue : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 18,
                      color: isActive ? Colors.white : AppColor.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        item.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isActive ? Colors.white : AppColor.textSecondary,
                          fontSize: 14,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
