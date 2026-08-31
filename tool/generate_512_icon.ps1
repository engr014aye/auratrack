Add-Type -AssemblyName System.Drawing

$source = "C:\Users\Engr Ammar Official\.gemini\antigravity\brain\ec3e6013-e38c-486b-b8e8-f7c9cb678dc6\auratrack_app_icon_1788031991564.jpg"
$img = [System.Drawing.Image]::FromFile($source)

$outPath = "D:\Antigravity\store listing\app_icon_512.png"
$bmp = New-Object System.Drawing.Bitmap 512, 512
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.DrawImage($img, 0, 0, 512, 512)
$g.Dispose()

$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
$img.Dispose()

Write-Host "512x512 App Icon successfully saved to $outPath"
