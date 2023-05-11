param ([string] $queuesPath)

# SCOM Specific Header
$api = New-Object -comObject 'MOM.ScriptAPI'
$api.LogScriptEvent('SingleQueuesStats.ps1', 102, 4, "Queue Path is $queuesPath")

# Take the following from the Discovery script as it is the same logic --> 

$queues = Get-ChildItem -Path $queuesPath -Recurse | where {$_.psIsContainer -eq $true}



foreach($queue in $queues)
{
	# $queue is an object so need to state property we want. 
	$files = Get-ChildItem -Path $queue.FullName -Recurse | where {$_.psIsContainer -eq $false}
		$api.LogScriptEvent('SingleQueuesStats.ps1', 103, 4, "Queue Name is $queues")


	if ($files -ne $null) {$count = $files.count}
	else {$count = 0}

	$size = 0
	$oldestfile = 0

		foreach($file in $files)
		{
			$size += $file.Length

			$ageinMinutes = ((Get-Date) - ($file.creationTime)).TotalMinutes

			if ($ageinMinutes -gt $oldestfile) {$oldestfile = $ageinMinutes}

		}

	$bag = $api.CreatePropertyBag()
	$bag.AddValue('StoreCode', $queue.Name)
	$bag.AddValue('FileCount', $count)
	$bag.AddValue('OldestFile', $oldestfile)
	$bag.AddValue('TotalSize', $size)


	$bag

 # For Testing
 # $api.return($bag)

}

