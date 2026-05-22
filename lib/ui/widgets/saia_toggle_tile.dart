import 'package:flutter/material.dart';

/// Settings tile with a Switch trailing — toggle on/off pattern.
///
/// Used by capability pages, notification preferences, privacy toggles, etc.
/// Theme-driven, host-agnostic.
class SaiaToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SaiaToggleTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: scheme.primary, size: 22),
          title: Text(
            title,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                )
              : null,
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: scheme.primary,
            activeTrackColor: scheme.primary.withValues(alpha: 0.4),
            inactiveThumbColor: scheme.onSurfaceVariant.withValues(alpha: 0.6),
            inactiveTrackColor: scheme.surfaceContainerHighest,
          ),
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        ),
        Divider(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          height: 1,
          indent: 20,
          endIndent: 20,
        ),
      ],
    );
  }
}
