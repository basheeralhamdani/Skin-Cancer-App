# CMake Code Review Report

This review covers the provided CMake configuration, focusing on industry best practices, optimizations, potential errors, and modern standards compliance.

---

## 1. Variable/Target Naming Consistency

**Issue:**  
The binary name is set to `diseas_discover`, which is likely a typo.

**Correction Suggestion:**
```cmake
set(BINARY_NAME "disease_discover")
set(APPLICATION_ID "com.example.disease_discover")
```

---

## 2. Policy Handling

**Issue:**  
You set only one policy (CMP0063). It's better to add recent relevant policies for CMake 3.13+ to avoid unexpected warnings or future issues.

**Correction Suggestion:**
```cmake
cmake_policy(SET CMP0074 NEW)
```
(And add explanations in comments that clarify which policies you're setting and why)

---

## 3. RPATH for Portable Binaries

**Issue:**  
`"$ORIGIN/lib"` is not portable to non-Linux systems. If cross-platform support is required, apply conditionally.

**Correction Suggestion:**
```cmake
if(UNIX AND NOT APPLE)
  set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")
endif()
```

---

## 4. Explicit Variable Types

**Issue:**  
Paths should use `PATH` instead of untyped cache variable for install prefix.

**Correction Suggestion:**
```cmake
set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "Bundle root" FORCE)
```

---

## 5. Minimum Compiler Version

**Issue:**  
You require C++14 features, but do NOT warn/fail if the compiler is not new enough.

**Correction Suggestion:**
```cmake
if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5.0)
  message(FATAL_ERROR "A compiler supporting C++14 is required.")
endif()
```

---

## 6. Optimization Flags for Release

**Issue:**  
Manual `-O3` adds optimization, but should be set via `CMAKE_CXX_FLAGS_RELEASE`.

**Correction Suggestion:**
```cmake
set(CMAKE_CXX_FLAGS_RELEASE "-O3" CACHE STRING "Release flags" FORCE)
```

---

## 7. Modern CMake Targets

**Issue:**  
You use `target_compile_features` and friends correctly, but for libraries such as GTK, it is preferable to use imported targets directly (as in `PkgConfig::GTK`).

**Correction Suggestion:**
```cmake
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)
```

---

## 8. Cleanup of Bundles

**Issue:**  
Repeated `install(CODE "...")` to `file(REMOVE_RECURSE ...)` could lead to accidental deletion if variables are not correct.

**Correction Suggestion:**
```cmake
if(EXISTS "${BUILD_BUNDLE_DIR}/")
  install(CODE "file(REMOVE_RECURSE \"${BUILD_BUNDLE_DIR}/\")" COMPONENT Runtime)
endif()
```

---

## 9. Variable Existence Checks

**Issue:**  
Some variables like `${AOT_LIBRARY}` may not be defined or set in all build types, leading to install errors.

**Correction Suggestion:**
```cmake
if(NOT CMAKE_BUILD_TYPE MATCHES "Debug" AND DEFINED AOT_LIBRARY AND EXISTS "${AOT_LIBRARY}")
  install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endif()
```

---

## 10. Use of `PROJECT_BUILD_DIR`

**Issue:**  
You use `${PROJECT_BUILD_DIR}` but this variable is not set/defined in this CMakeLists.txt. You should use `${CMAKE_BINARY_DIR}` for the build tree.

**Correction Suggestion:**
```cmake
set(NATIVE_ASSETS_DIR "${CMAKE_BINARY_DIR}/native_assets/linux/")
install(DIRECTORY "${NATIVE_ASSETS_DIR}"
   DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
   COMPONENT Runtime)

install(DIRECTORY "${CMAKE_BINARY_DIR}/${FLUTTER_ASSET_DIR_NAME}"
  DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)
```

---

## 11. Dependency Ordering

**Issue:**  
Using `add_dependencies(${BINARY_NAME} flutter_assemble)` before confirming both are valid CMake targets can cause configuration errors if `${BINARY_NAME}` isn't added yet.

**Correction Suggestion:**
```cmake
# Ensure ${BINARY_NAME} is already created (add_executable or add_library) before this point
add_dependencies(${BINARY_NAME} flutter_assemble)
```
*Or move the `add_dependencies` line after the `add_executable` or appropriate target creation in runner/CMakeLists.txt.*

---

## 12. Hardcoded String Literals

**Issue:**  
Do not use hardcoded names or paths such as `"flutter_assets"`, `"bundle"`, etc. Place at the top with an explanation/comment.

**Correction Suggestion:**
```cmake
set(FLUTTER_ASSET_DIR_NAME "flutter_assets")   # Flutter assets directory name (do not change!)
set(BUILD_BUNDLE_DIR "${PROJECT_BINARY_DIR}/bundle")  # Bundle directory for install
```

---

# Summary Table

| Issue                | Location/Lines        | Correction Snippet/Advice              |
|----------------------|----------------------|----------------------------------------|
| Typo in binary name  | Top                  | `set(BINARY_NAME "disease_discover")`  |
| CMake policy         | Early                | `cmake_policy(SET CMP0074 NEW)`        |
| RPATH portability    | <15                  | `if(UNIX AND NOT APPLE) ... endif()`   |
| Paths cache type     | Install config       | `CACHE PATH ...`                       |
| Compiler version     | Early                | Fatal error for old compilers          |
| Release flags        | Global/configure     | `set(CMAKE_CXX_FLAGS_RELEASE ...)`     |
| Target usage         | GTK/linking          | `target_link_libraries ...`            |
| Install clean-up     | Install section      | Conditional check for existence        |
| Variable existence   | Install section      | `if(DEFINED var AND EXISTS ...)`       |
| Build dir variable   | Asset install        | Use `${CMAKE_BINARY_DIR}`              |
| Dependency order     | add_dependencies     | After target is created                |
| String literals      | Top                  | Place as variables with comments       |

---

## General Recommendations

- Adopt modern CMake wherever possible (targets, imported libraries, INTERFACE targets).
- Thoroughly validate all variables and paths used in `install()`, especially those that might not always be defined.
- Use `CMAKE_${LANG}_STANDARD_REQUIRED` and `CMAKE_${LANG}_EXTENSIONS` for standards conformance.
- Document "magic strings" and directory layouts with explanations for maintainers.

**Always test a configuration on clean builds, and try at least Debug and Release types, to ensure variables and build/install steps function as intended.**