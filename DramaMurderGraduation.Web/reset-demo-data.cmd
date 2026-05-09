rem 重置演示数据库的 Windows 批处理入口。
rem 该脚本会启动 PowerShell 重置流程，请确认目标数据库是本地演示库。

@echo off
setlocal
set SCRIPT_DIR=%~dp0
echo Resetting demo data...
powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%reset-demo-data.ps1"
if errorlevel 1 (
    echo Demo reset failed.
    exit /b 1
)
echo Demo reset completed.
endlocal
