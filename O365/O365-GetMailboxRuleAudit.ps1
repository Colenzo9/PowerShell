$UPNS = (Get-Mailbox -Resultsize Unlimited).UserPrincipalName

foreach ($UPN in $UPNS) {
    Get-InboxRule -Mailbox $UPN | Where-Object {$_.Name -eq '.'} | Select-Object MailboxOwnerID, Name, Description
}