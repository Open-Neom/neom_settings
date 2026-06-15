import 'package:flutter/material.dart';
import 'package:sint/sint.dart';

import 'widgets/saia_setting_header.dart';
import 'widgets/saia_setting_tile.dart';

/// A single connector entry shown by [SaiaConnectorsPage].
///
/// `route` is the navigation target (passed to `Sint.toNamed`). When
/// null the tile is rendered as informational only (no tap action).
/// `statusIndicator` is an optional widget shown in the trailing slot
/// (typically a colored dot for online/offline status).
class SaiaConnectorItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? route;
  final Widget? statusIndicator;
  final bool locked;

  const SaiaConnectorItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.route,
    this.statusIndicator,
    this.locked = false,
  });
}

/// A grouped section of [SaiaConnectorItem]s with a header.
class SaiaConnectorSection {
  final String headerTitle;
  final List<SaiaConnectorItem> items;

  const SaiaConnectorSection({
    required this.headerTitle,
    required this.items,
  });
}

/// Agnostic connectors settings page.
///
/// Renders a list of [SaiaConnectorSection]s the host declares — Itzli
/// passes its specific connectors (RC daemon, Firestore, Cloud
/// Drive, custom APIs); EMXI / Gigmeout / Cyberneom can do the same with
/// their own connector lists.
///
/// Theme-driven, host-agnostic. The host owns the route names; this page
/// simply navigates to whatever string the connector item carries.
class SaiaConnectorsPage extends StatelessWidget {
  /// The connector sections to render. Order is preserved.
  final List<SaiaConnectorSection> sections;

  /// Optional title shown in the AppBar. Defaults to `settingsConnectors.tr`.
  final String? title;

  const SaiaConnectorsPage({
    super.key,
    required this.sections,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.onSurface),
          onPressed: () => Sint.back(),
        ),
        title: Text(
          title ?? 'settingsConnectors'.tr,
          style: TextStyle(
            color: scheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            children: [
              for (var i = 0; i < sections.length; i++) ...[
                if (i > 0) const SizedBox(height: 24),
                SaiaSettingHeader(title: sections[i].headerTitle),
                ...sections[i].items.map((item) => SaiaSettingTile(
                      icon: item.icon,
                      title: item.title,
                      subtitle: item.subtitle,
                      trailing: item.locked
                          ? Icon(
                              Icons.lock_outline,
                              color: scheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                              size: 18,
                            )
                          : item.statusIndicator ??
                              (item.route != null
                                  ? Icon(
                                      Icons.chevron_right,
                                      color: scheme.onSurfaceVariant
                                          .withValues(alpha: 0.6),
                                      size: 18,
                                    )
                                  : null),
                      onTap: item.route != null && !item.locked
                          ? () => Sint.toNamed(item.route!)
                          : null,
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Helper used by hosts to build a colored online/offline dot.
  static Widget statusDot({required bool online, ColorScheme? scheme}) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: online ? Colors.green : (scheme?.error ?? Colors.red),
      ),
    );
  }
}
