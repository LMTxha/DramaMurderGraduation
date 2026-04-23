using System;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    public partial class SettingsPage : System.Web.UI.Page
    {
        private readonly AccountRepository _accountRepository = new AccountRepository();
        private readonly FriendWorkspaceRepository _workspaceRepository = new FriendWorkspaceRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Page.Form != null)
            {
                Page.Form.Enctype = "multipart/form-data";
            }

            AuthManager.RequireLogin();

            if (!IsPostBack)
            {
                BindPage();
            }
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            SaveProfile();
        }

        protected void btnSaveAvatar_Click(object sender, EventArgs e)
        {
            SaveProfile();
        }

        private void SaveProfile()
        {
            pnlProfileMessage.Visible = true;
            var avatarUrl = txtAvatarUrl.Text.Trim();
            if (fuAvatarImage.HasFile)
            {
                if (!UploadHelper.TrySave(fuAvatarImage, "avatars", out var uploadedAvatarUrl, out var uploadError))
                {
                    ShowMessage(pnlProfileMessage, litProfileMessage, uploadError, false);
                    return;
                }

                avatarUrl = uploadedAvatarUrl;
                txtAvatarUrl.Text = avatarUrl;
            }

            if (!string.IsNullOrWhiteSpace(avatarUrl))
            {
                if (!IsValidAvatarUrl(avatarUrl, out var avatarError))
                {
                    ShowMessage(pnlProfileMessage, litProfileMessage, avatarError, false);
                    return;
                }
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _workspaceRepository.UpdateExtendedUserSettings(
                currentUser.UserId,
                txtDisplayName.Text.Trim(),
                txtPhone.Text.Trim(),
                avatarUrl,
                txtPublicUserCode.Text.Trim(),
                txtGender.Text.Trim(),
                txtRegion.Text.Trim(),
                txtSignature.Text.Trim(),
                out var message);

            ShowMessage(pnlProfileMessage, litProfileMessage, message, success);
            if (success)
            {
                RefreshCurrentUser(currentUser.UserId);
                BindPage();
            }
        }

        protected void btnSaveDesktopSettings_Click(object sender, EventArgs e)
        {
            pnlDesktopMessage.Visible = true;

            if (!int.TryParse(txtAutoDownloadMaxMb.Text, out var autoDownloadMaxMb) || autoDownloadMaxMb < 1 || autoDownloadMaxMb > 500)
            {
                ShowMessage(pnlDesktopMessage, litDesktopMessage, "自动下载大小请输入 1 到 500 之间的数字。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var settings = new DramaMurderGraduation.Web.Models.UserDesktopSettingsInfo
            {
                UserId = currentUser.UserId,
                LoginConfirmMode = ddlLoginConfirmMode.SelectedValue,
                KeepChatHistory = chkKeepChatHistory.Checked,
                StoragePath = txtStoragePath.Text.Trim(),
                AutoDownloadMaxMb = autoDownloadMaxMb,
                NotificationEnabled = chkNotificationEnabled.Checked,
                ShortcutScheme = ddlShortcutScheme.SelectedValue,
                PluginEnabled = chkPluginEnabled.Checked,
                FriendRequestEnabled = chkFriendRequestEnabled.Checked,
                PhoneSearchEnabled = chkPhoneSearchEnabled.Checked,
                ShowMomentsToStrangers = chkShowMomentsToStrangers.Checked,
                UseEnterToSend = chkUseEnterToSend.Checked
            };

            var success = _workspaceRepository.SaveDesktopSettings(currentUser.UserId, settings, out var message);
            ShowMessage(pnlDesktopMessage, litDesktopMessage, message, success);
            if (success)
            {
                BindPage();
            }
        }

        protected void btnLogoutProxy_Click(object sender, EventArgs e)
        {
            AuthManager.SignOut();
            Response.Redirect("~/Login.aspx", true);
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            pnlPasswordMessage.Visible = true;

            if (!string.Equals(txtNewPassword.Text, txtConfirmPassword.Text, StringComparison.Ordinal))
            {
                ShowMessage(pnlPasswordMessage, litPasswordMessage, "两次输入的新密码不一致。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.ChangePassword(currentUser.UserId, txtCurrentPassword.Text, txtNewPassword.Text, out var message);
            ShowMessage(pnlPasswordMessage, litPasswordMessage, message, success);

            if (success)
            {
                txtCurrentPassword.Text = string.Empty;
                txtNewPassword.Text = string.Empty;
                txtConfirmPassword.Text = string.Empty;
            }
        }

        private void BindPage()
        {
            var currentUser = AuthManager.GetCurrentUser();
            var settings = _workspaceRepository.GetExtendedUserSettings(currentUser.UserId) ?? _accountRepository.GetUserSettings(currentUser.UserId);
            if (settings == null)
            {
                AuthManager.SignOut();
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            var avatarUrl = string.IsNullOrWhiteSpace(settings.AvatarUrl)
                ? "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80"
                : settings.AvatarUrl;
            imgAvatar.ImageUrl = avatarUrl;
            imgAvatarPreview.ImageUrl = avatarUrl;
            litDisplayName.Text = settings.DisplayName;
            litUsername.Text = settings.Username;
            litPublicUserCode.Text = settings.PublicUserCode;
            litPhone.Text = settings.Phone;
            litEmail.Text = settings.Email;

            txtDisplayName.Text = settings.DisplayName;
            txtPhone.Text = settings.Phone;
            txtPublicUserCode.Text = settings.PublicUserCode;
            txtEmail.Text = settings.Email;
            txtAvatarUrl.Text = settings.AvatarUrl;
            txtGender.Text = settings.Gender;
            txtRegion.Text = settings.Region;
            txtSignature.Text = settings.Signature;

            var desktopSettings = _workspaceRepository.GetDesktopSettings(currentUser.UserId);
            if (desktopSettings != null)
            {
                SelectIfExists(ddlLoginConfirmMode, desktopSettings.LoginConfirmMode);
                chkKeepChatHistory.Checked = desktopSettings.KeepChatHistory;
                txtStoragePath.Text = desktopSettings.StoragePath;
                txtAutoDownloadMaxMb.Text = desktopSettings.AutoDownloadMaxMb.ToString();
                chkNotificationEnabled.Checked = desktopSettings.NotificationEnabled;
                SelectIfExists(ddlShortcutScheme, desktopSettings.ShortcutScheme);
                chkPluginEnabled.Checked = desktopSettings.PluginEnabled;
                chkFriendRequestEnabled.Checked = desktopSettings.FriendRequestEnabled;
                chkPhoneSearchEnabled.Checked = desktopSettings.PhoneSearchEnabled;
                chkShowMomentsToStrangers.Checked = desktopSettings.ShowMomentsToStrangers;
                chkUseEnterToSend.Checked = desktopSettings.UseEnterToSend;
            }
        }

        private void RefreshCurrentUser(int userId)
        {
            var latestUser = _accountRepository.GetUserById(userId);
            if (latestUser != null)
            {
                AuthManager.SignIn(AuthManager.CreateCurrentUser(latestUser));
            }
        }

        private static bool IsValidAvatarUrl(string avatarUrl, out string error)
        {
            error = string.Empty;

            if (string.IsNullOrWhiteSpace(avatarUrl)
                || avatarUrl.StartsWith("Uploads/", StringComparison.OrdinalIgnoreCase)
                || avatarUrl.StartsWith("~/Uploads/", StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }

            Uri parsedAvatarUrl;
            if (!Uri.TryCreate(avatarUrl, UriKind.Absolute, out parsedAvatarUrl))
            {
                error = "头像图片 URL 格式不正确，请填写完整的 http 或 https 图片地址。";
                return false;
            }

            if (parsedAvatarUrl.Scheme != Uri.UriSchemeHttp && parsedAvatarUrl.Scheme != Uri.UriSchemeHttps)
            {
                error = "头像图片 URL 只支持 http 或 https 地址。";
                return false;
            }

            return true;
        }

        private static void ShowMessage(System.Web.UI.WebControls.Panel panel, System.Web.UI.WebControls.Literal literal, string message, bool success)
        {
            panel.CssClass = success ? "status-message success" : "status-message error";
            literal.Text = message;
        }

        private static void SelectIfExists(System.Web.UI.WebControls.ListControl listControl, string value)
        {
            var item = listControl.Items.FindByValue(value ?? string.Empty);
            if (item == null)
            {
                return;
            }

            listControl.ClearSelection();
            item.Selected = true;
        }
    }
}
