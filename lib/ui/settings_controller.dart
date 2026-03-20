import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:geolocator/geolocator.dart';
import 'package:neom_commons/utils/app_locale_utilities.dart';
import 'package:neom_commons/utils/app_utilities.dart';
import 'package:neom_commons/utils/constants/app_page_id_constants.dart';
import 'package:neom_commons/utils/constants/translations/app_translation_constants.dart';
import 'package:neom_commons/utils/constants/translations/common_translation_constants.dart';
import 'package:neom_commons/utils/constants/translations/message_translation_constants.dart';
import 'package:neom_core/app_config.dart';
import 'package:neom_core/cloud_properties.dart';
import 'package:neom_core/data/implementations/app_hive_controller.dart';
import 'package:neom_core/data/implementations/geolocator_controller.dart';
import 'package:neom_core/domain/model/saia/saia_job_progress.dart';
import 'package:neom_core/domain/model/vector_index/vector_index_job_result.dart';
import 'package:neom_core/domain/model/vector_index/vector_index_progress.dart';
import 'package:neom_core/domain/repository/analytics_repository.dart';
import 'package:neom_core/domain/repository/job_repository.dart';
import 'package:neom_core/domain/use_cases/login_service.dart';
import 'package:neom_core/domain/use_cases/saia_admin_service.dart';
import 'package:neom_core/domain/use_cases/settings_service.dart';
import 'package:neom_core/domain/use_cases/user_service.dart';
import 'package:neom_core/domain/use_cases/vector_index_admin_service.dart';
import 'package:neom_core/utils/enums/app_in_use.dart';
import 'package:neom_core/utils/enums/app_locale.dart';
import 'package:neom_core/utils/neom_flow_tracker.dart';
import 'package:sint/sint.dart';

import '../utils/constants/setting_translation_constants.dart';

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
    NeomFlowTracker.trackScreen('settings');
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

  /// Vector index job progress state
  final Rx<VectorIndexProgress?> vectorIndexProgress = Rx<VectorIndexProgress?>(null);
  final RxBool isVectorJobRunning = false.obs;

  @override
  Future<void> runVectorIndexJob() async {
    if (isVectorJobRunning.value) return;

    isVectorJobRunning.value = true;
    update([AppPageIdConstants.settingsPrivacy]);

    final geminiApiKey = CloudProperties.getGeminiApiKey();
    final adminService = Sint.find<VectorIndexAdminService>();

    adminService.initialize(
      geminiApiKey: geminiApiKey,
      extractContent: geminiApiKey.isNotEmpty,
    );

    // Set up progress callback
    adminService.onProgressUpdate = (VectorIndexProgress progress) {
      vectorIndexProgress.value = progress;
      update([AppPageIdConstants.settingsPrivacy]);
    };

    try {
      AppConfig.logger.d("Starting Vector Index Job...");

      VectorIndexJobResult result = await adminService.runIndexJob(
        batchSize: 10,
        forceReindex: false,
      );

      AppConfig.logger.d("Vector Index Job completed: $result");

      // Show result
      AppUtilities.showSnackBar(
        title: result.success
            ? SettingTranslationConstants.vectorIndexJobComplete.tr
            : AppTranslationConstants.error.tr,
        message: result.message,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      AppConfig.logger.e("Vector Index Job failed: $e");
      AppUtilities.showSnackBar(
        title: AppTranslationConstants.error.tr,
        message: e.toString(),
      );
    }

    isVectorJobRunning.value = false;
    vectorIndexProgress.value = null;
    update([AppPageIdConstants.settingsPrivacy]);
  }

  /// Error log summary for admin section
  final RxList<Map<String, dynamic>> errorLogSummary = <Map<String, dynamic>>[].obs;
  final RxBool isErrorLogLoading = false.obs;
  int get totalErrorCount => errorLogSummary.fold(0, (acc, e) => acc + ((e['totalErrors'] as int?) ?? 0));

  Future<void> loadErrorLogSummary() async {
    if (isErrorLogLoading.value) return;
    isErrorLogLoading.value = true;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('errorLogs')
          .orderBy('totalErrors', descending: true)
          .limit(20)
          .get();

      errorLogSummary.value = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      AppConfig.logger.e('Error loading error logs: $e');
    }

    isErrorLogLoading.value = false;
    update([AppPageIdConstants.settingsPrivacy]);
  }

  /// SAIA admin job state
  final Rx<SaiaJobProgress?> saiaJobProgress = Rx<SaiaJobProgress?>(null);
  final RxBool isSaiaJobRunning = false.obs;
  final Rx<SaiaJobDashboard?> saiaDashboard = Rx<SaiaJobDashboard?>(null);

  /// Whether SaiaAdminService is available via DI
  bool get isSaiaAvailable {
    try {
      Sint.find<SaiaAdminService>();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Load SAIA dashboard (pending counts)
  Future<void> loadSaiaDashboard() async {
    if (!isSaiaAvailable) return;
    try {
      final saiaService = Sint.find<SaiaAdminService>();
      saiaDashboard.value = await saiaService.buildDashboard();
      update([AppPageIdConstants.settingsPrivacy]);
    } catch (e) {
      AppConfig.logger.e('Error loading SAIA dashboard: $e');
    }
  }

  @override
  Future<void> runSaiaDomainContextJob() async {
    await _runSaiaJob((service) => service.runDomainContextJob());
  }

  @override
  Future<void> runSaiaUserContextsJob({bool forceRebuild = false}) async {
    await _runSaiaJob((service) => service.runUserContextsJob(forceRebuild: forceRebuild));
  }

  @override
  Future<void> runSaiaFullPipelineJob() async {
    await _runSaiaJob((service) => service.runFullPipeline());
  }

  Future<void> _runSaiaJob(Future<SaiaJobResult> Function(SaiaAdminService) jobFn) async {
    if (isSaiaJobRunning.value || !isSaiaAvailable) return;

    isSaiaJobRunning.value = true;
    update([AppPageIdConstants.settingsPrivacy]);

    final saiaService = Sint.find<SaiaAdminService>();

    saiaService.onProgressUpdate = (SaiaJobProgress progress) {
      saiaJobProgress.value = progress;
      update([AppPageIdConstants.settingsPrivacy]);
    };

    try {
      final result = await jobFn(saiaService);

      AppUtilities.showSnackBar(
        title: result.success
            ? SettingTranslationConstants.saiaJobComplete.tr
            : AppTranslationConstants.error.tr,
        message: result.message,
        duration: const Duration(seconds: 5),
      );

      // Refresh dashboard after job
      await loadSaiaDashboard();
    } catch (e) {
      AppConfig.logger.e('SAIA job failed: $e');
      AppUtilities.showSnackBar(
        title: AppTranslationConstants.error.tr,
        message: e.toString(),
      );
    }

    isSaiaJobRunning.value = false;
    saiaJobProgress.value = null;
    update([AppPageIdConstants.settingsPrivacy]);
  }

}
