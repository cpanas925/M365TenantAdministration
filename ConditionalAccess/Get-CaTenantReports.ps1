#Compile list of managed tenants
Write-Host -ForegroundColor Blue "Checking for Managed Tenants..."
$ManagedTenants = Get-MgContract -All | Select-Object DisplayName, CustomerId, DefaultDomainName

#Write the number of managed tenants found to the console
if (!$ManagedTenants) {
    Write-Host -ForegroundColor Red "No managed tenants found. Confirm you are signed in to the partner tenant and have DAP/GDAP relationships."
    return
}else {
    Write-Host -ForegroundColor Green "Managed Tenants found: $($ManagedTenants.Count)"
}

#Expand the rights context to include the necessary scopes for reading tenant reports and other relevant information
$MSPTenantId = '735bcdb1-220c-47df-9e41-6a2552e729d8'
Connect-MgGraph -TenantId $MSPTenantId  -Scopes @(
    "Directory.Read.All",
    "Organization.Read.All",
    "Policy.Read.All",
    "UserAuthenticationMethod.Read.All",
    "AuditLog.Read.All",
    "RoleManagement.Read.Directory"
) -NoWelcome
Get-MgContext | Format-list -Property TenantId, Account, ContextScope
Get-MgContext | Select-Object -ExpandProperty Scopes | Sort-Object | Get-Unique | ForEach-Object { Write-Host -ForegroundColor Green "Scope: $_" }

$P2Skus = @('AAD_PREMIUM_P2', 'EMSPREMIUM_P2', 'SPB', 'SPE_E5', 'Microsoft_365_E5')
# SKUs that include Entra ID P1 (but not P2)
$P1Skus = @('AAD_PREMIUM', 'EMSPREMIUM', 'SPE_E3', 'SPB_ISG', 'Microsoft_365_Business_Premium', 'Microsoft_365_E3')

# Friendly names for the report
$SkuNames = @{
    'AAD_PREMIUM'                    = 'Entra ID P1'
    'AAD_PREMIUM_P2'                 = 'Entra ID P2'
    'EMSPREMIUM'                     = 'EMS E3'
    'EMSPREMIUM_P2'                  = 'EMS E5'
    'SPB'                            = 'M365 E5'
    'SPB_ISG'                        = 'M365 E3 (Firstline)'
    'SPE_E3'                         = 'M365 E3'
    'SPE_E5'                         = 'M365 E5'
    'Microsoft_365_Business_Premium' = 'M365 Business Premium'
    'Microsoft_365_E3'               = 'M365 E3'
    'Microsoft_365_E5'               = 'M365 E5'
    'O365_Business_Premium'          = 'M365 Business Standard'
    'STANDARDPACK'                   = 'Office 365 E1'
    'STANDARDWOFFPACK'               = 'Office 365 E2'
    'ENTERPRISEPACK'                 = 'Office 365 E3'
    'ENTERPRISEPREMIUM'              = 'Office 365 E5'
    'EXCHANGESTANDARD'               = 'Exchange Online P1'
    'EXCHANGEENTERPRISE'             = 'Exchange Online P2'
    'FLOW_FREE'                      = 'Power Automate Free'
    'SPB_FREE'                       = 'M365 Business Basic'
    'O365_Business_Essentials'       = 'M365 Business Basic'
}

$Results = foreach ($tenant in $ManagedTenants) {
    Write-Host -ForegroundColor Cyan "  Checking $($tenant.DisplayName) ($($tenant.DefaultDomainName))..."
    $row = [ordered]@{
        TenantName    = $tenant.DisplayName
        TenantId      = $tenant.CustomerId
        DefaultDomain = $tenant.DefaultDomainName
        Tier          = 'Other'
        P2Skus        = ''
        P1Skus        = ''
        OtherSkus     = ''
        TotalLicenses = 0
        Error         = ''
    }
    try {
        Connect-MgGraph -TenantId $tenant.CustomerId -NoWelcome -ErrorAction Stop
        $skus = Get-MgSubscribedSku | Where-Object { $_.PrepaidUnits.Enabled -gt 0 }

        $p2 = $skus | Where-Object { $_.SkuPartNumber -in $P2Skus }
        $p1 = $skus | Where-Object { $_.SkuPartNumber -in $P1Skus }
        $other = $skus | Where-Object { $_.SkuPartNumber -notin ($P2Skus + $P1Skus) }

        $row.P2Skus    = ($p2    | ForEach-Object { "$($SkuNames[$_.SkuPartNumber] ?? $_.SkuPartNumber) x$($_.PrepaidUnits.Enabled)" }) -join '; '
        $row.P1Skus    = ($p1    | ForEach-Object { "$($SkuNames[$_.SkuPartNumber] ?? $_.SkuPartNumber) x$($_.PrepaidUnits.Enabled)" }) -join '; '
        $row.OtherSkus = ($other | ForEach-Object { "$($SkuNames[$_.SkuPartNumber] ?? $_.SkuPartNumber) x$($_.PrepaidUnits.Enabled)" }) -join '; '
        $row.TotalLicenses = ($skus | Measure-Object -Property { $_.PrepaidUnits.Enabled } -Sum).Sum

        # Tier = highest owned. P2 wins even if P1 SKUs also exist.
        if     ($p2) { $row.Tier = 'P2' }
        elseif ($p1) { $row.Tier = 'P1' }
        else         { $row.Tier = 'Other' }
    }
    catch {
        $row.Error = $_.Exception.Message
        Write-Host -ForegroundColor Red "    Failed: $($_.Exception.Message)"
    }
    [PSCustomObject]$row
    pause
}