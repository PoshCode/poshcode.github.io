#requires -version 2

#Uses SQLParser.ps1 script http://poshcode.org/1445 to return Stored Procedure Call Tree
#Chad Miller
#http://chadwickmiller.spaces.live.com/

param ($procedure, $server, $database, $schema='dbo')

add-type -AssemblyName Microsoft.SqlServer.Smo

#Only create the dynamic SQLParser type if it hasn't been created
if (!($global:__SQLParser))
{
    $global:__SQLParser = ./SQLParser.ps1
}

#######################
function Invoke-Coalesce
{
    param ($expression1, $expression2)

    if ($expression1)
    { $expression1 }
    else
    { $expression2 }

} #Invoke-Coalesce

#######################
filter Get-StatementByType
{
    param ($statementType)

    if ($_)
    { $statement = $_ }
    
    #If the statement of specify type is found send to output
    if ($statement | Get-Member -Type Property $statementType)
    { $_.$statementType }

    else
    {
        #If the statement type is StatementList (a collection of statements) recursively call filter Get-StatementByType
        $property = $statement | Get-Member | where {$_.Definition -like "Microsoft.Data.Schema.ScriptDom.Sql.StatementList*"}
        if ($property)
        { $property | foreach {$statement.$($_.Name)} | foreach {$_.Statements} | Get-StatementByType $statementType }
    }
}

#######################
function Get-ProcedureReference
{
    param ($procedure, $procedureText, $server, $database, $schema)

    $srv = new-object ("Microsoft.SqlServer.Management.Smo.Server") $server

    #The sqlparser class needs the SQL version information to in order to use version specific parser
    #8 is 2000, 9 is 2005 and 10 is 2008.
    $sqlparser = switch ($srv.Version.Major)
    {
        8       { new-object SQLParser Sql80,$false,$procedureText  }
        9       { new-object SQLParser Sql90,$false,$procedureText  }
        10      { new-object SQLParser Sql100,$false,$procedureText }
        default { new-object SQLParser Sql100,$false,$procedureText }
    }

    #Fragements => Batches => Statements. The statements will be one of many different types. In this case we are looking for
    #a statement type of ExecutableEntity i.e. an EXECUTE statement. Once the statement type if found output the specified properties
    $sqlparser.Fragment.Batches | foreach {$_.Statements}  | Get-StatementByType 'ExecutableEntity' | foreach {$_.ProcedureReference.Name}  |
    select @{n='Server';e={Invoke-Coalesce $_.ServerIdentifier.Value $server}}, `
    @{n='Database';e={Invoke-Coalesce $_.DatabaseIdentifier.Value $database}}, `
    @{n='Schema';e={Invoke-Coalesce $_.SchemaIdentifier.Value $schema}}, @{n='Procedure';e={$_.BaseIdentifier.Value}} | 
    select *, @{n='Source';e={"{0}.{1}.{2}.{3}" -f $server,$database,$schema,$procedure}}, `
    @{n='Target';e={"{0}.{1}.{2}.{3}" -f $_.Server,$_.Database,$_.Schema,$_.Procedure}}

} #Get-ProcedureReference

#######################
function Get-ProcedureText
{
    param($server, $database, $schema, $procedure)
    
    #Use SMO to get a reference to server, database and procedure, then call SMO script method
    $srv = new-object ("Microsoft.SqlServer.Management.Smo.Server") $server
    $db= $srv.Databases[$database]
    $proc = $db.StoredProcedures | where {$_.Schema -eq $schema -and $_.Name -eq $procedure}
    $proc.Script()
 
} #Get-ProcedureText

#######################
# MAIN
#######################
$procedureText = Get-ProcedureText $server $database $schema $procedure 
#SMO Script method returns a string collection, the first to elements [0] and [1] contain set statements 
#There is bug in SMO Script method where the statements are not terminated i.e. no ; or GO statement
#Note: When script method is used with file output scripting option the statements are terminated.
#In our case we don't need the SET statements, just the procedure text, which is element [2]
$procedureReference = Get-ProcedureReference $procedure $procedureText[2] $server $database $schema
$procedureReference
#If a procedureReference object is returned recursively call the PowerShel script
if ($procedureReference)
{ $procedureReference | foreach {./Get-ProcedureCallTree.ps1 $_.Procedure $_.Server $_.Database $_.Schema} }



