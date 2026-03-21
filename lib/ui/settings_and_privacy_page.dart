import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neom_commons/app_flavour.dart';
import 'package:neom_commons/ui/theme/app_theme.dart';
import 'package:neom_commons/ui/widgets/app_circular_progress_indicator.dart';
import 'package:sint/sint.dart';
import 'package:neom_commons/ui/widgets/header_widget.dart';
import 'package:neom_commons/ui/widgets/title_subtitle_row.dart';
import 'package:neom_commons/ui/widgets/web_content_wrapper.dart';
import 'package:neom_commons/utils/constants/app_page_id_constants.dart';
import 'package:neom_commons/utils/constants/translations/app_translation_constants.dart';
import 'package:neom_commons/utils/constants/translations/common_translation_constants.dart';
import 'package:neom_commons/utils/external_utilities.dart';
import 'package:neom_core/app_config.dart';
import 'package:neom_core/app_properties.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';
import 'package:neom_core/utils/enums/app_in_use.dart';
import 'package:neom_core/utils/enums/user_role.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/constants/setting_translation_constants.dart';
import 'settings_controller.dart';
import 'web/settings_web_page.dart';
import 'widgets/error_log_summary_widget.dart';

class SettingsPrivacyPage extends StatelessWidget {

  const SettingsPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SintBuilder<SettingsController>(
      id: AppPageIdConstants.settingsPrivacy,
      init: SettingsController(),
      builder: (controller) {
        if (kIsWeb) return SettingsWebPage(controller: controller);
        return Scaffold(
        appBar: SintAppBar(title: CommonTranslationConstants.settingsPrivacy.tr),
        backgroundColor: AppFlavour.getBackgroundColor(),
        body: WebContentWrapper(
          maxWidth: 700,
          padding: EdgeInsets.zero,
          child: Obx(()=>Container(
          decoration: AppTheme.appBoxDecoration,
          child: controller.isLoading.value ? AppCircularProgressIndicator() :
          ListView(
          children: <Widget>[
            HeaderWidget(controller.userServiceImpl.user.name.capitalize),
            TitleSubtitleRow(SettingTranslationConstants.account.tr, navigateTo: AppRouteConstants.settingsAccount),
            TitleSubtitleRow(SettingTranslationConstants.privacyAndPolicy.tr, navigateTo: AppRouteConstants.privacyAndTerms),
            TitleSubtitleRow(SettingTranslationConstants.contentPreferences.tr, navigateTo: AppRouteConstants.contentPreferences),
            HeaderWidget(AppTranslationConstants.general.tr.capitalize, secondHeader: true,),
            TitleSubtitleRow(CommonTranslationConstants.aboutApp.tr, navigateTo: AppRouteConstants.about),
            // if(AppConfig.instance.appInUse == AppInUse.c) TitleSubtitleRow(AppTranslationConstants.likeMyWork.tr, subtitle: AppTranslationConstants.buyCoffee.tr,
            //   onPressed: () => launchUrl(Uri.parse(AppFlavour.getBuyMeACoffeeURL(),),)),
            TitleSubtitleRow(AppTranslationConstants.contactUs.tr, subtitle: SettingTranslationConstants.contactUsSub.tr,
                onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: 100,
                      child: Container(
                        decoration: AppTheme.appBoxDecoration75,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(FontAwesomeIcons.envelope,),
                                  iconSize: 40,
                                  tooltip: SettingTranslationConstants.gmail.tr,
                                  onPressed: () {
                                    Sint.back();
                                    final email = Uri.encodeFull(AppProperties.getEmail());
                                    final subject = Uri.encodeFull('Regarding Mobile App');
                                    final uri = Uri.parse(
                                      'mailto:$email?subject=$subject',
                                    );
                                    launchUrl(uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                ),
                                Text(SettingTranslationConstants.gmail.tr,),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(FontAwesomeIcons.whatsapp,),
                                  iconSize: 40,
                                  tooltip: SettingTranslationConstants.whatsContact.tr,
                                  onPressed: () {
                                    Sint.back();
                                    ExternalUtilities.launchWhatsappURL(AppProperties.getWhatsappBusinessNumber(), AppTranslationConstants.hello.tr);
                                  },
                                ),
                                Text(SettingTranslationConstants.whatsapp.tr,),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(FontAwesomeIcons.instagram,),
                                  iconSize: 40,
                                  tooltip: AppTranslationConstants.instagram.tr,
                                  onPressed: () {
                                    Sint.back();
                                    launchUrl(Uri.parse(AppProperties.getInstagram(),),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                ),
                                Text(
                                  SettingTranslationConstants.insta.tr,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            if(AppConfig.instance.appInUse != AppInUse.c) TitleSubtitleRow(SettingTranslationConstants.joinWhats.tr, subtitle: SettingTranslationConstants.joinWhatsSub.tr,
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: 100,
                      child: Container(
                        decoration: AppTheme.appBoxDecoration75,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            if (AppProperties.getMainWhatsGroupUrl().isNotEmpty)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(FontAwesomeIcons.whatsapp,),
                                    iconSize: 40,
                                    tooltip: SettingTranslationConstants.whatsCommunity.tr,
                                    onPressed: () {
                                      Sint.back();
                                      launchUrl(Uri.parse(AppProperties.getMainWhatsGroupUrl()),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                  ),
                                  Text(
                                    SettingTranslationConstants.whatsRock.tr,
                                  ),
                                ],
                              ),
                            if (AppProperties.getSecondaryWhatsGroupUrl().isNotEmpty)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(FontAwesomeIcons.whatsapp,),
                                    iconSize: 40,
                                    tooltip: SettingTranslationConstants.whatsCommunity.tr,
                                    onPressed: () {
                                      Sint.back();
                                      launchUrl(Uri.parse(AppProperties.getSecondaryWhatsGroupUrl()),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                  ),
                                  Text(SettingTranslationConstants.whatsCommunity.tr,),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            //TODO
            if(controller.userServiceImpl.user.userRole != UserRole.subscriber)
            Column(
              children: [
                HeaderWidget(SettingTranslationConstants.adminCenter.tr, secondHeader: true),
                TitleSubtitleRow(CommonTranslationConstants.createCoupon.tr, navigateTo: AppRouteConstants.createCoupon),
                TitleSubtitleRow(CommonTranslationConstants.createSponsor.tr, navigateTo: AppRouteConstants.createSponsor),
                TitleSubtitleRow(CommonTranslationConstants.usersDirectory.tr, navigateTo: AppRouteConstants.directory, navigateArguments: const [true],),
                TitleSubtitleRow(SettingTranslationConstants.seeAnalytics.tr, navigateTo: AppRouteConstants.analytics),
                TitleSubtitleRow(SettingTranslationConstants.errorMonitor.tr, navigateTo: AppRouteConstants.errorMonitor),
                TitleSubtitleRow(SettingTranslationConstants.flowMonitor.tr, navigateTo: AppRouteConstants.flowMonitor),
                ErrorLogSummaryWidget(controller: controller),
                if(controller.userServiceImpl.user.userRole.value >= UserRole.admin.value)
                  Column(
                    children: [
                      TitleSubtitleRow(SettingTranslationConstants.runAnalyticsJobs.tr, onPressed: controller.runAnalyticJobs),
                      TitleSubtitleRow(SettingTranslationConstants.runProfileJobs.tr, onPressed: controller.runProfileJobs),
                      _buildVectorIndexRow(context, controller),
                      if (controller.isSaiaAvailable)
                        _buildSaiaJobsSection(controller),
                  ],),
              ],
            ),
            TitleSubtitleRow("", showDivider: false, vPadding: 10, subtitle: SettingTranslationConstants.settingPrivacyMsg.tr),
          ],
        ),
        ),),
    ),);},
    );
  }

  /// Builds the Vector Index row with progress indicator
  Widget _buildVectorIndexRow(BuildContext context, SettingsController controller) {
    return Obx(() {
      final progress = controller.vectorIndexProgress.value;
      final isRunning = controller.isVectorJobRunning.value;

      if (isRunning && progress != null) {
        // Show progress
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      SettingTranslationConstants.vectorIndexJobRunning.tr,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.progress,
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(height: 4),
              Text(
                progress.currentStatus,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                '${progress.processedItems}/${progress.totalItems} · Nuevos: ${progress.newIndexes} · Errores: ${progress.errorItems}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const Divider(),
            ],
          ),
        );
      }

      // Show normal button
      return TitleSubtitleRow(
        SettingTranslationConstants.runVectorIndexJob.tr,
        onPressed: controller.runVectorIndexJob,
      );
    });
  }

  /// Builds the SAIA admin jobs section with progress
  Widget _buildSaiaJobsSection(SettingsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            SettingTranslationConstants.saiaSection.tr,
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        // Progress
        Obx(() {
          final progress = controller.saiaJobProgress.value;
          if (progress == null || !progress.isRunning) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                  '${progress.currentStep} (${progress.processedItems}/${progress.totalItems})',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          );
        }),
        TitleSubtitleRow(SettingTranslationConstants.runSaiaDomainJob.tr,
            onPressed: controller.runSaiaDomainContextJob),
        TitleSubtitleRow(SettingTranslationConstants.runSaiaUserContextsJob.tr,
            onPressed: controller.runSaiaUserContextsJob),
        TitleSubtitleRow(SettingTranslationConstants.saiaForceUpdate.tr,
            subtitle: SettingTranslationConstants.saiaContextsUpToDate.tr,
            onPressed: () => controller.runSaiaUserContextsJob(forceRebuild: true)),
        TitleSubtitleRow(SettingTranslationConstants.runSaiaFullPipeline.tr,
            onPressed: controller.runSaiaFullPipelineJob),
      ],
    );
  }
}
