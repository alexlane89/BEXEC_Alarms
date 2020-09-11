$path = 'd$\DeltaV\DVData\Batch\BMPersist'
$TimeStart = Get-Date
$TimeEnd = $TimeStart.AddMinutes(1)
$P_Server = (Get-Content -Path 'D:\DeltaV\DVData\BEXEC_Sync_Mon\Server_Names.data' -TotalCount 1)
$R_Server = (Get-Content -Path 'D:\DeltaV\DVData\BEXEC_Sync_Mon\Server_Names.data' -TotalCount 2)[-1]
$P_SUM_Array = @()
$R_SUM_Array = @()
$P_COUNT_Array = @()
$R_COUNT_Array = @()
$Fail_Count = 0
$Fail_PCT = 20
$result = 0
$status = 0
$loc = (Get-Content -Path 'D:\DeltaV\DVData\BEXEC_Sync_Mon\Server_Names.data' -TotalCount 3)[-1]
$output_path = 'D:\DeltaV\DVData\BEXEC_Sync_Mon\UFL_Output\SYNC_STATUS.txt'

#Do Until Loop for comparison of file parameters over a time range
Do
{
    $TimeNow = Get-Date
    if ($TimeNow -ge $TimeEnd)
    {
        #if number of entries is primary arrays do not match those of redundant arrays, throw an error.
        if($P_Sum_Array.Length -ne $R_SUM_Array.Length -or $P_COUNT_Array.Length -ne $R_COUNT_Array.Length)
            {
            $status = 1
            throw 'Data Collection Error'
            }
    } else {
        $P_SUM_Array += (Get-ChildItem -Path \\$P_Server\$path | Measure-Object -Sum Length).Sum
        $R_SUM_Array += (Get-ChildItem -Path \\$R_Server\$path | Measure-Object -Sum Length).Sum
        $P_COUNT_Array += (Get-ChildItem -Path \\$P_Server\$path | Measure-Object -Sum Length).Count
        $R_COUNT_Array += (Get-ChildItem -Path \\$R_Server\$path | Measure-Object -Sum Length).Count
    }
}
Until ($TimeNow -ge $TimeEnd)

#for all entries in SUM & COUNT arrays, compare Primary vs Redundant 
#Increment $Fail_Count whenever an unequal set of entries are found.
for ($a = 1; $a -lt $P_SUM_Array.Length; $a++)
{
    if ($P_SUM_Array[$a] -ne $R_SUM_Array[$a] -or $P_COUNT_Array[$a] -ne $R_COUNT_Array[$a])
    {
        $Fail_Count = $Fail_Count + 1
    }
}

#Determine the amount of incongruent "sets" as a percentage of sample number
#Compare bad sync percentage to the fail percent parameter,
#if less than, than result is pass "1"
$BAD_SYNC_PCT = (($Fail_Count / $P_SUM_Array.Length) * 100)
if ($BAD_SYNC_PCT -lt $Fail_PCT)
{
    $result = 1
}

#Write Result (1/0, Pass/Fail), Bad Sync percentage, and error status to text file

"{0},{1},{2}" -f ($loc + '_BEXECSYNC_RESULT'), $TimeEnd, $result |
    Out-File $output_path -Encoding ascii

"{0},{1},{2}" -f ($loc + '_BEX_BADSYNC_PCT'), $TimeEnd, $BAD_SYNC_PCT |
    Out-File -Append $output_path -Encoding ascii

"{0},{1},{2}" -f ($loc + '_MON_STATUS'), $TimeEnd, $status |
    Out-File -Append $output_path -Encoding ascii
