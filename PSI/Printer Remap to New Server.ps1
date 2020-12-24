<#
    This is a logon script used to remove old network mapped printers 
    and add the same printers back using the new print server.
    It will only run the entire script if it finds a printer using the old server.
#>

$OldPrintServer = "v64-prt-01"
$NewPrintServer = "Print1"

#$ErrorActionPreference = 'SilentlyContinue'
$Printers = Get-WmiObject -Class Win32_Printer | Where-Object { $_.Network -eq $true }

foreach ($Printer in $Printers) {
    if ($Printer.SystemName -like "\\$OldPrintServer*") {           
        $ShareName = $Printer.ShareName
        Add-Printer -ConnectionName "\\$NewPrintServer.lrmcenter.com\$ShareName"
        if ($Printer.Default -eq $true) {
            $Name = $Printer.Name -replace $OldPrintServer, $NewPrintServer
            $FQDN = $Printer.Name -replace $OldPrintServer, "$NewPrintServer.lrmcenter.com"
            (Get-WmiObject -Class Win32_Printer | Where-Object { $_.Name -eq $Name -or $FQDN }).SetDefaultPrinter() | Out-Null
        }
        $Printer.Delete()
    }
}