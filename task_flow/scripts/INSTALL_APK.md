Install APK script (PowerShell)

Overview

This script builds (optionally) and installs the release APK to a connected Android device using `adb`.

Files
- `install-apk.ps1` : PowerShell script to build (optional), wait for a device, and install the APK.

Requirements
- `flutter` on PATH
- Android `platform-tools` installed at `%USERPROFILE%\Android\platform-tools\adb.exe`
- Device with USB debugging enabled (or available via `adb connect`)

Usage

1) Build then install (recommended):

```powershell
cd "E:\Task flow App\task_flow\scripts"
.\install-apk.ps1 -Build
```

2) Install without building (fast):

```powershell
cd "E:\Task flow App\task_flow\scripts"
.\install-apk.ps1
```

Options
- `-Build` : Runs `flutter build apk --release --no-shrink` before attempting install.
- `-DeviceTimeoutSeconds <n>` : Number of seconds to wait for a device (default 60).

Notes
- If `adb` is not found at `%USERPROFILE%\Android\platform-tools\adb.exe`, update the script or add platform-tools to PATH.
- If the device is not showing, ensure USB mode is File Transfer (MTP), accept the RSA debugging prompt on the phone, or update drivers in Device Manager.

Troubleshooting
- "Timed out waiting for a device": check cable, USB mode, and that USB debugging is enabled.
- "adb install failed": run the install command manually to see detailed output:

```powershell
& '%USERPROFILE%\Android\platform-tools\adb.exe' install -r "E:\Task flow App\task_flow\build\app\outputs\flutter-apk\app-release.apk"
```
