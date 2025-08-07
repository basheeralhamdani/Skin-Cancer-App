# High-Level Documentation: Xcode Scheme Configuration

This XML defines an **Xcode scheme** for building, testing, running, profiling, analyzing, and archiving an iOS/macOS app project. The scheme organizes the build and execution workflow for the contained targets in Xcode.

## Purpose
- Controls how various actions (Build, Test, Run, Profile, Analyze, Archive) are executed for the app and its test targets.

## Key Components

### 1. BuildAction
- **Description**: Specifies build settings and dependencies for the main target.
- **Settings**:
  - Parallelized builds
  - Implicit dependency building
  - Enabled for Testing, Running, Profiling, Archiving, and Analyzing
- **Primary Target**: 
  - App: `diseas_discover.app` (Blueprint: `Runner`, Container: `Runner.xcodeproj`)

### 2. TestAction
- **Description**: Configures the test execution environment.
- **Settings**:
  - Build configuration: `Debug`
  - Uses LLDB debugger and launcher
  - Passive passing of scheme arguments/environment
- **Test Target**:
  - Test Bundle: `RunnerTests.xctest` (Blueprint: `RunnerTests`)
- **Macro Expansion**: Runs tests with the compiled app.

### 3. LaunchAction
- **Description**: Defines how the app is launched for debugging or normal running.
- **Settings**:
  - Build configuration: `Debug`
  - LLDB debugger/launcher
  - Simulates device location
  - Versioning and internal debug extensions enabled

### 4. ProfileAction
- **Description**: Provides settings for running performance or memory profiling.
- **Settings**:
  - Build configuration: `Profile`
  - Macro expansion and debugging options configured

### 5. AnalyzeAction
- **Description**: Static code analysis settings.
- **Build Configuration**: `Debug`

### 6. ArchiveAction
- **Description**: Defines how to create distributable/app store archives.
- **Settings**:
  - Build configuration: `Release`
  - Archive shown in Organizer after creation.

## Selected Project and Targets

- **Project Container**: `Runner.xcodeproj`
- **App Target**: `Runner` (Produces `diseas_discover.app`)
- **Test Target**: `RunnerTests` (Produces `RunnerTests.xctest`)

---

**Summary**:  
This scheme automates and manages the build, test, run, analyze, and release workflow for the `Runner` project, enabling parallelization, proper debugging, test integration, and archive management for deployment using standard Xcode tools and processes.