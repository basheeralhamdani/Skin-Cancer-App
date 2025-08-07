# High-Level Documentation: CMake Configuration for Flutter Windows Runner

This CMake configuration script defines the build specification for the Windows "runner" application in a Flutter project. Its main responsibilities are as follows:

### 1. Minimum Requirements and Project Declaration
- **Sets the minimum required CMake version** (`3.14`).
- **Declares the project** as `runner` using the C++ language.

### 2. Executable Target Setup
- Defines a Windows GUI executable (`WIN32`) whose actual name is determined by the variable `BINARY_NAME`.
- **Includes source files** typically found in a Flutter Windows runner, such as:
  - `flutter_window.cpp`
  - `main.cpp`
  - `utils.cpp`
  - `win32_window.cpp`
  - Auto-generated plugin registrant from the Flutter tool
  - Resource and manifest files

### 3. Build Settings
- **Applies standard Flutter build settings** via a helper function (`apply_standard_settings`).

### 4. Preprocessor Definitions
- **Injects version info as preprocessor definitions** (e.g., `FLUTTER_VERSION`, `FLUTTER_VERSION_MAJOR`, etc.) to make Flutter version details available to the C++ code.
- **Disables conflicting Windows macros** (`NOMINMAX`) to prevent issues with C++ standard functions.

### 5. Linking and Includes
- **Links against required libraries:**
  - The core `flutter` engine library and its wrapper (`flutter_wrapper_app`)
  - Windows-specific library: `dwmapi.lib`
- **Adds include directories** for source files, especially the main project directory.

### 6. Build Tool Dependency
- **Adds a build dependency on `flutter_assemble`**, ensuring that Flutter's toolchain runs prior to building the C++ executable.

### 7. Extension and Customization
- The script is intended to be modified if additional source files or dependencies are needed in your particular Flutter desktop application.

---

**In summary:**  
This script automates the process of building a Windows desktop runner for a Flutter application by collecting the appropriate sources, managing Flutter-specific build tools and versioning, configuring Windows-specific build options, and linking the necessary libraries. It forms the foundation of integrating native Windows code with the Flutter engine in a desktop environment.