#Check imported modules and load if not
#Prepend Local Documents Folder for modules first.
if (($env:PSModulePath -split ';')[0] -ne ("C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules")) {
    Write-Host -ForegroundColor Blue "PSModulePath is not correctly configured. Prepending local modules folder."
    $env:PSModulePath = "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules;" + $env:PSModulePath
}

if (!(Get-Module -Name Microsoft.Graph.Authentication)) {
    Import-Module -Global Microsoft.Graph.Authentication
}

#Collect Managed Tenants
Connect-MgGraph -Scopes "ManagedTenants.Read.All"

#Figure out what the user needs to administer


