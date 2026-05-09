# 重置演示数据库并重新导入模拟数据，供答辩或测试前恢复固定状态。
# 该脚本会调用 setup-database.ps1 -Reset，请确认目标数据库是本地演示库。

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$setupScript = Join-Path $scriptRoot "setup-database.ps1"

if (-not (Test-Path -LiteralPath $setupScript)) {
    throw "setup-database.ps1 was not found at $setupScript"
}

Write-Host "Resetting demo database and reseeding mock data..."
& $setupScript -Reset

if ($LASTEXITCODE -ne 0) {
    throw "Demo reset failed."
}

Write-Host "Demo reset finished. Restart the site and sign in with the default demo accounts."
