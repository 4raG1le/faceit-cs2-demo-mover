@echo off
setlocal

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

chcp 65001 >nul
title Faceit Demo Mover - Uninstall
echo Removing Faceit Demo Mover...

reg delete "HKEY_CLASSES_ROOT\SystemFileAssociations\.zst\shell\MoveToCS2" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\SystemFileAssociations\.dem\shell\MoveToCS2" /f >nul 2>&1

echo.
echo [SUCCESS] Menu removed successfully!
echo The worker script in C:\Scripts is kept.
exit