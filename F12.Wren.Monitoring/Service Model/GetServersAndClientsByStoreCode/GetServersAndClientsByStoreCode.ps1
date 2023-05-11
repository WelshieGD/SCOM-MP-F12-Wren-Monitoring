param($sourceId, $managedEntityId)

$moduleDir = (get-itemproperty -path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\System Center Operations Manager\12\Setup\Powershell\V2').InstallDirectory
$modulePath = join-path $moduleDir -ChildPath '\OperationsManager\OperationsManager.psm1'

Import-Module $modulePath 
New-SCOMManagementGroupConnection -ComputerName scomms

$api = New-Object -comObject 'MOM.ScriptAPI'
$discoveryData = $api.CreateDiscoveryData(0,$sourceId,$managedEntityId)

$Class = Get-SCOMClass -Name F12.Wren.Monitoring.Stores.ComputerRole.StoreComputer 
$api.LogScriptEvent('DiscoverStores.ps1',998,4,"Store Discovery Started")

$StoreServers = $Class | Get-SCOMClassInstance

$StoreCodes = $StoreServers | foreach ({$_."[F12.Wren.Monitoring.Stores.ComputerRole.StoreComputer].StoreCode"}) | group Value
$api.LogScriptEvent('DiscoverStores.ps1',998,4,"StoreCodes = $StoreCodes")


$storesHash = @{}
# Walk through all of the store codes 
# List of objects with a key value \ pair. List of store
foreach ($storeCode in $storeCodes)
{
	$api.LogScriptEvent('DiscoverStores.ps1',997,4,"Created store instance. Store Code: " + $storeCode.Name)
	$storeInstance = $discoveryData.CreateClassInstance("$MPElement[Name='F12.Wren.Monitoring.Stores.Store']$")
	$storeInstance.AddProperty("$MPElement[Name='F12.Wren.Monitoring.Stores.Store']/StoreCode$", $storeCode.Name)
	$discoveryData.AddInstance($storeInstance)
	$storesHash += @{$storeCode.Name = $storeInstance}
}
# Go back to list of store servers and iterate through by store Code
foreach ($storeServer in $storeServers)
{
	$storeCode = $storeServer."[F12.Wren.Monitoring.Stores.ComputerRole.StoreComputer].StoreCode".Value
	$computerName = $storeServer."[Microsoft.Windows.Computer].PrincipalName".value

	$compInstance = $discoveryData.CreateClassInstance("$MPElement[Name='F12.Wren.Monitoring.Stores.ComputerRole.StoreServer']$")
	$compInstance.AddProperty("$MPElement[Name='Windows!Microsoft.Windows.Computer']/PrincipalName$", $computerName)
	$compInstance.AddProperty("$MPElement[Name='F12.Wren.Monitoring.Stores.ComputerRole.StoreComputer']/StoreCode$", $storeCode)
	$discoveryData.AddInstance($compInstance)

	$relInstance = $discoveryData.CreateRelationshipInstance("$MPElement[Name='F12.Wren.Monitoring.Stores.StoresContainsStoreServer']$")
	$relInstance.Source = $storesHash[$storeCode]
    $relInstance.Target = $compInstance
	$discoveryData.AddInstance($relInstance)
}

$discoveryData

# $api.Return($discoveryData)

