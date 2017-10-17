﻿#Generamos los usuarios por buzon y comprimimos el resultado
#Autor: Pedro Genil
#Fecha: 2012/11/21
#Version: 1.0
# Añadimos modulo
If ((Get-PSSnapin | where {$_.Name -match "Exchange.Management"}) -eq $null)
{
	Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
}
# Creamos el alias para el 7zip
if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) {throw "$env:ProgramFiles\7-Zip\7z.exe needed"} 
set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"
#Directorios
$filePath = 'F:\Scripts\users_Acount\'
$fecha = get-date 
$fecha= $fecha.toString("yyyyMMdd")
$filedate = $fecha
$info = Get-Mailbox -resultsize unlimited -ignoredefaultscope |select database,displayname,samaccountname,PrimarySmtpAddress,EmailAddresses -expandproperty EmailAddresses | out-file F:\Scripts\users_Acount\$filedate.txt
$files = Get-ChildItem -Recurse -Path $filePath | Where-Object { $_.name -eq "$fecha.txt" }

#Cogemos el fichero , y creamos el zip
sz a "F:\Scripts\users_Acount\$fecha.zip" "$filepath\$files"
#Borramos el txt
remove-item "F:\Scripts\users_Acount\$filedate.txt"
#foreach ($file in $files)
#{

#                    $name = $file.name 
#                    $directory = $file.DirectoryName 
#                    sz a "F:\Scripts\users_Acount\$zipfile.zip" "$directory\$name"      
       

#}

