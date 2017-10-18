#requires -pssnapin VMware.Vimautomation.Core
Param(
    [int]
    $LastDays
)
Process
{
    $EventFilterSpecByTime = New-Object VMware.Vim.EventFilterSpecByTime
    If ($LastDays)
    {
        $EventFilterSpecByTime.BeginTime = (get-date).AddDays(-$($LastDays))
    }
    $EventFilterSpec = New-Object VMware.Vim.EventFilterSpec
    $EventFilterSpec.Time = $EventFilterSpecByTime
    $EventFilterSpec.DisableFullMessage = $False
    $EventFilterSpec.Type = "VmCreatedEvent","VmDeployedEvent","VmClonedEvent","VmDiscoveredEvent","VmRegisteredEvent"
    $EventManager = Get-View EventManager
    $NewVmTasks = $EventManager.QueryEvents($EventFilterSpec)

    Foreach ($Task in $NewVmTasks)
    {
        # If VM was deployed from a template then record which template.
        If ($Task.Template -and $Task.SrcTemplate.Vm)
        {
            
            $srcTemplate = Get-View $Task.SrcTemplate.Vm -Property name | 
                Select -ExpandProperty Name
        }
        Else
        {
            $srcTemplate = $null
        }
        write-output ""|Select-Object @{
                Name="Name"
                Expression={$Task.Vm.name}
            }, @{
                Name="Created"
                Expression={$Task.CreatedTime}
            }, @{
                Name="UserName"
                Expression={$Task.UserName}
            }, @{        
                Name="Type"
                Expression={$Task.gettype().name}
            }, @{
                Name="Template"
                Expression={$srcTemplate}
            }
    } 
}
