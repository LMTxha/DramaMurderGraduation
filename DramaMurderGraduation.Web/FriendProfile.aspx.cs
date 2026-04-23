using System;
using System.Collections.Generic;
using System.Web;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class FriendProfilePage : System.Web.UI.Page
    {
        private readonly AccountRepository _accountRepository = new AccountRepository();
        private readonly FeatureRepository _featureRepository = new FeatureRepository();
        private readonly ContentRepository _contentRepository = new ContentRepository();

        private int FriendUserId
        {
            get
            {
                return int.TryParse(Convert.ToString(ViewState["FriendUserId"]), out var userId) ? userId : 0;
            }
            set
            {
                ViewState["FriendUserId"] = value;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireLogin();

            if (!int.TryParse(Request.QueryString["friendId"], out var friendUserId) || friendUserId <= 0)
            {
                Response.Redirect("~/Friends.aspx");
                return;
            }

            FriendUserId = friendUserId;

            if (!IsPostBack)
            {
                BindPage();
            }
        }

        protected void btnInviteFriend_Click(object sender, EventArgs e)
        {
            pnlInviteMessage.Visible = true;

            if (!int.TryParse(ddlInviteScript.SelectedValue, out var scriptId) || scriptId <= 0)
            {
                ShowInviteMessage("请选择要邀请的剧本。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.SendGameInvite(currentUser.UserId, FriendUserId, scriptId, out var message);
            ShowInviteMessage(message, success);
            BindPage();
        }

        private void BindPage()
        {
            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser.UserId == FriendUserId)
            {
                Response.Redirect("~/PlayerHub.aspx");
                return;
            }

            var friendUser = _accountRepository.GetUserById(FriendUserId);
            if (friendUser == null)
            {
                Response.Redirect("~/Friends.aspx");
                return;
            }

            var isFriend = _accountRepository.AreFriends(currentUser.UserId, FriendUserId);
            var profile = _featureRepository.GetPlayerProfile(FriendUserId) ?? BuildFallbackProfile(friendUser);
            var recentMoments = _accountRepository.GetMomentFeedForUser(currentUser.UserId, FriendUserId, 6);

            litDisplayName.Text = HttpUtility.HtmlEncode(profile.DisplayName);
            litTitle.Text = HttpUtility.HtmlEncode(profile.DisplayTitle);
            litMotto.Text = HttpUtility.HtmlEncode(profile.Motto);
            litFavoriteGenre.Text = HttpUtility.HtmlEncode(profile.FavoriteGenre);
            litReputation.Text = HttpUtility.HtmlEncode(profile.ReputationLevel);
            litCompletedScripts.Text = profile.CompletedScripts.ToString();
            litWinRate.Text = profile.WinRate.ToString("F1") + "%";
            litJoinDays.Text = profile.JoinDays.ToString();
            litFriendshipStatus.Text = isFriend ? "已互为好友" : "仅查看公开资料";

            imgAvatar.Src = GetAvatarUrl(profile.AvatarUrl);
            lnkOpenChat.HRef = "Friends.aspx?friendId=" + FriendUserId + "#chat-panel";
            btnInviteFriend.Visible = isFriend;
            ddlInviteScript.Visible = isFriend;

            ddlInviteScript.DataSource = _contentRepository.GetFeaturedScripts(12);
            ddlInviteScript.DataTextField = "Name";
            ddlInviteScript.DataValueField = "Id";
            ddlInviteScript.DataBind();
            ddlInviteScript.Items.Insert(0, new System.Web.UI.WebControls.ListItem("请选择要邀请的剧本", string.Empty));

            rptRecentMoments.DataSource = recentMoments;
            rptRecentMoments.DataBind();
        }

        public string GetAvatarUrl(object avatarUrl)
        {
            var value = Convert.ToString(avatarUrl)?.Trim();
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

        public IHtmlString RenderMomentImage(object imageUrl)
        {
            var value = Convert.ToString(imageUrl);
            if (string.IsNullOrWhiteSpace(value))
            {
                return new HtmlString(string.Empty);
            }

            return new HtmlString("<img class=\"moment-image\" src=\"" + HttpUtility.HtmlAttributeEncode(value) + "\" alt=\"朋友圈图片\" />");
        }

        public IHtmlString RenderMomentLocation(object locationText)
        {
            var value = Convert.ToString(locationText);
            if (string.IsNullOrWhiteSpace(value))
            {
                return new HtmlString(string.Empty);
            }

            return new HtmlString("<p class=\"chat-location\">打卡位置：" + HttpUtility.HtmlEncode(value) + "</p>");
        }

        private static PlayerProfileInfo BuildFallbackProfile(UserAccountInfo friendUser)
        {
            return new PlayerProfileInfo
            {
                UserId = friendUser.Id,
                DisplayName = friendUser.DisplayName,
                DisplayTitle = "推理同好",
                Motto = "喜欢和靠谱队友一起还原真相。",
                AvatarUrl = string.Empty,
                FavoriteGenre = "本格推理",
                JoinDays = 30,
                CompletedScripts = 0,
                WinRate = 0,
                ReputationLevel = "新朋友"
            };
        }

        private void ShowInviteMessage(string message, bool success)
        {
            pnlInviteMessage.CssClass = success ? "status-message success" : "status-message error";
            litInviteMessage.Text = HttpUtility.HtmlEncode(message);
        }
    }
}
