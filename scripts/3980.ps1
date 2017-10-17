param(
[Parameter(Position=0,ValueFromPipeline=$True)]$GPOs = @(Get-GPO -All),
[string] $Reportfolder = [Environment]::getfolderpath("mydocuments") + "\GPOreports"
)

begin{
$script:GPObj = @()
$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
$startfolder = "\\$domain\SYSVOL\$domain\Policies"
write-verbose "getting info from $startfolder"

Function GPOSize($objGPO){
	$colItems = (Get-ChildItem "$("$startfolder\`{")$($objGPO.Id)$("`}")" -recurse | Measure-Object -property length -sum)
	$Result = "{0:N2}" -f ($colItems.sum / 1KB) + " KB"
	write-verbose "the size for $objGPO is $Result"
	return $Result
}
}# end begin

process{
foreach ($GPO in $GPOs){
	write-verbose "getting GPO $($GPO.DisplayName)"
	$DateRevMin = get-date -uformat "%Y-%m-%d"
	New-Item $Reportfolder\$DateRevMin -ItemType directory -Force | out-null
	$OutPath = $Reportfolder + "\" + $DateRevMin + "\" + $GPO.DisplayName + ".html"
	Get-GPOReport $GPO.Id -ReportType html -Path $OutPath
	$script:GPObj += New-Object PSObject -Property @{
		GPName = $GPO.DisplayName
		GPGUID = $GPO.ID
		Size = $(GPOSize $GPO)
		Report = $OutPath
		}
	}
}# end process

end{
$script:GPObj
}

# alternative oneliner to get reports for all GPO objects in domain
# Get-GPO -All | %{Get-GPOReport -guid $_.id -ReportType html -Path (join-path -path "c:\temp" -childpath "$($_.displayname).html")}

