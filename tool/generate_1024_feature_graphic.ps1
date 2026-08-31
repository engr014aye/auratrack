Add-Type -AssemblyName System.Drawing

$source = "C:\Users\Engr Ammar Official\.gemini\antigravity\brain\ec3e6013-e38c-486b-b8e8-f7c9cb678dc6\feature_graphic_banner_1788061106607.jpg"
$img = [System.Drawing.Image]::FromFile($source)

$outPath = "D:\Antigravity\store listing\feature_graphic_1024x500.png"
$targetWidth = 1024
$targetHeight = 500

$bmp = New-Object System.Drawing.Bitmap $targetWidth, $targetHeight
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

$g.DrawImage($img, 0, 0, $targetWidth, $targetHeight)
$g.Dispose()

$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
$img.Dispose()

Write-Host "Feature Graphic (1024x500 PNG) saved to $outPath"
