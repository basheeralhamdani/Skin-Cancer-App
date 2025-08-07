High-Level Documentation for runner_utils.h

Overview:
This header file defines utility functions intended for use in a runner application, particularly with integration for Flutter on Windows. The utilities support console management, Unicode string conversion, and command-line argument parsing, facilitating robust and cross-compatible application behavior.

Function Summaries:

1. Console Management
- void CreateAndAttachConsole():
  Allocates and attaches a console window to the current process (if not already present), and redirects the standard output (stdout) and standard error (stderr) streams to this console. This is useful for viewing log messages and debugging output from both the runner itself and the integrated Flutter library.

2. String Encoding Conversion
- std::string Utf8FromUtf16(const wchar_t* utf16_string):
  Converts a null-terminated UTF-16 encoded wide string (wchar_t*) to a UTF-8 encoded std::string. Returns an empty string if the conversion fails. This function ensures correct handling of Unicode text when interoperating between APIs that use different encodings (common in Windows-to-std interactions).

3. Command-Line Argument Parsing
- std::vector<std::string> GetCommandLineArguments():
  Retrieves the process's command-line arguments and returns them as a std::vector of UTF-8 encoded strings. Returns an empty vector on failure. This helps in easily accessing arguments in portable, cross-compatible format.

Usage Notes:
- These utilities are essential for Windows desktop Flutter runners or similar native apps needing proper Unicode support, argument parsing, and console output.
- All functions are cross-compatible C++ and use standard STL types for integration ease.

File Protection:
- The header is guarded with #ifndef / #define to prevent multiple inclusions.

Summary:
runner_utils.h provides essential functions for console setup, Unicode conversion, and command-line handling, supporting both native and embedded environments on Windows platforms.