# New-StoredProcFunction.ps1
# Steven Murawski
# http://blog.usepowershell.com
# 04/08/2009

# Example: ./New-StoredProcFunction.ps1 'Data Source=MySqlServer;Database=Northwind;User=AnythingButSa;Password=abc123' sp_createnewcustomer
# Example 'sp_createnewcustomer | ./New-StoredProcFunction.ps1 'Data Source=MySqlServer;Database=Northwind;User=AnythingButSa;Password=abc123'

param($ConnectionString, [String[]]$StoredProc= $null)
BEGIN
{
	if ($StoredProc.count -gt 0)
	{
		$StoredProc | ./New-StoredProcFunction.ps1 $ConnectionString
	}
	function Get-StoredProcText()
	{
		param ($ProcName, $ConnectionString)
		$query = @'
SELECT ROUTINE_DEFINITION
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_BODY = 'SQL' AND ROUTINE_NAME LIKE '$_'
'@
		$connection = New-Object System.Data.SqlClient.SqlConnection $connectionString
		$command = New-Object System.Data.SqlClient.SqlCommand $query,$connection
		$connection.Open()
		$adapter = New-Object System.Data.SqlClient.SqlDataAdapter $command
		$dataset = New-Object System.Data.DataSet
		[void] $adapter.Fill($dataSet)
		$result = $dataSet.Tables | ForEach-Object {$_.Rows} 
		$connection.Close()
		
		return $Result.ROUTINE_DEFINITION
	}
	function Get-FunctionParameter()
	{
		param ($Text)
		[regex]$EndRegex = '\)\s+AS'
		[regex]$ParamRegex = '@(?<Parameter>\w+?)\s+(?<DataType>\w+(\(\d+\))*)(,|\s+)*(?<Output>out)*'
		$ParamStart = $Text.indexof('(')
		$ParamEnd = $EndRegex.Match($text).index
		$ParamText = $Text.Substring($ParamStart, ($ParamEnd-$ParamStart))
		$RegMatches = $ParamRegex.matches($ParamText)
		foreach ($RegMatch in $RegMatches)
		{
			$Parameter = "" | Select-Object Name, DataType, IsOutput
			$Parameter.Name = $RegMatch.Groups[3].value
			$Parameter.DataType = $RegMatch.Groups[4].Value
			[bool]$Parameter.IsOutput = $RegMatch.Groups[5].Value
			$Parameter
		}
	}
}
PROCESS
{
	if ($_ -ne $null)
	{
		$FunctionName = $_
		$StoredProcText = Get-StoredProcText $FunctionName $ConnectionString
		$Parameters = Get-FunctionParameter $StoredProcText
		
		[String[]]$InputParamNames = $Parameters | where {-not $_.IsOutput} | ForEach-Object {$_.Name}
		[String[]]$OutputParameterNames = $Parameters | Where-Object {$_.IsOutput} | ForEach-Object {$_.Name}
		
		$ScriptText = ' '
		
		if ($InputParamNames.count -gt 0)
		{
			$OFS = ', $'
			$ScriptText += 'param (${0})' -f $InputParamNames
			$ScriptText += "`n" 
			$OFS = ', '
		}
		
		$BodyTemplate = @'
$connection = New-Object System.Data.SqlClient.SqlConnection('{0}')
$command = New-Object System.Data.SqlClient.SqlCommand('{1}', $connection)
$command.CommandType = [System.Data.CommandType]::StoredProcedure

'@
		$ScriptText += $BodyTemplate -f $ConnectionString, $FunctionName
		if ( ($Parameters -ne $null) -or ($Parameters.count -gt 1) )
		{
			
			if ($OutputParameterNames.count -gt 0)
			{
				$ReturnText = "" 
				$CommandOutput = "" | select $OutputParameterNames
			}
			#Add the parameters	
			foreach ($param in $Parameters)
			{
				if ($param.datatype -match '(?<type>\w+)\((?<nbr>\d+)\)')
				{
					$ParamTemplate = '$command.Parameters.Add("@{0}", "{1}", {2})  | out-null ' 
					$ScriptText += "`n" 
					$ScriptText += $ParamTemplate -f $param.name, $matches.type, $matches.nbr
				}
				else
				{
					$ParamTemplate = '$command.Parameters.Add("@{0}", "{1}")  | out-null '
					$ScriptText += "`n" 
					$ScriptText += $ParamTemplate -f $param.name, $param.datatype
				}
				
				if ($param.IsOutput)
				{
					$ScriptText += "`n" 
					$ScriptText += '$command.Parameters["@{0}"].Direction = [System.Data.ParameterDirection]::Output ' -f $param.Name
					$ReturnText += "`n"
					$ReturnText += '$CommandOutput.{0} = $command.Parameters["@{0}"].Value' -f $param.name
				}
				else
				{
					$ScriptText += "`n" 
					$ScriptText += '$command.Parameters["@{0}"].Value = ${0} ' -f $param.name
				}
			}				
		}
		
		$ScriptText += "`n"
		$ScriptText += @'
$connection.Open()  | out-null
$command.ExecuteNonQuery() | out-null

'@	
		if ($OutputParameterNames.count -gt 0)
		{
			$ScriptText += $ReturnText
		}
		
		$ScriptText += @'
		
$connection.Close() | out-null
return $CommandOutput 
'@
		
		#$ScriptText
		Set-Item -Path function:global:$FunctionName -Value $scripttext
	}
}
