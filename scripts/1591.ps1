###########################################################################
# Get-OLEDBData
# --------------------------------------------
# Description: This function is used to retrieve data via an OLEDB data
#              connection.
#
# Inputs: $connectstring  - Connection String.
#         $sql            - SQL statement to be executed to retrieve data.
# 
# Usage: Get-OLEDBData <connction string> <SQL statement>
#
#Connection String for Excel 2007:
#"Provider=Microsoft.ACE.OLEDB.12.0;Data Source=`"$filepath`";Extended Properties=`"Excel 12.0 Xml;HDR=YES`";"
#Connection String for Excel 2003:
#"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=`"$filepath`";Extended Properties=`"Excel 8.0;HDR=Yes;IMEX=1`";"
#Excel query
#'select * from [sheet1$]'
#Informix
#"password=$password;User ID=$userName;Data Source=$dbName@$serverName;Persist Security Info=true;Provider=Ifxoledbc.2"
#Oracle
#"password=$password;User ID=$userName;Data Source=$serverName;Provider=OraOLEDB.Oracle"
#SQL Server
#"Server=$serverName;Trusted_connection=yes;database=$dbname;Provider=SQLNCLI;"
###########################################################################
function Get-OLEDBData ($connectstring, $sql) {
   $OLEDBConn = New-Object System.Data.OleDb.OleDbConnection($connectstring)
   $OLEDBConn.open()
   $readcmd = New-Object system.Data.OleDb.OleDbCommand($sql,$OLEDBConn)
   $readcmd.CommandTimeout = '300'
   $da = New-Object system.Data.OleDb.OleDbDataAdapter($readcmd)
   $dt = New-Object system.Data.datatable
   [void]$da.fill($dt)
   $OLEDBConn.close()
   return $dt
}
