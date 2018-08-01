Invoke-Sqlcmd2 : Cannot process argument transformation on parameter 'ConnectionString'. Cannot convert the "System.Col
lections.Hashtable" value of type "System.Collections.Hashtable" to type "System.Data.SqlClient.SqlConnectionStringBuil
der".
At C:\Users\1\Desktop\1.ps1:64 char:39
+       Invoke-Sqlcmd2 -ConnectionString <<<<  $Connection -Query $Query
    + CategoryInfo          : InvalidData: (:) [Invoke-Sqlcmd2], ParameterBindin...mationException
    + FullyQualifiedErrorId : ParameterArgumentTransformationError,Invoke-Sqlcmd2
