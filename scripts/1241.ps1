$forest = [DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$Schema = $forest.schema 
$Properties = $Schema.FindAllProperties()
foreach($property in $Properties)
{
   "#################################"
   "Name:   {0}" -f $property.Name
   "Link:   {0}" -f $property.link
   "LinkID: {0}" -f $property.linkid
   if(!$?)
   {
        "Error: {0}" -f $error[0].message
   }
   "#################################"
}
