# High-Level Documentation: AndroidManifest.xml Overview

This `AndroidManifest.xml` configures the manifest for an Android application named **diseas_discover**. Below is a high-level summary of its purpose and main configurations:

---

## Application Declaration
- **App Name & Icon:** 
  - Name: `diseas_discover` (can be overridden by `${applicationName}` variable at build time)
  - Icon: Uses `@mipmap/launcher_icon`
- **Custom Application Class:** May be configured via `${applicationName}`.

---

## Main Activity Configuration

### Main Activity (`.MainActivity`)
- **Entry Point:** Declared as the launcher activity via intent filter for `MAIN` action and `LAUNCHER` category.
- **Exported:** Set to `true` — allows it to be started from outside the app.
- **LaunchMode:** `singleTop` - Reuses the activity instance at the top of the stack.
- **Task Affinity:** Empty string specifies the default activity task affiliation (can affect task switching).
- **Theme:**
  - **LaunchTheme**: Used to style this activity during Flutter UI initialization and as window background after.
  - **NormalTheme**: Applied via meta-data for Flutter embedding.
- **Configuration Changes:** Handles a broad range of device and UI changes to avoid activity recreation (orientation, locale, font scale, screen layout, etc.).
- **Window features:** 
  - `hardwareAccelerated="true"` enables hardware-accelerated rendering.
  - `windowSoftInputMode="adjustResize"` ensures the layout resizes when the soft keyboard appears.

---

## Meta-Data Tags
- **io.flutter.embedding.android.NormalTheme:** Specifies a normal theme for Flutter embedding.
- **flutterEmbedding:** Indicates Flutter embedding version (`2`). Required by the Flutter build tools.

---

## Package Visibility (Queries Section)
- **Purpose:** Allows the app to query for activities capable of processing text (required for Flutter's text processing plugins such as `ProcessTextPlugin`).
- **Intent filter:** Matches intents for processing plain text.

---

## General Notes
- This manifest is tailored for a Flutter application.
- Ensures correct theme and configuration compatibility during lifecycle and UI changes.
- Handles package visibility requirements introduced in Android 11 and later.
- Comments offer references and explanations for developers working with Flutter on Android.

---

**Summary:**  
This manifest sets up a robust entry point for a Flutter-based Android app with proper configuration to handle various device states, support required Flutter plugins, and ensure correct theming and icon usage.