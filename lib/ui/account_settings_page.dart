import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/ui/theme/app_theme.dart';
import 'package:neom_commons/ui/widgets/appbar_child.dart';
import 'package:neom_commons/ui/widgets/header_widget.dart';
import 'package:neom_commons/ui/widgets/title_subtitle_row.dart';
import 'package:neom_commons/utils/constants/app_page_id_constants.dart';
import 'package:neom_commons/utils/constants/translations/app_translation_constants.dart';
import 'package:neom_commons/utils/constants/translations/common_translation_constants.dart';
import 'package:neom_core/app_config.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';
import 'package:neom_core/utils/enums/app_in_use.dart';
import 'package:neom_core/utils/enums/subscription_level.dart';
import 'package:neom_core/utils/enums/subscription_status.dart';
import 'package:neom_core/utils/enums/user_role.dart';

import '../utils/constants/setting_translation_constants.dart';
import 'account_settings_controller.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountSettingsController>(
      id: AppPageIdConstants.accountSettings,
      init: AccountSettingsController(),
      builder: (_) => Scaffold(
      appBar: AppBarChild(title: SettingTranslationConstants.accountSettings.tr),
      backgroundColor: AppColor.main50,
      body: Container(
        decoration: AppTheme.appBoxDecoration,
        child: ListView(
        children: <Widget>[
          HeaderWidget(SettingTranslationConstants.loginAndSecurity.tr),
          TitleSubtitleRow(
            AppTranslationConstants.username.tr,
            subtitle: _.user.name,
          ),
          const Divider(height: 0),
          if((_.user.userRole != UserRole.subscriber || kDebugMode) && AppConfig.instance.appInUse != AppInUse.c) TitleSubtitleRow(
            AppTranslationConstants.subscription.tr,
            subtitle: (_.userServiceImpl.userSubscription?.status == SubscriptionStatus.active) ? AppTranslationConstants.active.tr.capitalize : _.userServiceImpl.subscriptionLevel == SubscriptionLevel.freeMonth ? CommonTranslationConstants.testPeriod.tr : SettingTranslationConstants.activateSubscription.tr,
            onPressed: () => _.user.subscriptionId.isEmpty ? _.getSubscriptionAlert(context) : (),
          ),
          TitleSubtitleRow(
            AppTranslationConstants.phone.tr,
            subtitle: _.user.phoneNumber.isEmpty ? AppTranslationConstants.notSpecified.tr : "+${_.user.countryCode} ${_.user.phoneNumber}",
            onPressed: () => _.getUpdatePhoneAlert(context),
          ),
          TitleSubtitleRow(
            AppTranslationConstants.email.tr,
            subtitle: _.user.email,
          ),
          const Divider(height: 0),
          if(_.userServiceImpl.userSubscription?.status == SubscriptionStatus.active)
            TitleSubtitleRow(SettingTranslationConstants.cancelSubscription.tr,  textColor: AppColor.ceriseRed,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        backgroundColor: AppColor.getMain(),
                        title: Text(SettingTranslationConstants.cancelThisSubscription.tr,),
                        children: <Widget>[
                          SimpleDialogOption(
                            child: Text(
                              AppTranslationConstants.yes.tr,
                              style: const TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              _.subscriptionServiceImpl.cancelSubscription();
                            },
                          ),
                          SimpleDialogOption(
                            child: Text(
                              AppTranslationConstants.no.tr,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
                },
            ),
          if(_.user.profiles.length > 1)
            TitleSubtitleRow(CommonTranslationConstants.removeProfile.tr,  textColor: AppColor.ceriseRed,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        backgroundColor: AppColor.main50,
                        title: Text(SettingTranslationConstants.removeThisAccount.tr),
                        children: <Widget>[
                          SimpleDialogOption(
                            child: Text(
                              AppTranslationConstants.remove.tr,
                              style: const TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              Get.toNamed(AppRouteConstants.profileRemove, arguments: [AppRouteConstants.accountSettings, AppRouteConstants.profileRemove]);
                            },
                          ),
                          SimpleDialogOption(
                            child: Text(
                              AppTranslationConstants.cancel.tr,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    }
                );

              },
            ),
          TitleSubtitleRow(SettingTranslationConstants.removeAccount.tr,  textColor: AppColor.ceriseRed,
            onPressed: (){
            showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    backgroundColor: AppColor.getMain(),
                    title: Text(SettingTranslationConstants.removeThisAccount.tr),
                    children: <Widget>[
                      SimpleDialogOption(
                        child: Text(
                          AppTranslationConstants.remove.tr,
                          style: const TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          Get.toNamed(AppRouteConstants.accountRemove, arguments: [AppRouteConstants.accountSettings, AppRouteConstants.accountRemove]);
                          },
                      ),
                      SimpleDialogOption(
                        child: Text(
                          AppTranslationConstants.cancel.tr,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          },
                      ),
                    ],
                  );
                });
            },),
        ],),
      ),
      ),
    );
  }
}
