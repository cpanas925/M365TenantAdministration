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
#$TenantId = "735bcdb1-220c-47df-9e41-6a2552e729d8"
#Connect-MgGraph -TenantId $TenantId -ContextScope CurrentUser -Scopes "Directory.Read.All" #Change as needed, sufficient for initial authentication

$TestTenantId = '<TENANT_ID>'
Connect-MgGraph -TenantId $TestTenantId -ContextScope CurrentUser -Scopes "Directory.Read.All" #Change as needed, sufficient for initial authentication



#Figure out what the user needs to administer


