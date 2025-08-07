# High-Level Documentation: Windows CMake Build Configuration for "diseas_discover"

This CMake script provides comprehensive configuration for building, installing, and managing a Windows application called **diseas_discover**, likely a Flutter-based desktop application. The script coordinates compiler and linker settings, build types, inclusion of Flutter and plugin rules, and the installation of assets and dependencies. Below is a high-level breakdown of its core components and intent:

## 1. **Project and CMake Requirements**
- Sets *minimum CMake version* (3.14) and project metadata.
- Declares project as C++ (CXX) only.

## 2. **Executable Naming**
- Sets a configurable name for the output binary (`diseas_discover`).

## 3. **CMake Policy and Modern Settings**
- Opts into a range of modern CMake policies (3.14 to 3.25) for best practices and minimized warnings.

## 4. **Build Configuration Options**
- Handles **multi-configuration** (Visual Studio, etc.) and **single-configuration** generators.
- Defines three build types: `Debug`, `Profile`, `Release`.
- Special `Profile` type mimics `Release` flags.
- Defaults to Debug if nothing is specified.

## 5. **Unicode Support**
- Ensures all code is compiled with Unicode (-DUNICODE -D_UNICODE).

## 6. **Target Compilation Configuration**
- Provides an `APPLY_STANDARD_SETTINGS` function for targets:
  - Sets C++17.
  - Enables strict warnings and treats warnings as errors.
  - Adjusts exception handling settings.
  - Adds debug-specific defines.

## 7. **Including Flutter and Plugins**
- Adds a managed subdirectory (usually auto-generated) for Flutter framework rules.
- Adds a `runner` subdirectory that contains main executable build logic.
- Includes generated file to wire up plugins to the build.

## 8. **Installation Rules & Bundle Layout**
- Installs the binary, Flutter libraries, ICU data, plugin libraries, native assets, etc., into a **bundle directory** next to the executable for easy running and debugging.
- Configures install prefix to point to this run-in-place location (especially important for Visual Studio users).
- Recursively copies assets and plugin files, always overwriting to prevent stale data.
- Installs AOT library only for non-Debug builds.

## 9. **Install-Time Cleanups**
- On every install step, removes and fully replaces asset directories to avoid build-up of old assets, ensuring a clean state.

---

## **Usage Context**
Developers building "diseas_discover" on Windows platforms will use this CMake configuration to:
- Compile the application with appropriate settings for various build profiles.
- Collect all runtime dependencies—Flutter engine, asset files, plugin binaries—into a ready-to-run bundle directory.
- Simplify debugging, testing, and release by ensuring all necessary files are collocated with the executable.

**Note:** Plugin and Flutter-specific rules are managed using generated files and regularly updated directories, which are referenced rather than defined within this file.

---

## **Customization Points**
- Change app name by modifying `BINARY_NAME`.
- Add/modify build settings via the `APPLY_STANDARD_SETTINGS` function or target-specific CMake commands.
- Extend install rules for more/optional assets by editing the relevant `install()` commands.

---

**In summary:**  
This file is a template-driven, robust, and Visual Studio–friendly CMake configuration for packaging a modern C++/Flutter Windows executable, consistently managing both development and production build flows.