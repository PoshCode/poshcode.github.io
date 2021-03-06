function Invoke-JQuery
{
<#
    .SYNOPSIS
        	Function to Invoke JQuery commands via IE COM
        
    .DESCRIPTION
	Invokes JQuery (or plain Javascript) commands via InternetExplorer.Application COM object,
	after initial injection of JQuery reference in header section. 
	Useful to utilize JQuery selectors and functions for IE automation.
    
    .PARAMETER IE
        	Initialized InternetExplorer.Application COM object
    
    .PARAMETER Command
        	JQuery/Javascript to Invoke
		
    .PARAMETER Function
        	Function to add in header section
        
    .PARAMETER Initialize
        	Switch to initially inject JQuery in header section.
        
    .EXAMPLE  
	$ie = new-object -com internetexplorer.application
	$ie.visible = $true
	$ie.navigate2("http://www.example.com")
	# Wait for page load
	while($ie.busy) {start-sleep 1}
	#add addtional div to store results
	$div="<div id='myResult'>"
	$ie.Document.body.innerHTML += $div
	#hide anchor tags
	Invoke-JQuery $ie '$("a").hide();' -Initialize
	#change innerhtml of div
	Invoke-JQuery $ie 'var str=$("p:first").text();$("#myResult").html(str);'
	#retrieve the value
	$result = $ie.document.getElementById("myResult").innerHtml
	$jFunc=@"
	function SelectText(element) { 
		var text = document.getElementById(element); 
		var range = document.body.createTextRange(); 
		range.moveToElementText(text); 
		range.select(); 
	}
	"@
	Invoke-JQuery $ie -Function $jFunc
	Invoke-JQuery $ie 'SelectText("myResult");'  
#>
    [cmdletbinding()]
    param(
        [parameter(position=0, mandatory=$true)]
        $IE,
		
        [parameter(position=1,mandatory=$false)]
        $Command,
		
        [parameter()]
        $Function,
        
        [parameter()]
        [switch]$Initialize
    )
	if ($Initialize -or $Function){
		$url='http://code.jquery.com/jquery-1.4.2.min.js'
		$document = $IE.document 
		$head = @($document.getElementsByTagName("head"))[0] 
		$script = $document.createElement('script') 
		$script.type = 'text/javascript'
	}
    
	if ($Initialize){
		$script.src = $url 
		$head.appendChild($script) | Out-Null
	}

	if ($Command){$IE.document.parentWindow.execScript("$Command","javascript")}

	if ($Function){
		$script.text = $Function
		$head.appendChild($script) | Out-Null
	}
}
