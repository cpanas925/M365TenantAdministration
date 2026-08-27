##Prerequisites

Write-Host -ForegroundColor Blue "Setting up prerequisites for Microsoft Graph PowerShell SDK"

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
Get-ExecutionPolicy