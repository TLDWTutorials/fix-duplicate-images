@echo off
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0dedup.ps1"

echo.
echo PowerShell finished.
pause
