# Small reader for top-level Clausewitz definitions. Preserves original source
# spans so generated overrides do not reformat or drop upstream properties.
function Get-HousingScriptBlocks {
    param([Parameter(Mandatory)][string]$Source)
    $tokens = [regex]::Matches($Source, '"(?:\\.|[^"\\])*"|#[^\r\n]*|[{}=]|[^\s{}="#]+')
    $depth = 0
    $start = -1
    $key = $null
    for ($i = 0; $i -lt $tokens.Count; $i++) {
        $token = $tokens[$i]
        if ($token.Value.StartsWith('#')) { continue }
        if ($token.Value -eq '{') { $depth++ }
        elseif ($token.Value -eq '}') {
            $depth--
            if ($depth -lt 0) { throw 'Unexpected closing brace.' }
            if ($depth -eq 0 -and $start -ge 0) {
                [pscustomobject]@{ Key = $key; Text = $Source.Substring($start, $token.Index + 1 - $start) }
                $start = -1
            }
        }
        elseif ($depth -eq 0 -and $i + 2 -lt $tokens.Count -and
                $tokens[$i + 1].Value -eq '=' -and $tokens[$i + 2].Value -eq '{') {
            $start = $token.Index
            $key = $token.Value
        }
    }
    if ($depth -ne 0) { throw 'Unbalanced script braces.' }
}

function Write-HousingScript {
    param([string]$Path, [string]$Text)
    [IO.Directory]::CreateDirectory((Split-Path $Path -Parent)) | Out-Null
    [IO.File]::WriteAllText($Path, ($Text.TrimEnd() + "`n"), [Text.UTF8Encoding]::new($true))
}
