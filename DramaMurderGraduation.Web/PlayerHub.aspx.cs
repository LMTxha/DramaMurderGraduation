using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// 玩家中心页面。
    /// 聚合玩家档案、订单确认/改期、服务消息、社交推荐、礼物赠送和好友申请处理。
    /// </summary>
    public partial class PlayerHubPage : System.Web.UI.Page
    {
        private readonly FeatureRepository _featureRepository = new FeatureRepository();
        private readonly AccountRepository _accountRepository = new AccountRepository();
        private readonly ContentRepository _contentRepository = new ContentRepository();

        protected string ActiveTab { get; private set; }

        /// <summary>
        /// 根据 tab 参数切换玩家中心分区，并在首次加载时绑定页面数据。
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireApprovedUser();

            ActiveTab = NormalizeTab(Request.QueryString["tab"]);
            pnlProfileTab.Visible = ActiveTab == "profile";
            pnlOrdersTab.Visible = ActiveTab == "orders";
            pnlSocialTab.Visible = ActiveTab == "social";

            if (!IsPostBack)
            {
                BindPage();
            }
        }

        /// <summary>
        /// 保存玩家档案。
        /// </summary>
        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            pnlProfileMessage.Visible = true;

            if (string.IsNullOrWhiteSpace(txtProfileDisplayName.Text) ||
                string.IsNullOrWhiteSpace(txtProfileTitle.Text) ||
                string.IsNullOrWhiteSpace(txtProfileMotto.Text) ||
                string.IsNullOrWhiteSpace(txtProfileAvatarUrl.Text) ||
                string.IsNullOrWhiteSpace(ddlProfileFavoriteGenre.SelectedValue))
            {
                ShowProfileMessage("\u8bf7\u5148\u5b8c\u6574\u586b\u5199\u73a9\u5bb6\u6863\u6848\u3002", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var profile = new PlayerProfileInfo
            {
                UserId = currentUser.UserId,
                DisplayName = txtProfileDisplayName.Text.Trim(),
                DisplayTitle = txtProfileTitle.Text.Trim(),
                Motto = txtProfileMotto.Text.Trim(),
                AvatarUrl = txtProfileAvatarUrl.Text.Trim(),
                FavoriteGenre = ddlProfileFavoriteGenre.SelectedValue
            };

            var success = _featureRepository.UpsertPlayerProfile(profile, out var message);
            ShowProfileMessage(message, success);
            BindPage();
        }

        /// <summary>
        /// 处理玩家订单列表中的确认、改期和留言命令。
        /// </summary>
        protected void rptHubReservations_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            pnlOrderMessage.Visible = true;

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var reservationId))
            {
                ShowOrderMessage("\u672a\u627e\u5230\u5bf9\u5e94\u8ba2\u5355\u3002", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            bool success;
            string message;

            if (string.Equals(e.CommandName, "ConfirmReservation", StringComparison.OrdinalIgnoreCase))
            {
                success = _contentRepository.ConfirmReservationByPlayer(reservationId, currentUser.UserId, out message);
            }
            else if (string.Equals(e.CommandName, "RequestReservationReschedule", StringComparison.OrdinalIgnoreCase))
            {
                var remarkBox = e.Item.FindControl("txtReservationRescheduleRemark") as TextBox;
                success = _contentRepository.RequestReservationReschedule(reservationId, currentUser.UserId, remarkBox != null ? remarkBox.Text.Trim() : string.Empty, out message);
            }
            else if (string.Equals(e.CommandName, "LeaveReservation", StringComparison.OrdinalIgnoreCase))
            {
                success = _contentRepository.LeaveReservationByPlayer(reservationId, currentUser.UserId, out message);
            }
            else if (string.Equals(e.CommandName, "SendReservationMessage", StringComparison.OrdinalIgnoreCase))
            {
                var messageBox = e.Item.FindControl("txtReservationServiceMessage") as TextBox;
                success = _contentRepository.AddServiceMessage("Reservation", reservationId, currentUser.UserId, false, messageBox != null ? messageBox.Text.Trim() : string.Empty, out message);
            }
            else
            {
                return;
            }

            ShowOrderMessage(message, success);
            BindPage();
        }

        protected void rptHubStoreRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            pnlOrderMessage.Visible = true;

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var requestId))
            {
                ShowOrderMessage("\u672a\u627e\u5230\u5bf9\u5e94\u7684\u5230\u5e97\u8054\u7cfb\u5355\u3002", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            bool success;
            string message;

            if (string.Equals(e.CommandName, "ConfirmStore", StringComparison.OrdinalIgnoreCase))
            {
                success = _contentRepository.ConfirmStoreVisitRequestByPlayer(requestId, currentUser.UserId, out message);
            }
            else if (string.Equals(e.CommandName, "RequestStoreReschedule", StringComparison.OrdinalIgnoreCase))
            {
                var remarkBox = e.Item.FindControl("txtStoreRescheduleRemark") as TextBox;
                success = _contentRepository.RequestStoreVisitReschedule(requestId, currentUser.UserId, remarkBox != null ? remarkBox.Text.Trim() : string.Empty, out message);
            }
            else if (string.Equals(e.CommandName, "SendStoreMessage", StringComparison.OrdinalIgnoreCase))
            {
                var messageBox = e.Item.FindControl("txtStoreServiceMessage") as TextBox;
                success = _contentRepository.AddServiceMessage("StoreVisit", requestId, currentUser.UserId, false, messageBox != null ? messageBox.Text.Trim() : string.Empty, out message);
            }
            else
            {
                return;
            }

            ShowOrderMessage(message, success);
            BindPage();
        }

        protected void btnSendGift_Click(object sender, EventArgs e)
        {
            pnlGiftMessage.Visible = true;

            if (!int.TryParse(ddlGiftReceiver.SelectedValue, out var receiverUserId) || receiverUserId <= 0)
            {
                ShowGiftMessage("\u8bf7\u5148\u9009\u62e9\u6536\u793c\u73a9\u5bb6\u3002", false);
                return;
            }

            if (!int.TryParse(ddlGiftCatalog.SelectedValue, out var giftId) || giftId <= 0)
            {
                ShowGiftMessage("\u8bf7\u5148\u9009\u62e9\u793c\u7269\u3002", false);
                return;
            }

            if (!int.TryParse(txtGiftQuantity.Text, out var quantity) || quantity <= 0 || quantity > 99)
            {
                ShowGiftMessage("\u793c\u7269\u6570\u91cf\u8bf7\u8f93\u5165 1 \u5230 99 \u4e4b\u95f4\u7684\u6574\u6570\u3002", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.SendGift(currentUser.UserId, receiverUserId, giftId, quantity, out var message);
            ShowGiftMessage(message, success);
            BindPage();
        }

        protected void btnSendFriendRequest_Click(object sender, EventArgs e)
        {
            pnlFriendMessage.Visible = true;

            if (!int.TryParse(ddlFriendCandidate.SelectedValue, out var receiverUserId) || receiverUserId <= 0)
            {
                ShowFriendMessage("\u8bf7\u5148\u9009\u62e9\u8981\u6dfb\u52a0\u7684\u73a9\u5bb6\u3002", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.SendFriendRequest(currentUser.UserId, receiverUserId, txtFriendRequestMessage.Text.Trim(), out var message);
            ShowFriendMessage(message, success);
            if (success)
            {
                txtFriendRequestMessage.Text = string.Empty;
            }

            BindPage();
        }

        protected void rptIncomingFriendRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            pnlFriendMessage.Visible = true;

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var requestId))
            {
                ShowFriendMessage("\u672a\u627e\u5230\u597d\u53cb\u7533\u8bf7\u3002", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var approved = string.Equals(e.CommandName, "Accept", StringComparison.OrdinalIgnoreCase);
            var success = _accountRepository.ReviewFriendRequest(requestId, currentUser.UserId, approved, out var message);
            ShowFriendMessage(message, success);
            BindPage();
        }

        private void BindPage()
        {
            var currentUser = AuthManager.GetCurrentUser();
            var profile = _featureRepository.GetPlayerProfile(currentUser.UserId) ?? BuildFallbackProfile(currentUser.DisplayName, currentUser.UserId);
            var abilities = _featureRepository.GetPlayerAbilities(currentUser.UserId) ?? BuildFallbackAbilities(currentUser.UserId);
            var achievements = _featureRepository.GetAchievements(currentUser.UserId);
            var battleRecords = _featureRepository.GetPlayerBattleRecords(currentUser.UserId, 8);
            var giftStats = _accountRepository.GetGiftStats(currentUser.UserId);
            var friends = _accountRepository.GetFriends(currentUser.UserId);
            var recommendations = _contentRepository.GetRepurchaseRecommendations(currentUser.UserId, 6);

            BindHeader(profile, achievements.Count, giftStats, friends.Count);
            BindProfileSection(profile, abilities, achievements, battleRecords);
            BindRepurchaseSection(profile, recommendations);
            BindOrdersSection(currentUser.UserId);
            BindSocialSection(currentUser.UserId, friends);
        }

        private void BindHeader(PlayerProfileInfo profile, int achievementCount, GiftStatsInfo giftStats, int friendCount)
        {
            imgAvatar.ImageUrl = string.IsNullOrWhiteSpace(profile.AvatarUrl)
                ? "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80"
                : profile.AvatarUrl;
            litDisplayName.Text = profile.DisplayName;
            litDisplayTitle.Text = profile.DisplayTitle;
            litMotto.Text = profile.Motto;
            litFavoriteGenre.Text = profile.FavoriteGenre;
            litReputationLevel.Text = profile.ReputationLevel;
            litCompletedScripts.Text = profile.CompletedScripts.ToString();
            litWinRate.Text = profile.WinRate.ToString("F1") + "%";
            litAchievementCount.Text = achievementCount.ToString();
            litGiftBalance.Text = giftStats.GiftBalance.ToString();
            litTotalGiftSent.Text = giftStats.TotalGiftCoinsSent + " coins";
            litTotalGiftReceived.Text = giftStats.TotalGiftCoinsReceived + " coins";
            litFriendCount.Text = friendCount.ToString();
        }

        private void BindProfileSection(PlayerProfileInfo profile, PlayerAbilityInfo abilities, IList<AchievementInfo> achievements, IList<PlayerBattleRecordInfo> battleRecords)
        {
            txtProfileDisplayName.Text = profile.DisplayName;
            txtProfileTitle.Text = profile.DisplayTitle;
            txtProfileMotto.Text = profile.Motto;
            txtProfileAvatarUrl.Text = profile.AvatarUrl;

            ddlProfileFavoriteGenre.Items.Clear();
            foreach (var genre in _contentRepository.GetGenres())
            {
                ddlProfileFavoriteGenre.Items.Add(new ListItem(genre.Name, genre.Name));
            }

            if (!string.IsNullOrWhiteSpace(profile.FavoriteGenre) && ddlProfileFavoriteGenre.Items.FindByValue(profile.FavoriteGenre) == null)
            {
                ddlProfileFavoriteGenre.Items.Insert(0, new ListItem(profile.FavoriteGenre, profile.FavoriteGenre));
            }

            if (!string.IsNullOrWhiteSpace(profile.FavoriteGenre))
            {
                ddlProfileFavoriteGenre.SelectedValue = profile.FavoriteGenre;
            }

            litRecommendedIdentity.Text = abilities.DeductionPower >= 90 ? "\u6838\u5fc3\u4fa6\u63a2\u4f4d" : "\u7a33\u5b9a\u53d1\u8a00\u4f4d";
            litPlayStyle.Text = abilities.ObservationPower >= abilities.CreativityPower ? "\u7ebf\u7d22\u6574\u5408\u578b\u73a9\u5bb6" : "\u5267\u60c5\u53d1\u6563\u578b\u73a9\u5bb6";
            litGrowthAdvice.Text = abilities.CollaborationPower >= 80 ? "\u9002\u5408\u5e26\u961f\u4e0e\u590d\u76d8\u89d2\u8272" : "\u5efa\u8bae\u7ee7\u7eed\u63d0\u5347\u534f\u4f5c\u4e0e\u53d1\u8a00\u8282\u594f";

            rptAbilities.DataSource = BuildAbilityItems(abilities);
            rptAbilities.DataBind();

            rptAchievements.DataSource = achievements;
            rptAchievements.DataBind();

            rptBattleRecords.DataSource = battleRecords;
            rptBattleRecords.DataBind();
        }

        private void BindRepurchaseSection(PlayerProfileInfo profile, IList<RecommendationInfo> recommendations)
        {
            litRepurchaseGenre.Text = string.IsNullOrWhiteSpace(profile.FavoriteGenre) ? "\u5f85\u8bbe\u7f6e" : profile.FavoriteGenre;

            var preferredPlayerCount = recommendations.Where(item => item.PlayerCount > 0).Select(item => item.PlayerCount).FirstOrDefault();
            litRepurchasePlayerCount.Text = preferredPlayerCount > 0 ? preferredPlayerCount + " \u4eba\u8f66" : "\u5f85\u79ef\u7d2f";
            litRepurchaseHint.Text = recommendations.Count == 0 ? "\u6682\u65e0\u5339\u914d" : recommendations[0].HighlightTag;
            litRepurchaseSessionCount.Text = recommendations.Sum(item => item.UpcomingSessionCount).ToString();

            pnlRepurchaseRecommendations.Visible = recommendations.Count > 0;
            pnlRepurchaseEmpty.Visible = recommendations.Count == 0;
            litRepurchaseEmpty.Text = "\u5f53\u524d\u5386\u53f2\u5c40\u6570\u8fd8\u4e0d\u591f\uff0c\u5148\u5b8c\u6210\u51e0\u573a\u9884\u7ea6\u6216\u8bc4\u4ef7\u540e\uff0c\u8fd9\u91cc\u4f1a\u81ea\u52a8\u7ed9\u4f60\u66f4\u51c6\u786e\u7684\u4e0b\u4e00\u573a\u63a8\u8350\u3002";

            rptRepurchaseRecommendations.DataSource = recommendations;
            rptRepurchaseRecommendations.DataBind();
        }

        private void BindOrdersSection(int userId)
        {
            rptHubReservations.DataSource = _contentRepository.GetReservationsForUser(userId, 12);
            rptHubReservations.DataBind();

            rptHubStoreRequests.DataSource = _contentRepository.GetStoreVisitRequests(12, userId);
            rptHubStoreRequests.DataBind();

            rptHubReplyLogs.DataSource = _contentRepository.GetUserNotifications(userId, 16);
            rptHubReplyLogs.DataBind();
        }

        private void BindSocialSection(int userId, IList<FriendInfo> friends)
        {
            ddlGiftCatalog.DataSource = _accountRepository.GetGiftCatalog();
            ddlGiftCatalog.DataTextField = "Name";
            ddlGiftCatalog.DataValueField = "Id";
            ddlGiftCatalog.DataBind();
            ddlGiftCatalog.Items.Insert(0, new ListItem("\u8bf7\u9009\u62e9\u793c\u7269", string.Empty));

            ddlGiftReceiver.DataSource = _accountRepository.GetGiftRecipientCandidates(userId, 50);
            ddlGiftReceiver.DataTextField = "DisplayName";
            ddlGiftReceiver.DataValueField = "Id";
            ddlGiftReceiver.DataBind();
            ddlGiftReceiver.Items.Insert(0, new ListItem("\u8bf7\u9009\u62e9\u6536\u793c\u73a9\u5bb6", string.Empty));

            ddlFriendCandidate.DataSource = _accountRepository.GetSuggestedFriends(userId, 50);
            ddlFriendCandidate.DataTextField = "DisplayName";
            ddlFriendCandidate.DataValueField = "Id";
            ddlFriendCandidate.DataBind();
            ddlFriendCandidate.Items.Insert(0, new ListItem("\u8bf7\u9009\u62e9\u597d\u53cb", string.Empty));

            rptGiftSentRecords.DataSource = _accountRepository.GetGiftSentRecords(userId, 8);
            rptGiftSentRecords.DataBind();

            rptGiftReceivedRecords.DataSource = _accountRepository.GetGiftReceivedRecords(userId, 8);
            rptGiftReceivedRecords.DataBind();

            rptFriends.DataSource = friends;
            rptFriends.DataBind();

            rptIncomingFriendRequests.DataSource = _accountRepository.GetIncomingFriendRequests(userId);
            rptIncomingFriendRequests.DataBind();

            rptOutgoingFriendRequests.DataSource = _accountRepository.GetOutgoingFriendRequests(userId);
            rptOutgoingFriendRequests.DataBind();
        }

        private void ShowProfileMessage(string message, bool success)
        {
            pnlProfileMessage.CssClass = success ? "status-message success" : "status-message error";
            litProfileMessage.Text = message;
        }

        private void ShowGiftMessage(string message, bool success)
        {
            pnlGiftMessage.CssClass = success ? "status-message success" : "status-message error";
            litGiftMessage.Text = message;
        }

        private void ShowOrderMessage(string message, bool success)
        {
            pnlOrderMessage.CssClass = success ? "status-message success" : "status-message error";
            litOrderMessage.Text = message;
        }

        private void ShowFriendMessage(string message, bool success)
        {
            pnlFriendMessage.CssClass = success ? "status-message success" : "status-message error";
            litFriendMessage.Text = message;
        }

        private static string NormalizeTab(string tab)
        {
            if (string.Equals(tab, "social", StringComparison.OrdinalIgnoreCase))
            {
                return "social";
            }

            if (string.Equals(tab, "orders", StringComparison.OrdinalIgnoreCase))
            {
                return "orders";
            }

            return "profile";
        }

        public string TranslateBusinessType(object value)
        {
            switch (Convert.ToString(value))
            {
                case "Reservation":
                    return "\u9884\u7ea6\u8ba2\u5355";
                case "StoreVisit":
                    return "\u5230\u5e97\u8054\u7cfb\u5355";
                case "AfterSale":
                    return "\u552e\u540e\u7533\u8bf7";
                default:
                    return Convert.ToString(value);
            }
        }

        public string BuildReservationTimeline(object dataItem)
        {
            var reservation = dataItem as ReservationInfo;
            if (reservation == null)
            {
                return string.Empty;
            }

            return BuildTimelineHtml(new[]
            {
                CreateTimelineStep("\u5df2\u4e0b\u5355", reservation.CreatedAt, true, "\u8ba2\u5355\u5df2\u63d0\u4ea4"),
                CreateTimelineStep("\u95e8\u5e97\u63a5\u5355", reservation.ProcessedAt, !string.IsNullOrWhiteSpace(reservation.AdminReply) || !string.IsNullOrWhiteSpace(reservation.AdminRemark), string.IsNullOrWhiteSpace(reservation.AdminReply) ? reservation.Status : reservation.AdminReply),
                CreateTimelineStep("\u7528\u6237\u786e\u8ba4", reservation.PlayerConfirmedAt, !string.IsNullOrWhiteSpace(reservation.ConfirmStatus), string.IsNullOrWhiteSpace(reservation.PlayerConfirmRemark) ? reservation.ConfirmStatus : reservation.PlayerConfirmRemark),
                CreateTimelineStep("\u5230\u5e97\u6838\u9500", reservation.CheckedInAt, reservation.CheckedInAt.HasValue, string.IsNullOrWhiteSpace(reservation.CheckInCode) ? "\u5f85\u751f\u6210\u6838\u9500\u7801" : "Code " + reservation.CheckInCode),
                CreateTimelineStep("\u5c65\u7ea6\u5b8c\u6210", reservation.Status == "已完成" ? reservation.CheckedInAt ?? reservation.ProcessedAt : (DateTime?)null, reservation.Status == "已完成", reservation.Status)
            });
        }

        public string BuildStoreTimeline(object dataItem)
        {
            var request = dataItem as StoreVisitRequestInfo;
            if (request == null)
            {
                return string.Empty;
            }

            return BuildTimelineHtml(new[]
            {
                CreateTimelineStep("\u5df2\u63d0\u4ea4", request.CreatedAt, true, "\u5230\u5e97\u9700\u6c42\u5df2\u63d0\u4ea4"),
                CreateTimelineStep("\u95e8\u5e97\u5b89\u6392", request.ProcessedAt, !string.IsNullOrWhiteSpace(request.AssignedRoomName) || !string.IsNullOrWhiteSpace(request.RequestStatus), string.IsNullOrWhiteSpace(request.AssignedRoomName) ? request.RequestStatus : request.AssignedRoomName),
                CreateTimelineStep("\u7528\u6237\u786e\u8ba4", request.PlayerConfirmedAt, !string.IsNullOrWhiteSpace(request.ConfirmStatus), string.IsNullOrWhiteSpace(request.PlayerConfirmRemark) ? request.ConfirmStatus : request.PlayerConfirmRemark),
                CreateTimelineStep("\u5230\u5e97\u63a5\u5f85", request.RequestStatus == "已到店完成" ? request.ProcessedAt : (DateTime?)null, request.RequestStatus == "已到店完成", request.RequestStatus)
            });
        }

        public string GetRecommendationPlayerRange(object dataItem)
        {
            var recommendation = dataItem as RecommendationInfo;
            if (recommendation == null)
            {
                return string.Empty;
            }

            var rangeText = recommendation.MinPlayerCount > 0 && recommendation.MaxPlayerCount >= recommendation.MinPlayerCount
                ? recommendation.MinPlayerCount + "-" + recommendation.MaxPlayerCount + " \u4eba"
                : "\u4eba\u6570\u5f85\u8865\u5145";

            if (recommendation.PlayerCount > 0 && recommendation.PlayerCount >= recommendation.MinPlayerCount && recommendation.PlayerCount <= recommendation.MaxPlayerCount)
            {
                return rangeText + " / \u5339\u914d\u4f60\u7684 " + recommendation.PlayerCount + " \u4eba\u8f66";
            }

            return rangeText;
        }

        public string GetRecommendationSessionText(object dataItem)
        {
            var recommendation = dataItem as RecommendationInfo;
            if (recommendation == null)
            {
                return string.Empty;
            }

            if (recommendation.NextSessionDateTime.HasValue)
            {
                return recommendation.NextSessionDateTime.Value.ToString("MM-dd HH:mm");
            }

            return recommendation.UpcomingSessionCount > 0 ? "\u6392\u671f\u6574\u7406\u4e2d" : "\u6682\u65e0\u5f00\u653e\u573a\u6b21";
        }

        public bool CanLeaveReservation(object dataItem)
        {
            var reservation = dataItem as ReservationInfo;
            if (reservation == null)
            {
                return false;
            }

            switch (reservation.Status)
            {
                case "待确认":
                case "已确认":
                case "玩家已确认":
                case "申请改期":
                case "已到店":
                    return true;
                default:
                    return false;
            }
        }

        private static string BuildTimelineHtml(IEnumerable<TimelineStep> steps)
        {
            var builder = new StringBuilder();

            foreach (var step in steps)
            {
                builder.Append("<div class=\"service-timeline-step");
                if (step.IsActive)
                {
                    builder.Append(" active");
                }

                builder.Append("\">");
                builder.Append("<span class=\"service-timeline-dot\"></span>");
                builder.Append("<div class=\"service-timeline-copy\"><strong>");
                builder.Append(HttpUtility.HtmlEncode(step.Title));
                builder.Append("</strong><small>");
                builder.Append(HttpUtility.HtmlEncode(step.Meta));
                builder.Append("</small></div></div>");
            }

            return builder.ToString();
        }

        private static TimelineStep CreateTimelineStep(string title, DateTime? time, bool isActive, string detail)
        {
            var meta = time.HasValue ? time.Value.ToString("MM-dd HH:mm") : "\u5f85\u5904\u7406";
            if (!string.IsNullOrWhiteSpace(detail))
            {
                meta += " / " + detail.Trim();
            }

            return new TimelineStep
            {
                Title = title,
                IsActive = isActive,
                Meta = meta
            };
        }

        private static IList<AbilityViewItem> BuildAbilityItems(PlayerAbilityInfo abilities)
        {
            return new List<AbilityViewItem>
            {
                new AbilityViewItem { Name = "\u63a8\u7406\u529b", Value = abilities.DeductionPower, Description = "\u64c5\u957f\u8fd8\u539f\u65f6\u95f4\u7ebf\u548c\u9501\u5b9a\u5173\u952e\u5acc\u7591\u70b9\u3002" },
                new AbilityViewItem { Name = "\u89c2\u5bdf\u529b", Value = abilities.ObservationPower, Description = "\u66f4\u5bb9\u6613\u6355\u6349\u7ec6\u8282\u7ebf\u7d22\u4e0e\u5f02\u5e38\u53d8\u5316\u3002" },
                new AbilityViewItem { Name = "\u521b\u9020\u529b", Value = abilities.CreativityPower, Description = "\u5bf9\u5267\u60c5\u5206\u652f\u548c\u601d\u8def\u62c6\u89e3\u66f4\u6709\u65b0\u89c6\u89d2\u3002" },
                new AbilityViewItem { Name = "\u534f\u4f5c\u529b", Value = abilities.CollaborationPower, Description = "\u9002\u5408\u4e32\u8054\u961f\u53cb\u4fe1\u606f\u548c\u63a8\u8fdb\u8ba8\u8bba\u8282\u594f\u3002" },
                new AbilityViewItem { Name = "\u6267\u884c\u529b", Value = abilities.ExecutionPower, Description = "\u5728\u9650\u65f6\u4efb\u52a1\u548c\u591a\u9636\u6bb5\u73a9\u6cd5\u4e2d\u63a8\u8fdb\u66f4\u7a33\u5b9a\u3002" }
            };
        }

        private static PlayerProfileInfo BuildFallbackProfile(string displayName, int userId)
        {
            return new PlayerProfileInfo
            {
                UserId = userId,
                AvatarUrl = "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80",
                DisplayName = string.IsNullOrWhiteSpace(displayName) ? "\u6f14\u793a\u73a9\u5bb6" : displayName,
                DisplayTitle = "\u5267\u672c\u6740\u4e92\u52a8\u73a9\u5bb6",
                Motto = "\u628a\u559c\u6b22\u7684\u5267\u672c\u3001\u804a\u5f97\u6765\u7684\u670b\u53cb\u548c\u6bcf\u4e00\u573a\u4f53\u9a8c\u90fd\u8ba4\u771f\u7559\u4e0b\u3002",
                FavoriteGenre = "\u672c\u683c\u63a8\u7406",
                JoinDays = 120,
                CompletedScripts = 16,
                WinRate = 78.4M,
                ReputationLevel = "A \u7ea7\u73a9\u5bb6"
            };
        }

        private static PlayerAbilityInfo BuildFallbackAbilities(int userId)
        {
            return new PlayerAbilityInfo
            {
                UserId = userId,
                DeductionPower = 82,
                ObservationPower = 79,
                CreativityPower = 75,
                CollaborationPower = 85,
                ExecutionPower = 81
            };
        }

        private sealed class AbilityViewItem
        {
            public string Name { get; set; }
            public int Value { get; set; }
            public string Description { get; set; }
        }

        private sealed class TimelineStep
        {
            public string Title { get; set; }
            public bool IsActive { get; set; }
            public string Meta { get; set; }
        }
    }
}
