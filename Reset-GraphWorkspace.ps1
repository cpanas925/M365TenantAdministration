#Start a NEW Elevated PowerShell session (do not reuse the broken one)

#Uninstall all Microsoft.Graph.* modules to remove version conflicts
Get-Module -ListAvailable Microsoft.Graph.* | ForEach-Object { Uninstall-Module $_ -AllVersions -Force -Verbose}

# All the locations Microsoft.Graph.Authentication can live, across PS 5.1 and PS 7, both scopes
$paths = @(
    $env:PSModulePath -split ';'
)

#Manually Delete any other folders that were missed
foreach ($p in $paths) {
    if (Test-Path $p) {
        Get-ChildItem -Path $p -Directory -Filter "Microsoft.Graph.Authentication*" -ErrorAction SilentlyContinue |
            ForEach-Object {
                Write-Host "Deleting $($_.FullName)"
                Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
            }
    }
}