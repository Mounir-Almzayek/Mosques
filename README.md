# Mosque Smart Display & Settings 🕌


A comprehensive, real-time Smart Mosque solution built with Flutter. This project provides a beautiful, customizable display for prayer times, announcements, and spiritual content, seamlessly synchronized across devices via Firebase.

![App Screenshot](assets/Screenshot.png)

---

## 🚀 Key Features

*   **Real-time Prayer Times:** Automatic calculation and display of prayer times using the `adhan` package, with instant synchronization across all connected screens.
*   **Dynamic Countdown:** Accurate countdown timers for the next prayer and Iqamah times.
*   **Advanced Customization:** 
    *   Customizable themes (Colors, Fonts, Backgrounds).
    *   Support for multiple background types (Solid, Gradient, Image).
    *   Granular control over font sizes and styles for every UI element.
*   **Instant Alerts & Announcements:** Real-time push notifications and scrollable marquee announcements for the congregation.
*   **Multi-Language Support:** Fully localized supporting Arabic and English (English by default, easily switchable).
*   **Hijri Calendar:** Integrated Hijri date display with manual adjustment options.
*   **Spiritual Content:** Display of Hadiths, Quranic verses, and DHikr.
*   **Offline Resilience:** Graceful handling of network interruptions with local caching and calculation fallback.
*   **Over-the-Air Updates:** Integrated with **Shorebird** for seamless, instant app updates without requiring a manual re-install.

---

## ✨ Project Advantages

*   **Premium UI/UX:** Modern, sleek, and high-contrast design optimized for large mosque displays.
*   **High Performance:** Built with **Flutter** and optimized with **BLoC** for smooth state management.
*   **Infinite Scalability:** Powered by **Firebase (Firestore, Auth, Messaging)** to handle multiple mosques and screens effortlessly.
*   **Extreme Flexibility:** Adjust prayer time offsets, calculation methods (MWL, ISNA, Egypt, etc.), and jurisdictional settings (Hanafi, Shafi'i).
*   **User-Friendly Admin:** Manage everything from a dedicated mobile settings interface.

---

## 🏗️ Architecture & Tech Stack

This project follows **Clean Architecture** principles to ensure maintainability and testability:

*   **Core:** Common utilities, themes, enums, and localization.
*   **Data:** Models, Repository implementations, and Data sources (Firestore, Local Hive DB).
*   **Features:** Modularized logic and UI (Auth, Display, Settings, Language, Splash).
*   **State Management:** `flutter_bloc` for predictable state transitions.
*   **Navigation:** `go_router` for robust routing.
*   **Database:** `Cloud Firestore` (Real-time Sync) & `Hive` (Local Storage).

---

## 🛠️ Local Setup

1.  **Prerequisites:**
    *   Flutter SDK (^3.10.7)
    *   A Firebase project configured for Android/iOS/Web.
2.  **Environment Variables:**
    *   Ensure any required keys are set up in a `.env` file if applicable (check `assets/.env`).
3.  **Run the project:**
    ```bash
    flutter pub get
    flutter run
    ```
4.  **Shorebird Setup:**
    ```bash
    shorebird login
    shorebird init
    shorebird release android
    ```

---

## 📞 Contact for a Free Account 🎁

To benefit from a **completely free, fully active account** and explore the full potential of this smart mosque system, please reach out to the project creator:

**Mounir Almzayek**
*   **GitHub:** [Mounir-Almzayek](https://github.com/Mounir-Almzayek)
*   **Inquiries:** Please contact me via GitHub or LinkedIn for access to a live demo and a free active account.

---

*Developed for the benefit of mosques worldwide.*
