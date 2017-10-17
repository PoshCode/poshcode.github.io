#Copyright (c) 2011 Justin Dearing
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

param(
    [Parameter(Mandatory=$true, HelpMessage='The name of the database object we wish to script')]
    [string] $ObjectName,
    [string] $Path = "$($ObjectName).sql",
    [string] $ConnectionString = 'Data Source=.\sqlexpress2k8R2;Initial Catalog=master;Integrated Security=SSPI;',
    [string] $AtlantisSchemaEngineBaseDir = 'F:\src\Atlantis.SchemaEngine\' # Adjust for your environment
);

Add-Type -Path "$($AtlantisSchemaEngineBaseDir)\Atlantis.SchemaEngine\bin\Debug\Atlantis.SchemaEngine.dll"
$schemaReader = [Atlantis.SchemaEngine.Container.SQLServer.SQLServerSchemaReaderFactory]::GetSpecificSQLServerSchemaReader($ConnectionString, [Atlantis.SchemaEngine.Enumerations.ContainerMode]::Navigation)
$dbObjects = $schemaReader.ReadObjects() | Where-Object { $_.ObjectName,$_.ObjectDesriptiveName,$_.ObjectQualifiedName -contains $ObjectName };
if ($dbObjects -eq $null) {
    Throw New-Object System.ArgumentException "Object `"$($ObjectName)`" not found.",'-ObjectName';
}
$dbObjects.Script([Atlantis.SchemaEngine.Enumerations.ScriptGenerationType]::Create, (New-Object Atlantis.SchemaEngine.Configuration.GenerationOptions)).Scripts
