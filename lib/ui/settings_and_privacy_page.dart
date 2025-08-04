import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/ui/theme/app_theme.dart';
import 'package:neom_commons/ui/widgets/app_circular_progress_indicator.dart';
import 'package:neom_commons/ui/widgets/appbar_child.dart';
import 'package:neom_commons/ui/widgets/header_widget.dart';
import 'package:neom_commons/ui/widgets/title_subtitle_row.dart';
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

class SettingsPrivacyPage extends StatelessWidget {

  const SettingsPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      id: AppPageIdConstants.settingsPrivacy,
      init: SettingsController(),
      builder: (_) => Scaffold(
        appBar: AppBarChild(title: CommonTranslationConstants.settingsPrivacy.tr),
        backgroundColor: AppColor.main50,
        body: Obx(()=>Container(
          decoration: AppTheme.appBoxDecoration,
          child: _.isLoading.value ? Container(
              decoration: AppTheme.appBoxDecoration,
              child: const AppCircularProgressIndicator()) :
          ListView(
          children: <Widget>[
            HeaderWidget(_.userServiceImpl.user.name.capitalize),
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
                                    Navigator.pop(context);
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
                                    Navigator.pop(context);
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
                                    Navigator.pop(context);
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
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(FontAwesomeIcons.whatsapp,),
                                  iconSize: 40,
                                  tooltip: SettingTranslationConstants.whatsCommunity.tr,
                                  onPressed: () {
                                    Navigator.pop(context);
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
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(FontAwesomeIcons.whatsapp,),
                                  iconSize: 40,
                                  tooltip: SettingTranslationConstants.whatsCommunity.tr,
                                  onPressed: () {
                                    Navigator.pop(context);
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
            if(_.userServiceImpl.user.userRole != UserRole.subscriber)
            Column(
              children: [
                HeaderWidget(SettingTranslationConstants.adminCenter.tr, secondHeader: true),
                TitleSubtitleRow(CommonTranslationConstants.createCoupon.tr, navigateTo: AppRouteConstants.createCoupon),
                TitleSubtitleRow(CommonTranslationConstants.createSponsor.tr, navigateTo: AppRouteConstants.createSponsor),
                TitleSubtitleRow(CommonTranslationConstants.usersDirectory.tr, navigateTo: AppRouteConstants.directory, navigateArguments: const [true],),
                TitleSubtitleRow(SettingTranslationConstants.seeAnalytics.tr, navigateTo: AppRouteConstants.analytics),
                if(_.userServiceImpl.user.userRole == UserRole.superAdmin)
                  Column(
                    children: [
                      TitleSubtitleRow(SettingTranslationConstants.runAnalyticsJobs.tr, onPressed: _.runAnalyticJobs),
                      TitleSubtitleRow(SettingTranslationConstants.runProfileJobs.tr, onPressed: _.runProfileJobs),
                  ],),
              ],
            ),
            TitleSubtitleRow("", showDivider: false, vPadding: 10, subtitle: SettingTranslationConstants.settingPrivacyMsg.tr),
          ],
        ),
        ),),
    ),);
  }
}
