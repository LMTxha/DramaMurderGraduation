using System;
using System.Collections.Generic;
using System.Web;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// FriendProfile.aspx 页面后台逻辑，负责当前 Web Forms 页面的权限校验、数据绑定和事件处理。
    /// </summary>
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

        /// <summary>
        /// 页面生命周期入口，负责权限校验和首次加载时的数据初始化。
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireApprovedUser();

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

        /// <summary>
        /// 处理页面按钮点击事件，并根据当前表单输入刷新或提交业务数据。
        /// </summary>
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

        /// <summary>
        /// 绑定页面展示数据到对应控件。
        /// </summary>
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

        /// <summary>
        /// 获取页面展示或业务判断所需的数据。
        /// </summary>
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

        /// <summary>
        /// 页面辅助方法，封装当前页面使用的局部业务逻辑。
        /// </summary>
        public IHtmlString RenderMomentImage(object imageUrl)
        {
            var value = Convert.ToString(imageUrl);
            if (string.IsNullOrWhiteSpace(value))
            {
                return new HtmlString(string.Empty);
            }

            return new HtmlString("<img class=\"moment-image\" src=\"" + HttpUtility.HtmlAttributeEncode(value) + "\" alt=\"朋友圈图片\" />");
        }

        /// <summary>
        /// 页面辅助方法，封装当前页面使用的局部业务逻辑。
        /// </summary>
        public IHtmlString RenderMomentLocation(object locationText)
        {
            var value = Convert.ToString(locationText);
            if (string.IsNullOrWhiteSpace(value))
            {
                return new HtmlString(string.Empty);
            }

            return new HtmlString("<p class=\"chat-location\">打卡位置：" + HttpUtility.HtmlEncode(value) + "</p>");
        }

        /// <summary>
        /// 根据业务数据构造页面展示所需的视图模型。
        /// </summary>
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

        /// <summary>
        /// 设置页面控件状态或提示信息。
        /// </summary>
        private void ShowInviteMessage(string message, bool success)
        {
            pnlInviteMessage.CssClass = success ? "status-message success" : "status-message error";
            litInviteMessage.Text = HttpUtility.HtmlEncode(message);
        }
    }
}
