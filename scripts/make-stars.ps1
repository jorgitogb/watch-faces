<#
.SYNOPSIS
  Generate the starfield layers for the Terminal Themes face (transparent PNGs, white stars).
  Stars are white so the watch face can tint each layer with the flavor palette.
.EXAMPLE
  .\scripts\make-stars.ps1            # same seed -> same sky
  .\scripts\make-stars.ps1 -Seed 7    # a different sky
#>
param([int]$Seed = 42)
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$out = Join-Path $PSScriptRoot "..\terminal-themes\src\main\res\drawable-nodpi"
$rng = New-Object System.Random $Seed
$S = 450

# Keep the area behind time/date/steps quieter so text stays legible.
function Get-Dim([double]$x, [double]$y) {
    if ($x -gt 30 -and $x -lt 420 -and $y -gt 70 -and $y -lt 370) { return 0.35 }
    return 1.0
}
function Inside-Circle([double]$x, [double]$y) {
    $dx = $x - 225; $dy = $y - 225
    return ($dx * $dx + $dy * $dy) -lt (205 * 205)   # stay inside the step ring
}

function New-Layer([string]$name, [int]$count, [double]$rMin, [double]$rMax, [int]$aMin, [int]$aMax, [int]$sparkles) {
    $bmp = New-Object System.Drawing.Bitmap $S, $S, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.Clear([System.Drawing.Color]::Transparent)

    $placed = 0
    while ($placed -lt $count) {
        $x = $rng.NextDouble() * $S; $y = $rng.NextDouble() * $S
        if (-not (Inside-Circle $x $y)) { continue }
        $r = $rMin + $rng.NextDouble() * ($rMax - $rMin)
        $a = [int](($aMin + $rng.Next($aMax - $aMin + 1)) * (Get-Dim $x $y))
        # soft glow + core
        $glow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb([int]($a * 0.25), 255, 255, 255))
        $g.FillEllipse($glow, $x - $r * 2.2, $y - $r * 2.2, $r * 4.4, $r * 4.4)
        $core = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($a, 255, 255, 255))
        $g.FillEllipse($core, $x - $r, $y - $r, $r * 2, $r * 2)
        $placed++
    }

    # A few 4-point sparkles, kept away from the text area
    $placed = 0
    while ($placed -lt $sparkles) {
        $x = 40 + $rng.NextDouble() * 370; $y = 40 + $rng.NextDouble() * 370
        if (-not (Inside-Circle $x $y) -or (Get-Dim $x $y) -lt 1) { continue }
        $len = 7 + $rng.NextDouble() * 6
        $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(230, 255, 255, 255)), 1.6
        $pen.StartCap = 'Round'; $pen.EndCap = 'Round'
        $g.DrawLine($pen, $x - $len, $y, $x + $len, $y)
        $g.DrawLine($pen, $x, $y - $len, $x, $y + $len)
        $g.FillEllipse([System.Drawing.Brushes]::White, $x - 2, $y - 2, 4, 4)
        $placed++
    }

    $g.Dispose()
    $bmp.Save((Join-Path $out "$name.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

#          name           count rMin rMax aMin aMax sparkles
New-Layer "stars_far"     90    0.5  1.0  70   150  0   # dim dust, static
New-Layer "stars_mid"     30    0.9  1.6  140  230  0   # twinkle A
New-Layer "stars_near"    10    1.3  2.0  200  255  4   # twinkle B + sparkles
Write-Host "Starfield written to $out (seed $Seed)"
