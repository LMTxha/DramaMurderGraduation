using System;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// Login.aspx 页面后台逻辑，负责当前 Web Forms 页面的权限校验、数据绑定和事件处理。
    /// </summary>
    public partial class LoginPage : System.Web.UI.Page
    {
        private readonly AccountRepository _accountRepository = new AccountRepository();

        /// <summary>
        /// 页面生命周期入口，负责权限校验和首次加载时的数据初始化。
        /// </summary>
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

        /// <summary>
        /// 处理页面按钮点击事件，并根据当前表单输入刷新或提交业务数据。
        /// </summary>
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = true;

            if (string.IsNullOrWhiteSpace(txtUsername.Text) || string.IsNullOrWhiteSpace(txtPassword.Text))
            {
                ShowMessage("请输入用户名和密码。", false);
                return;
            }

            var user = _accountRepository.Authenticate(
                txtUsername.Text.Trim(),
                txtPassword.Text,
                Request.UserHostAddress,
                Request.UserAgent,
                out var message);
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

            Response.Redirect(AuthManager.GetDefaultLandingUrl(AuthManager.CreateCurrentUser(user)));
        }

        /// <summary>
        /// 设置页面控件状态或提示信息。
        /// </summary>
        private void ShowMessage(string message, bool success)
        {
            pnlMessage.CssClass = success ? "status-message success" : "status-message error";
            litMessage.Text = message;
        }
    }
}
