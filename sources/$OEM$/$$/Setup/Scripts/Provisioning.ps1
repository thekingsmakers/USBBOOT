# Enable Logging
Start-Transcript -Path "C:\Windows\Temp\ProvisioningLog.txt" -Append

$branding  = "yourcompanyname"
$images = "%scriptroot/images/logo.png%"

# Display Progress UI
$progress = @{Activity="Provisioning Windows..."; Status="Initializing..."; PercentComplete=0}
Write-Progress @progress

# -------------------
# Step 1: Branding
# -------------------
$progress.Status = "Applying Branding..."
$progress.PercentComplete = 5
Write-Progress @progress

$brandImage = "C:\Branding\kingsmakers-logo.png"
$usbDrive = (Get-WmiObject Win32_Volume | Where-Object { $_.DriveType -eq 2 -and $_.Label -eq "WINSETUP" }).DriveLetter
if ($usbDrive) {
    Copy-Item "$usbDrive\Branding\kingsmakers-logo.png" -Destination "C:\Branding\" -Force
}
Write-Host "Branding applied."

# -------------------
# Step 2: Create Local Admin User
# -------------------
$progress.Status = "Creating Local Admin User..."
$progress.PercentComplete = 10
Write-Progress @progress

$Username = "admin"
$Password = ConvertTo-SecureString "" -AsPlainText -Force
New-LocalUser -Name $Username -Password $Password -FullName "Admin Account" -Description "Local Admin"
Add-LocalGroupMember -Group "Administrators" -Member $Username
Write-Host "Local admin user created."

# -------------------
# Step 3: Set Date, Time, Language, and Keyboard
# -------------------
$progress.Status = "Setting Date, Time, Language..."
$progress.PercentComplete = 20
Write-Progress @progress

Write-Host "Setting timezone to Kuwait/Riyadh..."
tzutil /s "Arab Standard Time"
Write-Host "Setting language and keyboard to US..."
Set-WinUserLanguageList -LanguageList en-US -Force

# -------------------
# Step 4: Install Applications
# -------------------
$progress.Status = "Installing Applications..."
$progress.PercentComplete = 30
Write-Progress @progress

$apps = @(
    "C:\Apps\AdobeReader.exe",
    "C:\Apps\ChromeEnterprise.msi",
    "C:\Apps\WinRAR.exe"
)

foreach ($app in $apps) {
    $progress.Status = "Installing $app..."
    Write-Progress @progress
    if ($app -match ".msi$") {
        Start-Process "msiexec.exe" -ArgumentList "/i $app /qn /norestart" -Wait
    } elseif ($app -match ".exe$") {
        Start-Process $app -ArgumentList "/silent /norestart" -Wait
    }
}
Write-Host "Applications Installed."

# -------------------
# Step 5: Install Microsoft Office
# -------------------
$progress.Status = "Installing Microsoft Office..."
$progress.PercentComplete = 50
Write-Progress @progress

$officePath = "C:\Office"
if (!(Test-Path $officePath)) {
    New-Item -Path $officePath -ItemType Directory -Force
}
Copy-Item "$usbDrive\Office\*" -Destination $officePath -Recurse -Force
Start-Process "$officePath\setup.exe" -ArgumentList "/configure $officePath\configuration.xml" -Wait
Write-Host "Microsoft Office Installed."

# -------------------
# Step 6: Bypass Privacy Settings
# -------------------
$progress.Status = "Applying Privacy Settings..."
$progress.PercentComplete = 70
Write-Progress @progress

$privacyKeys = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection",
    "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
)
foreach ($key in $privacyKeys) {
    if (!(Test-Path $key)) { New-Item -Path $key -Force }
    New-ItemProperty -Path $key -Name "Enabled" -Value 0 -PropertyType DWORD -Force
}
Write-Host "Privacy settings disabled."

# -------------------
# Step 7: Finalizing Setup
# -------------------
$progress.Status = "Finalizing Setup..."
$progress.PercentComplete = 90
Write-Progress @progress

Write-Host "Applying group policies..."
gpupdate /force

Write-Host "Provisioning Completed!"
$progress.Status = "Completed!"
$progress.PercentComplete = 100
Write-Progress @progress -Completed

Stop-Transcript
