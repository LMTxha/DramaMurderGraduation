using System;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class LoginPage : System.Web.UI.Page
    {
        private readonly AccountRepository _accountRepository = new AccountRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (AuthManager.IsLoggedIn())
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (IsPostBack)
            {
                return;
            }

            var notice = Request.QueryString["notice"];
            if (string.Equals(notice, "approval_required", StringComparison.OrdinalIgnoreCase))
            {
                ShowMessage("当前账号状态已变更，请使用已审核通过的账号重新登录。", false);
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = true;

            if (string.IsNullOrWhiteSpace(txtUsername.Text) || string.IsNullOrWhiteSpace(txtPassword.Text))
            {
                ShowMessage("请输入用户名和密码。", false);
                return;
            }

            var user = _accountRepository.Authenticate(txtUsername.Text.Trim(), txtPassword.Text, out var message);
            if (user == null)
            {
                ShowMessage(message, false);
                return;
            }

            AuthManager.SignIn(AuthManager.CreateCurrentUser(user));

            var returnUrl = Request.QueryString["returnUrl"];
            if (!string.IsNullOrWhiteSpace(returnUrl))
            {
                Response.Redirect(returnUrl);
                return;
            }

            if (string.Equals(user.RoleCode, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/AdminReview.aspx");
                return;
            }

            if (string.Equals(user.RoleCode, "DM", StringComparison.OrdinalIgnoreCase)
                || string.Equals(user.RoleCode, "Host", StringComparison.OrdinalIgnoreCase)
                || string.Equals(user.RoleCode, "Director", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/DmDashboard.aspx");
                return;
            }

            Response.Redirect("~/CreatorCenter.aspx");
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.CssClass = success ? "status-message success" : "status-message error";
            litMessage.Text = message;
        }
    }
}
