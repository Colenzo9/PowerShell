<#
.SYNOPSIS
    Exports a users pst file from O365
.DESCRIPTION
    Connects to Security and Compliance center with MFA, downloads the pst file, and exports it to the default \\lRDFS1\it\pstfiles\old
.EXAMPLE
    PS C:\> O365-PSTExport -Mailbox chjones@lrmcenter.com -Case chjones -SearchName chjones -ExportName -chjones
.NOTES
    The Exchange Online Managment module must be installed to access the commands. Run as admin, Install-Module ExchangeOnlineManagement
    Must be at least a Compliance Admin AND an eDiscovery Administrator to run this script
#>

[CmdletBinding()]
param (
    [Parameter()]
    [String]$Mailbox,
    [String]$Case,
    [String]$SearchName,
    [String]$ExportName
)

###########Test if already connected to Sec and comp center
#Connect with MFA to O365 Security and Compliance Center
Connect-IPPSSession

if (!$Case) {
    $Case = $Mailbox.Replace('@lrmcenter.com', '')
}
if (!$SearchName) {
    $SearchName = $Mailbox.Replace('@lrmcenter.com', '')
}
if (!$ExportName) {
    $ExportName = $Mailbox.Replace('@lrmcenter.com', '')
}

New-ComplianceCase -Name $Case | Out-Null
New-ComplianceSearch -Case $Case -Name $SearchName -ExchangeLocation $Mailbox | Out-Null
Start-ComplianceSearch -Identity $SearchName | Out-Null
Write-Host "`nStarting compliance search...`n"

#Make so this runs until the status property is -eq to Completed
do {
    Get-ComplianceSearch -Case $Case | Out-Null
    Start-Sleep -Seconds 1
} until ((Get-ComplianceSearch -Case $Case).Status -eq 'Completed')

New-ComplianceSearchAction -SearchName $SearchName -Export -Format FxStream -EnableDedupe $true | Out-Null

#Make so this runs until the status property is -eq to Completed
do {
    Get-ComplianceSearchAction -Case $Case | Out-Null
    Start-Sleep -Seconds 1
} until ((Get-ComplianceSearchAction -Case $Case).Status -eq 'Completed')

#Get the search name (not case), source, key, and destination. You must use the -IncludeCredential parameter to display the Key
$MyCaseExport = Get-ComplianceSearchAction -Case $Case -IncludeCredential -Details
$Source = (($MyCaseExport.Results).Split(';')[0]).Split(" ")[2]
$Key = (($MyCaseExport.Results).Split(';')[1]).Split(" ")[3]
$Destination = "\\LRDFS1\IT\PSTFILES\OLD\$ExportName"

#Loop to determine the export preparation % prior to downloading to PST $Destination
do {
    $MyCaseExportLoop = Get-ComplianceSearchAction -Case $Case -Details
    $Progress = $MyCaseExportLoop.Results.Split(';')[22].Split(" ")[2]
    Write-Host -NoNewline "`rPreparing PST file -- $Progress" -ForegroundColor Green
    Start-Sleep -Seconds 2
} until ($Progress -eq '100.00%')

Start-Process -FilePath "C:\Users\chjones\AppData\Local\Apps\2.0\WVW831W5.QO8\P667CCTJ.WTD\micr..tool_1975b8453054a2b5_000f.0014_34657a1d9b1f16e3\microsoft.office.client.discovery.unifiedexporttool.exe" -ArgumentList "-name $SearchName", "-source $Source", "-key $Key", "-dest `"$Destination`""

#Loop until process closes, verifying PST has been exported. Get PST file size?
if (!(Get-ChildItem -Path $Destination -Recurse -File '*.pst')) {
    do {
        Write-Host -NoNewline "`rWaiting for export to begin..." -ForegroundColor Yellow
    } until (Get-ChildItem -Path $Destination -Recurse -File '*.pst')
}

#Figure out how to check if process has ended
do {
    $PSTFileSize = Get-ChildItem -Path $Destination -Recurse -File '*.pst'
    Write-Host -NoNewline "`rExporting PST to $Destination -- $([Math]::Round($PSTFileSize.Length / 1MB))MB | $([Math]::Round([Long]$MyCaseExport.Results.Split(';')[18].Split(' ')[4].Replace(',','') / 1MB))MB" -ForegroundColor Green
    Start-Sleep -Seconds 1
} while (Get-Process -Name 'Microsoft.office.client.discovery.unifiedexporttool' -ErrorAction SilentlyContinue)