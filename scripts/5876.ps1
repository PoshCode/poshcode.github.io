<#
Script written to parse Event Log Entries to make usable Windows Event log filtering xpath for Windows Event Filters and Windows Eventlog Forwarding
Finds all Nodes and Attributes that are not empty and not null and then recurses 3 levels up to find the 'Event' node and writes out the correct xpath
This includes replacing tabs and carriage returns in the #text of the node which do not transport properly to an event filter via copy/paste
Written 5/22/2015 - Kurt Falde
#>


$EventRecordIDToParse = "3139115"
$xpath =  "*[System[EventRecordID=($EventRecordIDtoparse)]]"
$EventToParse = Get-WinEvent -LogName 'Security' -FilterXPath "$xpath"
[xml]$EventToParsexml = $EventToParse.ToXml()
$nodes = $EventToParsexml | Select-Xml -XPath './/*'
Foreach ($node in $nodes){

#Parse Nodes that are not empty, not null and do not have attributes
if (($node.node.IsEmpty -eq $false) -and ($node.node.'#text' -ne $null) -and ($node.node.HasAttributes -eq $false)){ 
    
    $Ntext = $node.Node.'#text'
    #write-Host $Ntext
    $Ntext = $Ntext.Replace("`n", "&#xD;&#xA;").Replace("`t", "&#x09;")
    #write-host $Ntext
    $Nname = $node.Node.Name
    #write-host $Nname
    if($node.node.Parentnode.ParentNode.Name -eq "Event"){
    write-host "*[$($node.node.Parentnode.name)[($Nname=$Ntext)]]"}
    if($node.node.Parentnode.ParentNode.ParentNode.Name -eq "Event"){
    write-host "*[$($node.node.ParentNode.Parentnode.name)[$($node.node.parentnode.name)[($Nname=$Ntext)]]]"}
    if($node.node.Parentnode.ParentNode.ParentNode.Parentnode.Name -eq "Event"){
    write-host "*[$($node.node.ParentNode.Parentnode.Parentnode.name)[$($node.node.ParentNode.Parentnode.name)[$($node.node.parentnode.name)[($Nname=$Ntext)]]]]"}
  }


#Parses nodes that are not empty, not null and have attributes
if (($node.node.IsEmpty -eq $false) -and ($node.node.'#text' -ne $null) -and ($node.node.HasAttributes -eq $true)){ 
    $Ntext = $node.Node.'#text'
    #write-Host $Ntext
    $Ntext = $Ntext.Replace("`n", "&#xD;&#xA;").Replace("`t", "&#x09;")
    #write-host $Ntext
    $Nname = $node.Node.Name
    #write-host $Nname
    # *[EventData[Data[@Name='Properties'] and (Data='%%7688&#x
    if($node.node.Parentnode.ParentNode.Name -eq "Event"){
    write-host "*[$($node.node.Parentnode.name)[$($node.node.LocalName)[@Name='$Nname'] and ($($node.node.LocalName)='$Ntext')]]"}
    if($node.node.Parentnode.ParentNode.ParentNode.Name -eq "Event"){
    write-host "*[$($node.node.ParentNode.Parentnode.name)[$($node.node.parentnode.name)[($Nname=$Ntext)]]]"}
    if($node.node.Parentnode.ParentNode.ParentNode.Parentnode.Name -eq "Event"){
    write-host "*[$($node.node.ParentNode.Parentnode.Parentnode.name)[$($node.node.ParentNode.Parentnode.name)[$($node.node.parentnode.name)[($Nname=$Ntext)]]]]"}
    }


#Parses nodes that are empty/null but have attributes
if (($node.node.IsEmpty -ne $false) -and ($node.node.'#text' -eq $null) -and ($node.node.HasAttributes -eq $true)){ 
    $AttributeText = ""
    $Attributes = $node.node.Attributes
    Foreach($Attribute in $Attributes){
    $AttrName = $Attribute.Name
    $AttrText = $Attribute.'#text'
    $AttributeText += "@$AttrName='$AttrText' and "
    #write-host $AttributeText
    }
    $AttributeText = $AttributeText.TrimEnd(" and ")
    $Nname = $node.Node.Name
    if($node.node.Parentnode.ParentNode.Name -eq "Event"){
    write-host "*[$($node.node.Parentnode.name)[$($node.node.LocalName)[$AttributeText]]"}
    if($node.node.Parentnode.ParentNode.ParentNode.Name -eq "Event"){
    write-host "*[$($node.node.ParentNode.Parentnode.name)[$($node.node.parentnode.name)[$AttributeText]]]"}
    if($node.node.Parentnode.ParentNode.ParentNode.Parentnode.Name -eq "Event"){
    write-host "*[$($node.node.ParentNode.Parentnode.Parentnode.name)[$($node.node.ParentNode.Parentnode.name)[$($node.node.parentnode.name)[$AttributeText]]]]"}
    }

}

