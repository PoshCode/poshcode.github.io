# by @bernd_k aka @sqlsulidae  http://sqlsulidae.blogspot.com/            
#             
            
# This is an extension of the script you find at            
# http://www.sqlmusings.com/2009/08/21/sql-server-powershell-how-to-view-your-ssrs-reports-rdl-using-powershell-and-reportviewer/            
# I show how to provide parameters and how to catch the navigate event            
            
            
# [void]             
 [System.Reflection.Assembly]::Load("Microsoft.ReportViewer.WinForms, Version=10.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")            
            
             
$rv = New-Object Microsoft.Reporting.WinForms.ReportViewer            
            
$eventHandler = [Microsoft.Reporting.WinForms.HyperlinkEventHandler]{            
    #$this                        #  $this is sender            
    Write-Host "Hyperlink Event fired"            
    Write-Host $_.Hyperlink       # $_ are the event args            
    $_.Cancel = $true                   
    }             
$rv.Add_Hyperlink($eventHandler)             
            
$rv.ProcessingMode = "Remote"            
$rv.ServerReport.ReportServerUrl = "http://localhost/reportserver"            
$rv.ServerReport.ReportPath = "/Reports/Sample Report"            
             
#if you need to provide basic credentials, use the following            
#$rv.ServerReport.ReportServerCredentials.NetworkCredentials=             
#    New-Object System.Net.NetworkCredential("myuser", "mypassword")            
             
$rv.Height = 800            
$rv.Width = 1200            
$rv.Dock = [System.Windows.Forms.DockStyle]::Fill            
            
# if you have more than 1 parameters            
# $params = new-object 'Microsoft.Reporting.WinForms.ReportParameter[]' 2            
# $params[0] = new-Object Microsoft.Reporting.WinForms.ReportParameter("Par1", "3159", $false)            
# $params[1] = new-Object Microsoft.Reporting.WinForms.ReportParameter("par2", "3159", $false)            
            
# my report has only 1 parameter            
$params = new-object 'Microsoft.Reporting.WinForms.ReportParameter[]' 1            
$params[0] = new-Object Microsoft.Reporting.WinForms.ReportParameter("Par1", "3159", $false)            
            
$rv.ServerReport.SetParameters($params);            
            
            
            
$rv.ShowParameterPrompts = $false            
$rv.RefreshReport()            
             
#--------------------------------------------------------------            
#Show as Dialog Using Windows Form            
#--------------------------------------------------------------            
#create a new form            
$form = New-Object Windows.Forms.Form            
             
#we're going to make it just slightly bigger than             
$form.Height = 810            
$form.Width= 1210            
$form.Controls.Add($rv)            
$rv.Show()            
$form.ShowDialog()            
            
            
<#
http://blogs.msdn.com/b/powershell/archive/2008/05/24/wpf-powershell-part-3-handling-events.aspx
http://social.msdn.microsoft.com/Forums/en-US/vsreportcontrols/thread/693694bc-bfbc-4786-98ee-a99826e78739
#>
