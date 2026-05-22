import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sint/sint.dart';

import 'saia_settings_controller.dart';
import 'widgets/saia_setting_header.dart';
import 'widgets/saia_setting_tile.dart';

/// Agnostic permissions settings page.
///
/// Shows the current OS permissions tracked by [SaiaSettingsController]
/// (location, microphone, photos, notification by default), with a tap
/// action that requests them. Theme-driven, host-agnostic.
///
/// The host wires this page in its `app_routes.dart` and pre-registers a
/// `SaiaSettingsController` (or a subclass like `ItzliSettingsController`)
/// before navigating. Translations are pulled from the host's labels via
/// the controller's [SaiaSettingsController.permissionLabel].
class SaiaPermissionsPage extends StatelessWidget {
  /// Optional title shown in the AppBar. Defaults to the localized
  /// `settingsPermissions` key when null.
  final String? title;

  /// Optional header copy displayed above the list. Defaults to
  /// `settingsPermHeader.tr`.
  final String? header;

  /// Optional footer copy displayed below the list. Defaults to
  /// `settingsPermFooter.tr`.
  final String? footer;

  const SaiaPermissionsPage({
    super.key,
    this.title,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Sint.find<SaiaSettingsController>();
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
          title ?? 'settingsPermissions'.tr,
          style: TextStyle(
            color: scheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: scheme.primary));
        }

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              children: [
                SaiaSettingHeader(
                  title: header ?? 'settingsPermHeader'.tr,
                ),
                ...ctrl.trackedPermissions.map((p) {
                  final status = ctrl.permissions[p] ?? PermissionStatus.denied;
                  return SaiaSettingTile(
                    icon: ctrl.permissionIcon(p),
                    title: ctrl.permissionLabel(p).tr,
                    subtitle: _statusLabel(status),
                    trailing: _buildStatusIndicator(scheme, status),
                    onTap: () => ctrl.requestPermission(p),
                  );
                }),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    footer ?? 'settingsPermFooter'.tr,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  String _statusLabel(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return 'Concedido';
      case PermissionStatus.denied:
        return 'Denegado';
      case PermissionStatus.permanentlyDenied:
        return 'Bloqueado';
      case PermissionStatus.restricted:
        return 'Restringido';
      case PermissionStatus.provisional:
        return 'Provisional';
    }
  }

  Widget _buildStatusIndicator(ColorScheme scheme, PermissionStatus status) {
    final isGranted = status == PermissionStatus.granted ||
        status == PermissionStatus.limited;

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isGranted ? Colors.green : scheme.error,
      ),
    );
  }
}
