#Check imported modules and load if not
Import-Module Microsoft.Graph.Beta.ManagedTenants -Global -verbose
Import-Module Microsoft.Graph.Identity.DirectoryManagement


#Prepend Local Documents Folder for modules first.
if (($env:PSModulePath -split ';')[0] -ne ("C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules")) {
    Write-Host -ForegroundColor Blue "PSModulePath is not correctly configured. Prepending local modules folder."
    $env:PSModulePath = "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules;" + $env:PSModulePath
}

if (!(Get-Module -Name Microsoft.Graph.Authentication)) {
    Import-Module -Global Microsoft.Graph.Authentication
}

#Set-MgGraphOption -DisableLoginByWAM $true
$MspTenantId = '735bcdb1-220c-47df-9e41-6a2552e729d8'
Connect-MgGraph -TenantId $MspTenantId -ContextScope CurrentUser -Scopes "Directory.Read.All" #Change as needed, sufficient for initial authentication

Get-MgContext | Format-list -Property TenantId, Account, Scopes, ContextScope
Get-MgContext | Select-Object -ExpandProperty Scopes | Sort-Object | Get-Unique | ForEach-Object { Write-Host -ForegroundColor Green "Scope: $_" }
Write-host -ForegroundColor Blue "Rerun this script if you need to switch users."