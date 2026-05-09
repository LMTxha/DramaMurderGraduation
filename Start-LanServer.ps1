param(
    [int]$Port = 5090,
    [int]$ProxyPort = 8090
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ipadLauncher = Join-Path $repoRoot "Start-iPadUrl.ps1"

if (-not (Test-Path $ipadLauncher)) {
    throw "Start-iPadUrl.ps1 was not found: $ipadLauncher"
}

& $ipadLauncher -IisPort $Port -ProxyPort $ProxyPort -RestartIisExpress
