# neom_settings
Purpose & Overview
neom_settings is a dedicated module within the Open Neom ecosystem responsible for managing all user-specific
and application-wide settings, preferences, and legal information. It provides a centralized and intuitive interface
for users to customize their experience, manage their account, control privacy, and access important legal and support resources.

This module is designed with a strong emphasis on user autonomy and transparency, aligning with Open Neom's vision of empowering
users in their digital well-being journey. It adheres to the Clean Architecture principles, ensuring that its functionalities
are well-organized, testable, and maintainable, while seamlessly integrating with neom_core for core data and neom_commons for shared UI components.

🌟 Features & Responsibilities
neom_settings provides a comprehensive suite of functionalities to manage various aspects of the user's interaction with the application:
•	User Account Management: Allows users to view and update their account details (e.g., phone number), manage subscriptions,
    and handle account/profile removal requests.
•	Privacy Controls: Offers options for managing privacy settings, including viewing and unblocking other profiles,
    and controlling location usage permissions.
•	Content Preferences: Enables users to customize their content experience, such as selecting the preferred application language.
•	Legal & Information Access: Provides direct access to essential legal documents like Terms of Service, Privacy Policy, Cookie Use,
    and Legal Notices, ensuring transparency. It also includes an "About" section with application version details and links
    to developer resources (GitHub, LinkedIn).
•	Support & Contact: Facilitates user support through various contact options (email, WhatsApp, Instagram),
    fostering community engagement and assistance.
•	Administrative Tools (Conditional): For users with appropriate roles (e.g., superAdmin), it provides access to administrative
    functionalities such as creating coupons/sponsors, managing user directories, viewing analytics, and running specific background jobs.
•	Internationalization (i18n): Manages the application's language settings, allowing users to switch between supported
    locales and enhancing global accessibility.
•	Location Permission Management: Integrates with device location services to verify and request necessary permissions,
    crucial for location-aware features.

Technical Highlights / Why it Matters (for developers)
For developers, neom_settings is an excellent module to study for understanding:
•	Modular UI Design: Demonstrates how to structure a complex settings section into multiple, navigable sub-pages 
    (AccountSettingsPage, PrivacyAndTermsPage, ContentPreferencePage, AboutPage, BlockedProfilesPage).
•   GetX State Management: Utilizes GetX for efficient state management (SettingsController, AccountSettingsController),
    handling reactive variables (RxBool, RxString, Rx<AppLocale>) and updating specific parts of the UI.
•	Service Layer Interaction: Shows how a UI-focused module interacts with various core services (LoginService, UserService,
    AnalyticsRepository, JobRepository, SubscriptionController) through their defined interfaces, maintaining architectural separation.
•	Dynamic UI Rendering: Implements conditional UI elements based on user roles (UserRole), application flavor (AppInUse),
    and data availability (e.g., blocked profiles list), showcasing flexible UI adaptation.
•	External Integrations: Provides examples of launching external URLs (email, WhatsApp, web links)
    and handling platform-specific permissions (Geolocator).
•	Localization Best Practices: Demonstrates how to integrate enum_to_string and Get.locale
    for robust internationalization of text and UI elements.

How it Supports the Open Neom Initiative
neom_settings is vital to the Open Neom ecosystem and the broader Tecnozenism vision by:
•	Empowering User Autonomy: It provides users with direct control over their data, preferences, and account,
    aligning with the principles of decentralization and conscious engagement with technology.
•	Ensuring Transparency: By making legal information and app details easily accessible,
    it fosters trust and transparency within the community.
•	Facilitating Global Adoption: Comprehensive language settings support Open Neom's goal of reaching
    a global audience and democratizing access to its technologies.
•	Supporting Community & Research: The contact options and administrative tools (for relevant roles) enable effective community
    management and support research-related activities within the platform.
•	Showcasing Clean Architecture: As a well-defined feature module, it exemplifies how a complex set of functionalities can be built
    and maintained within Open Neom's modular and decoupled architectural framework.

🚀 Usage
This module provides a collection of pages and a controller that can be integrated into the main application's navigation flow,
typically accessible from a main AppDrawer or a dedicated settings icon.

🛠️ Dependencies
neom_settings relies on neom_core for core services, models, and routing constants,
and on neom_commons for reusable UI components, themes, and utility functions.

🤝 Contributing
We welcome contributions to the neom_settings module! If you're passionate about user experience, privacy, or administrative tools,
your contributions can directly enhance the platform's usability and governance.

To understand the broader architectural context of Open Neom and how neom_settings fits into the overall
vision of Tecnozenism, please refer to the main project's MANIFEST.md.

For guidance on how to contribute to Open Neom and to understand the various levels of learning and engagement possible within the project,
consult our comprehensive guide: Learning Flutter Through Open Neom: A Comprehensive Path.

📄 License
This project is licensed under the Apache License, Version 2.0, January 2004. See the LICENSE file for details.
