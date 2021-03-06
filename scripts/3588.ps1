param
(
	[Parameter(
		Mandatory=$true,
		Position = 0,
		ValueFromPipeline=$true,
		HelpMessage="Specifies the path to the IIS *.log file to import. You can also pipe a path to Import-Iss-Log."
	)]
	[ValidateNotNullOrEmpty()]
	[string]
	$Path,
	
    [Parameter(
		Mandatory=$true,
		Position = 1,
		ValueFromPipeline=$true,
		HelpMessage="Specifies the desired field names. Must be in the following format: #Fields: fname1 fname2"
	)]
	[ValidateNotNullOrEmpty()]
	[string]
	$NewPath,
    
    [Parameter(
		Mandatory=$true,
		Position = 2,
		ValueFromPipeline=$true,
		HelpMessage="Specifies the output location for the modified log file."
	)]
	[ValidateNotNullOrEmpty()]
	[string]
	$OutPath,
    
	[Parameter(
		Position = 3,
		HelpMessage="Specifies the delimiter that separates the property values in the IIS *.log file. The default is a spacebar."
	)]
	[ValidateNotNullOrEmpty()]
	[string]
	$Delimiter = " ",
	
	[Parameter(HelpMessage="The character encoding for the IIS *log file. The default is the UTF8.")]
	[Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]
	$Encoding = [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]::UTF8
    
)
	
begin
	{
		$fieldNames = @()
		$newfieldnames = @() 
	}

process
	{

		#add headers to new output file
		 (get-content $path)[0..2] | Out-File $outpath -Append -encoding Default
		 $newpath | Out-File $outpath -Append -encoding Default
		
		#populate $newfieldnames from the mandatory parameter $newpath
		$newfieldNames = @($newpath.Substring("#Fields: ".Length).Split($Delimiter));
		
		  
	   
	foreach($line in Get-Content -Path $Path)
		{
	  # Indentify / parse the log header to determine field names
		if($line.StartsWith("#Fields: "))
			{
				$fieldNames = @($line.Substring("#Fields: ".Length).Split($Delimiter));
	   
			}
			
		# Identify / parse the "non log header" lines to determine field values
		elseif(-not $line.StartsWith("#"))
			{
			   $logline = ""
				
			   $fieldValues = @($line.Split($Delimiter));
					
                #Initialize a hashtable to hold fields and values
                #Default value is a hyphen
                #Only fields specified in the $newpath parameter are initialized
                
				$output = @{}
				foreach ($item in $newfieldnames)
					{
							switch($item)
							{
								"date"{ $output.add("date", "-")}
								"time"{ $output.add("time", "-")}
								"s-ip"{ $output.add("s-ip", "-")}
								"cs-method"{ $output.add("cs-method", "-")}
								"cs-uri-stem"{ $output.add("cs-uri-stem", "-")}
								"cs-uri-query"{ $output.add("cs-uri-query", "-")}
								"s-port"{ $output.add("s-port", "-")}
								"cs-username"{ $output.add("cs-username", "-")}
								"c-ip"{ $output.add("c-ip", "-")}
								"cs-version"{ $output.add("cs-version", "-")}
								"cs(User-Agent)"{ $output.add("cs(User-Agent)", "-")}
								"sc-status"{ $output.add("sc-status", "-")}
								"sc-substatus"{ $output.add("sc-substatus", "-")}
								"sc-win32-status"{ $output.add("sc-win32-status", "-")}
								"sc-bytes"{ $output.add("sc-bytes", "-")}
								"time-taken"{ $output.add("time-taken", "-")}
								"cs-host"{ $output.add("cs-host", "-")}
								"cs(Cookie)"{ $output.add("cs(Cookie)", "-")}
								"cs(Referer)"{ $output.add("cs(Referer)", "-")}
								"s-sitename"{ $output.add("s-sitename", "-")}
								"s-computername"{ $output.add("s-computername", "-")}
								"cs-bytes"{ $output.add("cs-bytes", "-")}
							}
					}

				
                #Add every field from old log file to the $ouptuts hashtable
                #Portions of the hash table which are not over written at this point retain the default value (hyphen)
				for($i = 0; $i -lt $fieldnames.Length; $i++)
					{
						$name = $fieldNames[$i]
						$value = $fieldValues[$i]
								 
							

								switch($name)
								{
							  
								"date"{ $output['date'] = $value}
								"time"{ $output['time'] = $value}
								"s-ip"{ $output['s-ip'] = $value}
								"cs-method"{ $output['cs-method'] = $value}
								"cs-uri-stem"{ $output['cs-uri-stem'] = $value}
								"cs-uri-query"{ $output['cs-uri-query'] = $value}
								"s-port"{ $output['s-port'] = $value}
								"cs-username"{ $output['cs-username'] = $value}
								"c-ip"{ $output['c-ip'] = $value}
								"cs-version"{ $output['cs-version'] = $value}
								"cs(User-Agent)"{ $output['cs(User-Agent)'] = $value}
								"sc-status"{ $output['sc-status'] = $value}
								"sc-substatus"{ $output['sc-substatus'] = $value}
								"sc-win32-status"{ $output['sc-win32-status'] = $value}
								"sc-bytes"{ $output['sc-bytes'] = $value}
								"time-taken"{ $output['time-taken'] = $value}
								"cs-host"{ $output['cs-host'] = $value}
								"cs(Cookie)"{ $output['cs(Cookie)'] = $value}
								"cs(Referer)"{ $output['cs(Referer)'] = $value}
								"s-sitename"{ $output['s-sitename'] = $value}
								"s-computername"{ $output['s-computername'] = $value}
								"cs-bytes"{ $output['cs-bytes'] = $value}
								}
								   
								
					}
							
				#$output 
				$linewriter = $null
                #Write lines to new log file
                #Only call upon keys (from output hash) which correspond to desired $newfieldnames as specified in $newpath parameter.
                #Unwanted fields from old log are inherently dropped
                #Newly included fields not present in old log are inherently replaced by hypens
				foreach ($item in $newfieldnames) 
				 
					{
						$linewriter += $output[$item]
						$linewriter += " "
					} 
				 
				$linewriter |%{$_ -replace " $",""}| Out-File $outpath -Append -encoding Default 
							 
			}
		}
	}

# usage example
#.\import-iislog-final.ps1 "C:\Old Logs\u_ex120218.log" "#Fields: date time s-ip cs-method cs-uri-stem cs-uri-query s-port cs-username c-ip cs-version cs(User-Agent) cs(Referer) sc-status sc-substatus sc-win32-status sc-bytes time-taken" "C:\Revised Logs\u_ex120218.log"
#foreach ($log in (gci "c:\Old Logs")) {.\import-iislog-final.ps1 $log.fullname "#Fields: date time s-ip cs-method cs-uri-stem cs-uri-query s-port cs-username c-ip cs-version cs(User-Agent) cs(Referer) sc-status sc-substatus sc-win32-status sc-bytes time-taken" "C:\Revised Logs\$log"}
                                                                        
