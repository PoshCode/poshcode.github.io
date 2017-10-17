Clear
$error.Clear()
$computador = Read-host "Qual o nome do computador?(ex: SERVIDOR)"
if ($computador -eq '')
{
    $computador = "SERVIDOR"
}
get-wmiobject -computer $computador win32_logicaldisk -filter "drivetype=3" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host Computador: $computador
        Write-Host Disco: $_.deviceid;
        write-host Capacidade do disco: ($_.size/1GB).tostring("0.00")GB;
        write-host Espaço Livre: ($_.freespace/1GB).tostring("0.00")GB
    }
if ($error[0])
{
    Write-host “Ocorreu(am) o(s) seguinte(s) erro(s): `n $error[0]”
} 

