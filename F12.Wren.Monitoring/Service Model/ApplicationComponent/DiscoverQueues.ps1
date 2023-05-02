
# Queues are hosted by Windows Computer so discovery needs to provide key property of all parents (Computer Name is key property)

# Testing - include curly braces around GUID when testing Script
# [guid]::NewGuid()
# DiscoverQueues.ps1 -sourceId '{GUID}' -managedEntityId '{GUID}' -topFolder 'C:\Wren\Stores\Queues' -computerName 'WinDev'
# Can be same GUID for testing

param ($sourceId, $managedEntityId, $topfolder, $computerName)

$api = New-Object -comObject 'MOM.ScriptAPI'
$discoverydata = $api.CreateDiscoveryData(0,$sourceId,$managedEntityId)

$subFolders = Get-ChildItem -Path $topfolder | where {$_.PSIsContainer -eq $true}

foreach ($subFolder in $subFolders)
{
	# $subFolder.FullName

	$instance = $discoverydata.CreateClassInstance("$MPElement[Name='F12.Wren.Monitoring.Stores.Queue']$")
	$instance.AddProperty("$MPElement[Name='Windows!Microsoft.Windows.Computer']/PrincipalName$", $computerName)
	$instance.AddProperty("$MPElement[Name='F12.Wren.Monitoring.Stores.Queue']/StoreCode$", $subFolder.Name)
	$instance.AddProperty("$MPElement[Name='F12.Wren.Monitoring.Stores.Queue']/FolderPath$", $subfolder.FullName)

	$discoverydata.AddInstance($instance)
}

$discoverydata

# For Testing - comment out line above $discoverydata and uncomment line below. 
# Run from PowerShell
# .\DiscoverQueues.ps1 -sourceId '{994b49ec-5db9-469a-87e4-01f4d8964763}' -managedEntityId '{994b49ec-5db9-469a-87e4-01f4d8964763}' -TopFolder 'C:\Wren\Stores\Queues' -ComputerName 'WinDev.langkah.net' | export-clixml c:\temp\scom.xml
# $api.Return($discoverydata)
