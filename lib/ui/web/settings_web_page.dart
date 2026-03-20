import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neom_commons/app_flavour.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/ui/theme/app_theme.dart';
import 'package:neom_commons/ui/widgets/title_subtitle_row.dart';
import 'package:neom_commons/ui/widgets/web/web_keyboard_manager.dart';
import 'package:neom_commons/ui/widgets/web/web_theme_constants.dart';
import 'package:neom_commons/utils/constants/translations/app_translation_constants.dart';
import 'package:neom_commons/utils/constants/translations/common_translation_constants.dart';
import 'package:neom_commons/utils/external_utilities.dart';
import 'package:neom_core/app_properties.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';
import 'package:neom_core/utils/enums/user_role.dart';
import 'package:sint/sint.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/constants/setting_translation_constants.dart';
import '../settings_controller.dart';
import '../widgets/error_log_summary_widget.dart';
import 'widgets/settings_web_nav.dart';
import 'widgets/settings_web_section.dart';

class SettingsWebPage extends StatefulWidget {

  final SettingsController controller;

  const SettingsWebPage({super.key, required this.controller});

  @override
  State<SettingsWebPage> createState() => _SettingsWebPageState();
}

class _SettingsWebPageState extends State<SettingsWebPage> {

  String _activeSection = 'account';

  List<SettingsNavItem> get _navItems => [
    SettingsNavItem(icon: Icons.person_outline, label: SettingTranslationConstants.account.tr, key: 'account'),
    SettingsNavItem(icon: Icons.lock_outline, label: SettingTranslationConstants.privacyAndPolicy.tr, key: 'privacy'),
    SettingsNavItem(icon: Icons.tune, label: SettingTranslationConstants.contentPreferences.tr, key: 'content'),
    SettingsNavItem(icon: Icons.info_outline, label: CommonTranslationConstants.aboutApp.tr, key: 'about'),
    SettingsNavItem(icon: Icons.mail_outline, label: AppTranslationConstants.contactUs.tr, key: 'contact'),
    if (widget.controller.userServiceImpl.user.userRole != UserRole.subscriber)
      SettingsNavItem(icon: Icons.admin_panel_settings_outlined, label: SettingTranslationConstants.adminCenter.tr, key: 'admin'),
  ];

  void _navigateSection(int delta) {
    final keys = _navItems.map((e) => e.key).toList();
    final currentIdx = keys.indexOf(_activeSection);
    final nextIdx = (currentIdx + delta).clamp(0, keys.length - 1);
    setState(() => _activeSection = keys[nextIdx]);
  }

  @override
  Widget build(BuildContext context) {
    return WebKeyboardManager(
      pageId: 'settings',
      pageShortcuts: {
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _navigateSection(-1),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _navigateSection(1),
        const SingleActivator(LogicalKeyboardKey.escape): () => Sint.back(),
      },
      child: Scaffold(
      backgroundColor: AppFlavour.getBackgroundColor(),
      body: Container(
        decoration: AppTheme.appBoxDecoration,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nav sidebar
                  SizedBox(
                    width: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 8),
                          child: Text(
                            CommonTranslationConstants.settingsPrivacy.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SettingsWebNav(
                          items: _navItems,
                          activeKey: _activeSection,
                          onItemTap: (key) => setState(() => _activeSection = key),
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(width: 1, color: AppColor.borderSubtle),
                  const SizedBox(width: 32),
                  // Content area
                  Expanded(
                    child: WebThemeConstants.fadeSwitch(
                      _buildSection(),
                      key: ValueKey(_activeSection),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSection() {
    switch (_activeSection) {
      case 'account':
        return SettingsWebSection(
          title: SettingTranslationConstants.account.tr,
          content: Column(
            children: [
              TitleSubtitleRow(SettingTranslationConstants.account.tr,
                  navigateTo: AppRouteConstants.settingsAccount),
            ],
          ),
        );
      case 'privacy':
        return SettingsWebSection(
          title: SettingTranslationConstants.privacyAndPolicy.tr,
          content: Column(
            children: [
              TitleSubtitleRow(SettingTranslationConstants.privacyAndPolicy.tr,
                  navigateTo: AppRouteConstants.privacyAndTerms),
            ],
          ),
        );
      case 'content':
        return SettingsWebSection(
          title: SettingTranslationConstants.contentPreferences.tr,
          content: Column(
            children: [
              TitleSubtitleRow(SettingTranslationConstants.contentPreferences.tr,
                  navigateTo: AppRouteConstants.contentPreferences),
            ],
          ),
        );
      case 'about':
        return SettingsWebSection(
          title: CommonTranslationConstants.aboutApp.tr,
          content: Column(
            children: [
              TitleSubtitleRow(CommonTranslationConstants.aboutApp.tr,
                  navigateTo: AppRouteConstants.about),
            ],
          ),
        );
      case 'contact':
        return SettingsWebSection(
          title: AppTranslationConstants.contactUs.tr,
          content: Column(
            children: [
              _buildContactRow(
                Icons.email_outlined,
                SettingTranslationConstants.gmail.tr,
                () {
                  final email = Uri.encodeFull(AppProperties.getEmail());
                  final subject = Uri.encodeFull('Regarding Web App');
                  launchUrl(Uri.parse('mailto:$email?subject=$subject'),
                    mode: LaunchMode.externalApplication);
                },
              ),
              _buildContactRow(
                Icons.chat_bubble_outline,
                'WhatsApp',
                () => ExternalUtilities.launchWhatsappURL(
                  AppProperties.getWhatsappBusinessNumber(),
                  AppTranslationConstants.hello.tr,
                ),
              ),
              _buildContactRow(
                Icons.camera_alt_outlined,
                'Instagram',
                () => launchUrl(
                  Uri.parse(AppProperties.getInstagram()),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
        );
      case 'admin':
        return SettingsWebSection(
          title: SettingTranslationConstants.adminCenter.tr,
          content: Column(
            children: [
              TitleSubtitleRow(CommonTranslationConstants.createCoupon.tr,
                  navigateTo: AppRouteConstants.createCoupon),
              TitleSubtitleRow(CommonTranslationConstants.createSponsor.tr,
                  navigateTo: AppRouteConstants.createSponsor),
              TitleSubtitleRow(CommonTranslationConstants.usersDirectory.tr,
                  navigateTo: AppRouteConstants.directory, navigateArguments: const [true]),
              TitleSubtitleRow(SettingTranslationConstants.seeAnalytics.tr,
                  navigateTo: AppRouteConstants.analytics),
              TitleSubtitleRow(SettingTranslationConstants.errorMonitor.tr,
                  navigateTo: AppRouteConstants.errorMonitor),
              TitleSubtitleRow(SettingTranslationConstants.flowMonitor.tr,
                  navigateTo: AppRouteConstants.flowMonitor),
              ErrorLogSummaryWidget(controller: widget.controller),
              if (widget.controller.userServiceImpl.user.userRole.value >= UserRole.admin.value) ...[
                TitleSubtitleRow(SettingTranslationConstants.runAnalyticsJobs.tr,
                    onPressed: widget.controller.runAnalyticJobs),
                TitleSubtitleRow(SettingTranslationConstants.runProfileJobs.tr,
                    onPressed: widget.controller.runProfileJobs),
                TitleSubtitleRow(SettingTranslationConstants.runVectorIndexJob.tr,
                    onPressed: widget.controller.runVectorIndexJob),
                if (widget.controller.isSaiaAvailable) ...[
                  const SizedBox(height: 16),
                  _buildSaiaSection(),
                ],
              ],
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSaiaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            SettingTranslationConstants.saiaSection.tr,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        // Dashboard stats
        Obx(() {
          final dashboard = widget.controller.saiaDashboard.value;
          if (dashboard == null) {
            // Auto-load dashboard on first view
            widget.controller.loadSaiaDashboard();
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text('Cargando...', style: TextStyle(color: Colors.white38, fontSize: 12)),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              '${dashboard.totalUsers} usuarios · ${dashboard.totalReleases} releases · '
              '${dashboard.pendingVectors} ${SettingTranslationConstants.saiaPendingVectors.tr} · '
              'Dominio: ${dashboard.hasCachedDomain ? "en caché" : "sin caché"}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          );
        }),
        const SizedBox(height: 4),
        // Progress indicator
        Obx(() {
          final progress = widget.controller.saiaJobProgress.value;
          if (progress == null || !progress.isRunning) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: progress.progress,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
                const SizedBox(height: 4),
                Text(
                  '${progress.currentStep} '
                  '(${progress.processedItems}/${progress.totalItems})',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          );
        }),
        // Job buttons
        TitleSubtitleRow(SettingTranslationConstants.runSaiaDomainJob.tr,
            onPressed: widget.controller.isSaiaJobRunning.value
                ? null : widget.controller.runSaiaDomainContextJob),
        TitleSubtitleRow(SettingTranslationConstants.runSaiaUserContextsJob.tr,
            onPressed: widget.controller.isSaiaJobRunning.value
                ? null : widget.controller.runSaiaUserContextsJob),
        TitleSubtitleRow(SettingTranslationConstants.saiaForceUpdate.tr,
            subtitle: SettingTranslationConstants.saiaContextsUpToDate.tr,
            onPressed: widget.controller.isSaiaJobRunning.value
                ? null : () => widget.controller.runSaiaUserContextsJob(forceRebuild: true)),
        TitleSubtitleRow(SettingTranslationConstants.runSaiaFullPipeline.tr,
            onPressed: widget.controller.isSaiaJobRunning.value
                ? null : widget.controller.runSaiaFullPipelineJob),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
      hoverColor: Colors.white.withAlpha(18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
