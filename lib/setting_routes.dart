import 'package:neom_core/ui/deferred_loader.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';
import 'package:sint/sint.dart';

import 'ui/about_page.dart' deferred as about;
import 'ui/account_settings_page.dart' deferred as account;
import 'ui/billing_page.dart' deferred as billing;
import 'ui/blocked_profiles_page.dart' deferred as blocked;
import 'ui/content_preferences_page.dart' deferred as content_prefs;
import 'ui/privacy_and_terms_page.dart' deferred as privacy_terms;
import 'ui/settings_and_privacy_page.dart' deferred as settings_privacy;
import 'ui/subscription_plans_page.dart' deferred as sub_plans;

class SettingRoutes {

  static final List<SintPage<dynamic>> routes = [
    SintPage(
      name: AppRouteConstants.settingsPrivacy,
      page: () => DeferredLoader(settings_privacy.loadLibrary, () => settings_privacy.SettingsPrivacyPage()),
      transition: Transition.leftToRight,
    ),
    SintPage(
      name: AppRouteConstants.privacyAndTerms,
      page: () => DeferredLoader(privacy_terms.loadLibrary, () => privacy_terms.PrivacyAndTermsPage()),
    ),
    SintPage(
      name: AppRouteConstants.settingsAccount,
      page: () => DeferredLoader(account.loadLibrary, () => account.AccountSettingsPage()),
    ),
    SintPage(
      name: AppRouteConstants.billing,
      page: () => DeferredLoader(billing.loadLibrary, () => billing.BillingPage()),
    ),
    SintPage(
      name: AppRouteConstants.subscriptionPlans,
      page: () => DeferredLoader(sub_plans.loadLibrary, () => sub_plans.SubscriptionPlansPage()),
    ),
    SintPage(
      name: AppRouteConstants.contentPreferences,
      page: () => DeferredLoader(content_prefs.loadLibrary, () => content_prefs.ContentPreferencePage()),
    ),
    SintPage(
      name: AppRouteConstants.about,
      page: () => DeferredLoader(about.loadLibrary, () => about.AboutPage()),
    ),
    SintPage(
      name: AppRouteConstants.blockedProfiles,
      page: () => DeferredLoader(blocked.loadLibrary, () => blocked.BlockedProfilesPage()),
    ),
  ];

}
