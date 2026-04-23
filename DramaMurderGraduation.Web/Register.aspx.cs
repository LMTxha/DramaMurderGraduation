using System;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class RegisterPage : System.Web.UI.Page
    {
        private readonly AccountRepository _accountRepository = new AccountRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (AuthManager.IsLoggedIn())
            {
                Response.Redirect("~/Default.aspx");
            }
        }

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

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.CssClass = success ? "status-message success" : "status-message error";
            litMessage.Text = message;
        }
    }
}
