# ---------------------------------------------------------------------------
### <Script>
### <Author>
### Chad Miller 
### </Author>
### <Description>
### Reports data model directories and bool value as to whether they have
### an htm file of the same name as the project directory.
### </Description>
### <Usage>
### ./Write-FileInfoToSQL.ps1
### </Usage>
### </Script>
# ---------------------------------------------------------------------------

$sqlserver = 'SQL1' 
$dbname = 'DataAdmin'
$tblname = 'data_model_fill'

#######################
function Clear-Fill
{

    $connString = "Server=$sqlserver;Database=$dbname;Integrated Security=SSPI;"
    $conn = new-object System.Data.SqlClient.SqlConnection $connString
    $conn.Open()
    $cmd = new-object System.Data.SqlClient.SqlCommand("TRUNCATE TABLE $tblname", $conn)
    $cmd.ExecuteNonQuery()
    $conn.Close()

} #Clear-Fill

#######################
function Out-DataTable 
{
    param($Properties="*")
    Begin
    {
        $dt = new-object Data.datatable  
        $First = $true 
    }
    Process
    {
        $DR = $DT.NewRow()  
        foreach ($item in $_ |  Get-Member -type *Property $Properties ) {  
          $name = $item.Name
          if ($first) {  
            $Col =  new-object Data.DataColumn  
            $Col.ColumnName = $name
            $DT.Columns.Add($Col)
          }  
            $DR.Item($name) = $_.$name  
        }  
        $DT.Rows.Add($DR)  
        $First = $false  
    }
    End
    {
        return @(,($dt))
    }

}# Out-DataTable 

#######################
function Write-DataTableToDatabase
{ 
    param($destServer,$destDb,$destTbl)
    process
    {
        $connectionString = "Data Source=$destServer;Integrated Security=true;Initial Catalog=$destdb;"
        $bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $connectionString
        $bulkCopy.DestinationTableName = "$destTbl"
        $bulkCopy.WriteToServer($_)
    }

}# Write-DataTableToDatabase

#######################
Clear-Fill
get-childitem "\\z001.contoso.com\wwwroot`$\Playbook\Databases\DataModels" | where {$_.PSIsContainer -eq $true} | select name, @{name='htm';Expression={test-path "\\z001.contoso.com\wwwroot`$\Playbook\Databases\DataModels\$($_.Name)\$($_.Name).htm"}}, @{name='lastWrite';Expression={if (test-path "\\z001.contoso.com\wwwroot`$\Playbook\Databases\DataModels\$($_.Name)\$($_.Name).htm") {$last = Get-Item "\\z001.contoso.com\wwwroot`$\Playbook\Databases\DataModels\$($_.Name)\$($_.Name).htm" | Select LastWriteTime;$last.LastWriteTime}}} |  
Out-DataTable | Write-DataTableToDatabase $sqlserver $dbname $tblname 


