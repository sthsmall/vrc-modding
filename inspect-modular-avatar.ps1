[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$ProjectRoot = (Get-Location).Path,
    [switch]$AsJson
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path $ProjectRoot).Path
$assets = Join-Path $root 'Assets'
$packages = Join-Path $root 'Packages'
$settings = Join-Path $root 'ProjectSettings'

if (-not (Test-Path $assets) -or -not (Test-Path $packages) -or -not (Test-Path $settings)) {
    throw "Not a Unity project root: $root (expected Assets, Packages, ProjectSettings)"
}

function Read-JsonFile([string]$Path) {
    if (-not (Test-Path $Path)) { return $null }
    return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
}

$manifestPath = Join-Path $packages 'manifest.json'
$lockPath = Join-Path $packages 'packages-lock.json'
$versionPath = Join-Path $settings 'ProjectVersion.txt'
$manifest = Read-JsonFile $manifestPath
$lock = Read-JsonFile $lockPath

$unityVersion = $null
if (Test-Path $versionPath) {
    $line = Get-Content -LiteralPath $versionPath -Encoding UTF8 | Select-Object -First 1
    if ($line -match '^m_EditorVersion:\s*(.+)$') { $unityVersion = $Matches[1].Trim() }
}

$candidates = @()
if ($manifest -and $manifest.dependencies) {
    foreach ($p in $manifest.dependencies.PSObject.Properties) {
        if ($p.Name -match '(?i)modular.?avatar') {
            $candidates += [pscustomobject]@{ packageId=$p.Name; manifestSpec=[string]$p.Value }
        }
    }
}

if ($lock -and $lock.dependencies) {
    foreach ($p in $lock.dependencies.PSObject.Properties) {
        if ($p.Name -match '(?i)modular.?avatar') {
            $existing = $candidates | Where-Object packageId -eq $p.Name | Select-Object -First 1
            if (-not $existing) {
                $existing = [pscustomobject]@{ packageId=$p.Name; manifestSpec=$null }
                $candidates += $existing
            }
            $existing | Add-Member -NotePropertyName resolvedVersion -NotePropertyValue ([string]$p.Value.version) -Force
            $existing | Add-Member -NotePropertyName source -NotePropertyValue ([string]$p.Value.source) -Force
            $existing | Add-Member -NotePropertyName depth -NotePropertyValue $p.Value.depth -Force
        }
    }
}

$packageCache = Join-Path $root 'Library/PackageCache'
foreach ($candidate in $candidates) {
    $locations = @()
    $embedded = Join-Path $packages $candidate.packageId
    if (Test-Path $embedded) { $locations += (Resolve-Path $embedded).Path }
    if (Test-Path $packageCache) {
        $pattern = $candidate.packageId + '@*'
        $locations += Get-ChildItem -LiteralPath $packageCache -Directory -Filter $pattern -ErrorAction SilentlyContinue |
            ForEach-Object { $_.FullName }
    }
    $locations = $locations | Select-Object -Unique
    $candidate | Add-Member -NotePropertyName locations -NotePropertyValue @($locations) -Force

    $packageJsons = @()
    foreach ($loc in $locations) {
        $pj = Join-Path $loc 'package.json'
        if (Test-Path $pj) {
            try {
                $data = Read-JsonFile $pj
                $packageJsons += [pscustomobject]@{
                    path=$pj
                    name=$data.name
                    displayName=$data.displayName
                    version=$data.version
                    unity=$data.unity
                }
            } catch {
                $packageJsons += [pscustomobject]@{ path=$pj; error=$_.Exception.Message }
            }
        }
    }
    $candidate | Add-Member -NotePropertyName packageJson -NotePropertyValue @($packageJsons) -Force
}

$ndmf = @()
if ($lock -and $lock.dependencies) {
    foreach ($p in $lock.dependencies.PSObject.Properties) {
        if ($p.Name -match '(?i)ndmf') {
            $ndmf += [pscustomobject]@{
                packageId=$p.Name
                version=[string]$p.Value.version
                source=[string]$p.Value.source
            }
        }
    }
}

$result = [pscustomobject]@{
    projectRoot=$root
    unityVersion=$unityVersion
    manifestPath=$manifestPath
    lockPath=$lockPath
    modularAvatar=@($candidates)
    ndmf=@($ndmf)
    notes=@(
        'Do not modify Library/PackageCache.',
        'Resolve exact component fields from the located installed source.',
        'If no package is found, confirm the package ID in manifest/lock files.'
    )
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 8
} else {
    $result | ConvertTo-Json -Depth 8
}
