#Check imported modules and load if not
if (!(Get-Module -Name Microsoft.Graph.Authentication)) {
    Import-Module Microsoft.Graph.Authentication
}

#Collect Managed Tenants
Connect-MgGraph -Scopes "ManagedTenants.Read.All"

#Figure out what the user needs to administer
