﻿# Version:	0.1
# Author:	Stefan Stranger
# Description:	Retrieve Dell Order Status
# Start Page Order Status USA: https://support.dell.com/support/order/status.aspx?c=us&cs=19&l=en&s=dhs&~ck=pn
# Start Page Order Status EMEA(nl): http://support.euro.dell.com/support/index.aspx?c=nl&l=nl&s=gen&~ck=bt
# Example Dell Order Status URL: http://support.euro.dell.com/support/order/emea/OrderStatus.aspx?c=nl&l=nl&s=gen&ir=[IR Number]&ea=[emailaddress]'

#param ([string]$url = $(read-host "Please enter Dell Order Status URL"))
$wc = New-Object System.Net.WebClient
$url = 'http://support.euro.dell.com/support/order/emea/OrderStatus.aspx?c=nl&l=nl&s=gen&ir=NL0131-8510-29070&ea=stefan.stranger@getronics.com'
$RawResult = $wc.DownloadString($url)

# $RawResult = gc orderstatus.txt
# Search for the Estimated Delivery Date in the url that starts with the word "lever" (Levering is the Dutch word for Delivery" and 
# and ends with </B></TD></TR>
# You should probable need to change the string "Lever" in "Deliv" or something
$r = New-Object regex('Lever.*?(\d+-\d+-\d{4})</B></TD></TR>','SingleLine' )
# String block with the Estimated Delivery Date
$m = $r.Matches($RawResult)
# Extract Delivery Date from string block
$date = ($m |% {$_.groups[1].value })
# Search for Current Order Status ("In preproduction" is Dutch for "In preproduction"
$r = New-Object regex('target="popup:640x480">(.*?)</a>'  )
$m = $r.Matches($RawResult)
$status = ($m |% {$_.groups[1].value }) 
$Orderstatus = 1 | select @{name='Status';expression={$status[0]}},@{name='Estimated Delivery Date';expression={$date}}
$Orderstatus | ft -a
#[string]$output = $orderstatus
$startdate = "16-09-2007"
$startdate
$currentdate = (get-date).ToString('MM-dd-yyyy')
$currentdate
$date
