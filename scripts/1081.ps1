	[void]([reflection.assembly]::LoadWithPartialName("Microsoft.office.server"))

	$serverContext = [Microsoft.Office.Server.ServerContext]::Default
	$upm = [Microsoft.Office.Server.UserProfiles.UserProfileManager]$serverContext
@@	$upm.psbase.properties | ? { $_.isvisibleonviewer } | select DisplayName, name, displayorder, managedpropertyname | % { "<SPSWC:ProfilePropertyCheckValue PropertyNames=""$($_.Name)"" runat=""server"" Text=""&lt;tr&gt;&lt;td class=&quot;ms-profilelabel&quot;gt;$($_.DisplayName): &lt;/td&gt;&lt;td width=&quot;65%&quot; valign=&quot;top&quot;&gt;""/><SPSWC:ProfilePropertyValue PropertyName=""$($_.name)"" class=""ms-profilevalue"" runat=""server"" /><SPSWC:ProfilePropertyCheckValue PropertyNames=""$($_.Name)"" runat=""server"" Text=""&lt;/td&gt;&lt;/tr&gt;""/>" } >a.txt; ii a.txt

