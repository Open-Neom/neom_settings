import 'package:flutter/material.dart';

/// Tappable settings tile with leading icon, title, optional subtitle and
/// optional trailing widget. Used as the base building block for
/// `SaiaSettingsPage`, `SaiaConnectorsPage`, `SaiaPermissionsPage`, etc.
///
/// Pure Flutter — uses `Theme.of(context).colorScheme` so any host theme
/// drives the look. Agnostic of any specific app.
class SaiaSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SaiaSettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
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
          trailing: trailing ??
              Icon(
                Icons.chevron_right,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                size: 20,
              ),
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onTap: onTap,
          hoverColor: scheme.surfaceContainerHighest,
          splashColor: scheme.primary.withValues(alpha: 0.1),
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
