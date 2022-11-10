################################################################################
### AZ RB AAD Domain Join VM - Ajit D.                                       ###
### List All VMs, Filter Vms which don't have AZ AD Extantion & update them  ###
################################################################################
$resourceGroupName = "myResourceGroup"		
$extName = "testdom"
$domainName = "testdom.net"
# Ensure you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process
# Connect to Azure with system-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity).context
# set and store context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
# List all VMs status
$vms = Get-AzVM -ResourceGroupName $resourceGroupName -Status -DefaultProfile $AzureContext
foreach ($VM in $vms.Name) {
    $ADD_Status = (Get-AzVMADDomainExtension -Name $extName -ResourceGroupName $resourceGroupName -VMName $VM)
    if($ADD_Status.Name -ne 'testdom') {
        Write-output "VM $VM is not joined to the domain"
		Write-output "Joining VM to the domain...."
		Set-AzVMADDomainExtension -ResourceGroupName $resourceGroupName -VMName $VM -Name $extName -DomainName $domainName
		Write-output "VM $VM is now joined to the domain !!!"
		}
    else { 
        echo "$VM is already joined to the domain !"
        }
}
Write-Output "Account ID of current context: " $AzureContext.Account.Id
