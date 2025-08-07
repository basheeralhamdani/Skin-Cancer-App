---
# Gradle Startup Script for Windows - High-Level Overview

This script (`gradlew.bat`) is the Windows batch file for launching Gradle builds using the Gradle Wrapper. Below is a high-level summary of its purpose and workflow:

## Purpose
- Provides a platform-independent way to invoke Gradle on Windows systems.
- Ensures the correct Java environment is used for building Java projects via Gradle.
- Manages environment setup, Java path verification, and delegates execution to the Gradle Wrapper JAR.

## Major Workflow Steps

1. **Environment Preparation**
    - Turns off command echoing for a cleaner output.
    - Sets the working directory and environment variables local to the script session.

2. **JVM Options**
    - Allows configuration of default JVM options, as well as passing options through general `JAVA_OPTS` and `GRADLE_OPTS` environment variables.

3. **Java Detection**
    - Attempts to locate the `java.exe` executable.
    - If `JAVA_HOME` is set, it uses the JVM from there.
    - If not, attempts to fall back to a system-wide `java.exe`.
    - If Java cannot be found, outputs a clear error message and stops.

4. **Command-line Arguments Processing**
    - Handles Windows command-line arguments (differences for NT, ME, 9x, and 4NT shells).
    - Collects all user-supplied parameters to forward them to the actual Gradle execution.

5. **Classpath and Gradle Wrapper Execution**
    - Sets the classpath to include the Gradle Wrapper JAR.
    - Invokes the Java executable with all the necessary options, pointing it to `org.gradle.wrapper.GradleWrapperMain`.

6. **Cleanup and Exit**
    - Handles normal termination as well as failure conditions, outputs relevant error information, and sets appropriate exit codes.
    - Cleans up local environment variables after execution.

## Key Use Cases
- Used for building, testing, or running Java applications in a manner identical to the project's expected Gradle configuration.
- Helps teams maintain consistent build environments across different machines by shipping the necessary Gradle version with the project.

---

**In summary:**  
This script ensures that the correct Java environment is available and then delegates to the Gradle Wrapper, providing a reliable, cross-machine way to build projects with Gradle on Windows systems.