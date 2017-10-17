#Generamos los usuarios por buzon
#Autor: Pedro Genil			
#Fecha: 2014/03/17
#Version: 1.0
# Añadimos modulo
clear-host
If ((Get-PSSnapin | where {$_.Name -match "Exchange.Management"}) -eq $null)
{
	Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
}
#Variables
$fecha = (get-date).toString("yyyyMMdd")
$formatEnumerationLimit = 100
$datos = @()
$Reportiis = "\\$maquinaiis\f$\sites\UbicacionUsuarios\"
#Creamos la pagina de inicio:
$index = @'
<html>
<head>
<title>Historico de Buzones</title>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">
</head>
<body>
<p>
En esta Web encontraras las últimas ubicaciones de los usuarios ordenados por mailboxserver.<br>
</p>
<hr>
<h3>Mailbox Server:</h3>
<table border= 0>
'@
foreach ($mailbox in get-mailboxserver |sort name)
{

$index += "<tr><td><A HREF='http://$ipiis/UbicacionUsuarios/$mailbox.html' TARGET='_new'>$mailbox</A></td></tr>"
    #Creamos la tabla 2
    $tabla002= @'
<html><title>Fecha</title>
<head>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">
</head> 
<body>
'@
    $tabla002 += "<h3>Fecha:</h3>"
    $tabla002 += "<table width='50%' border='0'>"
    #Creamos la tabla
    $notabla = @'
<html><title>Usuarios</title>
<head>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">
</head> 
<body>
'@
    $notabla += "<table width='100%' border='1'>"
    $notabla += "<tr><th>" +  "BBDD" + "</th><th>" + "DISPLAY NAME" +"</th><th>" + "SAM ACCOUNT NAME" + "</th><th>" +  "EMAIL PRIMARIO" + "</th><th>"+  "DIRECCIONES" + "</th></tr>"
    $resultados = Get-Mailbox -resultsize unlimited -server $mailbox.name -ignoredefaultscope | sort name
    foreach ($resultado in $resultados)
    {
        $arr = @()
        $(get-mailbox $resultado.displayname).emailaddresses |% {$arr += $_.smtpaddress}
        $notabla += "<tr><td>" +  $resultado.database.name + "</td><td>" + $resultado.displayname +"</td><td>" +  $($resultado.SamAccountName) + "</td><td>" +  $resultado.primarysmtpaddress + "</td><td>"+  $arr + "</td></tr>"      
        #Guardamos los datos en una variable para luego exportarla a un excel
        $objeto = New-Object PSObject -Property (@{
        BBDD = $resultado.database.name
        DisplayName = $resultado.displayname
        SamAccount = $resultado.SamAccountName
        PrimarySmtp = $resultado.primarysmtpaddress
        Direcciones = ([string]::Join(",",($arr)))
        })
        $datos += $objeto
    }
    $notabla += "</body></table></html>"  
    $notabla > "$Reportiis\$fecha-$mailbox.html"
    #Copiamos los ficheros al IIS
    $ficheros = get-childitem $Reportiis -Filter "*-$mailbox*"
    foreach ($fichero in $ficheros)
    {
        $tabla002 +="<tr><td><A HREF='http://$ipiis/UbicacionUsuarios/$fichero' TARGET='_new'>$fichero</A></td></tr>"
    }    
    $tabla002 += "</body></table></html>" 
    $tabla002 > "$Reportiis\$mailbox.html"
}
$index +="</body></html>"
$index > "$Reportiis\index.html"
#Exportamos a csv
$datos | export-csv F:\Scripts\users_Acount\CSV\$fecha.csv -notype





