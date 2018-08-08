Param([Parameter(Mandatory=$true)] [string]$VMGuest)

$vm = get-vm $VMGuest
$cpuCap = $vm.NumCPU*1000
$cpuRes = $cpuCap/2

$memCap = $vm.MemoryMB
$memRes = $memCap/4

$spec = new-object VMware.Vim.VirtualMachineConfigSpec;
$spec.memoryAllocation = New-Object VMware.Vim.ResourceAllocationInfo;
$spec.memoryAllocation.Shares = New-Object VMware.Vim.SharesInfo;
$spec.memoryAllocation.Limit = -1;
$spec.memoryAllocation.Reservation = $memRes;

$spec.cpuAllocation = New-Object VMware.Vim.ResourceAllocationInfo;
$spec.cpuAllocation.Limit = $cpuCap;
$spec.cpuAllocation.Reservation = $cpuRes;

($vm | get-view).ReconfigVM_Task($spec)

