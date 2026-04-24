using System;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    public partial class WalletPage : System.Web.UI.Page
    {
        private readonly AccountRepository _accountRepository = new AccountRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireApprovedUser();
            UpdatePaymentPanels();

            if (!IsPostBack)
            {
                BindWallet();
                BindRechargeRequests();
                BindTransactions();
                BindGiftTransactions();
            }
        }

        protected void btnQuickAmount_Click(object sender, EventArgs e)
        {
            var source = sender as LinkButton;
            if (source != null)
            {
                txtRechargeAmount.Text = source.CommandArgument;
            }
        }

        protected void btnGiftQuickAmount_Click(object sender, EventArgs e)
        {
            var source = sender as LinkButton;
            if (source != null)
            {
                txtGiftRechargeCoins.Text = source.CommandArgument;
            }
        }

        protected void rblPaymentMethod_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdatePaymentPanels();
        }

        protected void btnRecharge_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = true;

            if (!decimal.TryParse(txtRechargeAmount.Text, out var amount) || amount < 50M || amount > 5000M)
            {
                ShowMessage("充值金额请输入 50 到 5000 之间的数字。", false);
                return;
            }

            var paymentMethod = rblPaymentMethod.SelectedValue;
            var paymentAccount = string.Empty;
            if (paymentMethod == "BankCard")
            {
                paymentAccount = txtBankCardNumber.Text.Trim();
                if (string.IsNullOrWhiteSpace(paymentAccount) || paymentAccount.Length < 12 || paymentAccount.Length > 30)
                {
                    ShowMessage("银行卡号请输入 12 到 30 位。", false);
                    return;
                }
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.SubmitRechargeRequest(currentUser.UserId, paymentMethod, amount, paymentAccount, out var message);
            ShowMessage(message, success);

            BindWallet();
            BindRechargeRequests();
            BindTransactions();
            BindGiftTransactions();

            if (success && paymentMethod == "BankCard")
            {
                txtBankCardNumber.Text = string.Empty;
            }
        }

        protected void btnGiftRecharge_Click(object sender, EventArgs e)
        {
            pnlGiftMessage.Visible = true;

            if (!int.TryParse(txtGiftRechargeCoins.Text, out var giftCoins) || giftCoins < 50 || giftCoins > 5000)
            {
                ShowGiftMessage("赠送金兑换数量请输入 50 到 5000 之间的整数。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.RechargeGiftBalanceFromCash(currentUser.UserId, giftCoins, out var message);
            ShowGiftMessage(message, success);

            BindWallet();
            BindRechargeRequests();
            BindTransactions();
            BindGiftTransactions();
        }

        private void BindWallet()
        {
            var currentUser = AuthManager.GetCurrentUser();
            var latestUser = _accountRepository.GetUserById(currentUser.UserId);
            if (latestUser == null)
            {
                AuthManager.SignOut();
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            AuthManager.SignIn(AuthManager.CreateCurrentUser(latestUser));
            litBalance.Text = latestUser.Balance.ToString("F2");
            litWalletUserName.Text = latestUser.DisplayName;
            litGiftBalance.Text = _accountRepository.GetGiftStats(currentUser.UserId).GiftBalance.ToString();
        }

        private void BindRechargeRequests()
        {
            var currentUser = AuthManager.GetCurrentUser();
            rptRechargeRequests.DataSource = _accountRepository.GetRechargeRequests(currentUser.UserId, 8);
            rptRechargeRequests.DataBind();
        }

        private void BindTransactions()
        {
            var currentUser = AuthManager.GetCurrentUser();
            rptTransactions.DataSource = _accountRepository.GetWalletTransactions(currentUser.UserId, 8);
            rptTransactions.DataBind();
        }

        private void BindGiftTransactions()
        {
            var currentUser = AuthManager.GetCurrentUser();
            rptGiftTransactions.DataSource = _accountRepository.GetGiftWalletTransactions(currentUser.UserId, 8);
            rptGiftTransactions.DataBind();
        }

        private void UpdatePaymentPanels()
        {
            pnlBankCard.Visible = rblPaymentMethod.SelectedValue == "BankCard";
            switch (rblPaymentMethod.SelectedValue)
            {
                case "BankCard":
                    litPaymentTip.Text = "银行卡充值会记录卡号后四位并提交到后台审核，审核通过后再写入现金余额。";
                    break;
                case "ScanCode":
                    litPaymentTip.Text = "扫码支付用于模拟门店二维码收款，提交后会立即到账，并生成可审计的充值订单。";
                    break;
                default:
                    litPaymentTip.Text = "快捷支付采用即时到账模式，提交后会立刻增加账户余额。";
                    break;
            }
        }

        public string TranslatePaymentMethod(object value)
        {
            switch (Convert.ToString(value))
            {
                case "BankCard":
                    return "银行卡支付";
                case "ScanCode":
                    return "扫码支付";
                default:
                    return "快捷支付";
            }
        }

        public string TranslateRequestStatus(object value)
        {
            switch (Convert.ToString(value))
            {
                case "Approved":
                    return "已到账";
                case "Rejected":
                    return "已驳回";
                default:
                    return "待审核";
            }
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.CssClass = success ? "status-message success" : "status-message error";
            litMessage.Text = message;
        }

        private void ShowGiftMessage(string message, bool success)
        {
            pnlGiftMessage.CssClass = success ? "status-message success" : "status-message error";
            litGiftMessage.Text = message;
        }
    }
}
