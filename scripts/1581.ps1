function JoinTwoCustomObjs($Parent,$Child,$Key)
{	
	$CurrentErrorSetting = $ErrorActionPreference
	$ErrorActionPreference = 'SilentlyContinue'
	
	$new = New-Object -TypeName PsObject
	
	$ParentProps =  Get-Member -InputObject $Parent -MemberType NoteProperty
	foreach($prop in $ParentProps)
	{	$PropName = $prop.Name
		$value = $Parent.$PropName
		Write-Host $value		
		Add-Member -InputObject $new -MemberType NoteProperty -Name $PropName -Value $value
	}
	
	$ChildProps =  Get-Member -InputObject $Child -MemberType NoteProperty
	foreach($Prop in $ChildProps)
	{	$PropName = $prop.Name
		$ChildValue = $Child.$PropName

		if($PropName -notmatch $key)
		{	Add-Member -InputObject $new -MemberType NoteProperty -Name $PropName -Value $ChildValue }

		if(!$?)
		{	if($new.$PropName -notmatch $ChildValue)
			{	$new.$PropName += ', ' + $ChildValue 
			}
		}
	}
	$ErrorActionPreference = $CurrentErrorSetting
	$new
}

function Insert-Object($Child,$Key)
{	begin
	{	$CurrentErrorSetting = $ErrorActionPreference
		$ErrorActionPreference = 'SilentlyContinue'
		$objs = @()
		$childHash = @{}
		$child | %{ $ChildHash.Add($_.$Key,$_) ; if(!$?) { JoinTwoCustomObjs $ChildHash[$Key] $_ $Key } }
		$ErrorActionPreference = $CurrentErrorSetting
	}
	process
	{	$obj = New-Object -TypeName PsObject
		$thisKey = $_.$key
		if($ChildHash.ContainsKey($thisKey))
		{	
			$obj = JoinTwoCustomObjs -Parent $_ -Child $($childHash[$thisKey]) -Key $Key
			$objs += $obj
		}
	}
	end
	{	$objs
	}
}
