import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sint/sint.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/ui/theme/app_theme.dart';
import 'package:neom_commons/utils/app_alerts.dart';
import 'package:neom_commons/utils/app_utilities.dart';
import 'package:neom_commons/utils/constants/app_page_id_constants.dart';
import 'package:neom_commons/utils/constants/intl_countries_list.dart';
import 'package:neom_commons/utils/constants/translations/app_translation_constants.dart';
import 'package:neom_commons/utils/constants/translations/common_translation_constants.dart';
import 'package:neom_commons/utils/constants/translations/message_translation_constants.dart';
import 'package:neom_core/app_config.dart';
import 'package:neom_core/domain/model/app_user.dart';
import 'package:neom_core/domain/use_cases/subscription_service.dart';
import 'package:neom_core/domain/use_cases/user_service.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../domain/use_cases/account_settings_service.dart';
import '../utils/constants/setting_translation_constants.dart';

class AccountSettingsController extends SintController implements AccountSettingsService {

  UserService userServiceImpl = Sint.find<UserService>();
  SubscriptionService subscriptionServiceImpl = Sint.find<SubscriptionService>();
  AppUser user = AppUser();

  RxBool isLoading = true.obs;

  final Rx<Country> phoneCountry = IntlPhoneConstants.availableCountries[0].obs;
  TextEditingController controllerPhone = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    AppConfig.logger.d("AccountSettings Controller Init for userId ${userServiceImpl.user.id}");
    user = userServiceImpl.user;
    controllerPhone.text = user.phoneNumber;
  }

  @override
  void onReady() {
    super.onReady();
    AppConfig.logger.d("AccountSettings Controller Ready");
    isLoading.value = false;
  }

  @override
  void getSubscriptionAlert(BuildContext context) {
    AppAlerts.getSubscriptionAlert(subscriptionServiceImpl, context, AppRouteConstants.accountSettings);
  }

  @override
  Future<void> updatePhone(BuildContext context) async {
    String validateMsg = "";
    String phoneNumberText = controllerPhone.text;
    String phoneCountryCode = phoneCountry.value.dialCode;

    try {
      if (phoneNumberText.isEmpty || phoneNumberText.length < phoneCountry.value.minLength
          || phoneNumberText.length > phoneCountry.value.maxLength) {
        validateMsg = MessageTranslationConstants.pleaseEnterPhone;
      } else if (phoneCountry.value.code.isEmpty) {
        validateMsg = MessageTranslationConstants.pleaseEnterCountryCode;
      } else if(user.phoneNumber == phoneNumberText && user.countryCode == phoneCountryCode) {
        validateMsg = MessageTranslationConstants.sameNumber.tr;
      } else if(await userServiceImpl.updatePhoneNumber(phoneNumberText, phoneCountryCode)) {
        user.phoneNumber = phoneNumberText;
        user.countryCode = phoneCountryCode;
        AppUtilities.showSnackBar(title: AppTranslationConstants.updatePhone,
            message:  MessageTranslationConstants.updatedPhoneMsg);
        Navigator.pop(context);
      }

      if(validateMsg.isNotEmpty) {
        AppUtilities.showSnackBar(title: AppTranslationConstants.updatePhone,
            message: validateMsg);
      }
    } catch(e) {
      AppConfig.logger.e(e.toString());
    }
    update([AppPageIdConstants.accountSettings]);
  }

  @override
  Future<bool?> getUpdatePhoneAlert(BuildContext context) {
    AppConfig.logger.d("getUpdatePhoneAlert");
    return Alert(
        context: context,
        style: AlertStyle(
            backgroundColor: AppColor.main50,
            titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            titleTextAlign: TextAlign.justify
        ),
        content: Column(
          children: <Widget>[
            AppTheme.heightSpace20,
            Text(AppTranslationConstants.updatePhone.tr,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),textAlign: TextAlign.justify,
            ),
            AppTheme.heightSpace20,
            buildPhoneField(),
            AppTheme.heightSpace20,
          ],
        ),
        buttons: [
          DialogButton(
            color: AppColor.bondiBlue75,
            onPressed: () async {
              await updatePhone(context);
            },
            child: Text(SettingTranslationConstants.confirmAndUpdate.tr,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ]
    ).show();
  }

  @override
  Widget buildPhoneField() {
    return Container(
        padding: const EdgeInsets.only(
          left: AppTheme.padding10,
          right: AppTheme.padding10,
          bottom: AppTheme.padding5,
        ),
        decoration: BoxDecoration(
          color: AppColor.bondiBlue25,
          borderRadius: BorderRadius.circular(40),
        ),
        child: IntlPhoneField(
          controller: controllerPhone,
          countries: IntlPhoneConstants.availableCountries,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: AppTranslationConstants.phoneNumber.tr,
            labelStyle: const TextStyle(fontSize: 12),
            alignLabelWithHint: true,
          ),
          pickerDialogStyle: PickerDialogStyle(
              backgroundColor: AppColor.getMain(),
              searchFieldInputDecoration: InputDecoration(
                labelText: CommonTranslationConstants.searchByCountryName.tr,
              )
          ),
          dropdownTextStyle: const TextStyle(fontSize: 14),
          style: const TextStyle(fontSize: 14),
          initialCountryCode: IntlPhoneConstants.initialCountryCode,
          onChanged: (phone) {
            controllerPhone.text = phone.number;
          },
          onCountryChanged: (country) {
            phoneCountry.value = country;
          },
        )
    );
  }

}
