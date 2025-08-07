# High-Level Documentation

## Overview
This CMake configuration file sets up the native build process for a C++ application known as runner, typically used as the Linux host for a Flutter application.

## Key Responsibilities

- **Sets Minimum CMake Version and Project Details**
  - Requires CMake version 3.13 or higher.
  - Defines the project named runner using the C++ language.

- **Configures Executable Target**
  - Builds an executable (binary) whose name is specified by `BINARY_NAME`.
  - Includes source files: `main.cc`, `my_application.cc`, and a generated file for plugin registration, supporting Flutter plugins integration.

- **Applies Standard Build Settings**
  - Applies recommended build settings for C++ projects, specifically tailored for Flutter applications on Linux.

- **Defines Preprocessor Macros**
  - Sets a compile-time definition (`APPLICATION_ID`) for the binary, making the application ID available in the sources.

- **Manages Dependencies**
  - Links the executable with:
    - The Flutter engine's C++ embedder library.
    - The GTK library, accessed via PkgConfig for building native Linux UIs.

- **Configures Include Paths**
  - Ensures the application's source directory is available as a header include path during compilation.

## Intended Use
This file is auto-generated for Linux Flutter desktop projects but can be manually edited for custom native build requirements or additional dependencies. It provides the minimum structure and conventions to ensure smooth integration with Flutter tooling and plugin infrastructure.