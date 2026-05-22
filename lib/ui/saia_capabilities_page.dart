import 'package:flutter/material.dart';
import 'package:sint/sint.dart';

import 'saia_settings_controller.dart';
import 'widgets/saia_setting_header.dart';
import 'widgets/saia_toggle_tile.dart';

/// Declarative spec for a single capability toggle row.
///
/// `valueGetter` reads the current state from the host's
/// [SaiaSettingsController] (or subclass) so the page stays reactive
/// without coupling to specific field names. `capabilityKey` is the
/// string passed to `toggleCapability(...)` for persistence.
class SaiaCapabilityToggle {
  final IconData icon;
  final String title;
  final String subtitle;
  final String capabilityKey;
  final bool Function(SaiaSettingsController ctrl) valueGetter;

  const SaiaCapabilityToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.capabilityKey,
    required this.valueGetter,
  });
}

/// Agnostic capabilities page — renders a list of capability toggles
/// backed by [SaiaSettingsController.toggleCapability]. Hosts that need
/// extra sections (e.g. a tier-specific feature matrix) can pass
/// [trailing] widgets to be appended after the toggle list.
///
/// Example:
///
/// ```dart
/// SaiaCapabilitiesPage(
///   title: 'Capacidades',
///   header: 'Capacidades activas',
///   toggles: [
///     SaiaCapabilityToggle(
///       icon: Icons.travel_explore_outlined,
///       title: 'Búsqueda web',
///       subtitle: 'Permite consultar la web',
///       capabilityKey: 'webSearchEnabled',
///       valueGetter: (c) => c.webSearchEnabled.value,
///     ),
///     // ...
///   ],
///   trailing: [/* host-specific widgets like a feature matrix */],
/// )
/// ```
class SaiaCapabilitiesPage extends StatelessWidget {
  /// AppBar title. Defaults to `settingsCapabilities.tr`.
  final String? title;

  /// Header text shown above the toggle list. Defaults to
  /// `settingsCapHeader.tr`.
  final String? header;

  /// The toggles to render in order.
  final List<SaiaCapabilityToggle> toggles;

  /// Optional widgets appended after the toggle list (e.g. plan badge,
  /// feature matrix).
  final List<Widget> trailing;

  const SaiaCapabilitiesPage({
    super.key,
    required this.toggles,
    this.title,
    this.header,
    this.trailing = const [],
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ctrl = Sint.find<SaiaSettingsController>();

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
          title ?? 'settingsCapabilities'.tr,
          style: TextStyle(
            color: scheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() => Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                children: [
                  SaiaSettingHeader(
                    title: header ?? 'settingsCapHeader'.tr,
                  ),
                  for (final t in toggles)
                    SaiaToggleTile(
                      icon: t.icon,
                      title: t.title,
                      subtitle: t.subtitle,
                      value: t.valueGetter(ctrl),
                      onChanged: (v) => ctrl.toggleCapability(t.capabilityKey, v),
                    ),
                  ...trailing,
                ],
              ),
            ),
          )),
    );
  }
}
