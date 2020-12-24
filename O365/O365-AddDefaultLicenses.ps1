#Connects to Azure AD with encrypted credentials
$username = "chjones@lrmcenter.com"
$password = Get-Content 'C:\Jones IT\PSI\mysecurestring.txt' | ConvertTo-SecureString
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password

$WarningPreference = 'SilentlyContinue'

Connect-MsolService -Credential $cred

#Prompts admin to enter user account and email and assigns output to $account and $email variable
$email = Read-Host 'Enter user email'

#Assigns User with location and  LRMC base licenses
Set-MsolUser -UserPrincipalName $email -usagelocation US

if (Get-MsolUser -UserPrincipalName $email | Where-Object { ($_.licenses).AccountSkuId -notmatch "lrmcenter:ENTERPRISEPACK" }) {
        Set-MsolUserLicense -UserPrincipalName $email -AddLicenses "lrmcenter:ENTERPRISEPACK"
}


if (Get-MsolUser -UserPrincipalName $email | Where-Object { ($_.licenses).AccountSkuId -notmatch "lrmcenter:ATP_ENTERPRISE" }) {
        Set-MsolUserLicense -UserPrincipalName $email -AddLicenses "lrmcenter:ATP_ENTERPRISE"
}


$date = Get-Date

Write-Host "`n$email was equipped with the ATP and E3 licenses $date." -ForegroundColor Green

#Displays licenses on user account to confirm they were applied
Get-MsolUser -UserPrincipalName $email | Format-List DisplayName, Licenses

#Waits for user input to close
Read-Host 'Press ENTER to exit user setup...'