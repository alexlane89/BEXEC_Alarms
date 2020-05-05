$server = 'RTP22BEXEC', 'RTP22BEXEC_S'
$path = 'd$\DeltaV\DVData\Batch\BMPersist'
$b = @()
$SUM_array = @()
$COUNT_array = @()
for ($a = 1; $a -lt 10; $a++)
{
    foreach ($i in $server)
    {
        $SUM_array += (Get-ChildItem -Path \\$i\$path | Measure-Object -Sum Length).Sum
        $COUNT_array += (Get-ChildItem -Path \\$i\$path | Measure-Object -Sum Length).Count
    }
}
if
(($SUM_array[0] = $SUM_array[1]) -and ($COUNT_array[0] = $COUNT_array[1]))
{
$result = 1
} else {
$result = 0
}

#Write-Host '$result = ' $result

New-Object -TypeName PSCustomObject -Property @{
    TAG_NAME = 'BEXEC_SYNC'
    TIME_STAMP = Get-Date
    RESULT = $result
} | Export-Csv -Path D:\DeltaV\DVData\BEXEC_PS_Tests\test.csv -NoTypeInformation
