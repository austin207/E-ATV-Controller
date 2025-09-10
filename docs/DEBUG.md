# Debug Log - Flutter RC Controller App

## Project Overview
Flutter RC Controller App for ESP32/ESP8266 vehicles with BLE and WiFi WebSocket connectivity.

***

## Issue #1: BLE Commands Not Reaching ESP32

### Problem
- BLE connection established successfully (`"Flutter app connected!!"`)
- ESP32 receiving connection but no commands in Serial Monitor
- Flutter app buttons not sending data

### Root Cause
- Flutter `BLEService.sendCommand()` using wrong data encoding
- Using `command.codeUnits` instead of proper UTF-8 encoding
- Missing UUID matching between Flutter and ESP32

### Solution
```dart
// FIXED: Proper UTF-8 encoding
Future<bool> sendCommand(String deviceId, String command) async {
   // Look for exact UUIDs
   final serviceUuid = Guid("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
   final charUuid = Guid("beb5483e-36e1-4688-b7f5-ea07361b26a8");

   // Use UTF-8 encoding instead of codeUnits
   List<int> bytes = utf8.encode(command + "\n");
   await characteristic.write(bytes, withoutResponse: false);
}
```

### Result
✅ ESP32 Serial Monitor showing commands:
```
Raw: MOVE:UP=1,DOWN=0,LEFT=0,RIGHT=0,SPEED=50,BOOST=0
MOVEMENT: UP=1 DOWN=0 LEFT=0 RIGHT=0 SPEED=50 BOOST=0
Motor logic executed with speed: 50
```

***

## Issue #2: ESP32 Compilation Error

### Problem
```
error: 'processCommand' was not declared in this scope
```

### Root Cause
- C++ function `processCommand` called before declaration
- Forward declaration missing

### Solution
```cpp
// Added forward declarations at top of file
void processCommand(const String& command);
int getValue(const String& command, const String& key);
void handleMovement(int up, int down, int left, int right, int speed, int boost);
void stopAllMotors();
```

### Result
✅ ESP32 code compiles and uploads successfully

***

## Issue #3: Release Signing Configuration

### Problem
```
You uploaded an APK or Android App Bundle that was signed in debug mode.
You need to sign your APK or Android App Bundle in release mode.
```

### Steps Taken

#### 3.1: Create Keystore
```powershell
# Find keytool location
Get-ChildItem -Path "C:\Program Files" -Recurse -Name "keytool.exe"

# Create keystore using call operator
& "C:\Program Files\Java\jdk-17\bin\keytool.exe" -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**⚠️ SECURITY NOTE**: Keystore and passwords are excluded from this repository for security.

#### 3.2: Configure Gradle Signing

**Created `android/key.properties` (EXCLUDED FROM GIT):**
```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

**Updated `android/app/build.gradle.kts`:**
```kotlin
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }
    
    buildTypes {
        release {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}
```

***

## Issue #4: NDK Version Mismatch

### Problem
```
Your project is configured with Android NDK 26.3.11579264, but plugins require NDK 27.0.12077973
```

### Solution
```kotlin
android {
    ndkVersion = "27.0.12077973"
}
```

***

## Issue #5: Keystore File Not Found

### Problem
```
Keystore file not found for signing config 'release'.
```

### Solution
1. **Moved keystore to android folder**
2. **Updated key.properties with correct path**

***

## Issue #6: Restricted Package Name

### Problem
```
You need to use a different package name because 'com.example' is restricted.
```

### Solution
**Change package name from `com.example.e_atv` to unique identifier**

**Method A: Using Plugin**
```powershell
dart pub global activate change_app_package_name
dart pub global run change_app_package_name:main com.yourcompany.eatv
```

**Method B: Manual Update**
- `android/app/build.gradle.kts`: `applicationId = "com.yourcompany.eatv"`
- `android/app/build.gradle.kts`: `namespace = "com.yourcompany.eatv"`
- `android/app/src/main/AndroidManifest.xml`: `package="com.yourcompany.eatv"`

***

## Configuration Summary

### ESP32 UUIDs Used
- **Service UUID**: `4fafc201-1fb5-459e-8fcc-c5c9c331914b`
- **Characteristic UUID**: `beb5483e-36e1-4688-b7f5-ea07361b26a8`

### Command Format
```
MOVE:UP=1,DOWN=0,LEFT=0,RIGHT=0,SPEED=75,BOOST=1
LIGHT:1
HORN:1
STOP:1
```

### Build Commands
```powershell
flutter clean
flutter build appbundle --release
```

### Output Location
Release bundle: `build/app/outputs/bundle/release/app-release.aab`

***

## Important .gitignore Additions

Add these entries to your `.gitignore` to exclude sensitive files:

```gitignore
# Android Signing
android/key.properties
android/upload-keystore.jks
android/*.jks
android/*.keystore

# Build outputs
*.apk
*.aab
build/

# Android specific
android/.gradle/
android/app/build/
android/app/outputs/
android/captures/
android/local.properties
android/**/GeneratedPluginRegistrant.java

# IDE files
.idea/
.vscode/
*.iml
*.ipr
*.iws

# OS generated
.DS_Store
Thumbs.db
```

***

## Security Reminders

- 🔒 **NEVER commit keystore files to version control**
- 🔒 **NEVER commit `key.properties` with passwords**
- 🔒 **Store signing credentials securely outside of repository**
- 🔒 **Use environment variables or CI/CD secrets for production builds**

***

## Setup Instructions for New Contributors

1. **Get signing credentials** from project maintainer (not in repository)
2. **Create `android/key.properties`** with provided credentials
3. **Place keystore file** in `android/` directory
4. **Run `flutter clean && flutter pub get`**
5. **Test build**: `flutter build appbundle --release`

***

## Status: ✅ RESOLVED
App successfully builds in release mode with proper security measures in place.

**Note**: Signing credentials are intentionally excluded from this repository for security. Contact project maintainer for access to build release versions.
