# Get-DominosOrderStatus.psm1
# Author:       xcud.com
#
# Inspired by Dana Merrick's Dominos Pizza Script
# http://shakti.trincoll.edu/~dmerrick/dominos.html

function Get-DominosOrderStatus($phone_number) {
	$url = "http://trkweb.dominos.com/orderstorage/GetTrackerData?Phone=$phone_number"
	[xml]$content = (new-object System.Net.WebClient).DownloadString($url);
	$statii = select-xml -xml @($content) `
			   -Namespace @{dominos="http://www.dominos.com/message/"} `
			   -XPath descendant::dominos:OrderStatus
	if($statii.Count -gt 0) { $statii | %{ $_.Node } }
	else { "No orders" }
}

Export-ModuleMember Get-DominosOrderStatus
