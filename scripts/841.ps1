# ---------------------------------------------------------------------------
### <Script>
### <Author>
### Chad Miller 
### </Author>
### <Description>
### Generates an XSD File with SQLXML annotations for a Powershell object
### The XSD file can be used with SQLXML to automatically create a SQL table
### and import the XML
### </Description>
### <Usage>
### New-Xsd -Object $SqlServerRole -ItemTag ServerRole -Attribute Server,Name,timestamp -ChildItems members
### </Usage>
### </Script>
# ---------------------------------------------------------------------------
param($Object,$ItemTag="ITEM", $ChildItems="*", $Attributes=$Null)

$header =  @"
<?xml version="1.0" ?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:sql="urn:schemas-microsoft-com:mapping-schema">
<xs:element name="ROOT" sql:is-constant="1">
<xs:complexType>
<xs:sequence>
"@

$footer  = @"
</xs:sequence>
</xs:complexType>
</xs:element>
</xs:schema>
"@

#######################
function Get-SqlType
{
    param($definition)

    $type = ([regex]'System\.([^ ]*) ').matches($definition) | %{$_.Groups[1].Value}

    switch ($type)
    {
        "Int64" {"bigint"}
        "Byte[]" {"varbinary"}
        "Boolean" {"bit"}
        "Decimal" {"decimal"}
        "DateTime" {"datetime"}
        "Double" {"float"}
        "Guid" {"uniqueidentifier"}
        "Int32" {"int"}
        "Single" {"real"}
        "Int16" {"smallint"}
        "Byte" {"tinyint"}
        default {"varchar(255)"}
    }
    
}# Get-SqlType

#######################
    $xsd = $header
    $xsd += "`n   <xs:element name=`"$ItemTag`" sql:relation=`"$ItemTag`">`n"
    $xsd += "    <xs:complexType>`n"
    $xsd += "     <xs:sequence>`n"
    $seen = @()
    foreach ($prop in $Object | Get-Member -Type *Property $childItems)
    {
        $Name = $prop.Name
        if (!($seen -contains $Name))
        {
            $seen += $Name
            $xsd += "    <xs:element name=`"$Name`" sql:field=`"$Name`" sql:datatype=`"$(Get-SqlType $prop.Definition)`" />`n"
        }
    }
    $xsd += "    </xs:sequence>`n"
 
    if ($Attributes)
    {
        foreach ($attr in $Object | Get-Member -type *Property $attributes)
        {
            $Name = $attr.Name
            if (!($seen -contains $Name))
            {
                $seen += $Name
                $xsd += "    <xs:attribute name=`"$Name`" sql:field=`"$Name`" sql:datatype=`"$(Get-SqlType $attr.Definition)`" />`n"
            }
        }
    }

    $xsd += "    </xs:complexType>`n"
    $xsd += "   </xs:element>`n"
    $xsd += $footer
    $xsd

