#Make sure you are in the correct context to manage the tenant
$CurrentContext = Get-MgContext

#Compile list of managed tenants
Write-Host -ForegroundColor Blue "Checking for Managed Tenants..."
$ManagedTenants = Get-MgContract -All | Select-Object DisplayName, CustomerId, DefaultDomainName

if (!$ManagedTenants) {
    Write-Host -ForegroundColor Red "No managed tenants found. Confirm you are signed in to the partner tenant and have DAP/GDAP relationships."
    return
}

#Figure out what the user needs to administer
$DesiredTenant = Read-Host -Prompt "What Managed Tenant do you want to administer? (Enter some of the DisplayName or CustomerId)"
$FilteredTenants = $ManagedTenants | Where-Object { $_.DisplayName -like "*$DesiredTenant*" -or $_.CustomerId -like "*$DesiredTenant*" }

#Filter the list of tenants based on user input and handle cases for no matches, multiple matches, or a single match.
if ($FilteredTenants.Count -eq 0) {
    Write-Host -ForegroundColor Red "No matching tenants found. Please check your input and try one more time."
    $DesiredTenant = Read-Host -Prompt "What Managed Tenant do you want to administer? (Enter some of the DisplayName or CustomerId)"
    if ($DesiredTenant) {
        $FilteredTenants = $ManagedTenants | Where-Object { $_.DisplayName -like "*$DesiredTenant*" -or $_.CustomerId -like "*$DesiredTenant*" }
        Write-Host -ForegroundColor Green "Selected Tenant: $($SelectedTenantObject.DisplayName) - $($SelectedTenantObject.CustomerId)"
    } else {
        Write-Host -ForegroundColor Red "No input provided. Exiting."
        return
    }
} elseif ($FilteredTenants.Count -gt 1) {
    Write-Host -ForegroundColor Yellow "Multiple tenants found. Please select one:"
    $FilteredTenants | ForEach-Object { Write-Host "$($_.DisplayName) - $($_.CustomerId)" }
    $SelectedTenant = Read-Host -Prompt "Enter the CustomerId of the tenant you want to administer"
    $SelectedTenantObject = $FilteredTenants | Where-Object { $_.CustomerId -eq $SelectedTenant }
    Write-Host -ForegroundColor Green "Selected Tenant: $($SelectedTenantObject.DisplayName) - $($SelectedTenantObject.CustomerId)"
    if (!$SelectedTenantObject) {
        Write-Host -ForegroundColor Red "Invalid selection. Exiting."
        return
    }
} else {
    $SelectedTenantObject = $FilteredTenants[0]
    Write-Host -ForegroundColor Green "Selected Tenant: $($SelectedTenantObject.DisplayName) - $($SelectedTenantObject.CustomerId)"
}

#Switch context to the selected tenant if not already in that context
Get-MgContext | ForEach-Object {
    if ($_.TenantId -ne $SelectedTenantObject.CustomerId) {
        Write-Host -ForegroundColor Yellow "Switching context to the selected tenant..."
        Connect-MgGraph -TenantId $SelectedTenantObject.CustomerId -Scopes "User.Read.All", "Directory.Read.All", "Group.ReadWrite.All", "Reports.Read.All"
    }
}