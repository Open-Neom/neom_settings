import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sint/sint.dart';

/// Agnostic settings controller for any host of the Open Neom ecosystem.
///
/// Owns the **generic** settings concerns:
///
///   - Tracked OS permissions (location, microphone, photos, notification)
///     with reactive status map and request flow.
///   - Capability toggles (web search, docs, images, voice, memory)
///     persisted to Hive under the host-supplied box name.
///
/// Host-specific concerns (subscription tier label/icon/color, gem
/// branding, premium-only multipliers, etc.) live in subclasses such as
/// `ItzliSettingsController extends SaiaSettingsController`. The host
/// passes its own [hiveBoxName] so each app keeps its preferences in a
/// distinct namespace (`itzli_profile`, `emxi_profile`, ...).
class SaiaSettingsController extends SintController {
  /// Hive box name used to persist capability toggles. Each host should
  /// pass a stable, unique value (e.g. `'itzli_profile'`).
  final String hiveBoxName;

  SaiaSettingsController({this.hiveBoxName = 'saia_profile'});

  // ─── Permissions (reactive) ───
  final RxMap<Permission, PermissionStatus> permissions =
      <Permission, PermissionStatus>{}.obs;

  // ─── Loading flag ───
  final RxBool isLoading = true.obs;

  // ─── Capability toggles (Hive-backed) ───
  final RxBool webSearchEnabled = true.obs;
  final RxBool docsEnabled = true.obs;
  final RxBool imagesEnabled = true.obs;
  final RxBool voiceEnabled = true.obs;
  final RxBool memoryEnabled = true.obs;

  /// OS permissions tracked by default. Subclasses can extend by
  /// overriding [trackedPermissions] (or by appending in their own init).
  static const List<Permission> defaultTrackedPermissions = [
    Permission.location,
    Permission.microphone,
    Permission.photos,
    Permission.notification,
  ];

  /// Override in a subclass to expand or restrict the tracked set.
  List<Permission> get trackedPermissions => defaultTrackedPermissions;

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    await Future.wait([
      loadPermissions(),
      loadCapabilities(),
    ]);
    isLoading.value = false;
  }

  // ═══════════════════════════════════════
  // Permissions
  // ═══════════════════════════════════════

  Future<void> loadPermissions() async {
    for (final p in trackedPermissions) {
      permissions[p] = await p.status;
    }
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    permissions[permission] = status;
  }

  /// Default Spanish labels — subclasses may override to customize per
  /// host or to hook the host's translation system.
  String permissionLabel(Permission permission) {
    switch (permission) {
      case Permission.location:
        return 'settingsPermLocation';
      case Permission.microphone:
        return 'settingsPermMicrophone';
      case Permission.photos:
        return 'settingsPermPhotos';
      case Permission.notification:
        return 'settingsPermNotifications';
      default:
        return permission.toString();
    }
  }

  IconData permissionIcon(Permission permission) {
    switch (permission) {
      case Permission.location:
        return Icons.location_on_outlined;
      case Permission.microphone:
        return Icons.mic_outlined;
      case Permission.photos:
        return Icons.photo_library_outlined;
      case Permission.notification:
        return Icons.notifications_outlined;
      default:
        return Icons.security_outlined;
    }
  }

  // ═══════════════════════════════════════
  // Capabilities (Hive-persisted)
  // ═══════════════════════════════════════

  Future<void> loadCapabilities() async {
    try {
      final box = await Hive.openBox(hiveBoxName);
      webSearchEnabled.value =
          box.get('webSearchEnabled', defaultValue: true) as bool;
      docsEnabled.value =
          box.get('docsEnabled', defaultValue: true) as bool;
      imagesEnabled.value =
          box.get('imagesEnabled', defaultValue: true) as bool;
      voiceEnabled.value =
          box.get('voiceEnabled', defaultValue: true) as bool;
      memoryEnabled.value =
          box.get('memoryEnabled', defaultValue: true) as bool;
    } catch (_) {
      // Defaults already set.
    }
  }

  Future<void> toggleCapability(String key, bool value) async {
    debugPrint('⚙️ [SaiaSettingsController] Toggling capability "$key" to: $value');
    switch (key) {
      case 'webSearchEnabled':
        webSearchEnabled.value = value;
      case 'docsEnabled':
        docsEnabled.value = value;
      case 'imagesEnabled':
        imagesEnabled.value = value;
      case 'voiceEnabled':
        voiceEnabled.value = value;
      case 'memoryEnabled':
        memoryEnabled.value = value;
    }
    try {
      final box = await Hive.openBox(hiveBoxName);
      await box.put(key, value);
      debugPrint('⚙️ [SaiaSettingsController] Capability "$key" successfully persisted with value: $value');
    } catch (e) {
      debugPrint('⚙️ [SaiaSettingsController] Failed to persist capability "$key" to Hive: $e');
    }
  }

  // ═══════════════════════════════════════
  // Format helpers
  // ═══════════════════════════════════════

  /// Pretty-print a duration as `Xh Ym` / `M min` / `Menos de 1 min`.
  String formatDuration(Duration d) {
    if (d.inMinutes < 1) return 'Menos de 1 min';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '$m min';
  }
}
