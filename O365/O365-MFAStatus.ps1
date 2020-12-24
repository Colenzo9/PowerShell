$MSOLUsers = Get-MsolUser -All | Where-Object {$_.IsLicensed -eq $true} | Select-Object UserPrincipalName, StrongAuthenticationRequirements | Sort-Object UserPrincipalName

function Out-Object {
    [PSCustomObject][Ordered] @{
        'UserPrincipalName' = $MSOLUser.UserPrincipalName
        'MFA'               = $MSOLUser.StrongAuthenticationRequirements.State
    }
}

foreach ($MSOLUser in $MSOLUsers) {
    Out-Object
}