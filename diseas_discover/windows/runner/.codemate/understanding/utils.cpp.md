**High-Level Documentation for utils.cpp**

This code provides utility functions for a Windows application utilizing Flutter. The key functionalities are:

### 1. Console Creation and Attachment

- **Function:** `CreateAndAttachConsole()`
- **Purpose:** Dynamically allocates and attaches a Windows console to the application if it doesn't already exist. This enables runtime output to be seen in a console window.
- **Details:**
  - It routes standard output (`stdout`) and error (`stderr`) streams to the new console.
  - It synchronizes C++ standard streams with the underlying C streams.
  - It invokes Flutter-specific code to resynchronize output streams for debug or logging.

### 2. Command-line Argument Processing

- **Function:** `GetCommandLineArguments()`
- **Purpose:** Retrieves the current process's command-line arguments and converts them from UTF-16 (used by Windows) to UTF-8 encoded `std::string` objects.
- **Details:**
  - Uses Windows API to parse command-line arguments into individual strings.
  - Skips the first argument, which is the executable’s name.
  - Converts each argument from UTF-16 to UTF-8 for compatibility with the application (and Flutter engine).

### 3. String Encoding Conversion

- **Function:** `Utf8FromUtf16(const wchar_t* utf16_string)`
- **Purpose:** Converts a single UTF-16 encoded wide character string (used by Windows APIs) into a UTF-8 encoded standard string.
- **Details:**
  - Uses Windows API to perform the encoding conversion.
  - Handles potential edge cases, such as null input or conversion errors.
  - Ensures returned UTF-8 string excludes any trailing null characters.

---

**Summary:**  
These utilities enable robust handling of console logging and cross-encoding of command-line arguments, making the Windows-based application and its interaction with the Flutter engine more reliable, especially when dealing with Unicode input.