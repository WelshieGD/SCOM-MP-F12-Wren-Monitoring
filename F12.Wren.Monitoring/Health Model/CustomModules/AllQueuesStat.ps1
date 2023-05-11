param ([string] $queuesPath)

# SCOM Specific Header
$api = New-Object -comObject 'MOM.ScriptAPI'
$api.LogScriptEvent('AllQueuesStats.ps1', 101, 4, "Queue Path is $queuesPath")



$files = Get-ChildItem -Path $queuesPath -Recurse | where {$_.psIsContainer -eq $false}


if ($files -ne $null) {$count = $files.count}
else {$count = 0}

$size = 0
$oldestfile = 0

foreach ($file in $files)
{
	$size += $file.Length

	$ageinMinutes = ((Get-Date) - ($file.creationTime)).TotalMinutes

	if ($ageinMinutes -gt $oldestfile) {$oldestfile = $ageinMinutes}

}

$bag = $api.CreatePropertyBag()
$bag.AddValue('FileCount', $count)
$bag.AddValue('OldestFile', $oldestfile)
$bag.AddValue('TotalSize', $size)


$bag

# For Testing
# $api.return($bag)


