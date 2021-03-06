function Move-VMThin {
    PARAM(
         [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage="Virtual Machine Objects to Migrate")]
         [ValidateNotNullOrEmpty()]
            [System.String]$VM
        ,[Parameter(Mandatory=$true,HelpMessage="Destination Datastore")]
         [ValidateNotNullOrEmpty()]
            [System.String]$Datastore
    )
    
	Begin {
        #Nothing Necessary to process
	} #Begin
    
    Process {        
        #Prepare Migration info, uses .NET API to specify a transformation to thin disk
        $vmView = Get-View -ViewType VirtualMachine -Filter @{"Name" = "$VM"}
        $dsView = Get-View -ViewType Datastore -Filter @{"Name" = "$Datastore"}
        
        #Abort Migration if free space on destination datastore is less than 50GB
        if (($dsView.info.freespace / 1GB) -lt 50) {throw "Move-ThinVM ERROR: Destination Datastore $Datastore has less than 50GB of free space. This script requires at least 50GB of free space for safety. Please free up space or use the VMWare Client to perform this Migration"}

        #Prepare VM Relocation Specificatoin
        $spec = New-Object VMware.Vim.VirtualMachineRelocateSpec
        $spec.datastore =  $dsView.MoRef
        $spec.transform = "sparse"
        
        #Perform Migration
        $vmView.RelocateVM($spec, $null)
    } #Process
}
