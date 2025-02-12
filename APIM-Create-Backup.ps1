param(
    [string]$subscriptionId,
    [string]$ResourceGroupName,
    [string]$ApiManagementName,
    [string]$StorageAccountName,
    [string]$ContainerName
)

#this script uses the azure cli to extract an access token
#that access token is used to call the azure management api
#in this way we can use the backup functionality of APIM using a systemassigned identity, this is not possible in a direct way using the azure cli

az login --identity

#get access token using azure cli
$token = az account get-access-token --subscription $subscriptionId --query accessToken --output tsv
      
$backupName = "backup-" + $apiManagementName + "-" + $(Get-Date -Format 'yyyyMMddHHmmss')
$accessType="SystemAssignedManagedIdentity"

#construct API call for the azure management API
$uri = "https://management.azure.com/subscriptions/" + $subscriptionId + "/resourceGroups/" + $ResourceGroupName + "/providers/Microsoft.ApiManagement/service/"+ $ApiManagementName + "/backup?api-version=2024-05-01"
$body = @{
    storageAccount = $StorageAccountName          
    containerName = $ContainerName
    backupName = $BackupName
    accessType = $accessType
} | ConvertTo-Json

#call azure management API with access token
Invoke-RestMethod -Method Post -Uri $uri -Headers @{Authorization = "Bearer $token"} -ContentType "application/json" -Body $body

