<#
.SYNOPSIS
  Approximate mockups of the Terminal Themes face for every theme x style, read from watchface.xml.
  This is a desktop approximation (GDI+), not the watch renderer.
.EXAMPLE
  .\scripts\render-previews.ps1                       # grid of all themes x styles -> previews\grid.png
  .\scripts\render-previews.ps1 -UpdatePickerPreview  # also rewrite res/drawable-nodpi/preview.png (theme 0, style 0)
#>
param([switch]$UpdatePickerPreview, [string]$OutDir = (Join-Path $PSScriptRoot "..\previews"))
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$res = (Resolve-Path (Join-Path $PSScriptRoot "..\terminal-themes\src\main\res")).Path
$xml = [xml](Get-Content "$res\raw\watchface.xml" -Raw -Encoding UTF8)
$strings = [xml](Get-Content "$res\values\strings.xml" -Raw -Encoding UTF8)
$themes = foreach ($o in $xml.WatchFace.UserConfigurations.ColorConfiguration.ColorOption) {
    $name = ($strings.resources.string | Where-Object { $_.name -eq $o.displayName }).'#text'
    [pscustomobject]@{ Name = $name; P = @($o.colors -split '\s+' | ForEach-Object { '#' + $_.Substring(3) }) }
}

$pb = New-Object System.Drawing.Text.PrivateFontCollection; $pb.AddFontFile("$res\font\jetbrains_mono_bold.ttf")
$pr = New-Object System.Drawing.Text.PrivateFontCollection; $pr.AddFontFile("$res\font\jetbrains_mono_regular.ttf")
function C($h) { [System.Drawing.ColorTranslator]::FromHtml($h) }
function F($size, $bold) { New-Object System.Drawing.Font($(if ($bold) { $pb.Families[0] } else { $pr.Families[0] }), $size, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel) }

function Render($t, [int]$style) {
    $P = $t.P
    $bmp = New-Object System.Drawing.Bitmap 450, 450
    $g = [System.Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAliasGridFit'
    $g.Clear((C $P[0]))
    foreach ($l in @(@('stars_far', 2, 1.0), @('stars_mid', 4, 0.9), @('stars_near', 8, 1.0))) {
        $c = C $P[$l[1]]; $img = [System.Drawing.Image]::FromFile("$res\drawable-nodpi\$($l[0]).png")
        $m = New-Object System.Drawing.Imaging.ColorMatrix; $m.Matrix00 = $c.R / 255; $m.Matrix11 = $c.G / 255; $m.Matrix22 = $c.B / 255; $m.Matrix33 = $l[2]
        $ia = New-Object System.Drawing.Imaging.ImageAttributes; $ia.SetColorMatrix($m)
        $g.DrawImage($img, (New-Object System.Drawing.Rectangle(0, 0, 450, 450)), 0, 0, 450, 450, 'Pixel', $ia); $img.Dispose()
    }
    $g.DrawEllipse((New-Object System.Drawing.Pen((C $P[1]), 10)), 12, 12, 426, 426)
    $pen = New-Object System.Drawing.Pen((C $P[6]), 10); $pen.StartCap = 'Round'; $pen.EndCap = 'Round'
    $g.DrawArc($pen, 12, 12, 426, 426, -90, 0.68 * 360)

    function T($s, $size, $col, $x, $y, $w, $h, $align = 'Center', $bold = $false) {
        $sf = New-Object System.Drawing.StringFormat; $sf.Alignment = $align; $sf.LineAlignment = 'Center'; $sf.FormatFlags = 'NoClip'
        $g.DrawString($s, (F $size $bold), (New-Object System.Drawing.SolidBrush((C $col))), (New-Object System.Drawing.RectangleF($x, $y, $w, $h)), $sf)
    }
    if ($style -eq 0) {
        T '14°' 38 $P[5] 75 78 300 46 'Center' $true
        T 'Cloudy · 16°/8°' 22 $P[3] 75 124 300 30
        T '10' 110 $P[2] 20 160 175 120 'Far' $true
        T ':' 100 $P[3] 195 155 60 110 'Center' $true
        T '08' 110 $P[4] 255 160 175 120 'Near' $true
        T 'Thu 5 Nov' 28 $P[7] 75 284 300 38
        T '4521 steps' 26 $P[6] 75 330 300 36
    } else {
        T '○' 20 $P[6] 129 56 30 28 'Near'
        T 'brizuela' 20 $P[2] 153 56 110 28 'Near' $true
        T '@gw7' 20 $P[3] 249 56 60 28 'Near'
        T '~' 20 $P[7] 309 56 20 28 'Near' $true
        T '14°' 22 $P[5] 60 90 110 32 'Far' $true
        T ' Cloudy ↑16 ↓8' 22 $P[3] 170 90 215 32 'Near'
        T '10' 104 $P[2] 20 150 175 120 'Far' $true
        T ':' 96 $P[9] 195 145 60 110 'Center' $true
        T '08' 104 $P[4] 255 150 175 120 'Near' $true
        T '≡' 22 $P[9] 146 270 30 30 'Near'
        T 'Thu 5 Nov' 22 $P[7] 172 270 190 30 'Near'
        T '»' 22 $P[9] 146 302 30 30 'Near'
        T '4521 steps' 22 $P[6] 172 302 190 30 'Near'
        T '❯' 24 $P[6] 146 340 30 34 'Near' $true
        T '█' 24 $P[2] 175 340 20 34 'Near'
    }
    $g.Dispose(); return $bmp
}

New-Item -ItemType Directory -Force $OutDir | Out-Null
$tile = 300; $pad = 16; $label = 30
$cols = $themes.Count; $rows = 2
$grid = New-Object System.Drawing.Bitmap ($cols * ($tile + $pad) + $pad), ($rows * ($tile + $label) + $pad)
$gg = [System.Drawing.Graphics]::FromImage($grid); $gg.Clear((C '#0b0b12')); $gg.TextRenderingHint = 'AntiAliasGridFit'; $gg.InterpolationMode = 'HighQualityBicubic'
for ($s = 0; $s -lt $rows; $s++) {
    for ($i = 0; $i -lt $cols; $i++) {
        $b = Render $themes[$i] $s
        $x = $pad + $i * ($tile + $pad); $y = $s * ($tile + $label) + $label
        $gg.DrawImage($b, $x, $y, $tile, $tile)
        $gg.DrawString("$($themes[$i].Name) · $(@('classic','terminal')[$s])", (F 15 $false), [System.Drawing.Brushes]::Gainsboro, $x, $y - 24)
        if ($UpdatePickerPreview -and $i -eq 0 -and $s -eq 0) { $b.Save("$res\drawable-nodpi\preview.png", [System.Drawing.Imaging.ImageFormat]::Png) }
        $b.Dispose()
    }
}
$out = Join-Path (Resolve-Path $OutDir).Path "grid.png"
$grid.Save($out, [System.Drawing.Imaging.ImageFormat]::Png); $gg.Dispose(); $grid.Dispose()
Write-Host $out
