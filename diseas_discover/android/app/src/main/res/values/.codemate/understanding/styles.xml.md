**High-Level Documentation**

This XML file defines two custom Android themes related to app startup and display, primarily for use in a Flutter project:

1. **LaunchTheme**
   - Inherits from Android’s `Theme.Light.NoTitleBar`.
   - Sets a custom background drawable (`@drawable/launch_background`) as the window background.
   - Purpose: Used as the splash screen theme while the app's process initializes, before Flutter draws its first frame.
   - Visible only momentarily during app startup to show a branded or styled launch image.

2. **NormalTheme**
   - Also inherits from `Theme.Light.NoTitleBar`.
   - Sets the window background to the system’s default background color (`?android:colorBackground`).
   - Purpose: Applied once the app process has started and while the Flutter UI is initializing and running.
   - Ensures the system window blends with the Flutter UI.

**Usage Note:**
- `LaunchTheme` provides a visually appealing first impression during the brief startup moment.
- `NormalTheme` takes over once Flutter is ready, ensuring seamless transition and proper window background during app runtime.
- These patterns follow Flutter’s recommendations for Android window theming, especially with Flutter v2 embedding.

**Target Audience:**  
Android and Flutter developers integrating native styling and splash screens into their app startup sequence.