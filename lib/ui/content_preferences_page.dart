import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:neom_commons/app_flavour.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/ui/theme/app_theme.dart';
import 'package:neom_commons/ui/widgets/appbar_child.dart';
import 'package:neom_commons/ui/widgets/header_widget.dart';
import 'package:neom_commons/ui/widgets/title_subtitle_row.dart';
import 'package:neom_commons/utils/app_alerts.dart';
import 'package:neom_commons/utils/app_locale_utilities.dart';
import 'package:neom_commons/utils/constants/app_locale_constants.dart';
import 'package:neom_commons/utils/constants/app_page_id_constants.dart';
import 'package:neom_commons/utils/constants/translations/app_translation_constants.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sint/sint.dart';

import '../utils/constants/setting_translation_constants.dart';
import 'settings_controller.dart';

class ContentPreferencePage extends StatelessWidget {

  const ContentPreferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SintBuilder<SettingsController>(
      init: SettingsController(),
      id: AppPageIdConstants.settingsPrivacy,
      builder: (controller) => Scaffold(
        appBar: AppBarChild(title: SettingTranslationConstants.contentPreferences.tr),
        backgroundColor: AppFlavour.getBackgroundColor(),
        body: Container(
        decoration: AppTheme.appBoxDecoration,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            HeaderWidget(AppTranslationConstants.language.tr, secondHeader: true),
            TitleSubtitleRow(
                SettingTranslationConstants.preferredLanguage.tr,
                subtitle: AppLocaleUtilities.languageFromLocale(Sint.locale!).tr,
                onPressed: () => Alert(
                  context: context,
                  style: AlertStyle(
                      backgroundColor: AppColor.main50,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                  title: SettingTranslationConstants.chooseYourLanguage.tr,
                  content: Obx(()=> DropdownButton<String>(
                        items: AppLocaleConstants.supportedLanguages.map<DropdownMenuItem<String>>((String language) {
                          return DropdownMenuItem<String>(
                              value: language,
                              child: Text(language.tr)
                          );
                        }).toList(),
                        onChanged: (String? selectedLanguage) {
                          controller.setNewLanguage(selectedLanguage!);
                        },
                        value: controller.newLanguage.value,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: AppColor.main75,
                        underline: Container(
                            height: 1,
                            color: Colors.grey
                        ),
                      ),
                  ),
                  buttons: [
                    DialogButton(
                      color: AppColor.bondiBlue75,
                      onPressed: () => {
                        controller.setNewLocale()
                      },
                      child: Text(AppTranslationConstants.setLocale.tr,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ).show()
            ),
            HeaderWidget(AppTranslationConstants.safety.tr, secondHeader: true),
            TitleSubtitleRow('${SettingTranslationConstants.locationUsage.tr}: ${controller.locationPermission.value.name.tr}',
              onPressed: () async {
                //Sint.toNamed(GigRouteConstants.INTRO_REQUIRED_PERMISSIONS);
                controller.locationPermission.value == LocationPermission.denied ?
                  await controller.verifyLocationPermission()
                  : AppAlerts.showAlert(context, title: SettingTranslationConstants.locationUsage.tr,
                    message: SettingTranslationConstants.changeThisInTheAppSettings.tr.tr);
              }
            ),
            TitleSubtitleRow(SettingTranslationConstants.blockedProfiles.tr,
              onPressed: () => controller.userServiceImpl.profile.blockTo!.isNotEmpty
                  ? Sint.toNamed(AppRouteConstants.blockedProfiles, arguments: controller.userServiceImpl.profile.blockTo)
                  : AppAlerts.showAlert(context, title: SettingTranslationConstants.blockedProfiles.tr,
                      message: SettingTranslationConstants.blockedProfilesMsg.tr),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
