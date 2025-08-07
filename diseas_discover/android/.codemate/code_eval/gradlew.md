# Critical Code Review Report

**Script:** gradle start up script for UNIX  
**Language:** Bash

---

## Summary

This script is generally functional, but it has a number of deviations from best practices, and several places where efficiency, reliability, and maintainability can be significantly improved. The issues listed below pertain to industry standards violations, unoptimized implementations, and outright errors. All suggestions are accompanied by corrected pseudo-code snippets (not the full script).

---

## Issues & Recommendations

---

### 1. **Deprecated Backticks and Command Substitution**

**Issue:**  
Use of backticks (`` `command` ``) is outdated and less readable than `$()`.

**Recommendation:**  
Replace backtick notation with `$()`.

**Corrected Code:**
```bash
APP_BASE_NAME=$(basename "$0")

case "$(uname)" in
    # ...
esac

ls=$(ls -ld "$PRG")
link=$(expr "$ls" : '.*-> \(.*\)$')
PRG=$(dirname "$PRG")"/$link"

SAVED="$(pwd)"
cd "$(dirname "$PRG")/" >/dev/null
APP_HOME="$(pwd -P)"
cd "$SAVED" >/dev/null

MAX_FD_LIMIT=$(ulimit -H -n)

# etc. for other usages
```

---

### 2. **Insecure Temporary Variable Usage and Path Handling**

**Issue:**  
Use of unquoted variables (e.g., `$link`, `$dir`, "$args$i") can lead to word splitting and globbing issues.

**Recommendation:**  
Wrap all variable expansions in double quotes.

**Corrected Code:**
```bash
if [ -h "$PRG" ] ; do
    ls=$(ls -ld "$PRG")
    link=$(expr "$ls" : '.*-> \(.*\)$')
    # ...
    PRG="$(dirname "$PRG")"/"$link"
fi

for dir in $ROOTDIRSRAW ; do
    ROOTDIRS="$ROOTDIRS$SEP$dir"
    SEP="|"
done

eval "args$i=$(cygpath --path --ignore --mixed "$arg")"
```

---

### 3. **Function Declaration Format (Bash Compatibility)**

**Issue:**  
Functions declared with spaces and parenthesis are less portable (`function name() { ... }` or `name ( ) { ... }`).

**Recommendation:**  
Use POSIX-compliant function definitions.

**Corrected Code:**
```bash
warn() {
    echo "$*"
}

die() {
    echo
    echo "$*"
    echo
    exit 1
}
```

---

### 4. **Unsafe Parsing of `ls` Output**

**Issue:**  
Parsing `ls` output is fragile and non-portable.

**Recommendation:**  
Use `readlink` if available to resolve symbolic links.

**Corrected Code:**
```bash
if command -v readlink >/dev/null 2>&1; then
    while [ -h "$PRG" ]; do
        PRG=$(readlink "$PRG")
    done
else
    # fallback to current approach if readlink is unavailable
fi
```

---

### 5. **Shell Arithmetic Subexpression**

**Issue:**  
The usage `i=$((i+1))` is Bash-specific; if POSIX shell compatibility is desired, use `i=$(expr $i + 1)`.

**Recommendation:**  
Where Bash is guaranteed (as with `#!/usr/bin/env bash`), this is acceptable, but for strict portability use `expr`.

---

### 6. **Non-portable Array Usage**

**Issue:**  
Arrays (`JVM_OPTS[${#JVM_OPTS[*]}]="..."`) are non-POSIX.

**Recommendation:**  
If running with Bash is required, it's acceptable, but declare the array for clarity:

**Corrected Code:**
```bash
declare -a JVM_OPTS
JVM_OPTS+=("-Dorg.gradle.appname=$APP_BASE_NAME")
```

---

### 7. **Quoting and Escaping in Darwin Block**

**Issue:**  
Escaping and use of quotes in this line is incorrect, and will result in the variable having unwanted literal quotes.

```bash
GRADLE_OPTS="$GRADLE_OPTS \"-Xdock:name=$APP_NAME\" \"-Xdock:icon=$APP_HOME/media/gradle.icns\""
```

**Recommendation:**  
Append without extra embedded quotes.

**Corrected Code:**
```bash
GRADLE_OPTS="$GRADLE_OPTS -Xdock:name=$APP_NAME -Xdock:icon=$APP_HOME/media/gradle.icns"
```

---

### 8. **Unsafe Handling of MAX_FD Variable**

**Issue:**  
If `ulimit -H -n` fails, `MAX_FD_LIMIT` could be an empty string, leading to invalid `ulimit -n` invocation.

**Recommendation:**  
Add checks for empty/unset `MAX_FD_LIMIT` before using it.

**Corrected Code:**
```bash
if [ -n "$MAX_FD_LIMIT" ]; then
    # continue
else
    warn "ulimit failed to retrieve maximum file descriptor limit"
fi
```

---

### 9. **Use of `which`**

**Issue:**  
`which` is obsolete for checking command presence; use `command -v`.

**Corrected Code:**
```bash
command -v java >/dev/null 2>&1 || die "ERROR: ..."
```

---

### 10. **SplitJvmOpts Function**

**Issue:**  
This function does nothing useful; it just assigns all arguments to `JVM_OPTS`, but is called via eval (unsafe, unneeded).

**Recommendation:**  
Compose the array directly.

**Corrected Code:**
```bash
declare -a JVM_OPTS
JVM_OPTS=($DEFAULT_JVM_OPTS $JAVA_OPTS $GRADLE_OPTS)
JVM_OPTS+=("-Dorg.gradle.appname=$APP_BASE_NAME")
```

---

### 11. **Security: No Source Directory Validation for CLASSPATH**

**Issue:**  
Directly setting CLASSPATH without ensuring the jar file exists can lead to unclear failures.

**Recommendation:**  
Verify the jar exists before proceeding.

**Corrected Code:**
```bash
if [ ! -f "$CLASSPATH" ]; then
    die "Gradle wrapper jar not found: $CLASSPATH"
fi
```

---

### 12. **Miscellaneous**

- Use `set -euo pipefail` at the top for safety (if Bash is guaranteed).
- Consider `exec`'s trailing parameters quoting: always double-quote.

**Corrected Code:**
```bash
set -euo pipefail

exec "$JAVACMD" "${JVM_OPTS[@]}" -classpath "$CLASSPATH" org.gradle.wrapper.GradleWrapperMain "$@"
```

---

## Summary Table

| Issue                      | Error/Problem                                     | Suggestion                                                      |
|----------------------------|---------------------------------------------------|------------------------------------------------------------------|
| Legacy command substitution| Use of backticks                                   | Replace with `$(...)`                                            |
| Quoting/escaping           | Unquoted/interpolated vars, wrong escaping         | Double-quote variable references                                 |
| Function semantics         | Non-standard function decl                         | Use POSIX style functions                                        |
| `ls` parsing               | Fragile symlink resolution                         | Prefer `readlink` if available                                   |
| Use of expr/arithmetic     | Bash arithmetic used without fallback              | POSIX fallback if stricter portability needed                    |
| Array usage                | Non-portable arrays                                | Declare arrays only when Bash is guaranteed                      |
| Darwin block quoting       | Incorrect quotes around JVM options                | Remove extra quotes                                              |
| MAX_FD unguarded           | Empty var could be passed to ulimit                | Check MAX_FD_LIMIT non-empty                                     |
| `which`                    | Use of deprecated tool                             | Use `command -v` instead of `which`                              |
| Empty/Jar check            | Unchecked CLASSPATH                               | Add missing file check                                           |
| SplitJvmOpts               | Unsafe and unnecessary function                    | Compose array directly, avoid `eval`                             |
| Shell safety               | Script does not exit on error                      | Use `set -euo pipefail`                                          |

---

## Final Recommendations

Applying these corrections will significantly improve maintainability, portability, security, and reliability, in line with best practices for production-grade shell scripting. If strict POSIX-shell compatibility is not a requirement, make sure to declare dependencies on Bash features clearly.