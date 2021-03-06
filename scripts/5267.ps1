$method = @{}
$method['clear'] = {
	$this.Items() | foreach -Process {
		# for the first we must remove all Junction-points
		if ($_.IsLink) { (gi $_.Path).Delete() } # directly (1)
		ls $_.Path -Recurse -Force -Directory | foreach {
			$d_item = gi -LiteralPath $_.FullName
			if ($d_item.Attributes -match 'ReparsePoint') { $d_item.Delete() } # and recursively (2)
		}
		ri $_.Path -Recurse -Force -Confirm:$false # and now the actual cleanup (3)
	}
} # /method.clear
$method['count'] = {
	Set-Variable -Name links,files,folders,size -Value 0 -Option AllScope
	function Calculate-Items ($ItemsList)
	{
		function count ($folder, $list)
		{
			if (-not $list) { $list = Get-Item "$($folder)\*" }
			$list | foreach {
				if ($_.Attributes -match 'ReparsePoint') { ++$links }
				elseif ($_.Attributes -notmatch 'Directory') { ++$files;  $size += $_.Length }
				else { ++$folders; count -folder $_.FullName } # recursively call
			}
		}
		count -list $ItemsList # initial call
	} # gci w/o links
	$upper_items_list = @()
	$this.Items() | foreach -Process { $upper_items_list += gi -LiteralPath $_.Path }
	if ($upper_items_list) { Calculate-Items -ItemsList $upper_items_list }
	return New-Object -TypeName psobject -Property @{
			Links = $links; Files = $files; Folders = $folders; Length = $size
	}
} # /method.count
$bin = (New-Object -ComObject 'Shell.Application').Namespace(0xA)
$bin | Add-Member -MemberType 'ScriptMethod' -Name 'Clear' -Value $method.clear
$bin | Add-Member -MemberType 'ScriptMethod' -Name 'Count' -Value $method.count
New-Variable -Name RecycleBin -Value $Bin -Option Constant
Remove-Variable -Name method, bin

