#Invoke-Command -Command {Start-AdSyncSyncCycle -Policytype Delta} -ComputerName WSUS

function Invoke-ADSync {
    $Return = @{ } 
    $Result = Invoke-Command -ComputerName WSUS -ErrorAction Stop -ScriptBlock {
        Start-ADSyncSyncCycle -PolicyType Delta
        (Get-ADSyncScheduler).NextSyncCycleStartTimeInUTC.ToLocalTime()
    }

    $Result2 = $Result | Select-Object -Last 1
    $date = Get-Date
    $Return.NextSync = $Result2
    $Return.LastSync = $Date
    $Return
}