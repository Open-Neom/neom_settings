import 'package:neom_core/utils/constants/app_route_constants.dart';
import 'package:sint/sint.dart';

import 'ui/about_page.dart';
import 'ui/account_settings_page.dart';
import 'ui/blocked_profiles_page.dart';
import 'ui/content_preferences_page.dart';
import 'ui/privacy_and_terms_page.dart';
import 'ui/settings_and_privacy_page.dart';

class SettingRoutes {

  static final List<SintPage<dynamic>> routes = [
    SintPage(
      name: AppRouteConstants.settingsPrivacy,
      page: () => const SettingsPrivacyPage(),
      transition: Transition.leftToRight,
    ),
    SintPage(
      name: AppRouteConstants.privacyAndTerms,
      page: () => const PrivacyAndTermsPage(),
    ),
    SintPage(
      name: AppRouteConstants.settingsAccount,
      page: () => const AccountSettingsPage(),
    ),
    SintPage(
      name: AppRouteConstants.contentPreferences,
      page: () => const ContentPreferencePage(),
    ),
    SintPage(
      name: AppRouteConstants.about,
      page: () => const AboutPage(),
    ),
    SintPage(
      name: AppRouteConstants.blockedProfiles,
      page: () => const BlockedProfilesPage(),
    ),
  ];

}
