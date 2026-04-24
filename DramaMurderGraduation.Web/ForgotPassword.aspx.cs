using System;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    public partial class ForgotPasswordPage : System.Web.UI.Page
    {
        private readonly AccountRepository _accountRepository = new AccountRepository();

        protected void btnRequestTicket_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = true;
            var success = _accountRepository.CreatePasswordResetTicket(txtUsername.Text.Trim(), txtPhone.Text.Trim(), out var ticketCode, out var message);
            if (success)
            {
                txtTicketCode.Text = ticketCode;
                ShowMessage(message + " 当前演示校验码：" + ticketCode, true);
                return;
            }

            ShowMessage(message, false);
        }

        protected void btnResetPassword_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = true;

            if (!string.Equals(txtNewPassword.Text, txtConfirmPassword.Text, StringComparison.Ordinal))
            {
                ShowMessage("两次输入的新密码不一致。", false);
                return;
            }

            var success = _accountRepository.ResetPasswordWithTicket(
                txtUsername.Text.Trim(),
                txtTicketCode.Text.Trim(),
                txtNewPassword.Text,
                out var message);

            ShowMessage(message, success);
            if (!success)
            {
                return;
            }

            txtNewPassword.Text = string.Empty;
            txtConfirmPassword.Text = string.Empty;
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.CssClass = success ? "status-message success" : "status-message error";
            litMessage.Text = message;
        }
    }
}
