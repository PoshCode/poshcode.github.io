function demo-attributes
{

[System.Configuration.SettingsDescription({
    @{something = 1;
      this = 'that';
      array = (1,2,3);
      sub = @{ sub1 = 1 ; sub2 =2 }
    }})]
    
[CmdletBinding(DefaultParameterSetName="noname")]
param (
 [Parameter(Position=1,mandatory = $true)]
  [string]$something 
 
)
1..10
}
$settingstext = ((dir function:\demo-attributes).scriptblock.attributes |Where-Object { $_.typeid -like '*settingsdescription*'  }).description
$settingsscriptblock = $ExecutionContext.InvokeCommand.NewScriptBlock("DATA {" + $settingstext + "}")
&$settingsscriptblock
