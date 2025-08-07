# High-Level Documentation: CMake Configuration for "diseas_discover"

This CMake configuration script sets up the build system for a C++ application named **diseas_discover**. The application is designed to integrate with the Flutter framework and uses GTK for its graphical user interface on Linux.

## Key Features and Responsibilities

### 1. Project Setup & Naming
- Specifies the **minimum CMake version** and **project name**.
- Sets the output binary's name (`diseas_discover`) and defines a **unique application identifier** for GTK-based systems.

### 2. Modern CMake Policies and Toolchain Support
- Opts in for recent CMake behaviors to avoid compatibility warnings.
- Allows for **cross-compilation** by adjusting root file system and search paths if targeting a different platform.

### 3. Build Type Management
- Defaults to a **Debug** build if not otherwise specified; supports "Debug," "Profile," and "Release" build modes.

### 4. Compiler Options and Warnings
- Provides a reusable function to apply **standard compile settings** (C++14, warnings as errors, optimization in non-Debug modes) to targets.

### 5. Dependencies
- Integrates Flutter by including a managed subdirectory.
- Locates and links against GTK 3 using `pkg-config`.

### 6. Application Target and Plugins
- Adds the application source code from the `runner` subdirectory.
- Ensures that Flutter build steps are always run before building the application binary.
- Configures the application to run from a **protected subdirectory** to prevent incorrect resource loading when run outside of a bundle.
- Includes and sets up **Flutter plugins** via a generated CMake file.

### 7. Installation and Bundle Generation
- Configures the default installation to produce a **relocatable application bundle** in the build directory.
- Cleans and repopulates the bundle directory on each build to avoid stale files.
- Installs:
  - The application binary
  - Flutter ICU data and shared libraries
  - Plugin-provided libraries
  - Any native assets required by packages (from `build.dart`)
  - The complete set of application assets (`flutter_assets`)
  - The ahead-of-time (AOT) compiled Flutter library (only for non-Debug builds)

### 8. Bundle Directory Structure
- Assets and libraries are organized into `data/` and `lib/` directories within the bundle.
- Ensures all components (binaries, libraries, assets) are placed relative to ensure correct loading by the app at runtime.

## Intended Usage

Developers should use this script as the basis for building and bundling a Flutter-embedded C++ application on Linux, with automatic management of build types, dependencies, and support for plugins and native assets. Installation produces a single directory bundle ready for deployment or further packaging.

---

**Note:**  
This documentation covers the main setup and build flow. Project-specific extensions (e.g., more dependencies, custom installation steps) should be added with caution, ideally by expanding application-specific sections and not modifying shared or infrastructural sections unless necessary.