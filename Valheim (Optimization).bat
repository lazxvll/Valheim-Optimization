@echo off
powershell -noprofile -command "Add-Type -AssemblyName System.Windows.Forms;$w=Add-Type -MemberDefinition '[DllImport(\"user32.dll\")]public static extern bool SetWindowPos(IntPtr hWnd,IntPtr hWndInsertAfter,int X,int Y,int cx,int cy,uint uFlags);[DllImport(\"kernel32.dll\")]public static extern IntPtr GetConsoleWindow();' -Name Win32 -PassThru;$h=$w::GetConsoleWindow();$s=[System.Windows.Forms.Screen]::PrimaryScreen.Bounds;$width=670;$height=360;$left=[math]::Round(($s.Width-$width)/2);$top=[math]::Round(($s.Height-$height)/2);$w::SetWindowPos($h,0,$left,$top,0,0,1)" >nul 2>&1
@chcp 65001 >nul 2>&1
cd /d "%~dp0"
title Valheim Optimization
mode con:cols=75 lines=35
cls
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"
set "Red=%ESC%[91m"
set "Green=%ESC%[92m"
set "Cyan=%ESC%[96m"
set "R=%ESC%[0m"
set "Gray=%ESC%[90m"
set "INI_URL=https://raw.githubusercontent.com/lazxvll/Valheim-Optimization/main/valheim.ini"

echo.
echo  ---------------------------------------------------------
echo   Title:       Valheim Optimization
echo   Description: Очистка + Загрузка конфига
echo   Version:     0.1
echo   Date:        22.12.2025
echo   Developer:   Laz
echo  ---------------------------------------------------------
echo.

if not exist "valheim.exe" (
    echo  %Red%[ОШИБКА] Не найден valheim.exe!%R%
    echo.
    echo  Скрипт должен лежать в папке с игрой.
    pause
    exit
)

taskkill /f /im "valheim.exe" >nul 2>&1
timeout /t 1 >nul

if exist ".backup\BackupMarker.txt" goto :RESTORE_MODE

:CLEAN_MODE
echo. [%Cyan%!%R%] Убираем файлы в %Cyan%.backup%R%
if not exist ".backup\valheim_Data\Plugins\x86_64" md ".backup\valheim_Data\Plugins\x86_64"
echo BackupActive > ".backup\BackupMarker.txt"

set "ROOT=.backup"
set "PLUGINS_BACKUP=.backup\valheim_Data\Plugins\x86_64"
set "PLUGINS_ORIG=valheim_Data\Plugins\x86_64"

:: Убираем фоновую слежку при вылетах игры.
if exist "UnityCrashHandler64.exe" (
    move "UnityCrashHandler64.exe" "%ROOT%\" >nul
    echo  [%Cyan%-%R%] UnityCrashHandler64 ..... %Gray%Готово...%R%
)

:: :: DirectX 12, лучше использвовать DirectX 11 или Vulkan.
if exist "D3D12" (
    move "D3D12" "%ROOT%\" >nul
    echo  [%Cyan%-%R%] D3D12 ................... %Gray%Готово...%R%
)

:: Xbox файлы
if exist "%PLUGINS_ORIG%\Microsoft.Xbox.Services.141.GDK.C.Thunks.dll" (
    move "%PLUGINS_ORIG%\Microsoft.Xbox.Services.141.GDK.C.Thunks.dll" "%PLUGINS_BACKUP%\" >nul
    echo  [%Cyan%-%R%] Xbox Services ........... %Gray%Готово...%R%
)
if exist "%PLUGINS_ORIG%\PartyXboxLive.dll" (
    move "%PLUGINS_ORIG%\PartyXboxLive.dll" "%PLUGINS_BACKUP%\" >nul
    echo  [%Cyan%-%R%] PartyXboxLive ........... %Gray%Готово...%R%
)
if exist "%PLUGINS_ORIG%\PartyXboxLiveWin32.dll" (
    move "%PLUGINS_ORIG%\PartyXboxLiveWin32.dll" "%PLUGINS_BACKUP%\" >nul
    echo  [%Cyan%-%R%] PartyXboxLiveWin32 ...... %Gray%Готово...%R%
)
if exist "%PLUGINS_ORIG%\XCurl.dll" (
    move "%PLUGINS_ORIG%\XCurl.dll" "%PLUGINS_BACKUP%\" >nul
    echo  [%Cyan%-%R%] XCurl ................... %Gray%Готово...%R%
)
if exist "%PLUGINS_ORIG%\XGamingRuntimeThunks.dll" (
    move "%PLUGINS_ORIG%\XGamingRuntimeThunks.dll" "%PLUGINS_BACKUP%\" >nul
    echo  [%Cyan%-%R%] XGamingRuntimeThunks .... %Gray%Готово...%R%
)

echo.
echo  [%Cyan%NET%R%] Загрузка valheim.ini с GitHub
curl -L -s -o "valheim.ini" "%INI_URL%"

if exist "valheim.ini" (
    echo  [%Cyan%+%R%] valheim.ini ............. %Gray%Готово...%R%
) else (
    echo  [%Red%i%R%] Ошибка загрузки ......... %Red%Ошибка...%R%
)

echo.
echo  ---------------------------------------------------------
echo  %Gray%Готово...%R% Оптимизация завершена.
echo  ---------------------------------------------------------
pause
exit

:RESTORE_MODE

set "ROOT=.backup"
set "PLUGINS_BACKUP=.backup\valheim_Data\Plugins\x86_64"
set "PLUGINS_ORIG=valheim_Data\Plugins\x86_64"
echo. [%Cyan%!%R%]  Восстановливаем файлы
if exist "%ROOT%\UnityCrashHandler64.exe" move "%ROOT%\UnityCrashHandler64.exe" "." >nul
if exist "%ROOT%\D3D12" move "%ROOT%\D3D12" "." >nul

if exist "%PLUGINS_BACKUP%\*.dll" (
    move "%PLUGINS_BACKUP%\*.dll" "%PLUGINS_ORIG%\" >nul
    echo  [%Cyan%+%R%]  Библиотеки Xbox ......... %Gray%Готово...%R%
)

echo  [%Cyan%+%R%]  Остальные файлы ......... %Gray%Готово...%R%

if exist "valheim.ini" (
    del /q "valheim.ini"
    echo  [%Cyan%-%R%]  valheim.ini ............. %Red%Удалено%R%
)


rd /s /q ".backup" >nul 2>&1

echo.
echo  ---------------------------------------------------------
echo  %Gray%Готово...%R% Готово файлы восстановлены.
echo  ---------------------------------------------------------
pause
exit
