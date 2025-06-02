@echo off
setlocal enabledelayedexpansion

:: Check for administrative permissions
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Dynamically detect USB drive containing the scripts folder
for /f "tokens=1,*" %%a in ('wmic logicaldisk where "drivetype=2" get deviceid^, volumename /value') do (
    set "drive=%%a"
    set "volname=%%b"
    set Wifi_XMLPATH==%DRIVE%\scripts\home.xml
    if exist "!drive!\scripts\home.xml" (
        set "USBDRIVE=!drive!"
        goto found_wifi
    )
)

:found_wifi

if not defined USBDRIVE (
    echo ERROR: WiFi folder not found on any removable drive.
    pause
    exit /b 1
)

:: Import WiFi profile from the scripts folder
echo Importing WiFi profile from %USBDRIVE%\scripts\home.xml
netsh wlan add profile filename="%USBDRIVE%\scripts\home.xml"

:: Extract SSID from the XML and connect to the network
for /f "tokens=2 delims=<>" %%i in ('find "<name>" "%USBDRIVE%\scripts\home.xml"') do (
    set "SSID=%%i"
    goto connect_now
)

:connect_now

:: Ensure SSID is extracted correctly
if not defined SSID (
    echo ERROR: SSID not found in the profile.
    pause
    exit /b 1
)

:: Connect to the WiFi network
echo Connecting to WiFi: !SSID!
netsh wlan connect name="!SSID!"

:: Verify connection
timeout /t 10 >nul
netsh wlan show interfaces | find "State"

:: Proceed with the rest of the installations
:: Get the current drive letter
for %%i in ("%~dp0.") do set "DRIVE=%%~di"

:: Set paths to the installation files
set APPS_PATH=%DRIVE%\Apps
set OFFICE_PATH=%DRIVE%\Office







:: Install Notepad++
if exist "%APPS_PATH%\npp*.exe" (
    echo Installing Notepad++...
    for %%f in ("%APPS_PATH%\npp*.exe") do (
        "%%f" /S
    )
    echo Notepad++ installed successfully.
) else (
    echo Notepad++ installer not found in %APPS_PATH%
)

:: Run activator
if exist "%DRIVE%\scripts\kingsmakersactivator.bat" (
    echo Running activator...
    call "%DRIVE%\scripts\kingsmakersactivator.bat"
)

echo All installations complete.
pause
