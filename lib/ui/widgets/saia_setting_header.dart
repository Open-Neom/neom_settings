import 'package:flutter/material.dart';

/// Section header for settings pages.
///
/// Renders an uppercase, accent-colored caption used to group tiles in
/// `SaiaSettingsPage`, `SaiaPermissionsPage`, `SaiaConnectorsPage`, etc.
///
/// Uses `Theme.of(context).colorScheme.primary` so the host theme drives
/// the look — agnostic of any host (Itzli, EMXI, Gigmeout, Cyberneom, ...).
class SaiaSettingHeader extends StatelessWidget {
  final String title;

  const SaiaSettingHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
