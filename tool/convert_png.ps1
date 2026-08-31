Add-Type -AssemblyName System.Drawing

$source = "C:\Users\Engr Ammar Official\.gemini\antigravity\brain\ec3e6013-e38c-486b-b8e8-f7c9cb678dc6\auratrack_app_icon_1788031991564.jpg"
$img = [System.Drawing.Image]::FromFile($source)

$targets = @(
    @{ Path = "android\app\src\main\res\mipmap-mdpi\ic_launcher.png"; Size = 48 },
    @{ Path = "android\app\src\main\res\mipmap-hdpi\ic_launcher.png"; Size = 72 },
    @{ Path = "android\app\src\main\res\mipmap-xhdpi\ic_launcher.png"; Size = 96 },
    @{ Path = "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png"; Size = 144 },
    @{ Path = "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png"; Size = 192 },
    @{ Path = "assets\icons\app_icon.png"; Size = 512 }
)

foreach ($t in $targets) {
    $outPath = $t.Path
    $size = $t.Size
    $dir = Split-Path $outPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }

    $bmp = New-Object System.Drawing.Bitmap $size, $size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($img, 0, 0, $size, $size)
    $g.Dispose()
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Saved true PNG ($size x $size) to $outPath"
}

$img.Dispose()
Write-Host "All icons converted to valid PNG format successfully."
