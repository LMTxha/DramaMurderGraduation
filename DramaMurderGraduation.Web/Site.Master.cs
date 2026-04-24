using System;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        private readonly AccountRepository _accountRepository = new AccountRepository();
        private readonly ContentRepository _contentRepository = new ContentRepository();
        protected string TakeawayUrl => "https://pro.m.jd.com/mall/active/4CJH74pqm4snemxqc2TBUJpZe9JQ/index.html?cu=true&addressID=0&provinceCode=10&province=%E9%BB%91%E9%BE%99%E6%B1%9F&cityCode=731&city=%E5%8F%8C%E9%B8%AD%E5%B1%B1%E5%B8%82&districtCode=3340&district=%E5%B0%96%E5%B1%B1%E5%8C%BA&townCode=58167&town=%E9%93%81%E8%A5%BF%E8%A1%97%E9%81%93&fullAddress=%E9%BB%91%E9%BE%99%E6%B1%9F%E5%8F%8C%E9%B8%AD%E5%B1%B1%E5%B8%82%E5%B0%96%E5%B1%B1%E5%8C%BA%E9%93%81%E8%A5%BF%E8%A1%97%E9%81%93%E6%96%B0%E5%85%B4%E5%A4%A7%E8%A1%97191%E5%8F%B7&detailAddress=%E6%96%B0%E5%85%B4%E5%A4%A7%E8%A1%97191%E5%8F%B7&lng=131.15841&lat=46.64635&lbsData=vTsHJXSLSeyJhZGRyZXNzSUQiOjAsInByb3ZpbmNlQ29kZSI6MTAsInByb3ZpbmNlIjoi6buR6b6Z5rGfIiwiY2l0eUNvZGUiOjczMSwiY2l0eSI6IuWPjOm4reWxseW4giIsImRpc3RyaWN0Q29kZSI6MzM0MCwiZGlzdHJpY3QiOiLlsJblsbHljLoiLCJ0b3duQ29kZSI6NTgxNjcsInRvd24iOiLpk4Hopb%2FooZfpgZMiLCJmdWxsQWRkcmVzcyI6Ium7kem%2Bmeaxn%2BWPjOm4reWxseW4guWwluWxseWMuumTgeilv%2Bihl%2BmBk%2BaWsOWFtOWkp%2BihlzE5MeWPtyIsImRldGFpbEFkZHJlc3MiOiLmlrDlhbTlpKfooZcxOTHlj7ciLCJsbmciOjEzMS4xNTg0MSwibGF0Ijo0Ni42NDYzNX0%3D&hasChanged=1";

        protected void Page_Load(object sender, EventArgs e)
        {
            var settings = _contentRepository.GetSiteSettings();
            var metrics = _contentRepository.GetSiteMetrics();
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

            if (currentUser != null)
            {
                var latestUser = _accountRepository.GetUserById(currentUser.UserId);
                if (latestUser != null && AuthManager.HasApprovedUserAccess(AuthManager.CreateCurrentUser(latestUser)))
                {
                    currentUser = AuthManager.CreateCurrentUser(latestUser);
                    AuthManager.SignIn(currentUser);
                }
                else
                {
                    AuthManager.SignOut();
                    currentUser = null;
                }
            }

            var isLoggedIn = currentUser != null;
            phAnonymous.Visible = !isLoggedIn;
            phMemberMenu.Visible = isLoggedIn;
            phLoggedIn.Visible = isLoggedIn;
            phSocialNav.Visible = isLoggedIn;
            phAdmin.Visible = isLoggedIn && currentUser.CanAccessAdminConsole;
            phDm.Visible = isLoggedIn && currentUser.CanManageGameRoom;

            if (isLoggedIn)
            {

                litCurrentUserName.Text = currentUser.DisplayName;
                litCurrentBalance.Text = currentUser.Balance.ToString("F2");
                var userSettings = _accountRepository.GetUserSettings(currentUser.UserId);
                imgCurrentAvatar.ImageUrl = ResolveAvatarUrl(userSettings?.AvatarUrl);
                imgCurrentAvatar.AlternateText = currentUser.DisplayName + "头像";
                var unreadFriendMessages = _accountRepository.GetUnreadFriendMessageCount(currentUser.UserId);
                var unreadNotifications = _contentRepository.GetUnreadNotificationCount(currentUser.UserId);
                litSocialNavLabel.Text = unreadFriendMessages > 0
                    ? "好友互动 <span class=\"nav-badge\">" + unreadFriendMessages + "</span>"
                    : "好友互动";
                litNotificationLabel.Text = unreadNotifications > 0
                    ? "通知中心 <span class=\"nav-badge\">" + unreadNotifications + "</span>"
                    : "通知中心";
                litNotificationNavLabel.Text = unreadNotifications > 0
                    ? "通知中心 <span class=\"nav-badge\">" + unreadNotifications + "</span>"
                    : "通知中心";
                lnkAdminReviewNav.Visible = currentUser.CanAccessAdminConsole;
                lnkAnalyticsNav.Visible = currentUser.CanViewAnalytics;
            }
        }

        private string ResolveAvatarUrl(string avatarUrl)
        {
            var value = (avatarUrl ?? string.Empty).Trim();
            if (string.IsNullOrWhiteSpace(value))
            {
                return "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80";
            }

            if (value.StartsWith("~/", StringComparison.Ordinal))
            {
                return ResolveUrl(value);
            }

            if (value.StartsWith("/", StringComparison.Ordinal) || Uri.IsWellFormedUriString(value, UriKind.Absolute))
            {
                return value;
            }

            return ResolveUrl("~/" + value.TrimStart('/'));
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            AuthManager.SignOut();
            Response.Redirect("~/Default.aspx");
        }
    }
}
