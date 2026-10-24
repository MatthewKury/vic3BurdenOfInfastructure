# Draws the three placeholder water icons (256x256) and writes PNG + mipmapped
# DDS beside them. Placeholder art: simple flat shapes, replace freely. The DDS
# header is borrowed from boi_horses.dds, as Convert-HousingIcons.ps1 does.
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path $PSScriptRoot -Parent
$template = [IO.File]::ReadAllBytes((Join-Path $root 'gfx/interface/icons/goods_icons/boi_horses.dds'))
if ($template.Length -ne 349652) { throw 'Expected the 256x256 RGBA DDS horse icon with nine mip levels.' }
[byte[]]$header = $template[0..127]

function New-Canvas {
    $bmp = [System.Drawing.Bitmap]::new(256, 256, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)
    return @{ Bitmap = $bmp; Graphics = $g }
}
function Color([int]$a, [int]$r, [int]$gr, [int]$b) { [System.Drawing.Color]::FromArgb($a, $r, $gr, $b) }

# A water drop: a circle plus a triangle from the tip to the two tangent points.
# Drawn twice, first expanded in the edge colour, then normal in the fill colour.
function Fill-DropShape($g, [float]$cx, [float]$top, [float]$bottom, [float]$r, $brush) {
    $cy = $bottom - $r
    $d = $cy - $top
    $phi = [Math]::Acos($r / $d)
    $dx = $r * [Math]::Sin($phi)
    $dy = $r * [Math]::Cos($phi)
    $g.FillEllipse($brush, $cx - $r, $cy - $r, 2 * $r, 2 * $r)
    $points = [System.Drawing.PointF[]]@(
        [System.Drawing.PointF]::new($cx, $top),
        [System.Drawing.PointF]::new($cx + $dx, $cy - $dy),
        [System.Drawing.PointF]::new($cx - $dx, $cy - $dy)
    )
    $g.FillPolygon($brush, $points)
}

function Draw-Drop($g, [float]$cx, [float]$top, [float]$bottom, [float]$halfWidth, $fill, $edge) {
    $edgeBrush = [System.Drawing.SolidBrush]::new($edge)
    $fillBrush = [System.Drawing.SolidBrush]::new($fill)
    Fill-DropShape $g $cx ($top - 7) ($bottom + 4) ($halfWidth + 4) $edgeBrush
    Fill-DropShape $g $cx $top $bottom $halfWidth $fillBrush
    $edgeBrush.Dispose(); $fillBrush.Dispose()
}
$deep = Color 255 38 112 178
$edge = Color 255 20 62 112
$light = Color 255 120 190 235
$stone = Color 255 168 156 138
$stoneEdge = Color 255 84 76 64

# 1. water: one big drop with a highlight.
$c = New-Canvas
Draw-Drop $c.Graphics 128 24 232 78 $deep $edge
$hl = [System.Drawing.SolidBrush]::new((Color 200 255 255 255))
$c.Graphics.FillEllipse($hl, 92, 138, 26, 46)
$hl.Dispose()
$water = $c.Bitmap; $c.Graphics.Dispose()

# 2. bulk_water: three small drops over a barrel band, reading as "water in transit".
$c = New-Canvas
$g = $c.Graphics
$barrel = [System.Drawing.SolidBrush]::new((Color 255 140 98 56))
$hoop = [System.Drawing.Pen]::new((Color 255 60 40 24), 7)
$g.FillEllipse($barrel, 46, 150, 164, 90)
$g.DrawEllipse($hoop, 46, 150, 164, 90)
$g.DrawArc($hoop, 46, 176, 164, 36, 0, 180)
$barrel.Dispose(); $hoop.Dispose()
Draw-Drop $g 90 30 120 24 $deep $edge
Draw-Drop $g 128 18 108 28 $light $edge
Draw-Drop $g 168 34 124 24 $deep $edge
$bulk = $c.Bitmap; $g.Dispose()

# 3. waterworks: three aqueduct arches with water running along the top.
$c = New-Canvas
$g = $c.Graphics
$brush = [System.Drawing.SolidBrush]::new($stone)
$pen = [System.Drawing.Pen]::new($stoneEdge, 6)
$g.FillRectangle($brush, 16, 110, 224, 120)
$g.DrawRectangle($pen, 16, 110, 224, 120)
$hole = [System.Drawing.SolidBrush]::new((Color 255 40 36 32))
foreach ($x in @(34, 98, 162)) {
    $g.FillEllipse($hole, $x, 134, 60, 70)
    $g.FillRectangle($hole, $x, 168, 60, 62)
    $g.DrawArc($pen, $x, 134, 60, 70, 180, 180)
}
$channel = [System.Drawing.SolidBrush]::new($deep)
$g.FillRectangle($channel, 16, 84, 224, 28)
$g.DrawRectangle($pen, 16, 84, 224, 28)
$sheen = [System.Drawing.SolidBrush]::new($light)
$g.FillRectangle($sheen, 24, 90, 208, 8)
$brush.Dispose(); $pen.Dispose(); $hole.Dispose(); $channel.Dispose(); $sheen.Dispose()
$works = $c.Bitmap; $g.Dispose()

function Save-Icon($bitmap, [string]$folder, [string]$name) {
    $directory = Join-Path $root "gfx/interface/icons/$folder"
    [IO.Directory]::CreateDirectory($directory) | Out-Null
    $bitmap.Save((Join-Path $directory "$name.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $stream = [IO.File]::Open((Join-Path $directory "$name.dds"), [IO.FileMode]::Create, [IO.FileAccess]::Write)
    try {
        $writer = [IO.BinaryWriter]::new($stream)
        $writer.Write($header)
        foreach ($size in @(256, 128, 64, 32, 16, 8, 4, 2, 1)) {
            $mip = [System.Drawing.Bitmap]::new($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
            $mg = [System.Drawing.Graphics]::FromImage($mip)
            $mg.Clear([System.Drawing.Color]::Transparent)
            $mg.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
            $mg.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $mg.DrawImage($bitmap, [System.Drawing.Rectangle]::new(0, 0, $size, $size))
            $mg.Dispose()
            $data = $mip.LockBits([System.Drawing.Rectangle]::new(0, 0, $size, $size), [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
            [byte[]]$pixels = New-Object byte[] ($data.Stride * $size)
            [Runtime.InteropServices.Marshal]::Copy($data.Scan0, $pixels, 0, $pixels.Length)
            for ($row = 0; $row -lt $size; $row++) { $writer.Write($pixels, $row * $data.Stride, $size * 4) }
            $mip.UnlockBits($data); $mip.Dispose()
        }
        $writer.Flush()
    }
    finally { $stream.Dispose() }
    if ((Get-Item (Join-Path $directory "$name.dds")).Length -ne $template.Length) { throw "DDS size mismatch: $name" }
    Write-Output "Wrote $folder/$name.png and .dds"
}

Save-Icon $water 'goods_icons' 'boi_water'
Save-Icon $bulk 'goods_icons' 'boi_bulk_water'
Save-Icon $works 'building_icons' 'boi_waterworks'
