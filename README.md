# neom_settings

A comprehensive settings and preferences management module for Flutter applications, part of the Open Neom ecosystem.

## Current Version: 1.2.0

## Philosophy

**User autonomy and transparency.** neom_settings empowers users with full control over their data, preferences, and account, aligning with the principles of decentralization and conscious engagement with technology.

## Features

### Current Capabilities (v1.2.0)

#### Account Management
- **Profile Updates** - Phone number, subscription status
- **Account Removal** - Request account/profile deletion
- **Subscription Management** - View and manage subscriptions
- **Blocked Profiles** - View and unblock users

#### Privacy Controls
- **Location Permissions** - Manage location access
- **Privacy Settings** - Control data visibility
- **Terms & Policies** - Access legal documents

#### Content Preferences
- **Language Selection** - Multi-language support (ES, EN, FR)
- **Locale Management** - Persistent language settings
- **Theme Preferences** - UI customization

#### Admin Tools (v1.2.0)
- **Vector Index Job** - Run AI-powered content indexing
- **Analytics Jobs** - User location analytics
- **Profile Jobs** - Batch profile processing
- **Coupon Management** - Create promotional codes

#### Support & Contact
- **Email Support** - Direct email contact
- **WhatsApp** - Instant messaging support
- **Social Links** - Instagram, GitHub, LinkedIn

## Installation

```yaml
dependencies:
  neom_settings:
    git:
      url: git@github.com:Open-Neom/neom_settings.git
```

## Usage

### Navigate to Settings

```dart
import 'package:neom_settings/setting_routes.dart';

// Open main settings page
Navigator.pushNamed(context, AppRouteConstants.settingsAndPrivacy);

// Open specific settings section
Navigator.pushNamed(context, AppRouteConstants.accountSettings);
Navigator.pushNamed(context, AppRouteConstants.privacyAndTerms);
Navigator.pushNamed(context, AppRouteConstants.contentPreferences);
Navigator.pushNamed(context, AppRouteConstants.about);
```

### Vector Index Admin Job

```dart
// Run from SettingsController
final settingsController = Sint.find<SettingsController>();
await settingsController.runVectorIndexJob();

// Progress is tracked via vectorIndexProgress observable
Obx(() {
  final progress = settingsController.vectorIndexProgress.value;
  if (progress != null) {
    return LinearProgressIndicator(value: progress.progress);
  }
  return SizedBox.shrink();
})
```

---

## ROADMAP 2026: Intelligent Settings Platform

Our vision is to create a **personalized, AI-enhanced settings experience** that adapts to user behavior and preferences.

### Q1 2026: Smart Preferences

#### AI-Powered Personalization
- [ ] **Usage Analysis** - Learn from user behavior
- [ ] **Smart Defaults** - AI-suggested settings
- [ ] **Preference Sync** - Cross-device settings sync
- [ ] **Backup & Restore** - Cloud settings backup
- [ ] **Import/Export** - Settings portability

#### Enhanced Privacy
- [ ] **Privacy Dashboard** - Visual data usage overview
- [ ] **Data Download** - Export all user data (GDPR)
- [ ] **Consent Management** - Granular permission controls
- [ ] **Audit Log** - View account activity history

### Q2 2026: Admin Enhancement

#### Advanced Admin Tools
- [ ] **Batch Operations** - Multi-user management
- [ ] **Scheduled Jobs** - Cron-like job scheduling
- [ ] **Job History** - View past job results
- [ ] **Real-time Monitoring** - Live job dashboards
- [ ] **Error Alerts** - Proactive issue detection

#### Content Management
- [ ] **Vector Index Dashboard** - Visual index management
- [ ] **Content Moderation** - Flag and review content
- [ ] **Analytics Dashboard** - User engagement metrics
- [ ] **A/B Testing** - Settings experiments

### Q3 2026: Accessibility & UX

#### Accessibility Features
- [ ] **Screen Reader** - Full VoiceOver/TalkBack support
- [ ] **High Contrast** - Accessibility theme options
- [ ] **Font Scaling** - Custom text sizing
- [ ] **Motion Reduction** - Reduce animations option
- [ ] **Keyboard Navigation** - Full keyboard support

#### Enhanced UX
- [ ] **Search Settings** - Find settings quickly
- [ ] **Quick Actions** - Common settings shortcuts
- [ ] **Settings Wizard** - Guided initial setup
- [ ] **Contextual Help** - In-app setting explanations

### Q4 2026: Integration & Automation

#### Automation
- [ ] **Settings Rules** - Conditional preferences
- [ ] **Time-Based Settings** - Schedule preference changes
- [ ] **Location-Based** - Settings based on location
- [ ] **Profile Modes** - Work, Home, Travel presets

#### Integrations
- [ ] **Webhook Notifications** - External event triggers
- [ ] **API Access** - Settings via REST API
- [ ] **Third-Party Sync** - Connect external services

---

## Architecture

```
lib/
├── domain/
│   └── use_cases/
│       └── account_settings_service.dart   # Service interface
├── ui/
│   ├── settings_controller.dart            # Main settings logic
│   ├── account_settings_controller.dart    # Account-specific logic
│   ├── settings_and_privacy_page.dart      # Main settings page
│   ├── account_settings_page.dart          # Account settings
│   ├── privacy_and_terms_page.dart         # Legal documents
│   ├── content_preferences_page.dart       # Language & preferences
│   ├── blocked_profiles_page.dart          # Blocked users
│   └── about_page.dart                     # App info & credits
├── utils/
│   └── constants/
│       └── setting_translation_constants.dart
└── setting_routes.dart                     # Route definitions
```

## Key Components

### SettingsController
- Implements `SettingsService` interface
- Language/locale management
- Location permission handling
- Admin job execution (analytics, profiles, vector index)
- Vector index progress tracking

### AccountSettingsController
- Account update operations
- Subscription management
- Profile removal requests
- Phone number verification

### Admin Features
- **runVectorIndexJob()** - AI content indexing via Gemini
- **runAnalyticJobs()** - User location analytics
- **runProfileJobs()** - Batch profile processing

## Dependencies

- `neom_core` - Core services, models, and repositories
- `neom_commons` - Shared UI components and themes
- `sint` - State management (GetX-based)
- `geolocator` - Location permissions (via neom_core)
- `enum_to_string` - Locale enum handling

## Admin Job Requirements

For vector index job:
```dart
// Requires VectorIndexAdminService registered in Sint
// Typically registered by neom_corpus module
Sint.lazyPut<VectorIndexAdminService>(() => VectorIndexAdminServiceImpl());
```

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.

---

**Open Neom** - Empowering user autonomy through transparent settings.
