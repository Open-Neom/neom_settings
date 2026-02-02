import 'package:enum_to_string/enum_to_string.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sint/sint.dart';
import 'package:neom_commons/utils/app_locale_utilities.dart';
import 'package:neom_commons/utils/app_utilities.dart';
import 'package:neom_commons/utils/constants/app_page_id_constants.dart';
import 'package:neom_commons/utils/constants/translations/common_translation_constants.dart';
import 'package:neom_commons/utils/constants/translations/message_translation_constants.dart';
import 'package:neom_core/app_config.dart';
import 'package:neom_core/data/implementations/app_hive_controller.dart';
import 'package:neom_core/data/implementations/geolocator_controller.dart';
import 'package:neom_core/domain/repository/analytics_repository.dart';
import 'package:neom_core/domain/repository/job_repository.dart';
import 'package:neom_core/domain/use_cases/login_service.dart';
import 'package:neom_core/domain/use_cases/settings_service.dart';
import 'package:neom_core/domain/use_cases/user_service.dart';
import 'package:neom_core/utils/enums/app_in_use.dart';
import 'package:neom_core/utils/enums/app_locale.dart';

class SettingsController extends SintController implements SettingsService {
  
  final loginServiceImpl = Sint.find<LoginService>();
  final userServiceImpl = Sint.find<UserService>();
  final analyticsRepositoryImpl = Sint.find<AnalyticsRepository>();
  final jobsRepositoryImpl = Sint.find<JobRepository>();

  final RxBool isLoading = true.obs;
  final RxString newLanguage = "".obs;
  final Rx<AppLocale> appLocale = AppLocale.english.obs;
  final Rx<LocationPermission> locationPermission = LocationPermission.whileInUse.obs;

  @override
  void onInit() async {
    super.onInit();
    AppConfig.logger.d("Settings Controller Init");
    await userServiceImpl.getProfiles();
    newLanguage.value = AppLocaleUtilities.languageFromLocale(Sint.locale!);
    isLoading.value = false;
    locationPermission.value = await Geolocator.checkPermission();
  }

  @override
  void setNewLanguage(String newLang){
    AppConfig.logger.d("Setting new language as $newLang");
    newLanguage.value = newLang;
    update([AppPageIdConstants.settingsPrivacy]);
  }

  @override
  void setNewLocale(){
    AppConfig.logger.d("Setting new locale");
    appLocale.value = EnumToString.fromString(AppLocale.values, newLanguage.value)!;
    bool isAvailable = false;
    Sint.back();

    switch(appLocale.value){
      case AppLocale.spanish:
        isAvailable = true;
        break;
      case AppLocale.english:
      case AppLocale.french:
        if(AppConfig.instance.appInUse == AppInUse.g) isAvailable = true;
        break;
      case AppLocale.deutsch:
        break;
    }

    try {
      if(isAvailable) {
        AppHiveController().setLocale(appLocale.value);
        AppHiveController().updateLocale(appLocale.value);
      } else {
        AppUtilities.showSnackBar(
          title: CommonTranslationConstants.underConstruction.tr,
          message: MessageTranslationConstants.underConstructionMsg.tr,
        );
      }
    } catch (e) {
      AppConfig.logger.e(e.toString());
    }

    update([AppPageIdConstants.settingsPrivacy]);
  }

  @override
  Future<void> verifyLocationPermission() async {
    AppConfig.logger.d("Verifying and requesting location permission");
    locationPermission.value = await GeoLocatorController().requestPermission();
    update([AppPageIdConstants.settingsPrivacy]);
  }

  @override
  Future<void> runAnalyticJobs() async {
    isLoading.value = true;

    try {
      await analyticsRepositoryImpl.setUserLocations();
    } catch(e) {
      AppConfig.logger.e(e.toString());
    }

    isLoading.value = false;
    AppConfig.logger.d("Analytic Job successfully ran.");
    update([AppPageIdConstants.settingsPrivacy]);
  }

  @override
  Future<void> runProfileJobs() async {
    isLoading.value = true;
    update([AppPageIdConstants.settingsPrivacy]);

    try {
      await jobsRepositoryImpl.createProfileInstrumentsCollection();
    } catch(e) {
      AppConfig.logger.e(e.toString());
    }

    isLoading.value = false;
    AppConfig.logger.d("Profile Job successfully ran.");
    update([AppPageIdConstants.settingsPrivacy]);
  }

}
