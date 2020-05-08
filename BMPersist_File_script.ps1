$server = 'RTP22BEXEC', 'RTP22BEXEC_S'
$path = 'd$\DeltaV\DVData\Batch\BMPersist'
$date = Get-Date
$b = @()
$SUM_array = @()
$COUNT_array = @()

#for loop is used to extract file size (run for each iteration) several times
for ($a = 1; $a -lt 10; $a++)
{
    foreach ($i in $server) #foreach writes file size and count to arrays, respectively
    {
        $SUM_array += (Get-ChildItem -Path \\$i\$path | Measure-Object -Sum Length).Sum
        $COUNT_array += (Get-ChildItem -Path \\$i\$path | Measure-Object -Sum Length).Count
    }
}

#if/else condition writes result as True or False 
#based on BEXEC, BEXEC_S array values being equal
if
(($SUM_array[0] = $SUM_array[1]) -and ($COUNT_array[0] = $COUNT_array[1]))
{
$result = 1
} else {
$result = 0
}

"{0},{1},{2}" -f 'BEXEC_SYNC', $date, $result |
    Out-File D:\DeltaV\DVData\BEXEC_PS_Tests\SYNC_STATUS.txt -Encoding ascii
