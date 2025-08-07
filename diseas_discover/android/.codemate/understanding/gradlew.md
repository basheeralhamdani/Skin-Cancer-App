# High-Level Documentation for the Provided Gradle Unix Startup Script

## Overview

This Bash script serves as the standard UNIX startup wrapper for **Gradle Wrapper**. Its primary purpose is to detect the correct environment, configure Java and JVM options, ensure platform compatibility, and launch the Gradle Wrapper Java process. It is meant to be invoked as `./gradlew` or similar, enabling consistent Gradle builds across different user systems without manually installing Gradle.

---

## Major Responsibilities and Workflow

1. **Define Defaults and Helper Functions**
   - Sets default JVM options.
   - Defines helper `warn` and `die` functions for messaging and error handling.

2. **Detect Operating System**
   - Checks for Cygwin, MSYS (MinGW), and macOS (Darwin) environments to handle platform-specific behavior.

3. **Resolve Application Home Directory**
   - Determines the script's actual directory even if it's invoked via a symlink.
   - Sets `APP_HOME` to the physical path containing the script.

4. **Prepare Java Environment**
   - Sets up the `CLASSPATH` pointing to the embedded `gradle-wrapper.jar`.
   - Locates the Java executable:
     - Prefers `$JAVA_HOME`, and validates it.
     - Falls back to `java` in `PATH`, aborts with an error if not found.

5. **Handle System Limits**
   - Attempts to maximize open file descriptors for performance (non-Windows/OS X only).

6. **Platform-Specific Adjustments**
   - On macOS, sets JVM options so the process has a custom Dock icon and name.
   - On Cygwin, converts path formats between Unix and Windows-style as needed in arguments and critical variables.

7. **JVM and Gradle Option Argument Handling**
   - Combines JVM options from different sources (`DEFAULT_JVM_OPTS`, `$JAVA_OPTS`, `$GRADLE_OPTS`), ensuring proper shell quoting and splitting.
   - Always sets the system property to identify the calling script as the Gradle app name.

8. **Launch Gradle Wrapper Main Class**
   - Finally, invokes the Java process to run the Gradle Wrapper main class (`org.gradle.wrapper.GradleWrapperMain`) with the constructed options and all script arguments passed through to Gradle.

---

## Key Features

- **Cross-Platform Support**: Handles differences between UNIX-like systems, including special cases for Cygwin/MSYS and macOS.
- **Self-contained**: Does not require a prior Gradle installation; only Java is needed.
- **Environment Validation**: Stops execution with helpful messages if Java is not installed or `$JAVA_HOME` is incorrect.
- **Path and Argument Safety**: Accurately manages spaces/quoting and OS-based path conversion for robust behavior.
- **Configurable**: JVM settings can be influenced by environment variables or edited inline for CI/CD or local needs.

---

## Typical Use

Users do not need to modify or interact with this script directly except, perhaps, to add JVM options. It is called automatically when running commands like:

```shell
./gradlew build
```

---