#Requires -Version 2
Add-Type -Assembly PresentationFramework
Add-Type -Assembly PresentationCore
#Add-Type –AssemblyName WindowsBase

function Get-Runspace ($ScriptPath)
{
	if ($runspaceCreated -or [System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.apartmentstate -eq "STA")
	{
		Write-Debug "No new runspace was created"
		return
	}

	if ($PSBoundParameters.ContainsKey('ScriptPath'))
	{
		$ScriptPath = Resolve-Path $ScriptPath
	}
	elseif ($host.version.major -ge 3) 
	{
		$ScriptPath = $MyInvocation.PSCommandPath
	} 
	else
	{
		$ScriptPath = Resolve-Path (Get-PSCallStack)[-2].InvocationInfo.InvocationName
	} 

	Write-Debug "Script path: $ScriptPath"
	Write-Debug "Creating a new STA runspace ..."
	# Create a new runspace
	$rs = [Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($Host)
	$rs.ApartmentState = "STA"
	$rs.ThreadOptions = “ReuseThread”
	$rs.Open()
	$rs.SessionStateProxy.SetVariable("runspaceCreated",$true)
	$rs.SessionStateProxy.SetVariable("debugPreference",$debugPreference)
	# Rerun the script in the new apartment
	$psCmd = [System.Management.Automation.PowerShell]::Create()
	$psCmd.Runspace = $rs
	Write-Debug "Rerunning $ScriptPath"
	[void]$psCmd.AddCommand("Set-Location")
	[void]$pscmd.AddParameter("Path",(Get-Location).Path)
	[void]$psCmd.AddScript($ScriptPath)
	[void]$psCmd.Invoke()
	$rs.Close()
	exit
}

function Get-WindowsClasses
{
	$exportedClasses = [System.Reflection.Assembly]::GetAssembly([System.Windows.Window]).exportedTypes
	$exportedControlClasses = $exportedClasses | Where-Object {$_.isclass -and $_.fullname -like "System.Windows.*"}
	
	$controlClasses = @{}
	foreach ($controlClass in $exportedControlClasses)
	{
		$controlClasses[$controlClass.Name] = $controlClass.FullName
	} 
	$controlClasses
}

function Show-WpfWindow ([string]$XamlPath=".\MainWindow.xaml", [string]$HashTableName)
{	
	if (!(Test-Path $XamlPath))
	{
		throw "Could not find file $XamlPath"
	}
    [xml]$xaml = Get-Content $XamlPath
	$nsmgr = new-object system.xml.xmlnamespacemanager($xaml.nametable)
	$nsmgr.AddNamespace("x",$xaml.DocumentElement.x)
	$xaml.window.RemoveAttribute("x:Class")
	$controlEvents = @{}
	$controlClasses = Get-WindowsClasses
	:outer foreach ($element in $xaml.SelectNodes('//*[@x:Name]', $nsmgr))
	{
	    $name = $element.name
	    $typename = $controlClasses[$element.LocalName]
	    $type = $null
	    try { $type = [type]$typename } catch { Write-Debug "type $typename does not exist"; continue outer}
	    Write-Debug "$typeName`: $name ($(@($type.GetEvents()).count))"
	    foreach ($event in $type.GetEvents())
	    {
	        $attributeName = $event.Name
	        $attributeValue = $element.GetAttribute($attributeName)
	        
		    if ($attributeValue -and (Test-Path "function:$attributeValue"))
	        {
                Write-Debug "Found event handler: $attributeName - $attributeValue"
	            $controlEvents[$name] += @{$attributeName=$attributeValue}
	        }
		    elseif (Test-Path "function:${name}_$attributeName")
		    {
                Write-Debug "Found eventhandler $name_$attributeName"
	            $controlEvents[$name] += @{$attributeName="${name}_$attributeName"}
		    }
		    if ($AttributeValue)
		    {
			    $element.RemoveAttribute($attributeName)
		    }
	    }
	    
	}
	
	$reader = New-Object System.Xml.XmlNodeReader($xaml)
	$Window = [Windows.Markup.XamlReader]::Load( $reader )
    if ($PSBoundParameters.ContainsKey("HashTableName"))
    {
        if (Test-Path "Variable:$HashTableName")
        {
            Remove-Variable $HashTableName
        }

        $HashTable = (new-variable -name $HashTableName -value @{} -PassThru -Option Constant).Value
    }
            
	foreach ($element in $xaml.SelectNodes('//*[@x:Name]', $nsmgr))
	{
	    $name = $element.name
	    $control = $Window.FindName($name)
	
	    if ($control)
	    {
            if ($PSBoundParameters.ContainsKey("HashTableName"))
            {
                $HashTable[$name] = $control
            }
            else
            {
                if (Test-Path "Variable:$name")
                {
                    Remove-Variable $name
                }
	            New-Variable -Name $name -Value $control -Option Constant -ErrorAction SilentlyContinue
            }
	    }
	}
	
	foreach ($controlName in $controlEvents.Keys)
	{
	    $control = $Window.FindName($controlName)
	    if (!$control)
	    {
	        continue
	    }
	    foreach ($eventName in $controlEvents[$controlName].Keys)
	    {
	        $scriptBlock = [System.Management.Automation.ScriptBlock]::Create($controlEvents[$controlName][$eventName])
	        Write-Debug "$controlname.add_$eventName"
	        ($control."add_$eventName").Invoke($scriptBlock)
	    }
	}
	[void]$Window.ShowDialog()
}

function Get-ScriptStub ($XamlPath=".\MainWindow.xaml", [string]$HashTableName,
	[parameter()]
	[ValidateSet("None", "Normal", "High", "Full")]
	[String[]]
	$CommentDetail="Normal",
	$CommentBorderLength = 85)
{
    if ([System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.apartmentstate -ne "STA")
	{
        throw "Generate-ScriptStub must be run in a single threaded apartment. Start PowerShell with the -STA flag and rerun the script."
        exit
    }

	[xml]$xaml = Get-Content $XamlPath
	$nsmgr = new-object system.xml.xmlnamespacemanager($xaml.nametable)
	$nsmgr.AddNamespace('x',$xaml.DocumentElement.x)
	#$xaml.window.RemoveAttribute("x:Class")
        if ($CommentDetail -ne 'None')
        {
	    '#' * $CommentBorderLength
	    '# Controls:'
	    '#'
        }

	$controlEvents = @{}
	$controlTypes = @{}
	$controlClasses = Get-WindowsClasses
	:outer foreach ($element in $xaml.SelectNodes('//*[@x:Name]', $nsmgr))
	{
	    $name = $element.name
	    $typename = $controlClasses[$element.LocalName]
	    Write-Debug "$typeName`: $name"
	    $type = $null
        if ($controlTypes.ContainsKey($typename))
        {
            $type = $controlTypes[$typename]
        }
        else
        {
	        try { $type = [type]$typename } catch { Write-Debug "Unknown error getting type $typename"; continue outer}
            $controlTypes[$typename] = $type
        }
        
        if ($CommentDetail -ne 'None')
        {
            if ($PSBoundParameters.ContainsKey("HashTableName"))
            {
                '#  ${0}{1,-20} ({2})' -F $HashTableName,"['$name']",$typename
            }
            else
            {
                '#  ${0,-20} ({1})' -F $name,$typename
            }
	    }
	    foreach ($event in $type.GetEvents())
	    {
	        $attributeName = $event.Name
	        $attributeValue = $element.GetAttribute($attributeName)
		    if ($attributeValue)
	        {
	            Write-Debug "Found event handler: $attributeName - $attributeValue"
	            $controlEvents[$attributeValue] += @{$name=$attributeName}
	            #$element.RemoveAttribute($attributeName)
	        }
	    }
	    
	}
    if ("High","Full" -contains $CommentDetail)
    {
	    '#' * $CommentBorderLength
	    '# Types:'
	    '#'
	    foreach ($typename in $controlTypes.Keys)
	    {
	        "# $typename"
            $str = '#     Events:'
		    $count = 0
            foreach ($eventName in ($controlTypes[$typename].GetEvents() | Select-Object -ExpandProperty Name))
            {
                if (!($count++ % 3))
                {
                    $str += "`n#      "
                }
                $str += "$eventName ".PadRight(30)
            }
		    $str.Split("`n")
		    if ($CommentDetail -ne "Full")
		    {
		        continue
            }
            "#     Properties:"
            foreach ($Property in $controlTypes[$typename].GetProperties())
            {
                '#      {0,-30} ({1})' -F $property.name,$property.propertyType.fullname
            }

        }
    } 
    if ($CommentDetail -ne 'None')
    {
	    '#'
	    '#' * $CommentBorderLength
            ''
    }
    '#Requires -Version 2'
    '. .\wpftools.ps1'
	'Get-Runspace $MyInvocation.MyCommand.Definition'
	''
	'# Event handlers:'
	''
	foreach ($eventName in $controlEvents.Keys)
	{
	    foreach ($controlName in $controlEvents[$eventName].Keys)
	    {
	        "# $controlName $($controlevents[$eventName][$controlName])"
        }
	    "function $eventName"
        '{'
        '}'
        ''	    
	}
	
    if ($PSBoundParameters.ContainsKey("HashTableName"))
    {
        "Show-WpfWindow -XamlPath '$XamlPath' -HashTableName '$HashTableName'"
    }
    else
    {
	    "Show-WpfWindow -XamlPath '$XamlPath'"
    }
}
