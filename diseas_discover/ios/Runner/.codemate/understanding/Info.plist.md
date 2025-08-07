# High-Level Documentation: iOS App Info.plist

This code is an XML-formatted **Info.plist** file—a property list configuration file for an iOS application. The Info.plist is essential for iOS apps, providing metadata that the operating system uses to understand how to launch and manage the app. Here's an overview of its key components:

---

## Core Information

- **App Identity**
  - **CFBundleDisplayName**: The display name of the app as shown on the device (here: "Diseas Discover").
  - **CFBundleName**: The internal short name of the bundle.
  - **CFBundleIdentifier**: The unique identifier for the app (typically reverse-domain style, set via build variable).
  - **CFBundleExecutable**: The name of the main executable.
  - **CFBundleVersion & CFBundleShortVersionString**: The build number and user-visible version of the app.

- **Localization**
  - **CFBundleDevelopmentRegion**: The app’s default language/region.

---

## App Launch & UI

- **Launch Files**
  - **UILaunchStoryboardName**: The storyboard used for the launch screen ("LaunchScreen").
  - **UIMainStoryboardFile**: The main storyboard for the app UI ("Main").

- **Supported Interface Orientations**
  - For iPhone: Portrait, Landscape Left & Right.
  - For iPad: Portrait, Portrait Upside Down, Landscape Left & Right.

---

## Platform and System Features

- **CFBundlePackageType**: Set as "APPL", identifying it as an application.
- **CFBundleSignature**: Placeholder signature (legacy macOS/iOS field).
- **LSRequiresIPhoneOS**: Declares the app is for iOS/iPadOS devices only.
- **CADisableMinimumFrameDurationOnPhone**: Performance-related flag (may relate to animation frame intervals).
- **UIApplicationSupportsIndirectInputEvents**: Indicates support for indirect input (such as keyboards, game controllers, or pointer events).

---

## Variable Placeholders

Several values are dynamically set during build time via variables:
- **$(DEVELOPMENT_LANGUAGE)**
- **$(EXECUTABLE_NAME)**
- **$(PRODUCT_BUNDLE_IDENTIFIER)**
- **$(FLUTTER_BUILD_NAME)**
- **$(FLUTTER_BUILD_NUMBER)**

These allow easy configuration for different builds and environments.

---

## Summary

This **Info.plist** configures the essential parameters of a Flutter-based iOS app, specifying its name, identity, supported device orientations, launch files, and certain system capabilities, while leveraging variable substitution for flexibility across build environments.