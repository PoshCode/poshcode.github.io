
$VMs = get-vm
$Results = @()
foreach ($VM in $VMs) {
    $Result = new-object PSObject
    $Result | add-member -membertype NoteProperty -name "Name" -value $VM.Name
    $Result | add-member -membertype NoteProperty -name "Description" -value $VM.Notes
    $VMDiskCount = 1
    get-harddisk $VM | foreach {
        $disk = $_
        $Result | add-member -name "Disk($VMDiskCount)SizeGB" -value ([math]::Round($disk.CapacityKB / 1MB)) -membertype NoteProperty
        $Result | add-member -name "Disk($VMDiskCount)Type" -value $disk.DiskType -membertype NoteProperty
        $VMDiskCount++
    }
    $Results += $Result
}
$Results | select-object * | export-csv -notypeinformation E:\VCBDiskReport.csv
