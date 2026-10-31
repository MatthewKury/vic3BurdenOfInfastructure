[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$modRoot = Split-Path $PSScriptRoot -Parent
$templatePath = Join-Path $modRoot 'gfx/interface/icons/goods_icons/boi_horses.dds'
$template = [IO.File]::ReadAllBytes($templatePath)
if ($template.Length -ne 349652) { throw 'Expected the 256x256 RGBA DDS horse icon with nine mip levels.' }
[byte[]]$header = $template[0..127]

$assets = @(
    @{ Name = 'boi_housing'; Source = 'art/housing'; Folder = 'goods_icons' },
    @{ Name = 'boi_luxury_housing'; Source = 'art/housing'; Folder = 'goods_icons' },
    @{ Name = 'boi_slums'; Source = 'art/housing/buildings'; Folder = 'building_icons' },
    @{ Name = 'boi_tenements'; Source = 'art/housing/buildings'; Folder = 'building_icons' },
    @{ Name = 'boi_apartments'; Source = 'art/housing/buildings'; Folder = 'building_icons' },
    @{ Name = 'boi_luxury_apartments'; Source = 'art/housing/buildings'; Folder = 'building_icons' },
    @{ Name = 'boi_suburbs'; Source = 'art/housing/buildings'; Folder = 'building_icons' },
    @{ Name = 'boi_temporary_shelter'; Source = 'art/housing/buildings'; Folder = 'building_icons' }
)

foreach ($asset in $assets) {
    $name = $asset.Name
    $sourceDirectory = Join-Path $modRoot $asset.Source
    $outputDirectory = Join-Path $modRoot (Join-Path 'gfx/interface/icons' $asset.Folder)
    [IO.Directory]::CreateDirectory($outputDirectory) | Out-Null
    $sourcePath = Join-Path $sourceDirectory "$name.png"
    $pngPath = Join-Path $outputDirectory "$name.png"
    $ddsPath = Join-Path $outputDirectory "$name.dds"
    if (-not (Test-Path -LiteralPath $sourcePath)) { throw "Missing generated source: $sourcePath" }

    $source = [System.Drawing.Image]::FromFile($sourcePath)
    try {
        $icon = [System.Drawing.Bitmap]::new(256, 256, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        try {
            $graphics = [System.Drawing.Graphics]::FromImage($icon)
            try {
                $graphics.Clear([System.Drawing.Color]::Transparent)
                $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.DrawImage($source, [System.Drawing.Rectangle]::new(0, 0, 256, 256))
            }
            finally { $graphics.Dispose() }
            $icon.Save($pngPath, [System.Drawing.Imaging.ImageFormat]::Png)

            $stream = [IO.File]::Open($ddsPath, [IO.FileMode]::Create, [IO.FileAccess]::Write)
            try {
                $writer = [IO.BinaryWriter]::new($stream)
                try {
                    $writer.Write($header)
                    foreach ($size in @(256, 128, 64, 32, 16, 8, 4, 2, 1)) {
                        $mip = [System.Drawing.Bitmap]::new($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
                        try {
                            $mipGraphics = [System.Drawing.Graphics]::FromImage($mip)
                            try {
                                $mipGraphics.Clear([System.Drawing.Color]::Transparent)
                                $mipGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
                                $mipGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                                $mipGraphics.DrawImage($icon, [System.Drawing.Rectangle]::new(0, 0, $size, $size))
                            }
                            finally { $mipGraphics.Dispose() }
                            $rectangle = [System.Drawing.Rectangle]::new(0, 0, $size, $size)
                            $data = $mip.LockBits($rectangle, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
                            try {
                                [byte[]]$pixels = New-Object byte[] ($data.Stride * $size)
                                [Runtime.InteropServices.Marshal]::Copy($data.Scan0, $pixels, 0, $pixels.Length)
                                for ($row = 0; $row -lt $size; $row++) {
                                    $writer.Write($pixels, $row * $data.Stride, $size * 4)
                                }
                            }
                            finally { $mip.UnlockBits($data) }
                        }
                        finally { $mip.Dispose() }
                    }
                }
                finally { $writer.Dispose() }
            }
            finally { $stream.Dispose() }
            if ((Get-Item -LiteralPath $ddsPath).Length -ne $template.Length) { throw "DDS size mismatch: $ddsPath" }
        }
        finally { $icon.Dispose() }
    }
    finally { $source.Dispose() }
    Write-Output "Wrote $pngPath and $ddsPath"
}
