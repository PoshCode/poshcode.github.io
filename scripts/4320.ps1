function Add-ForeachStatement
{
    <#
    .Synopsis
        Adds a Foreach Statement to the current document		   Adds a Foreach Statement to the current document  Adds a Foreach Statement to the current document
    .Description
        Adds a Foreach Statement to the current document
    .Example
        Add-ForeachStatement    
    #>
    param()
	
	process {
		Add-TextToCurrentDocument -Text "foreach (`$item in `$listOfItems) { <# Do Something #> }"	
	}	
}
Add-ForeachStatement
