#  Import the Exchange Web Services module
Import-Module -Name "C:\Program Files\Microsoft\Exchange\Web Services\2.2\Microsoft.Exchange.WebServices.dll"

#  Create the services object used to connect to Exchange
#  You can specify a specific Exchange version, which I had to do to connect to 2007
#  Exchange2007_SP1
#  Exchange2010
#  Exchange2010_SP1
#  Exchange2010_SP2
#  Exchange2013
#  $ExchangeVersion = [Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2007_SP1
#  $Service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService($ExchangeVersion) 
  $Service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService
$Service.UseDefaultCredentials = $true

#  Specify an SMTP address.  The autodiscover URL from the associated mailbox will be used to connect to Exchange
#  Email specified here is used to get which server to query
$Service.AutodiscoverUrl("john@example.com")

#  Increase the amount output at the end to include the SOAP commands
#$Service.TraceEnabled = $true

#  Specify time frame to get free/busy for
#  This will get the next 7 days
$StartTime = [DateTime]::Parse([DateTime]::Now.ToString("yyyy-MM-dd 0:00"))  
$EndTime = $StartTime.AddDays(7)  

#  Create the various objects needed to perform the EWS request
$drDuration = new-object Microsoft.Exchange.WebServices.Data.TimeWindow($StartTime,$EndTime)  
$AvailabilityOptions = new-object Microsoft.Exchange.WebServices.Data.AvailabilityOptions  
$AvailabilityOptions.RequestedFreeBusyView = [Microsoft.Exchange.WebServices.Data.FreeBusyViewType]::DetailedMerged  
$Attendeesbatch = New-Object "System.Collections.Generic.List[Microsoft.Exchange.WebServices.Data.AttendeeInfo]" 
$attendee = New-Object Microsoft.Exchange.WebServices.Data.AttendeeInfo($userSMTPAddress) 

#  Specify SMTP addresses of accounts to request availability for
#$Attendeesbatch.Add("dave@example.com")
#$Attendeesbatch.Add("mike@contoso.com")

#  Clear out old results so that a failed request doesn't show information still
$availresponse = ""
#  Request the availability information from Exchange
$availresponse = $service.GetUserAvailability($Attendeesbatch,$drDuration,[Microsoft.Exchange.WebServices.Data.AvailabilityData]::FreeBusy,$AvailabilityOptions)

#  Show summary information that would include errors
$availresponse.AttendeesAvailability

#  Show all of the appointments in the requested time period
foreach($avail in $availresponse.AttendeesAvailability){
    foreach($cvtEnt in $avail.CalendarEvents){
        "Start : " + $cvtEnt.StartTime
        "End : " + $cvtEnt.EndTime
        "Subject : " + $cvtEnt.Details.Subject
        "Location : " + $cvtEnt.Details.Location
        ""
    }
}

