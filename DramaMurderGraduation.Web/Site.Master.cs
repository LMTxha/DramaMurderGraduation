using System;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        private readonly AccountRepository _accountRepository = new AccountRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            var repository = new ContentRepository();
            var settings = repository.GetSiteSettings();
            var metrics = repository.GetSiteMetrics();
            var currentUser = AuthManager.GetCurrentUser();

            litSiteName.Text = settings.SiteName;
            litFooterSiteName.Text = settings.SiteName;
            litAddress.Text = settings.Address;
            litBusinessHours.Text = settings.BusinessHours;
            litPhone.Text = settings.ContactPhone;
            litWeChat.Text = settings.ContactWeChat;
            litHeaderScriptCount.Text = metrics.ScriptCount.ToString();
            litHeaderRoomCount.Text = metrics.RoomCount.ToString();
            litHeaderReservationCount.Text = metrics.ReservationCount.ToString();
            litHeaderRating.Text = metrics.AverageRating.ToString("F1");

            var isLoggedIn = currentUser != null;
            phAnonymous.Visible = !isLoggedIn;
            phMemberMenu.Visible = isLoggedIn;
            phLoggedIn.Visible = isLoggedIn;
            phSocialNav.Visible = isLoggedIn;
            phAdmin.Visible = isLoggedIn && currentUser.IsAdmin;
            phDm.Visible = isLoggedIn && currentUser.CanManageGameRoom;

            if (isLoggedIn)
            {
                var latestUser = _accountRepository.GetUserById(currentUser.UserId);
                if (latestUser != null)
                {
                    currentUser = AuthManager.CreateCurrentUser(latestUser);
                    AuthManager.SignIn(currentUser);
                }

                litCurrentUserName.Text = currentUser.DisplayName;
                litCurrentBalance.Text = currentUser.Balance.ToString("F2");
                var unreadFriendMessages = _accountRepository.GetUnreadFriendMessageCount(currentUser.UserId);
                litSocialNavLabel.Text = unreadFriendMessages > 0
                    ? "好友互动 <span class=\"nav-badge\">" + unreadFriendMessages + "</span>"
                    : "好友互动";
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            AuthManager.SignOut();
            Response.Redirect("~/Default.aspx");
        }
    }
}
