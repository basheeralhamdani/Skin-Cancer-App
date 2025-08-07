# High-Level Documentation: Flutter Windows CMake Build Script

This CMake script configures the build process for embedding Flutter applications on the Windows platform. It is auto-generated and should not be directly edited; its purpose is to orchestrate the build steps required by Flutter's Windows embedding, including the compilation and linkage of Flutter framework libraries and necessary C++ wrapper components.

## Key Components

### 1. Generated Configuration Inclusion
- The script includes a generated configuration file (`generated_config.cmake`) containing build variables set by the Flutter tool.

### 2. Directory Structure Setup
- Defines paths (like `ephemeral` and `cpp_client_wrapper`) where generated sources and headers reside.

### 3. Platform and Binary Variables
- Ensures the build targets the correct platform (default: `windows-x64`).
- Sets variables for key binaries and assets:
  - Flutter DLL (`flutter_windows.dll`)
  - ICU Data file (`icudtl.dat`)
  - AOT-compiled (ahead-of-time) application binary (`app.so`)

### 4. CMake Targets
- **Flutter Library Target:**
  - Declares an `INTERFACE` library for linking against the Flutter DLL.
  - Exposes Flutter header files for use by other targets.
  - Ensures dependent targets link against the Flutter dynamic library.

- **C++ Wrapper Libraries:**
  - **flutter_wrapper_plugin**: Static library providing wrapper sources needed by plugins.
  - **flutter_wrapper_app**: Static library providing wrapper sources needed by the application runner.
  - Both set up appropriate include directories, apply standard project settings, and link against the core Flutter interface library.

### 5. flutter_assemble Custom Target
- Custom command to run the Flutter backend tool (`tool_backend.bat`) with environment variables and expected outputs.
- Uses a "_phony_" output file trick to ensure the command always reruns (as required by Flutter's toolchain behavior).
- `flutter_assemble` is a CMake target dependent on all generated binaries and sources, ensuring the build is always up-to-date with Flutter tool output.

## Purpose and Usage

- **Entry Point for Windows Runner Build:** All the logic for generating, copying, and arranging necessary Flutter and wrapper files for the Windows platform.
- **Separation of Concerns:** Wraps plugin and app logic in distinct static libraries for pluggability.
- **Integrator Expectations:** This file should remain unedited and managed via Flutter's tooling and ephemeral configuration files.
- **Extensibility Placeholder:** Some responsibilities are noted as "TODO" to eventually be moved to generated files within the `ephemeral` directory.

## In Summary

This script configures the CMake build for Flutter desktop applications on Windows, ensuring that both Flutter's engine binaries and the native C++ wrappers are properly built, included, and made available for both application runners and dynamically loaded plugins. It heavily leverages generated and tool-provided configuration.