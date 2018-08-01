function Set-WebConfigSqlConnectionString {
	param(  [switch]$help,
	        [string]$configfile = $(read-host "Please enter a web.config file to read"),
	        [string]$connectionString = $(read-host "Please enter a connection string"),
	        [switch]$backup = $TRUE	
		)
	
	$usage = "`$conString = `"Data Source=MyDBname;Initial Catalog=serverName;Integrated Security=True;User Instance=True`"`n"
	$usage += "`"Set-WebConfigSqlConnectionString -configfile `"C:\Inetpub\wwwroot\myapp\web.config`" -connectionString `$conString"
	if ($help) {Write-Host $usage}
	
	
	$webConfigPath = (Resolve-Path $configfile).Path 
	$backup = $webConfigPath + ".bak"

	# Get the content of the config file and cast it to XML and save a backup copy labeled .bak
	$xml = [xml](get-content $webConfigPath)

	#save a backup copy if requested
	if ($backup) {$xml.Save($backup)}

	$root = $xml.get_DocumentElement();
	$root.connectionStrings.add.connectionString = $connectionString
	# Save it
	$xml.Save($webConfigPath)
	
	}

