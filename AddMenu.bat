@echo off
setlocal

echo ====================================================
echo   Faceit Demo Mover Install
echo ====================================================
echo.

:: 1. Проверка прав администратора
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] No admin rights. Requesting...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
echo [+] Admin rights confirmed.

:: 2. Определяем язык
for /f "usebackq tokens=*" %%a in (`powershell -NoProfile -Command "(Get-Culture).Name"`) do set "SYS_LANG=%%a"

:: 3. Путь к скрипту
set "SCRIPT_PATH=%~dp0MoveDemoToCS2.ps1"
if not exist "%SCRIPT_PATH%" (
    echo [ERROR] MoveDemoToCS2.ps1 not found!
    pause
    exit /b
)
echo [+] Worker script found at: %SCRIPT_PATH%
echo.

:: 4. Записываем в реестр через API PowerShell (Без кракозябр, с правильным %1)
echo [*] Writing to registry...
powershell -NoProfile -Command ^
    "$scriptPath = '%SCRIPT_PATH%';" ^
    "$icon = 'C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\bin\win64\cs2.exe';" ^
    "if ('%SYS_LANG%' -eq 'ru-RU') {" ^
    "    $menuText = [char]0x041F + [char]0x0435 + [char]0x0440 + [char]0x0435 + [char]0x043C + [char]0x0435 + [char]0x0441 + [char]0x0442 + [char]0x0438 + [char]0x0442 + [char]0x044C + [char]0x0020 + [char]0x0434 + [char]0x0435 + [char]0x043C + [char]0x043A + [char]0x0443 + [char]0x0020 + [char]0x0432 + [char]0x0020 + 'CS2';" ^
    "} else { $menuText = 'Move demo to CS2'; }" ^
    "$exts = @('.zst', '.dem');" ^
    "foreach ($ext in $exts) {" ^
    "    $baseKey = [Microsoft.Win32.Registry]::ClassesRoot.CreateSubKey(\"SystemFileAssociations\$ext\shell\MoveToCS2\");" ^
    "    $baseKey.SetValue('', $menuText);" ^
    "    $baseKey.SetValue('Icon', $icon);" ^
    "    $baseKey.Close();" ^
    "    $cmdKey = [Microsoft.Win32.Registry]::ClassesRoot.CreateSubKey(\"SystemFileAssociations\$ext\shell\MoveToCS2\command\");" ^
    "    $cmdKey.SetValue('', \"powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `\"$scriptPath`\" `\"%%1`\"\");" ^
    "    $cmdKey.Close();" ^
    "    Write-Host \"    [+] Added for $ext\";" ^
    "}"

echo.
echo ====================================================
echo   [DONE] Installation complete!
echo ====================================================
echo.
exit