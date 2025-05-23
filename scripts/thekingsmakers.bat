@echo off
:: Check for administrative permissions
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)


:: Get the current drive letter
for %%i in ("%~dp0.") do set "DRIVE=%%~di"

:: Set paths to the installation files
set APPS_PATH=%DRIVE%\Apps
set OFFICE_PATH=%DRIVE%\Office

:: Install Adobe Acrobat Reader DC
if exist "%APPS_PATH%\AcroRdrDC*.exe" (
    echo Installing Adobe Acrobat Reader DC...
    for %%f in ("%APPS_PATH%\AcroRdrDC*.exe") do (
        "%%f" /sAll /rs /rps /msi EULA_ACCEPT=YES
    )
    echo Adobe Acrobat Reader DC installed successfully.
) else (
    echo Adobe Acrobat Reader DC installer not found in %APPS_PATH%
)

:: Install Google Chrome Enterprise
if exist "%APPS_PATH%\GoogleChromeStandaloneEnterprise64.msi" (
    echo Installing Google Chrome Enterprise...
    msiexec /i "%APPS_PATH%\GoogleChromeStandaloneEnterprise64.msi" /qn /norestart
    echo Google Chrome Enterprise installed successfully.
) else (
    echo Google Chrome Enterprise installer not found in %APPS_PATH%
)

:: Install WinRAR
if exist "%APPS_PATH%\winrar-x64-*.exe" (
    echo Installing WinRAR...
    for %%f in ("%APPS_PATH%\winrar-x64-*.exe") do (
        "%%f" /s
    )
    echo WinRAR installed successfully.
) else (
    echo WinRAR installer not found in %APPS_PATH%
)

:: Install Office 365
if exist "%OFFICE_PATH%\setup.exe" (
    echo Installing Office 365...
    cd /d "%OFFICE_PATH%"
    setup.exe /configure Configuration.xml
    echo Office 365 installation started. This may take some time...
) else (
    echo Office 365 setup.exe not found in %OFFICE_PATH%
)

:: Run activator
if exist "%USBDRIVE%\scripts\kingsmakersactivator.bat" (
    echo Running activator...
    call "%USBDRIVE%\scripts\kingsmakersactivator.bat"
)

echo All installations complete.



pause