
Param(  
    [string]$Username,
    [string]$Password,
    [String]$URL
)

# Create a new IE instance
$ie = New-Object -com internetexplorer.application 
$ie.visible = $true

$ie.navigate($URL)

#wait for the page to load
while ($ie.ReadyState -ne 4)
{
    Start-Sleep -Seconds 1;
}

# If there is an SSL error, click past it.
if ($ie.document.url.contains("SSLError"))
{
    ($ie.Document.getElementsByTagName("a") | where { $_.innerText.toLower().Contains("continue to this website") } | select -first 1).click()

    Start-Sleep -Seconds 1;

    while ($ie.ReadyState -ne 4)
    {
        Start-Sleep -Seconds 1
    }
}

# Enter the username and password and click the 'login' button
$ie.Document.getElementById("user").value = $Username
$ie.Document.getElementByID("pass").value = $Password
($ie.Document.getElementsByTagName("input") | where {$_.Value -eq "Login"}).click()

