import 'package:get/get.dart';


import 'package:neom_core/utils/constants/app_route_constants.dart';

import 'ui/about_page.dart';
import 'ui/account_settings_page.dart';
import 'ui/blocked_profiles_page.dart';
import 'ui/content_preferences.dart';
import 'ui/privacy_and_terms_page.dart';
import 'ui/settings_and_privacy_page.dart';

class SettingRoutes {

  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: AppRouteConstants.settingsPrivacy,
      page: () => const SettingsPrivacyPage(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: AppRouteConstants.privacyAndTerms,
      page: () => const PrivacyAndTermsPage(),
    ),
    GetPage(
      name: AppRouteConstants.settingsAccount,
      page: () => const AccountSettingsPage(),
    ),
    GetPage(
      name: AppRouteConstants.contentPreferences,
      page: () => const ContentPreferencePage(),
    ),
    GetPage(
      name: AppRouteConstants.about,
      page: () => const AboutPage(),
    ),
    GetPage(
      name: AppRouteConstants.blockedProfiles,
      page: () => const BlockedProfilesPage(),
    ),
  ];

}
