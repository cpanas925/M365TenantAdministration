##Prerequisites
Write-Host -ForegroundColor Blue "Setting up prerequisites for Microsoft Graph PowerShell SDK"

# Check if the current session is running as Administrator
Write-Host -ForegroundColor Blue "Checking administrative privileges..."
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Host -ForegroundColor Green "Running with Administrator privileges."
}

if (-not $isAdmin) {
    Write-Host "Not running as Admin. Requesting elevation..." -ForegroundColor Yellow
    Write-Host "Please run this script as Administrator." -ForegroundColor Red
    Pause
    Exit
}

# Get the PowerShell Version, as 5.1 is needed
$PowerShellVersion = $PSVersionTable.PSVersion

if ($PowerShellVersion.Major -ge "5" -and $PowerShellVersion.Minor -ge "1") {
    Write-Host -ForegroundColor Green "PowerShell version is greater than version 5.1"
} else {
    Write-Host -ForegroundColor Yellow "PowerShell version is less than version 5.1"
    break
}

# Get the .NET Framework Version, as 4.7.2 is needed
$release = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release

if ($release -gt 461808) {
    Write-Host -ForegroundColor Green ".NET Framework is later than 4.7.2"
} else {
    Write-Host -ForegroundColor Yellow ".NET Framework is 4.7.2 or earlier"
    break
}

#Check execution policy for current session
$ExPolicy = Get-ExecutionPolicy

switch ($ExPolicy) {
    "Unrestricted" {
        Write-Host -ForegroundColor Green "Execution policy is Unrestricted"
    }
    "Bypass" {
        Write-Host -ForegroundColor Green "Execution policy is Bypass"
    }
    "RemoteSigned" {
        Write-Host -ForegroundColor Green "Execution policy is RemoteSigned"
    }
    "Restricted" {
        Write-Host -ForegroundColor Yellow "Execution policy is Restricted"
        Write-Host -ForegroundColor Cyan "Changing to Unrestricted"
        Set-ExecutionPolicy Unrestricted
    }
    "AllSigned" {
        Write-Host -ForegroundColor Yellow "Execution policy is AllSigned"
        Write-host -ForegroundColor Yellow "Changing to Unrestricted"
        Set-ExecutionPolicy Unrestricted
    }
    "Default" {
        Write-Host -ForegroundColor Yellow "Execution policy is Default"
        Write-Host -ForegroundColor Cyan "Changing to Unrestricted"
        Set-ExecutionPolicy Unrestricted
    }
    default {
        Write-Host -ForegroundColor Yellow "Execution policy is $($ExPolicy)"
    }
}

#Prepend Local Documents Folder for modules first.
if (($env:PSModulePath -split ';')[0] -ne ("C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules")) {
    Write-Host -ForegroundColor Blue "PSModulePath is not correctly configured. Prepending local modules folder."
    $env:PSModulePath = "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules;" + $env:PSModulePath
}

#Check the Microsoft Graph PowerShell SDK installation
$IsGraphSdkInstalled = Get-InstalledModule Microsoft.Graph -ErrorAction SilentlyContinue
$GraphBetaNeeded = Read-Host "Do you need the Microsoft Graph Beta module? (Y/N)"
$GraphBetaNeeded = $GraphBetaNeeded.ToUpper()

Write-Host -ForegroundColor Blue "Checking Microsoft Graph PowerShell SDK installation..."
if (!$IsGraphSdkInstalled) {
    Write-Host -ForegroundColor Yellow "Microsoft Graph PowerShell SDK is not installed"
    Write-Host -ForegroundColor Blue "Installing Microsoft Graph PowerShell SDK..."
    Install-Module Microsoft.Graph -Scope AllUsers -Repository PSGallery -Force -Verbose
}

$IsGraphSdkBetaInstalled = Get-InstalledModule Microsoft.Graph.Beta -ErrorAction SilentlyContinue
if ($GraphBetaNeeded -eq "Y" -and !$IsGraphSdkBetaInstalled) {
    Write-Host -ForegroundColor Blue "Installing Microsoft Graph PowerShell SDK Beta..."
    Install-Module Microsoft.Graph.Beta -Scope AllUsers -Repository PSGallery -Force -Verbose
}

#Validation
[version]$CurrentGraphVersion = (Get-InstalledModule Microsoft.Graph -ErrorAction Stop).Version
[version]$LatestGraphVersion = (Find-Module -Name Microsoft.Graph -Repository PSGallery -ErrorAction Stop).Version

# Compare major and minor versions only; patch and build differences are ignored.
[version]$CurrentMajorMinor = "$($CurrentGraphVersion.Major).$($CurrentGraphVersion.Minor)"
[version]$LatestMajorMinor = "$($LatestGraphVersion.Major).$($LatestGraphVersion.Minor)"

Write-Host -ForegroundColor Blue "Current Microsoft Graph PowerShell SDK version: $CurrentGraphVersion"
Write-Host -ForegroundColor Blue "Latest Microsoft Graph PowerShell SDK version: $LatestGraphVersion"

#Compare versions
if ($CurrentMajorMinor -ge $LatestMajorMinor) {
    Write-Host -ForegroundColor Green "Microsoft Graph PowerShell SDK is up to date"
} else {
    Write-Host -ForegroundColor Yellow "Microsoft Graph PowerShell SDK is out of date"
    $WantToUpdateGraph = Read-Host "Do you want to update the Microsoft Graph PowerShell SDK? (Y/N)"
    $WantToUpdate = $WantToUpdateGraph.ToUpper()
}

if ($WantToUpdate -eq "Y") {
    Write-Host -ForegroundColor Blue "Updating Microsoft Graph PowerShell SDK..."
    Update-Module Microsoft.Graph -Verbose -Scope AllUsers
    if ($GraphBetaNeeded -eq "Y") {
        Update-Module Microsoft.Graph.Beta -Verbose -Scope AllUsers
    }
}
