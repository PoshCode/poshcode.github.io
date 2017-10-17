public partial class MailboxTasks : System.Web.UI.Page
{
    private void Page_Load(object sender, System.EventArgs e)
    {
        System.Text.StringBuilder sbValid = new System.Text.StringBuilder();
        sbValid.Append("if (typeof(Page_ClientValidate) == 'function') { ");
        sbValid.Append("if (Page_ClientValidate() == false) { return false; }} ");
        sbValid.Append("this.value = 'Please wait...';");
        sbValid.Append("this.disabled = true;");
        sbValid.Append("document.all.btnNext.disabled = true;");
        sbValid.Append(ClientScript.GetPostBackEventReference(this.btnNext,""));
        sbValid.Append(";");
        this.btnNext.Attributes.Add("onclick", sbValid.ToString());
        if (IsPostBack)
        {
            Server.Transfer("MailboxConfirm.aspx", true);
        }
    }
}

