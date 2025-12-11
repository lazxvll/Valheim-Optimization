@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Valheim Optimization [Net]
mode con:cols=75 lines=35
cls
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"
set "Red=%ESC%[91m"
set "Green=%ESC%[92m"
set "Cyan=%ESC%[96m"
set "Reset=%ESC%[0m"
set "INI_URL=https://raw.githubusercontent.com/lazxvll/Valheim-Optimization/main/valheim.ini"

echo.
echo  ---------------------------------------------------------
echo   Title:       Valheim Optimization
echo   Description: Очистка + Загрузка конфига
echo   Version:     0.1
echo   Date:        11.12.2025
echo   Developer:   Laz
echo  ---------------------------------------------------------
echo.

if not exist "valheim.exe" (
    echo  %Red%[ОШИБКА] Не найден valheim.exe!%Reset%
    echo.
    echo  Скрипт должен лежать в папке с игрой.
    pause
    exit
)

taskkill /f /im "valheim.exe" >nul 2>&1
timeout /t 1 >nul

if exist ".backup\BackupMarker.txt" goto :RESTORE_MODE

:CLEAN_MODE
echo  [РЕЖИМ] ОПТИМИЗАЦИЯ...
echo.

if not exist ".backup\valheim_Data\Plugins\x86_64" md ".backup\valheim_Data\Plugins\x86_64"
echo BackupActive > ".backup\BackupMarker.txt"

set "ROOT=.backup"
set "PLUGINS_BACKUP=.backup\valheim_Data\Plugins\x86_64"
set "PLUGINS_ORIG=valheim_Data\Plugins\x86_64"

:: Убираем фоновую слежку при вылетах игры.
if exist "UnityCrashHandler64.exe" (
    move "UnityCrashHandler64.exe" "%ROOT%\" >nul
    echo  [-] UnityCrashHandler64 ..... %Red%[СПРЯТАН]%Reset%
)

:: :: DirectX 12, лучше использвовать DirectX 11 или Vulkan.
if exist "D3D12" (
    move "D3D12" "%ROOT%\" >nul
    echo  [-] D3D12 ................... %Red%[СПРЯТАН]%Reset%
)

:: Xbox файлы
if exist "%PLUGINS_ORIG%\Microsoft.Xbox.Services.141.GDK.C.Thunks.dll" (
    move "%PLUGINS_ORIG%\Microsoft.Xbox.Services.141.GDK.C.Thunks.dll" "%PLUGINS_BACKUP%\" >nul
    echo  [-] Xbox Services ........... %Red%[СПРЯТАН]%Reset%
)
if exist "%PLUGINS_ORIG%\PartyXboxLive.dll" (
    move "%PLUGINS_ORIG%\PartyXboxLive.dll" "%PLUGINS_BACKUP%\" >nul
    echo  [-] PartyXboxLive ........... %Red%[СПРЯТАН]%Reset%
)
if exist "%PLUGINS_ORIG%\PartyXboxLiveWin32.dll" (
    move "%PLUGINS_ORIG%\PartyXboxLiveWin32.dll" "%PLUGINS_BACKUP%\" >nul
    echo  [-] PartyXboxLiveWin32 ...... %Red%[СПРЯТАН]%Reset%
)
if exist "%PLUGINS_ORIG%\XCurl.dll" (
    move "%PLUGINS_ORIG%\XCurl.dll" "%PLUGINS_BACKUP%\" >nul
    echo  [-] XCurl ................... %Red%[СПРЯТАН]%Reset%
)
if exist "%PLUGINS_ORIG%\XGamingRuntimeThunks.dll" (
    move "%PLUGINS_ORIG%\XGamingRuntimeThunks.dll" "%PLUGINS_BACKUP%\" >nul
    echo  [-] XGamingRuntimeThunks .... %Red%[СПРЯТАН]%Reset%
)

echo.
echo  [NET] Загрузка valheim.ini с GitHub...
curl -L -s -o "valheim.ini" "%INI_URL%"

if exist "valheim.ini" (
    echo  [+] valheim.ini ............. %Cyan%[СКАЧАН]%Reset%
) else (
    echo  [!] Ошибка загрузки ......... %Red%[FAIL]%Reset%
)

echo.
echo  ---------------------------------------------------------
echo  [ГОТОВО] Оптимизация завершена.
echo  ---------------------------------------------------------
pause
exit

:RESTORE_MODE
echo  [РЕЖИМ] ВОССТАНОВЛЕНИЕ...
echo.

set "ROOT=.backup"
set "PLUGINS_BACKUP=.backup\valheim_Data\Plugins\x86_64"
set "PLUGINS_ORIG=valheim_Data\Plugins\x86_64"

if exist "%ROOT%\UnityCrashHandler64.exe" move "%ROOT%\UnityCrashHandler64.exe" "." >nul
if exist "%ROOT%\D3D12" move "%ROOT%\D3D12" "." >nul

if exist "%PLUGINS_BACKUP%\*.dll" (
    move "%PLUGINS_BACKUP%\*.dll" "%PLUGINS_ORIG%\" >nul
    echo  [+] Библиотеки Xbox ......... %Green%[ВОССТАНОВЛЕН]%Reset%
)

if exist "valheim.ini" (
    del /q "valheim.ini"
    echo  [-] valheim.ini ............. %Red%[УДАЛЕН]%Reset%
)

echo  [+] Остальные файлы ......... %Green%[ВОССТАНОВЛЕН]%Reset%

rd /s /q ".backup" >nul 2>&1

echo.
echo  ---------------------------------------------------------
echo  [ГОТОВО] Игра возвращена в исходное состояние.
echo  ---------------------------------------------------------
pause
exit
