# High-Level Documentation

## Overview

This XML file is a Windows Application Manifest. It specifies application-level settings that inform the Windows operating system about the application's compatibility, DPI awareness, and other configuration details. This manifest is commonly included in Windows application distributions to ensure optimal operation on modern Windows versions, particularly regarding display scaling and OS compatibility.

## Key Components

- **Assembly Declaration**: The root `<assembly>` element defines the application manifest and specifies its schema version.

- **Application DPI Awareness**:
  - The `<application>` section defines Windows-specific settings.
  - `<windowsSettings>` contains DPI awareness information.
    - `<dpiAwareness>` is set to **PerMonitorV2**, indicating the application supports advanced, per-monitor DPI scaling. This ensures crisp UI rendering on high-DPI displays and across monitors with different scaling factors.

- **OS Compatibility**:
  - The `<compatibility>` element declares which Windows versions the application explicitly supports.
    - `<supportedOS>` uses a GUID to indicate compatibility with **Windows 10 and Windows 11** (GUID: `{8e0f7a12-bfb3-4fe8-b9a5-48fd50a15a9a}`).

## Purpose

- **DPI Scaling**: Enables best-practice high-DPI support, allowing the application to render correctly on modern displays with varied DPI settings.
- **Windows Compatibility**: Ensures that the application is recognized as compatible by Windows 10 and 11, potentially unlocking newer features and improving reliability/stability on these operating systems.

## Typical Usage

This manifest file should be embedded in or distributed alongside a Windows application executable to:

- Improve user experience on high-resolution monitors.
- Enable proper scaling of UI elements.
- Inform Windows Update/OS compatibility dialogs that the app is ready for use on current Windows platforms.

---

**Summary**:  
This manifest configures the application for advanced per-monitor DPI awareness and declares compatibility with Windows 10/11 for better display handling and OS integration.