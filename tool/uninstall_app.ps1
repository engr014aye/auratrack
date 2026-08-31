$adb = "C:\Android\Sdk\platform-tools\adb.exe"
Write-Host "Waiting for device to connect..."
for ($i = 0; $i -lt 30; $i++) {
    $devs = & $adb devices
    if ($devs -match "25878f4\s+device" -or $devs -match "device\b") {
        Write-Host "Device detected! Uninstalling com.palawshaapps.auratrack..."
        & $adb uninstall com.palawshaapps.auratrack
        Write-Host "App successfully uninstalled."
        exit 0
    }
    Start-Sleep -Milliseconds 800
}
Write-Host "No device detected after 25s."
