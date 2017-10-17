#Sacamos los dispositivos asociados a cada mailbox
#Verificamos su ultima conexión o si alguna vez no se han conectado
#Autor: Pedro Genil
#Fecha:23/11/2012
#Version: 1.0
If ((Get-PSSnapin | where {$_.Name -match "Exchange.Management"}) -eq $null)
{
	Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
}
#Select-Object Identity, DeviceFriendlyName, Devicetype, DeviceUserAgent, FirstSyncTime, LastSuccessSync
$mailbox = Get-MailboxServer
$fecha = get-date 
$fecha= $fecha.adddays(-30).ToString("yyyyMMdd")
#Recorremos todos los mailbox
foreach ($mail in $mailbox)
{
$a=0
$b=0
echo "Analizando $mail" >> resultado.txt
$devices = Get-Mailbox -server $mail -resultsize unlimited| ForEach {Get-ActiveSyncDeviceStatistics -Mailbox:$_.Identity} 
#Recorremos los dispositivos de cada usuario
foreach ($device in $devices)
   {
     if($device.LastSuccessSync -ne $NULL)
          {
           if ($device.LastSuccessSync.ToString("yyyyMMdd") -gt $fecha)
            {$a=$a+1}
          }
           else
            {$b=$b+1}
          }
echo "Numero de dispositivos nunca conectados en $mail $b" >> resultado.txt
echo "Numero de dispositivos conectados en los ultimos 30 dias en $mail $a" >> resultado.txt           
}     

