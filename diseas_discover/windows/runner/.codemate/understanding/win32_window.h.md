# High-Level Documentation: Win32Window Class

## Purpose

The `Win32Window` class provides an abstraction for creating and managing a high-DPI aware Win32 window on Microsoft Windows systems. It is designed as a base class for other classes that require custom rendering and input handling within a Windows desktop application.

## Key Features

- **Window Creation and Management**: Supports creating a window with a specific title, position, and size (in logical pixels), consistent across different DPI settings.
- **Visibility Control**: Allows explicit showing and destroying of the window.
- **Native Handle Access**: Exposes the native HWND for direct OS-level manipulations (such as setting icons).
- **Content Hosting**: Enables attaching a child HWND to embed native content/widgets inside the window.
- **Client Area Query**: Retrieves the client area's dimensions for rendering or layout purposes.
- **Quit-on-Close Logic**: Configurable behavior to determine if closing the window should terminate the entire application.

## Extensibility

- Designed for subclassing: Derived classes can override:
  - `MessageHandler`: For custom message processing (mouse, window sizing, DPI changes, etc.)
  - `OnCreate` and `OnDestroy`: For extra setup and teardown during window lifecycle.

## DPI Handling

- Ensures window size and non-client area scale appropriately for systems with varying DPI using OS mechanisms.

## Notable Internals

- **WndProc**: Implements the standard Windows message procedure, with a focus on DPI-awareness and delegating general messages to `MessageHandler`.
- **WindowClassRegistrar (friend class)**: Likely involved in registering window classes for the OS.
- **Theme Updates**: Supports syncing window frame appearance with system theme.

## Usage Pattern

Typical usage involves:

1. Creating an instance of a derived class.
2. Calling `Create` to setup the window.
3. Optionally embedding content via `SetChildContent`.
4. Showing the window with `Show`.
5. Handling input/rendering via overriding `MessageHandler` in subclasses.
6. Destroying the window and associated resources when done.

## Thread Safety

No explicit mention of thread-safety; standard Win32 message pumping and window creation/destruction principles apply.

---

**In summary:**  
This header defines a robust, extensible base for high-DPI Win32 windows, abstracting away common boilerplate and adding support for embedding, native handle access, and system theme integration, with hooks for custom UI and input behavior.