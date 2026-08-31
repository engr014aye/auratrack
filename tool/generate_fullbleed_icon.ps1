Add-Type -AssemblyName System.Drawing

$source = "C:\Users\Engr Ammar Official\.gemini\antigravity\brain\ec3e6013-e38c-486b-b8e8-f7c9cb678dc6\auratrack_app_icon_1788031991564.jpg"
$img = [System.Drawing.Image]::FromFile($source)

$outPath = "D:\Antigravity\store listing\app_icon_512.png"
$targetSize = 512

# Create a 512x512 bitmap
$bmp = New-Object System.Drawing.Bitmap $targetSize, $targetSize
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Dark background color from the icon edge (#101422)
$bgColor = [System.Drawing.ColorTranslator]::FromHtml("#101422")
$g.Clear($bgColor)

# Source crop rectangle (zooming in 30% so all corners are 100% full-bleed midnight blue)
$cropX = [int]($img.Width * 0.165)
$cropY = [int]($img.Height * 0.165)
$cropW = [int]($img.Width * 0.67)
$cropH = [int]($img.Height * 0.67)

$srcRect = New-Object System.Drawing.Rectangle $cropX, $cropY, $cropW, $cropH
$destRect = New-Object System.Drawing.Rectangle 0, 0, $targetSize, $targetSize

$g.DrawImage($img, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()

$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
$img.Dispose()

# Also update the app project mipmap icons and assets
$scriptDir = "D:\Antigravity\AuraTrack"
$sizes = @{
    "android\app\src\main\res\mipmap-mdpi\ic_launcher.png" = 48
    "android\app\src\main\res\mipmap-hdpi\ic_launcher.png" = 72
    "android\app\src\main\res\mipmap-xhdpi\ic_launcher.png" = 96
    "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png" = 144
    "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png" = 192
    "assets\icons\app_icon.png" = 512
}
$fullBleedImg = [System.Drawing.Image]::FromFile($outPath)
foreach ($rel in $sizes.Keys) {
    $dst = Join-Path $scriptDir $rel
    $s = $sizes[$rel]
    $b = New-Object System.Drawing.Bitmap $s, $s
    $g2 = [System.Drawing.Graphics]::FromImage($b)
    $g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g2.DrawImage($fullBleedImg, 0, 0, $s, $s)
    $g2.Dispose()
    $b.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
    $b.Dispose()
}
$fullBleedImg.Dispose()

Write-Host "Full-bleed 512x512 App Icon successfully generated and distributed!"
