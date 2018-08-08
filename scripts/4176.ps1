function New-ObjectFromGenericType {
	<#
		.SYNOPSIS
			Get an instances of a Generic Type.

		.DESCRIPTION
			Get an instances of a Generic Type.
			
			For examples List<Int> where ClassName is List and TypeName is Int. This is just an example as
			Powershell can manage dynamic collections nativly.

		.PARAMETER  ClassName
			This is the name of the generic class.

		.PARAMETER  TypeName
			This is the name of the type parameter.

		.EXAMPLE
			PS C:\> $serializer = New-ObjectFromGenericType "YamlDotNet.RepresentationModel.Serialization.YamlSerializer" "Models.CustomModelClass"

		.INPUTS
			System.String,System.String[]

		.OUTPUTS
			System.Object

		.LINK
			about_functions_advanced

		.LINK
			http://msdn.microsoft.com/en-us/library/system.activator.aspx
			
		.FUNCTION
			Helper

	#>
	
	[CmdletBinding()]
	[OutputType([System.Object])]
	param(
		[Parameter(Position=0, Mandatory)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$ClassName,

		[Parameter(Position=1, Mandatory)]
		[ValidateNotNull()]
		[System.String[]]
		$TypeName
	)
	try {
		$classType = ($ClassName+'`'+$TypeName.Count) -as "Type"
	
		if ($classType -ne $null)
		{				
			$typeParameter = @()
			foreach ($name in $TypeName)
			{
				try
				{
					$typeParameter += ($name -as "Type")
				}
				catch
				{
					Write-Error -Message "Type is not accessible in this session" -TargetObject $name
				}
			}		
			$typeObject = $classType.MakeGenericType($typeParameter)		
			$objectInstance = [Activator]::CreateInstance($typeObject)		
			Write-Output $objectInstance		
		}
		else
		{
			Write-Warning "$ClassName is not accessible in this session."
		}
	}
	catch {
		Write-Error -Message $_.Exception.Message
	}
}
