using System;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// ForgotPassword.aspx 页面后台逻辑，负责当前 Web Forms 页面的权限校验、数据绑定和事件处理。
    /// </summary>
    public partial class ForgotPasswordPage : System.Web.UI.Page
    {
        private readonly AccountRepository _accountRepository = new AccountRepository();

        /// <summary>
        /// 处理页面按钮点击事件，并根据当前表单输入刷新或提交业务数据。
        /// </summary>
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

        /// <summary>
        /// 处理页面按钮点击事件，并根据当前表单输入刷新或提交业务数据。
        /// </summary>
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
