# Call WCF Services With PowerShell V1.0 22.12.2008
# 
# by Christian Glessner
# Blog: http://www.iLoveSharePoint.com
# Twitter: http://twitter.com/cglessner
# Codeplex: http://codeplex.com/iLoveSharePoint
#
# requires .NET 3.5

# load WCF assemblies
[void][System.Reflection.Assembly]::LoadWithPartialName("System.ServiceModel")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Runtime.Serialization")

# get metadata of a service
function global:Get-WsdlImporter($wsdlUrl=$(throw "parameter -wsdlUrl is missing"), $httpGet)
{
	if($httpGet -eq $true)
	{
		$local:mode = [System.ServiceModel.Description.MetadataExchangeClientMode]::HttpGet
	}
	else
	{
		$local:mode = [System.ServiceModel.Description.MetadataExchangeClientMode]::MetadataExchange
	}
	
	$mexClient = New-Object System.ServiceModel.Description.MetadataExchangeClient((New-Object System.Uri($wsdlUrl)),$mode)
	$mexClient.MaximumResolvedReferences = [System.Int32]::MaxValue
	$metadataSet = $mexClient.GetMetadata()
	$wsdlImporter = New-Object System.ServiceModel.Description.WsdlImporter($metadataSet)
	
	return $wsdlImporter	
}

# Generate wcf proxy types
function global:Get-WcfProxy($wsdlImporter=$null, $wsdlUrl, $proxyPath)
{
	if($wsdlImporter -eq $null -and $wsdlUrl -eq $null)
	{
		throw "parameter -wsdlImporter or -wsdlUrl must be specified"
	}
	else
	{
		if($wsdlImporter -eq $null)
		{
			$wsdlImporter = Get-WsdlImporter -wsdlUrl $wsdlUrl
			trap [Exception]
			{
				$script:wsdlImporter = Get-WsdlImporter -wsdlUrl $wsdlUrl -httpGet $true
				continue
			}
		}
	}
	
	$generator = new-object System.ServiceModel.Description.ServiceContractGenerator
	
	foreach($contractDescription in $wsdlImporter.ImportAllContracts())
	{
		[void]$generator.GenerateServiceContractType($contractDescription)
	}
	
	$parameters = New-Object System.CodeDom.Compiler.CompilerParameters
	if($proxyPath -eq $null)
	{
		[void]$parameters.GenerateInMemory = $true
	}
	else
	{
		$parameters.OutputAssembly = $proxyPath
	}
	
	$providerOptions = new-object "System.Collections.Generic.Dictionary``2[System.String,System.String]"
	[void]$providerOptions.Add("CompilerVersion","v3.5")
	
	$compiler = New-Object Microsoft.CSharp.CSharpCodeProvider($providerOptions)
	$result = $compiler.CompileAssemblyFromDom($parameters, $generator.TargetCompileUnit);
	
	if($result.Errors.Count -gt 0)
	{
		throw "Proxy generation failed"       
	}
	
	foreach($type in $result.CompiledAssembly.GetTypes())
	{
		if($type.BaseType.IsGenericType)
		{
			if($type.BaseType.GetGenericTypeDefinition().FullName -eq "System.ServiceModel.ClientBase``1" )
			{
				$type
			}
		}
	}
}
