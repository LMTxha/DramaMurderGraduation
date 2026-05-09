using System;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// Register.aspx 页面后台逻辑，负责当前 Web Forms 页面的权限校验、数据绑定和事件处理。
    /// </summary>
    public partial class RegisterPage : System.Web.UI.Page
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
            }
        }

        /// <summary>
        /// 处理页面按钮点击事件，并根据当前表单输入刷新或提交业务数据。
        /// </summary>
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = true;

            if (string.IsNullOrWhiteSpace(txtUsername.Text) ||
                string.IsNullOrWhiteSpace(txtDisplayName.Text) ||
                string.IsNullOrWhiteSpace(txtPhone.Text) ||
                string.IsNullOrWhiteSpace(txtEmail.Text) ||
                string.IsNullOrWhiteSpace(txtPassword.Text))
            {
                ShowMessage("请完整填写注册信息。", false);
                return;
            }

            if (!string.Equals(txtPassword.Text, txtConfirmPassword.Text, StringComparison.Ordinal))
            {
                ShowMessage("两次输入的密码不一致。", false);
                return;
            }

            var request = new UserRegistrationRequest
            {
                Username = txtUsername.Text.Trim(),
                DisplayName = txtDisplayName.Text.Trim(),
                Phone = txtPhone.Text.Trim(),
                Email = txtEmail.Text.Trim(),
                Password = txtPassword.Text
            };

            var success = _accountRepository.Register(request, out var message);
            ShowMessage(message, success);

            if (success)
            {
                txtUsername.Text = string.Empty;
                txtDisplayName.Text = string.Empty;
                txtPhone.Text = string.Empty;
                txtEmail.Text = string.Empty;
                txtPassword.Text = string.Empty;
                txtConfirmPassword.Text = string.Empty;
            }
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
