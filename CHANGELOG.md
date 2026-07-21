
## [2.0.0-unreleased] - 2026-07-21
- Refactor and compatibility updates for setting_de_translations.dart, setting_fr_translations.dart.
# Changelog - neom_settings

## Unreleased - System updates
- Actualizaciones de estabilidad y compatibilidad.

## Unreleased - Settings support opens the chat directly
- Tapping **"Atención y Soporte"** in Settings now opens the support inbox thread **directly** (no intermediate "Enviar mi pregunta" section/click). Removed the now-unused support section.

## Unreleased - "Atención al Cliente" entry in Settings
- Added a **Customer Support** option in Settings (web nav section + mobile account row). Tapping **"Enviar mi pregunta"** opens (or creates) the user's support inbox thread (`InboxFirestore.getOrCreateAppBotRoom`) and navigates to it, so they send their question directly — and the thread also appears in their regular Inbox for follow-up. New translations `customerSupport` / `customerSupportDesc` / `sendYourQuestion` (ES/EN/FR/DE).

### 1.2.0 - Vector Index Admin Job & Code Quality

This release introduces admin tools for AI-powered content indexing and code quality improvements.

**New Features:**

**Vector Index Admin Job:**
- `runVectorIndexJob()` method in SettingsController
- Real-time progress tracking via `VectorIndexProgress`
- Gemini API integration for AI embeddings
- PDF content extraction for richer indexing
- Batch processing with configurable size
- Progress callback with UI updates

**Admin Tools:**
- Vector index job accessible for superAdmin users
- Job status display with progress indicator
- Success/error notifications
- Cancel job capability

**Code Quality:**
- Updated to flutter_lints ^6.0.0
- SDK constraint updated to >=3.8.0 <4.0.0
- Import ordering fixes (directives_ordering)
- Service interface improvements

**Documentation:**
- Comprehensive README.md with ROADMAP 2026
- Architecture documentation
- Admin job usage examples

---

### 1.1.0 - Enhanced Account Management

**Features:**
- Subscription management integration
- Blocked profiles viewing and unblocking
- Profile removal request flow
- Phone number update functionality

**Privacy & Terms:**
- Terms of Service access
- Privacy Policy display
- Cookie Use information
- Legal Notices section

**Admin Features:**
- Analytics job execution
- Profile batch jobs
- Coupon creation (superAdmin)
- User directory access

---

### 1.0.0 - Initial Release & Decoupling from neom_home

This marks the initial official release of `neom_settings` as a standalone module.

**Module Decoupling:**
- Fully separated from `neom_home`
- Independent settings management
- Clear responsibility boundaries

**Centralized Settings Management:**
- Account Management (phone, subscription, removal)
- Privacy Controls (blocked profiles, location)
- Content Preferences (language selection)
- Legal & Information access
- Support and Contact options
- Conditional Admin Tools

**Architecture:**
- `SettingsController` implementing `SettingsService`
- `AccountSettingsController` for account operations
- Multiple specialized settings pages
- Translation constants for localization

**Dependencies:**
- Built upon `neom_core` for services and models
- Uses `neom_commons` for shared UI components
