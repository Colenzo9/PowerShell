#Connects to Microsoft Teams with encrypted credentials
$username = "nbafn1@ccbcc.com"
$password = Get-Content 'C:\Jones IT\PSI\mysecurestring.txt' | ConvertTo-SecureString
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password

$WarningPreference = 'SilentlyContinue'

Connect-MicrosoftTeams -Credential $cred