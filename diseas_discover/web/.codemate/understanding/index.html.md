# High-Level Documentation

## Overview

This HTML file serves as the entry point for a Flutter web application named **"diseas_discover."** It lays out the structure, metadata, and resources needed to initialize and run the Flutter app in a web browser.

---

## Key Components

### 1. Base Href Configuration
- Uses the `<base>` tag with a placeholder (`$FLUTTER_BASE_HREF`) that enables serving the app from a subdirectory path.
- Ensures correct resource paths when deploying to non-root domains.

### 2. Metadata Tags
- Specifies character encoding (`UTF-8`).
- Sets compatibility for IE Edge.
- Provides app description for search and link previews.
- Includes iOS-specific tags for web app capabilities, appearance, and icons.

### 3. Icons & Manifest
- Links to the app’s favicon and Apple touch icon.
- Provides a manifest file for Progressive Web App (PWA) support, allowing installation and native-like behavior.

### 4. App Title
- Sets the web page’s title to "diseas_discover".

### 5. Flutter App Bootstrap
- Loads the `flutter_bootstrap.js` script which initializes and runs the Flutter web application.
- The script is loaded asynchronously for performance.

---

## Purpose

- To provide a ready-to-deploy web wrapper for a Flutter-built application.
- Ensures cross-platform compatibility, PWA functionality, and correct routing/asset loading.