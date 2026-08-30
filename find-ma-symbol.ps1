[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$PackageSource,
    [Parameter(Mandatory=$true, Position=1)]
    [string]$Symbol
)

$ErrorActionPreference = 'Stop'
$source = (Resolve-Path $PackageSource).Path
if (-not (Test-Path $source -PathType Container)) {
    throw "Package source directory not found: $source"
}

$escaped = [Regex]::Escape($Symbol)
Get-ChildItem -LiteralPath $source -Recurse -File -Include *.cs,*.md,*.json |
    Select-String -Pattern $escaped -CaseSensitive:$false |
    Select-Object Path, LineNumber, Line |
    Format-Table -AutoSize -Wrap
