### 1.0.0 - Initial Release & Decoupling from neom_home

This marks the **initial official release (v1.0.0)** of `neom_settings` as a standalone, independent module within the Open Neom ecosystem. Previously, its functionalities were integrated directly into `neom_home`. This decoupling is a key step in further enhancing Open Neom's modularity, testability, and adherence to Clean Architecture principles.

**Key Highlights of this Release:**

* **Module Decoupling:**
    * `neom_settings` has been fully separated from `neom_home`, allowing it to manage all settings-related UI and logic independently.
    * This improves the clarity of responsibilities and reduces inter-module coupling.

* **Centralized Settings Management:**
    * Provides a comprehensive and organized interface for all user and application settings, including:
        * Account Management (e.g., phone number updates, subscription status, account/profile removal).
        * Privacy Controls (e.g., blocked profiles, location permissions).
        * Content Preferences (e.g., language selection).
        * Access to Legal & Information (Terms of Service, Privacy Policy, About App).
        * Support and Contact options.
        * Conditional Admin Tools (for authorized users).

* **Enhanced Maintainability & Scalability:**
    * As a dedicated module, `neom_settings` is now easier to maintain, test, and extend without impacting other core parts of the application.
    * This aligns with the overall architectural vision of Open Neom, fostering a more collaborative and efficient development environment.

* **Leverages Core Open Neom Modules:**
    * Built upon `neom_core` for fundamental services and data models, and `neom_commons` for shared UI components, ensuring consistency and efficiency across the platform.