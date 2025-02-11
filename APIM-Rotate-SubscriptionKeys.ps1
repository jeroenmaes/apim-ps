param(
    [string]$apimName,
    [string]$apimResourceGroup,
    [string]$masterSubscriptionId
)

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect to Azure with system-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity).context

# Set and store context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext  

# Get API Management Services information
$ApiManagements = Get-AzApiManagement -ResourceGroupName $apimResourceGroup -Name $apimName

foreach ($ApiManagement in $ApiManagements)
{
 #Setting Up Azure API Management Context to work. 
 $ApiManagementContext = New-AzApiManagementContext -ResourceId $ApiManagement.Id

# Get all API Management Subscriptions with specific ProductID
 $ApiManagementSubscriptions = Get-AzApiManagementSubscription -Context $ApiManagementContext -SubscriptionId $masterSubscriptionId
 foreach ($ApiManagementSubscription in $ApiManagementSubscriptions)
 {     
    # Regenerating Primary Key
    $PrimaryKey = (New-Guid) -replace '-',''
    $SecondaryKey = (New-Guid) -replace '-',''
 
 #In Order to set a new value 
 $newvalue = Set-AzApiManagementSubscription -Context $ApiManagementContext -SubscriptionId $ApiManagementSubscription.SubscriptionId -PrimaryKey $PrimaryKey -SecondaryKey $SecondaryKey -State Active 
 
 }
}
