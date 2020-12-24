#Variables for Secure string
$username = "chjones@lrmcenter.com"
$password = Get-Content 'C:\Jones IT\PSI\mysecurestring.txt' | ConvertTo-SecureString
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password

#Prevents wall of text after connecting to MsolService
$WarningPreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'

#Uses Secure String to connect to Azure AD
Connect-AzureAD -Credential $cred

Start-Sleep -Seconds 5

#Gets all groups a user is a member of
$email = Read-Host 'Enter users email'

Get-AzureADUser -SearchString $email | Get-AzureADUserMembership | Where-Object { $_.ObjectType -ne "Role" } | Select-Object DisplayName, ObjectType, MailEnabled, SecurityEnabled, ObjectId | Format-Table