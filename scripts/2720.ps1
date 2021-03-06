function New-SqlConnectionString {
#.Synopsis
#  Create a new SQL ConnectionString
#.Description
#  Builds a SQL ConnectionString using SQLConnectionStringBuilder with the supplied parameters
#.Example
#  New-SqlConnectionString -Server DBServer12 -Database NorthWind -IntegratedSecurity -MaxPoolSize 4 -Pooling
#.Example
#  New-SqlConnectionString -Server DBServer4 -Database NorthWind -Login SA -Password ""
[CmdletBinding(DefaultParameterSetName='Default')]
PARAM(
   # A full-blown connection string to start from
   [String]${ConnectionString},
   # The name of the application associated with the connection string.
   [String]${ApplicationName},
   # Whether asynchronous processing is allowed by the connection created by using this connection string.
   [Switch]${AsynchronousProcessing},
   # The name of the primary data file. This includes the full path name of an attachable database.
   [String]${AttachDBFilename},
   # The length of time (in seconds) to wait for a connection to the server before terminating the attempt and generating an error.
   [String]${ConnectTimeout},
   # Whether a client/server or in-process connection to SQL Server should be made.
   [Switch]${ContextConnection},
   # The SQL Server Language record name.
   [String]${CurrentLanguage},
   # The name and/or network address of the instance of SQL Server to connect to.
   [Parameter(Position=0)]
   [Alias("Server","Address")]
   [String]${DataSource},
   # Whether SQL Server uses SSL encryption for all data sent between the client and server if the server has a certificate installed.
   [Switch]${Encrypt},
   # Whether the SQL Server connection pooler automatically enlists the connection in the creation thread's current transaction context.
   [Switch]${Enlist},
   # The name or address of the partner server to connect to if the primary server is down.
   [String]${FailoverPartner},
   # The name of the database associated with the connection.
   [Parameter(Position=1)]
   [Alias("Database")]
   [String]${InitialCatalog},
   # Whether User ID and Password are specified in the connection (when false) or whether the current Windows account credentials are used for authentication (when true).
   [Switch]${IntegratedSecurity},
   # The minimum time, in seconds, for the connection to live in the connection pool before being destroyed.
   [Int]${LoadBalanceTimeout},
   # The maximum number of connections allowed in the connection pool for this specific connection string.
   [Int]${MaxPoolSize},
   # The minimum number of connections allowed in the connection pool for this specific connection string.
   [Int]${MinPoolSize},
   # Whether multiple active result sets can be associated with the associated connection.
   [Switch]${MultipleActiveResultSets},
   # The name of the network library used to establish a connection to the SQL Server.
   [String]${NetworkLibrary},
   # The size in bytes of the network packets used to communicate with an instance of SQL Server.
   [Int]${PacketSize},
   # The password for the SQL Server account.
   [AllowEmptyString()]
   [String]${Password},
   # Whether security-sensitive information, such as the password, is returned as part of the connection if the connection is open or has ever been in an open state.
   [Switch]${PersistSecurityInfo},
   # Whether the connection will be pooled or explicitly opened every time that the connection is requested.
   [Switch]${Pooling},
   # Whether replication is supported using the connection.
   [Switch]${Replication},
   # How the connection maintains its association with an enlisted System.Transactions transaction.
   [String]${TransactionBinding},
   # Whether the channel will be encrypted while bypassing walking the certificate chain to validate trust.
   [Switch]${TrustServerCertificate},
   # The type system the application expects.
   [String]${TypeSystemVersion},
   # The user ID to be used when connecting to SQL Server.
   [Alias("UserName","Login")]
   [String]${UserID},
   # Whether to redirect the connection from the default SQL Server Express instance to a runtime-initiated instance running under the account of the caller.
   [Switch]${UserInstance},
   # The name of the workstation connecting to SQL Server.
   [String]${WorkstationID},
   # Whether to return the SqlConnectionStringBuilder for further modification instead of just a connection string.
   [Switch]${AsBuilder}
)
BEGIN {
   if(!( 'System.Data.SqlClient.SqlConnectionStringBuilder' -as [Type] )) {
     $null = [Reflection.Assembly]::Load( 'System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089' ) 
   }
}
PROCESS {
   $Builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder -Property $PSBoundParameters
   if($AsBuilder) {
      Write-Output $Builder
   } else {
      Write-Output $Builder.ToString()
   }
}
}

