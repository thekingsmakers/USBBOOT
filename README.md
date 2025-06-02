# Windows Installation Automation

This project provides a fully automated solution for setting up a Windows environment with essential applications, Office 365, WiFi configuration, and activation. The automation is primarily driven by batch scripts located in the `scripts` directory, along with unattended installation files in the `sources/$OEM$` directory.

## Directory Structure

- **scripts/**: Contains all automation and helper scripts.
- **Apps/**: Contains installers for third-party applications (e.g., Chrome, WinRAR, Notepad++, Adobe Reader).
- **Office/**: Contains the Office 365 installer and configuration file.
- **Office/Configuration.xml**: Specifies which Office components and languages to install.
- **scripts/home.xml**: WiFi profile used for automatic wireless connection.
- **sources/$OEM$/$$/Setup/Scripts/**: Contains unattended installation scripts:
  - **Provisioning.ps1**: PowerShell script for post-installation tasks.
  - **SetupComplete.cmd**: Batch script that launches the PowerShell script.

## Main Automation Script

### `scripts/thekingsmakers.bat`

This is the main script that orchestrates the entire setup process. It performs the following steps:

1. **Detects the Drive Letter**: Automatically determines the drive where the scripts and installers are located.
2. **WiFi Connection**: Calls `connectwifi.bat` to import and connect to the WiFi profile defined in `home.xml`.
3. **Admin Privileges**: Checks for administrative rights and relaunches itself with elevated permissions if needed.
4. **Application Installations**:
    - **Adobe Acrobat Reader DC**: Installs silently if the installer is present in `Apps/`.
    - **Google Chrome Enterprise**: Installs silently using MSI.
    - **WinRAR**: Installs silently.
    - **Office 365**: Installs using `setup.exe` and the provided `Configuration.xml`.
    - **Notepad++**: Installs silently.
5. **Activation**: Runs `kingsmakersactivator.bat` to activate Windows/Office using an online script.
6. **Completion**: Notifies the user when all installations are complete.

### Application Installers

Place the following installers in the `Apps/` directory:
- `AcroRdrDC*.exe` (Adobe Reader)
- `GoogleChromeStandaloneEnterprise64.msi` (Chrome)
- `winrar-x64-*.exe` (WinRAR)
- `npp.*.Installer.x64.exe` (Notepad++)

### Office 365

Place the Office 365 installer (`setup.exe`) and `Configuration.xml` in the `Office/` directory. The configuration file specifies:
- 64-bit Office
- English (en-us) and Arabic (ar-sa) languages
- Excludes Groove, Lync, Teams, and Bing
- Enables updates and removes old MSI-based Office installations

### WiFi Automation

- `connectwifi.bat` imports the WiFi profile from `home.xml` and connects automatically.
- Ensure `home.xml` is a valid exported WiFi profile.

### Activation

- `kingsmakersactivator.bat` runs a PowerShell command to download and execute an online activation script.
- User interaction may be required to complete activation in the prompted window.

## Unattended Installation

### `sources/$OEM$/$$/Setup/Scripts/Provisioning.ps1`

This PowerShell script handles post-installation tasks automatically:

1. **Logging**: Starts a transcript to log all actions to `C:\Windows\Temp\ProvisioningLog.txt`.
2. **Branding**: Copies a logo from the USB drive to `C:\Branding\`.
3. **Local Admin User**: Creates a local admin user with a blank password.
4. **Date, Time, Language**: Sets the timezone to "Arab Standard Time" and language to US English.
5. **Application Installation**: Installs applications from `C:\Apps\` silently.
6. **Office 365 Installation**: Copies Office files from the USB drive and installs using `Configuration.xml`.
7. **Privacy Settings**: Disables telemetry and advertising settings.
8. **Finalization**: Applies group policies and completes the setup.

### `sources/$OEM$/$$/Setup/Scripts/SetupComplete.cmd`

This batch script is executed at the end of the Windows installation. It launches `Provisioning.ps1` with elevated permissions.

## How to Use

1. **Copy all folders and files to a USB drive or local directory.**
2. **Update the installers in `Apps/` and Office files in `Office/` as needed.**
3. **Export your WiFi profile as `home.xml` and place it in `scripts/`.**
4. **Run `scripts/thekingsmakers.bat` as Administrator.**
5. **Follow any prompts, especially for activation.**

## Notes

- All installations are silent (no user interaction required) except for activation.
- Ensure you have the correct and up-to-date installers in the `Apps/` directory.
- The script will attempt to elevate itself if not run as Administrator.
- The unattended installation process is fully automated and logs all actions for troubleshooting.

## Detailed Instructions

### 1. Preparing the Bootable USB

- **Download Windows ISO**: Download the Windows installation ISO from the official Microsoft website.
- **Create Bootable USB**: Use tools like Rufus or the Windows Media Creation Tool to create a bootable USB drive.
- **Copy Project Files**: Copy all project folders (`scripts`, `Apps`, `Office`, `sources`, etc.) to the root of the bootable USB.

### 2. Downloading Applications

- **Adobe Acrobat Reader DC**: Download from [Adobe's website](https://get.adobe.com/reader/enterprise/).
- **Google Chrome Enterprise**: Download from [Google's website](https://chrome.google.com/business/).
- **WinRAR**: Download from [WinRAR's website](https://www.win-rar.com/download.html).
- **Notepad++**: Download from [Notepad++'s website](https://notepad-plus-plus.org/downloads/).
- Place all installers in the `Apps/` directory.

### 3. Exporting WiFi Settings

- **Export WiFi Profile**:
  - Open Command Prompt as Administrator.
  - Run: `netsh wlan export profile name="YourWiFiName" key=clear folder="C:\Path\To\Save"`.
  - Rename the exported XML file to `home.xml`.
  - Copy `home.xml` to the `scripts/` directory.

### 4. Office 365 Setup

- **Download Office 365**: Use the [Office Deployment Tool](https://www.microsoft.com/en-us/download/details.aspx?id=49117) to download `setup.exe`.
- **Configuration File**: Create or modify `Configuration.xml` in the `Office/` directory to specify installation options.
- **Copy Files**: Copy `setup.exe` and `Configuration.xml` to the `Office/` directory.

### 5. Running the Automation - NOT required since it is silent but FYI

- **Boot from USB**: Insert the bootable USB and boot the target machine.
- **Run Script**: Navigate to the `scripts/` directory and run `thekingsmakers.bat` as Administrator.
- **Follow Prompts**: Complete any required activation steps.

---

By thekingsmakers 
Omar osman Mahat
