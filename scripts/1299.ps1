# This function returns all datastores that can be shared amongst ESX hosts.
function Get-ShareableDatastore {
	# Get all datastores.
	$datastores = Get-Datastore

	# Load the HostStorageSystems of all hosts.
	$hosts = Get-VMHost | Get-View -property ConfigManager
	$storageSystems = @()
	foreach ($h in $hosts) {
		$sdi = Get-View $h.ConfigManager.StorageSystem -Property StorageDeviceInfo
		Write-Debug ("GSD: SDI for host $h is " + $sdi)
		$storageSystems += $sdi
	}

	foreach ($dso in $datastores) {
		$ds = $dso | Get-View -Property Info

		# Check if this datastore is NFS.
		$dsInfo = $ds.Info
		Write-Debug ("GSD: Is it NFS? " + $dsInfo.getType())
		if ($dsInfo -is [VMware.Vim.NasDatastoreInfo]) {
			Write-Output $dso
			continue
		}

		# Get the first extent of the datastore.
		$firstExtent = $dsInfo.Vmfs.Extent[0]
		Write-Debug ("GSD: first extent: " + $firstExtent.DiskName)

		# Find a host that maps this LUN.
		foreach ($hss in $storageSystems) {
			$lun = $hss.StorageDeviceInfo.ScsiLun | Where { $_.CanonicalName -eq $firstExtent.DiskName }

			if ($lun) {
				Write-Debug ("GSD: found " + $lun.DeviceName + " on " + $hss.MoRef.Value)
				Write-Debug ("GSD: LUN details: Name:" + $lun.DisplayName + ", Type:" + $lun.DeviceType + ", Vendor:" + $lun.Vendor + ", Model:" + $lun.Model)

				# Search the adapter topology of this host, looking for the LUN.
				$adapterTopology = $hss.StorageDeviceInfo.ScsiTopology.Adapter |
					Where { $_.Target |
						Where { $_.Lun |
							Where { $_.ScsiLun -eq $lun.key }
						}
					} | Select -First 1

				# We've found a host that has this LUN. Find how it maps to an adapter.
				$adapter = $hss.StorageDeviceInfo.HostBusAdapter | Where { $_.Key -eq $adapterTopology.Adapter }
				Write-Debug ("GSD: HBA type is: " + $adapter.getType())

				# It's shared if it's Fibre Channel or iSCSI (we checked for NFS earlier)
				if ($adapter -is [VMware.Vim.HostFibreChannelHba] -or $adapter -is [VMware.Vim.HostInternetScsiHba]) {
					Write-Debug "GSO: $dso is sharable"
					Write-Output $dso
				}

				# Otherwise it's not shared and we quit walking through hosts.
				break
			}
		}
	}
}

