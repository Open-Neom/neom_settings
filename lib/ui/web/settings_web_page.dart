import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:neom_commons/app_flavour.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/ui/theme/app_theme.dart';
import 'package:neom_commons/ui/widgets/header_widget.dart';
import 'package:neom_commons/ui/widgets/title_subtitle_row.dart';
import 'package:neom_commons/ui/widgets/web/web_keyboard_manager.dart';
import 'package:neom_commons/ui/widgets/web/web_theme_constants.dart';
import 'package:neom_commons/utils/app_alerts.dart';
import 'package:neom_commons/utils/app_locale_utilities.dart';
import 'package:neom_commons/utils/constants/app_locale_constants.dart';
import 'package:neom_commons/utils/constants/app_page_id_constants.dart';
import 'package:neom_commons/utils/constants/translations/app_translation_constants.dart';
import 'package:neom_commons/utils/constants/translations/common_translation_constants.dart';
import 'package:neom_commons/utils/external_utilities.dart';
import 'package:neom_core/app_config.dart';
import 'package:neom_core/app_properties.dart';
import 'package:neom_commons/utils/auth_guard.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';
import 'package:neom_core/utils/enums/app_in_use.dart';
import 'package:neom_core/utils/enums/subscription_status.dart';
import 'package:neom_core/utils/enums/user_role.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sint/sint.dart';
import 'package:intl/intl.dart';
import 'package:neom_core/data/firestore/subscription_event_firestore.dart';
import 'package:neom_core/domain/model/subscription_event.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/constants/setting_translation_constants.dart';
import '../account_settings_controller.dart';
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
  List<SubscriptionEvent>? _billingEvents;
  bool _billingLoading = false;

  List<SettingsNavItem> get _navItems => [
    SettingsNavItem(icon: Icons.person_outline, label: SettingTranslationConstants.account.tr, key: 'account'),
    SettingsNavItem(icon: Icons.lock_outline, label: SettingTranslationConstants.privacyAndPolicy.tr, key: 'privacy'),
    if (AppConfig.instance.appInUse != AppInUse.c)
      SettingsNavItem(icon: Icons.receipt_long_outlined, label: SettingTranslationConstants.billing.tr, key: 'billing'),
    SettingsNavItem(icon: Icons.tune, label: SettingTranslationConstants.preferences.tr, key: 'content'),
    SettingsNavItem(icon: Icons.info_outline, label: CommonTranslationConstants.aboutApp.tr, key: 'about'),
    SettingsNavItem(icon: Icons.mail_outline, label: AppTranslationConstants.contactUs.tr, key: 'contact'),
    if (widget.controller.userServiceImpl.user.userRole != UserRole.subscriber)
      SettingsNavItem(icon: Icons.admin_panel_settings_outlined, label: SettingTranslationConstants.adminCenter.tr, key: 'admin'),
  ];

  Future<void> _loadBillingEvents() async {
    if (_billingLoading || _billingEvents != null) return;
    final subId = widget.controller.userServiceImpl.user.subscriptionId;
    if (subId.isEmpty) {
      setState(() => _billingEvents = []);
      return;
    }
    setState(() => _billingLoading = true);
    try {
      final events = await SubscriptionEventFirestore().getBySubscriptionId(subId);
      events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (mounted) setState(() { _billingEvents = events; _billingLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _billingEvents = []; _billingLoading = false; });
    }
  }

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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 22),
                  tooltip: AppTranslationConstants.goBack.tr,
                  onPressed: () => Sint.back(),
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
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
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSection() {
    switch (_activeSection) {
      case 'account':
        return SintBuilder<AccountSettingsController>(
          id: AppPageIdConstants.accountSettings,
          init: AccountSettingsController(),
          builder: (accountCtrl) => SettingsWebSection(
            title: SettingTranslationConstants.account.tr,
            content: Column(
              children: [
                HeaderWidget(SettingTranslationConstants.loginAndSecurity.tr),
                TitleSubtitleRow(
                  AppTranslationConstants.username.tr,
                  subtitle: accountCtrl.user.name.capitalize,
                ),
                const Divider(height: 0),
                TitleSubtitleRow(
                  AppTranslationConstants.phone.tr,
                  subtitle: accountCtrl.user.phoneNumber.isEmpty
                      ? AppTranslationConstants.notSpecified.tr
                      : "+${accountCtrl.user.countryCode} ${accountCtrl.user.phoneNumber}",
                  onPressed: () => AuthGuard.protect(context, () {
                    accountCtrl.getUpdatePhoneAlert(context);
                  }),
                ),
                TitleSubtitleRow(
                  AppTranslationConstants.email.tr,
                  subtitle: accountCtrl.user.email,
                ),
                const Divider(height: 0),
                if (accountCtrl.user.profiles.length > 1)
                  TitleSubtitleRow(CommonTranslationConstants.removeProfile.tr, textColor: AppColor.ceriseRed,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => SimpleDialog(
                          backgroundColor: AppColor.scaffold,
                          title: Text(SettingTranslationConstants.removeThisAccount.tr),
                          children: <Widget>[
                            SimpleDialogOption(
                              child: Text(AppTranslationConstants.remove.tr, style: const TextStyle(color: Colors.red)),
                              onPressed: () => Sint.toNamed(AppRouteConstants.profileRemove, arguments: [AppRouteConstants.accountSettings, AppRouteConstants.profileRemove]),
                            ),
                            SimpleDialogOption(
                              child: Text(AppTranslationConstants.cancel.tr),
                              onPressed: () => Sint.back(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                if (!AppConfig.instance.isGuestMode)
                  TitleSubtitleRow(SettingTranslationConstants.removeAccount.tr, textColor: AppColor.ceriseRed,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => SimpleDialog(
                          backgroundColor: AppColor.scaffold,
                          title: Text(SettingTranslationConstants.removeThisAccount.tr),
                          children: <Widget>[
                            SimpleDialogOption(
                              child: Text(AppTranslationConstants.remove.tr, style: const TextStyle(color: Colors.red)),
                              onPressed: () => Sint.toNamed(AppRouteConstants.accountRemove, arguments: [AppRouteConstants.accountSettings, AppRouteConstants.accountRemove]),
                            ),
                            SimpleDialogOption(
                              child: Text(AppTranslationConstants.cancel.tr),
                              onPressed: () => Sint.back(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      case 'privacy':
        return SettingsWebSection(
          title: SettingTranslationConstants.privacyAndPolicy.tr,
          content: Column(
            children: [
              HeaderWidget(SettingTranslationConstants.dataAndPrivacy.tr, secondHeader: true),
              TitleSubtitleRow(
                SettingTranslationConstants.blockedProfiles.tr,
                onPressed: () => widget.controller.userServiceImpl.profile.blockTo!.isNotEmpty
                    ? Sint.toNamed(AppRouteConstants.blockedProfiles, arguments: widget.controller.userServiceImpl.profile.blockTo)
                    : AppAlerts.showAlert(context,
                        title: SettingTranslationConstants.blockedProfiles.tr,
                        message: SettingTranslationConstants.blockedProfilesMsg.tr),
              ),
              TitleSubtitleRow(
                SettingTranslationConstants.downloadMyData.tr,
                subtitle: CommonTranslationConstants.featureComingSoon.tr,
              ),
              const Divider(height: 24),
              HeaderWidget(AppTranslationConstants.legal.tr),
              TitleSubtitleRow(
                SettingTranslationConstants.termsOfService.tr,
                showDivider: true,
                url: AppProperties.getTermsOfServiceUrl(),
              ),
              TitleSubtitleRow(
                SettingTranslationConstants.privacyPolicy.tr,
                showDivider: true,
                url: AppProperties.getPrivacyPolicyUrl(),
              ),
              TitleSubtitleRow(
                SettingTranslationConstants.legalNotices.tr,
                showDivider: true,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => Theme(
                      data: ThemeData(
                        brightness: Brightness.dark,
                        fontFamily: AppTheme.fontFamily,
                        cardColor: AppColor.surfaceCard,
                      ),
                      child: LicensePage(
                        applicationVersion: AppConfig.instance.appVersion,
                        applicationName: AppProperties.getAppName(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 'billing':
        return _buildBillingSection();
      case 'content':
        return SettingsWebSection(
          title: SettingTranslationConstants.preferences.tr,
          content: Column(
            children: [
              HeaderWidget(AppTranslationConstants.language.tr, secondHeader: true),
              TitleSubtitleRow(
                SettingTranslationConstants.preferredLanguage.tr,
                subtitle: AppLocaleUtilities.languageFromLocale(Sint.locale!).tr,
                onPressed: () => Alert(
                  context: context,
                  style: AlertStyle(
                    backgroundColor: AppColor.scaffold,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  title: SettingTranslationConstants.chooseYourLanguage.tr,
                  content: Obx(() => DropdownButton<String>(
                    items: AppLocaleConstants.supportedLanguages.map<DropdownMenuItem<String>>((String language) {
                      return DropdownMenuItem<String>(value: language, child: Text(language.tr));
                    }).toList(),
                    onChanged: (String? selectedLanguage) {
                      widget.controller.setNewLanguage(selectedLanguage!);
                    },
                    value: widget.controller.newLanguage.value,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: AppColor.surfaceElevated,
                    underline: Container(height: 1, color: Colors.grey),
                  )),
                  buttons: [
                    DialogButton(
                      color: AppColor.bondiBlue75,
                      onPressed: () => widget.controller.setNewLocale(),
                      child: Text(AppTranslationConstants.setLocale.tr, style: const TextStyle(fontSize: 15)),
                    ),
                  ],
                ).show(),
              ),
              HeaderWidget(AppTranslationConstants.safety.tr, secondHeader: true),
              TitleSubtitleRow(
                '${SettingTranslationConstants.locationUsage.tr}: ${widget.controller.locationPermission.value.name.tr}',
                onPressed: () async {
                  widget.controller.locationPermission.value == LocationPermission.denied
                      ? await widget.controller.verifyLocationPermission()
                      : AppAlerts.showAlert(context,
                          title: SettingTranslationConstants.locationUsage.tr,
                          message: SettingTranslationConstants.changeThisInTheAppSettings.tr);
                },
              ),
            ],
          ),
        );
      case 'about':
        return SettingsWebSection(
          title: CommonTranslationConstants.aboutApp.tr,
          content: Column(
            children: [
              HeaderWidget(SettingTranslationConstants.help.tr, secondHeader: true),
              TitleSubtitleRow(
                SettingTranslationConstants.helpCenter.tr,
                vPadding: 0,
                showDivider: false,
                url: AppProperties.getWebContact(),
              ),
              HeaderWidget(AppTranslationConstants.websites.tr),
              TitleSubtitleRow(
                AppProperties.getAppName().tr,
                showDivider: true,
                url: AppProperties.getLandingPageUrl(),
              ),
              TitleSubtitleRow(
                SettingTranslationConstants.blog,
                showDivider: true,
                url: AppProperties.getBlogUrl(),
              ),
              HeaderWidget(SettingTranslationConstants.developer.tr),
              TitleSubtitleRow(
                SettingTranslationConstants.github,
                showDivider: true,
                url: AppProperties.getDevGithub(),
              ),
              TitleSubtitleRow(
                SettingTranslationConstants.linkedin,
                showDivider: true,
                url: AppProperties.getDevLinkedIn(),
              ),
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
              TitleSubtitleRow(SettingTranslationConstants.subscriptionPlansAdmin.tr,
                  navigateTo: AppRouteConstants.planManager),
              TitleSubtitleRow(CommonTranslationConstants.coupons.tr,
                  navigateTo: AppRouteConstants.couponManager),
              TitleSubtitleRow(CommonTranslationConstants.sponsors.tr,
                  navigateTo: AppRouteConstants.sponsorManager),
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

  Widget _buildBillingSection() {
    // Lazy load billing events
    if (_billingEvents == null && !_billingLoading) {
      Future.microtask(_loadBillingEvents);
    }

    final userSub = widget.controller.userServiceImpl.userSubscription;
    final hasSubscription = userSub != null && userSub.status == SubscriptionStatus.active;
    final levelName = userSub?.level?.name ?? '';
    final displayLevel = levelName.isNotEmpty
        ? '${levelName[0].toUpperCase()}${levelName.substring(1)}'
        : '';

    return SettingsWebSection(
      title: SettingTranslationConstants.billing.tr,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. Plan actual
          HeaderWidget(SettingTranslationConstants.currentPlanSection.tr),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Icon(
                  hasSubscription ? Icons.workspace_premium : Icons.person_outline,
                  color: hasSubscription ? Colors.amber : Colors.white38,
                  size: 36,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasSubscription
                            ? '${AppProperties.getGeneralSubscriptionName()} — $displayLevel'
                            : CommonTranslationConstants.freeAccount.tr,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      if (hasSubscription && (userSub!.price?.amount ?? 0) > 0)
                        Text(
                          '\$${userSub.price!.amount.toStringAsFixed(0)} ${userSub.price!.currency.name.toUpperCase()} / ${SettingTranslationConstants.perMonth.tr}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                      if (hasSubscription && userSub!.endDate > 0)
                        Text(
                          '${SettingTranslationConstants.renewsOn.tr} ${DateFormat.yMMMd(Sint.locale?.languageCode ?? 'es').format(DateTime.fromMillisecondsSinceEpoch(userSub.endDate))}',
                          style: TextStyle(color: Colors.green[400], fontSize: 12),
                        ),
                    ],
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  onPressed: () => Sint.toNamed(AppRouteConstants.subscriptionPlans),
                  child: Text(hasSubscription
                      ? SettingTranslationConstants.adjustPlan.tr
                      : SettingTranslationConstants.acquireSubscription.tr),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // B. Payment method
          HeaderWidget(SettingTranslationConstants.paymentMethod.tr),
          Builder(builder: (_) {
            final events = _billingEvents ?? [];
            final lastPaid = events.where((e) => e.paymentMethodBrand.isNotEmpty).toList();
            if (lastPaid.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.credit_card, color: Colors.white24, size: 20),
                    const SizedBox(width: 12),
                    Text(SettingTranslationConstants.noPaymentMethod.tr,
                        style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                  ],
                ),
              );
            }
            final pm = lastPaid.first;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: Colors.white70, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    '${pm.paymentMethodBrand} \u2022\u2022\u2022\u2022 ${pm.paymentMethodLast4}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: () => Sint.toNamed(AppRouteConstants.subscriptionPlans),
                    child: Text(SettingTranslationConstants.updatePayment.tr),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // C. Payment history
          HeaderWidget(SettingTranslationConstants.paymentHistory.tr),
          if (_billingLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_billingEvents == null || _billingEvents!.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(SettingTranslationConstants.noPaymentHistory.tr,
                  style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            )
          else ...[
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(SettingTranslationConstants.billingDate.tr,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600))),
                  Expanded(flex: 2, child: Text(SettingTranslationConstants.billingTotal.tr,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600))),
                  Expanded(flex: 2, child: Text(SettingTranslationConstants.billingStatus.tr,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600))),
                  Expanded(flex: 2, child: Text(SettingTranslationConstants.billingActions.tr,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
            // Table rows
            ...(_billingEvents!.where((e) => e.hasFinancialData).take(15).map((event) {
              final date = DateFormat.yMMMd(Sint.locale?.languageCode ?? 'es')
                  .format(DateTime.fromMillisecondsSinceEpoch(event.createdAt));
              final isPaid = event.stripeEventType.contains('succeeded');
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white.withAlpha(8))),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(date, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                    Expanded(flex: 2, child: Text('\$${event.amount.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 13))),
                    Expanded(flex: 2, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPaid ? Colors.green.withAlpha(30) : Colors.red.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPaid ? SettingTranslationConstants.billingPaid.tr : SettingTranslationConstants.billingFailed.tr,
                        style: TextStyle(color: isPaid ? Colors.green[400] : Colors.red[400], fontSize: 12),
                      ),
                    )),
                    Expanded(flex: 2, child: event.invoiceUrl.isNotEmpty
                        ? GestureDetector(
                            onTap: () => launchUrl(Uri.parse(event.invoiceUrl), mode: LaunchMode.externalApplication),
                            child: Text(SettingTranslationConstants.billingView.tr,
                                style: TextStyle(color: Colors.blue[400], fontSize: 13, decoration: TextDecoration.underline)),
                          )
                        : const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            })),
          ],

          // D. Cancellation
          if (hasSubscription) ...[
            const SizedBox(height: 32),
            const Divider(height: 1, color: Colors.white12),
            const SizedBox(height: 16),
            HeaderWidget(SettingTranslationConstants.cancellation.tr),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(SettingTranslationConstants.cancelPlan.tr,
                        style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withAlpha(40),
                      foregroundColor: Colors.red[300],
                      elevation: 0,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => SimpleDialog(
                          backgroundColor: AppColor.scaffold,
                          title: Text(SettingTranslationConstants.cancelThisSubscription.tr),
                          children: [
                            SimpleDialogOption(
                              child: Text(AppTranslationConstants.yes.tr, style: const TextStyle(color: Colors.red)),
                              onPressed: () {
                                if (Sint.isRegistered<AccountSettingsController>()) {
                                  Sint.find<AccountSettingsController>().subscriptionServiceImpl.cancelSubscription();
                                }
                              },
                            ),
                            SimpleDialogOption(
                              child: Text(AppTranslationConstants.no.tr),
                              onPressed: () => Sint.back(),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(AppTranslationConstants.cancel.tr),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
