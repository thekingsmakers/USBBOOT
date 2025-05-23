@echo off
setlocal enabledelayedexpansion

:: Get USB drive letter (works in all contexts)
for %%d in (C D E F G H) do if exist "%%d:\scripts\%~nx0" set "USBDRIVE=%%d" && goto found_drive
:found_drive
if not defined USBDRIVE (
    echo ERROR: Could not find USB drive with scripts!
    pause
    exit /b 1
)

:: Set paths
set APPS_PATH=%USBDRIVE%\Apps
set OFFICE_PATH=%USBDRIVE%\Office

:: Install applications
echo Installing applications from %USBDRIVE%...

:: Adobe Acrobat
if exist "%APPS_PATH%\AcroRdrDC*.exe" (
    echo Installing Adobe Acrobat Reader DC...
    for %%f in ("%APPS_PATH%\AcroRdrDC*.exe") do "%%f" /sAll /rs /rps /msi EULA_ACCEPT=YES
)

:: Google Chrome
if exist "%APPS_PATH%\GoogleChromeStandaloneEnterprise64.msi" (
    echo Installing Chrome...
    msiexec /i "%APPS_PATH%\GoogleChromeStandaloneEnterprise64.msi" /qn /norestart
)

:: WinRAR
if exist "%APPS_PATH%\winrar-x64-*.exe" (
    echo Installing WinRAR...
    for %%f in ("%APPS_PATH%\winrar-x64-*.exe") do "%%f" /s
)

:: Office 365
if exist "%OFFICE_PATH%\setup.exe" (
    echo Installing Office 365...
    pushd "%OFFICE_PATH%"
    setup.exe /configure Configuration.xml
    popd
)

:: Run activator
if exist "%USBDRIVE%\scripts\kingsmakersactivator.bat" (
    echo Running activator...
    call "%USBDRIVE%\scripts\kingsmakersactivator.bat"
)

:: Open thekingsmakers site
start "" "https://thekingsmakers.github.io"

echo All installations completed at %time%
pause