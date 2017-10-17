#Requires -version 2

# TITLE: 	Newer-LinkedClone.ps1
# AUTHOR:	Cameron Smith (original by Hal Rottenberg)
# Adapted from a technique published originally by Keshav Attrey http://www.vmdev.info/?p=40
# Also see William Lam's Perl script: http://engineering.ucsb.edu/~duonglt/vmware/vGhettoLinkedClone.html
# And Leo's manual version for ESX 3.5: http://blog.core-it.com.au/?p=333

param (
	[parameter(Mandatory=$true)][string]$SourceName,
	[parameter(Mandatory=$true)][string]$CloneName,
	[parameter(Mandatory=$true)][string]$SnapName
)
$vm = Get-VM $SourceName

# Create new snapshot for clone
#$cloneSnap = $vm | New-Snapshot -Name "Clone Snapshot"

# Get managed object view
$vmView = $vm | Get-View

# Get folder managed object reference
$cloneFolder = $vmView.parent

# Build clone specification
$cloneSpec = new-object Vmware.Vim.VirtualMachineCloneSpec
#$cloneSpec.Snapshot = $vmView.Snapshot.CurrentSnapshot
$SnapRef = (Get-Snapshot -VM $SourceName -name "$SnapName") | Get-View
$cloneSpec.Snapshot = $SnapRef.moref

# Make linked disk specification
$cloneSpec.Location = new-object Vmware.Vim.VirtualMachineRelocateSpec
$cloneSpec.Location.DiskMoveType = [Vmware.Vim.VirtualMachineRelocateDiskMoveOptions]::createNewChildDiskBacking

# Create clone
$vmView.CloneVM( $cloneFolder, $cloneName, $cloneSpec )

# Write newly created VM to stdout as confirmation
Get-VM $cloneName
