**High-Level Documentation**

This file is a Gradle Wrapper properties configuration, commonly named `gradle-wrapper.properties`. It specifies settings for managing the Gradle Wrapper, which ensures consistent build tooling across different machines and environments. 

### Purpose
- Provides configuration for downloading and managing a specific version of the Gradle build tool.
- Ensures all users and CI systems use the same Gradle version regardless of their local installations.

### Key Settings Explained
- **distributionBase**: Determines where the Gradle distribution is stored locally (e.g., user's home directory).
- **distributionPath**: Sets the sub-path for Gradle distributions within the base directory.
- **zipStoreBase**: Sets where to cache the unpacked Gradle zip file (commonly matches distributionBase).
- **zipStorePath**: Specifies the subdirectory for storing the unpacked Gradle distribution.
- **distributionUrl**: URL to the specific Gradle distribution to download (in this case, Gradle 8.3 with all features).

### Effect
Whenever a build is run using the Gradle Wrapper (`./gradlew`), these settings ensure that Gradle 8.3 is downloaded (if not already cached) and used for the build, guaranteeing version consistency.