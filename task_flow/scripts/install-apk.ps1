param(
    [switch]$Build,
    [int]$DeviceTimeoutSeconds = 60
)

# Build and/or install the release APK, waiting for an Android device.
# Usage:
#  .\install-apk.ps1 -Build            # Builds release APK then installs when device appears
#  .\install-apk.ps1                   # Installs existing APK when device appears

 $scriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
 $projectRoot = Split-Path -Parent -Path $scriptDir
Write-Host "Project root: $projectRoot"

$apkRelPath = "build\app\outputs\flutter-apk\app-release.apk"
$adb = "$env:USERPROFILE\Android\platform-tools\adb.exe"
if (-not (Test-Path $adb)) {
    Write-Error "adb not found at $adb. Ensure platform-tools are installed and in $env:USERPROFILE\Android\platform-tools"
    exit 2
}

if ($Build) {
    Write-Host "Building release APK... (this may take several minutes)"
    Push-Location $projectRoot
    & flutter build apk --release --no-shrink
    $buildExit = $LASTEXITCODE
    Pop-Location
    if ($buildExit -ne 0) {
        Write-Error "flutter build failed with exit code $buildExit"
        exit $buildExit
    }
}

$apkPath = Join-Path $projectRoot $apkRelPath
if (-not (Test-Path $apkPath)) {
    Write-Error "APK not found at $apkPath. Run with -Build to build it first."
    exit 3
}

Write-Host "Waiting for an Android device (timeout ${DeviceTimeoutSeconds}s)..."
$elapsed = 0
while ($elapsed -lt $DeviceTimeoutSeconds) {
    & $adb kill-server | Out-Null
    & $adb start-server | Out-Null
    $devices = & $adb devices -l | Select-String -Pattern "device$|device\s" -SimpleMatch
    if ($devices) {
        # pick the first non-emulator device if possible
        $first = (& $adb devices -l) -split "\r?\n" | Where-Object { $_ -and ($_ -notmatch "List of devices") } | Where-Object { $_ -match "device" -and ($_ -notmatch "emulator") } | Select-Object -First 1
        if (-not $first) {
            $first = (& $adb devices -l) -split "\r?\n" | Where-Object { $_ -and ($_ -notmatch "List of devices") } | Select-Object -First 1
        }
        if ($first) {
            $deviceId = ($first -split '\s+')[0]
            Write-Host "Found device: $deviceId"
            Write-Host "Installing APK..."
            & $adb install -r $apkPath
            $installExit = $LASTEXITCODE
            if ($installExit -eq 0) {
                Write-Host "Install successful."
                exit 0
            }
            else {
                Write-Error "adb install failed with exit code $installExit"
                exit $installExit
            }
        }
    }
    Start-Sleep -Seconds 2
    $elapsed += 2
}

Write-Error "Timed out waiting for a device. Run the script again or connect your device."
exit 4
