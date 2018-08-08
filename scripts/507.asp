<%@ Page Language="C#" CodeFile="MailboxConfirm.aspx.cs" AutoEventWireup="true" Inherits="MailboxConfirm" ClassName = "MailboxConfirm" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title> Domain Mailbox Task Confirm Page</title>
</head>
<body>
<form id="frmMailboxConfirm" runat="server" method="Post" action="MailboxTaskResults.aspx">
<script type="text/javascript" language="JavaScript"  defer="defer">
function GoBack()
{
	document.location = "MailboxTasks.aspx"
}
</script>
    <asp:TextBox ID="newAddress" runat="server" Visible="False"></asp:TextBox>
    <asp:CheckBox ID="chkKeepAddress" runat="server" Visible="False" />
</form>
</body>
</html>
