#Variables for Secure string
$username = "chjones@lrmcenter.com"
$password = Get-Content 'C:\Jones IT\PSI\mysecurestring.txt' | ConvertTo-SecureString
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password

#Prevents wall of text after connecting to MsolService
$WarningPreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'

#Uses Secure String to connect
Connect-MsolService -Credential $cred
$ExchOnlineSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $ExchOnlineSession

#Prompts user
$Name = Read-Host 'Enter user full name'
$Login = Read-Host 'Enter user login'
$Group = Read-Host 'Enter Distribution Group'

#Adds user to a CLOUD ONLY Distribution group
Add-DistributionGroupMember -Identity $Group -Member $Login

#Verifies user was added to group
Get-DistributionGroupMember -Identity $Group | Where-Object Name -Like "*$Name*" | Select-Object Identity, PrimarySmtpAddress, RecipientType