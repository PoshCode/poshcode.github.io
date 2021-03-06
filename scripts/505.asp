<%@ Page Language="C#" AutoEventWireup="true" CodeFile="mailboxTasks.aspx.cs" Inherits="mailboxTasks" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title> Domain Exchange Mailbox Tasks</title>
</head>
<body>
<p>
<b>This page is for all domain accounts.</b><br />
<br />
Enter the Logon ID of the user/mailbox that you want to modify.<br /><br />
If you are logged into your workstation with  domain credentials, we will use those for security checks.<br />
If you are not logged in with  domain credentials, you will see a prompt for them.
</p>
<form method="Post" action="MailboxConfirm.aspx" runat="server" id ="frmMailboxTasks">
<table>
<tr>
<td>User's Logon ID:</td> 
<td><input type="Text" name="txtTargName" /></td>
</tr>
<tr>
<td><input type="radio" name="rdoMailboxAction" value="Create Mailbox" checked="checked" />Create Mailbox</td>
<td><input type="radio" name="rdoMailboxAction" value="Delete Mailbox" />Delete Mailboxt</td>
<td><input type="radio" name="rdoMailboxAction" value="Change Address" />Change Address</td>
</tr>
<tr>
<td colspan="2"><asp:Button ID="btnNext" Text="Next" Runat="server"></asp:Button></td>
</tr>
</table>
</form>
<hr />
<p>
<b>Information about Creating Mailboxes</b><br />
<b><span style='color:Red'>IMPORTANT:</span></b> You must create the user object before you can mailbox-enable it.<br />
The user object must have values for the agency and last name fields. If these are blank, you will not be able to create a mailbox for the user.<br /> 
The agency information should be your agencies three-letter acronym."<br /> 
You need to set this on the user object in Active Directory; find the user object, open the properties, then click on the Organization tab and put your agency acronym in the Company field.<br />
    <br />
Also, please allow several minutes between creating a user object in Active Directory and trying to set up a mailbox.
This will give the new user object time to replicate amongst all of the domain controllers.<br />
    <br />
Exchange 2007 will automatically assign an internet email address for the user. Typically, this will be in the "standard" form: jdoe@domain.com for Jane Doe.<br />
However, if the "standard" email address is already in use, Exchange will set up a non-standard address such as jdoe2@domain.com.<br />
Please check the email address on the mailbox after it's created to see if it is in the correct format.
 If not, contact the Customer Support Center at x2000 and we will set the address to our fall-back standard: jadoe@domain.com.<br />
You can check the email address assigned to the user by pulling up the properties of the user object in Active Directory and looking at the E-mail attribute on the General tab.<br /><br />
<b>Information about Deleting Mailboxes</b><br />
There are two possible scenarios related to deleting an Exchange mailbox:<br />
1) You don't want to keep the mailbox OR the Active Directory user account. In this case, simply delete the user account from Active Directory. This will simultaneously delete the mailbox.<br />
2) You don't want to keep the mailbox, but you DO want to keep the Active Directory user account. In this case, use this page and select "Delete Mailbox"<br />
</p>
</body>
</html>

