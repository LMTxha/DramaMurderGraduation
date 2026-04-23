using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class PlayerHubPage : System.Web.UI.Page
    {
        private readonly FeatureRepository _featureRepository = new FeatureRepository();
        private readonly AccountRepository _accountRepository = new AccountRepository();
        private readonly ContentRepository _contentRepository = new ContentRepository();

        protected string ActiveTab { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireLogin();

            ActiveTab = NormalizeTab(Request.QueryString["tab"]);
            pnlProfileTab.Visible = ActiveTab == "profile";
            pnlSocialTab.Visible = ActiveTab == "social";

            if (!IsPostBack)
            {
                BindPage();
            }
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            pnlProfileMessage.Visible = true;

            if (string.IsNullOrWhiteSpace(txtProfileDisplayName.Text) ||
                string.IsNullOrWhiteSpace(txtProfileTitle.Text) ||
                string.IsNullOrWhiteSpace(txtProfileMotto.Text) ||
                string.IsNullOrWhiteSpace(txtProfileAvatarUrl.Text) ||
                string.IsNullOrWhiteSpace(ddlProfileFavoriteGenre.SelectedValue))
            {
                ShowProfileMessage("请完整填写档案信息后再保存。", false);
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

        protected void btnSendGift_Click(object sender, EventArgs e)
        {
            pnlGiftMessage.Visible = true;

            if (!int.TryParse(ddlGiftReceiver.SelectedValue, out var receiverUserId) || receiverUserId <= 0)
            {
                ShowGiftMessage("请选择收礼玩家。", false);
                return;
            }

            if (!int.TryParse(ddlGiftCatalog.SelectedValue, out var giftId) || giftId <= 0)
            {
                ShowGiftMessage("请选择礼物类型。", false);
                return;
            }

            if (!int.TryParse(txtGiftQuantity.Text, out var quantity) || quantity <= 0 || quantity > 99)
            {
                ShowGiftMessage("赠送数量请输入 1 到 99 之间的整数。", false);
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
                ShowFriendMessage("请选择要添加的玩家。", false);
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
                ShowFriendMessage("未找到对应的好友申请。", false);
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

            BindHeader(profile, achievements.Count, giftStats, friends.Count);
            BindProfileSection(currentUser.UserId, profile, abilities, achievements, battleRecords);
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
            litTotalGiftSent.Text = giftStats.TotalGiftCoinsSent + " 币";
            litTotalGiftReceived.Text = giftStats.TotalGiftCoinsReceived + " 币";
            litFriendCount.Text = friendCount.ToString();
        }

        private void BindProfileSection(int userId, PlayerProfileInfo profile, PlayerAbilityInfo abilities, IList<AchievementInfo> achievements, IList<PlayerBattleRecordInfo> battleRecords)
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

            if (ddlProfileFavoriteGenre.Items.FindByValue(profile.FavoriteGenre) == null)
            {
                ddlProfileFavoriteGenre.Items.Insert(0, new ListItem(profile.FavoriteGenre, profile.FavoriteGenre));
            }

            ddlProfileFavoriteGenre.SelectedValue = profile.FavoriteGenre;

            litRecommendedIdentity.Text = abilities.DeductionPower >= 90 ? "核心侦探位" : "稳定发言位";
            litPlayStyle.Text = abilities.ObservationPower >= abilities.CreativityPower ? "线索整合型玩家" : "剧情发散型玩家";
            litGrowthAdvice.Text = abilities.CollaborationPower >= 80 ? "适合担任带队与复盘角色" : "建议继续提升协作和发言节奏";

            rptAbilities.DataSource = BuildAbilityItems(abilities);
            rptAbilities.DataBind();

            rptAchievements.DataSource = achievements;
            rptAchievements.DataBind();

            rptBattleRecords.DataSource = battleRecords;
            rptBattleRecords.DataBind();
        }

        private void BindSocialSection(int userId, IList<FriendInfo> friends)
        {
            var giftCatalog = _accountRepository.GetGiftCatalog();
            var recipients = _accountRepository.GetGiftRecipientCandidates(userId, 50);

            ddlGiftCatalog.DataSource = giftCatalog;
            ddlGiftCatalog.DataTextField = "Name";
            ddlGiftCatalog.DataValueField = "Id";
            ddlGiftCatalog.DataBind();
            ddlGiftCatalog.Items.Insert(0, new ListItem("请选择礼物", string.Empty));

            ddlGiftReceiver.DataSource = recipients;
            ddlGiftReceiver.DataTextField = "DisplayName";
            ddlGiftReceiver.DataValueField = "Id";
            ddlGiftReceiver.DataBind();
            ddlGiftReceiver.Items.Insert(0, new ListItem("请选择收礼玩家", string.Empty));

            ddlFriendCandidate.DataSource = _accountRepository.GetSuggestedFriends(userId, 50);
            ddlFriendCandidate.DataTextField = "DisplayName";
            ddlFriendCandidate.DataValueField = "Id";
            ddlFriendCandidate.DataBind();
            ddlFriendCandidate.Items.Insert(0, new ListItem("请选择要添加的玩家", string.Empty));

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

        private void ShowFriendMessage(string message, bool success)
        {
            pnlFriendMessage.CssClass = success ? "status-message success" : "status-message error";
            litFriendMessage.Text = message;
        }

        private static string NormalizeTab(string tab)
        {
            return string.Equals(tab, "social", StringComparison.OrdinalIgnoreCase) ? "social" : "profile";
        }

        private static IList<AbilityViewItem> BuildAbilityItems(PlayerAbilityInfo abilities)
        {
            return new List<AbilityViewItem>
            {
                new AbilityViewItem { Name = "推理力", Value = abilities.DeductionPower, Description = "负责还原时间线、排除错误结论与锁定关键嫌疑。" },
                new AbilityViewItem { Name = "观察力", Value = abilities.ObservationPower, Description = "善于捕捉角色卡细节与线索板中容易被忽略的信息。" },
                new AbilityViewItem { Name = "创造力", Value = abilities.CreativityPower, Description = "在剧情分支和谜题互动中更容易提出新视角。" },
                new AbilityViewItem { Name = "协作力", Value = abilities.CollaborationPower, Description = "适合承担串联队友信息、带动讨论节奏的职责。" },
                new AbilityViewItem { Name = "执行力", Value = abilities.ExecutionPower, Description = "面对限时挑战和多阶段任务时推进效率更高。" }
            };
        }

        private static PlayerProfileInfo BuildFallbackProfile(string displayName, int userId)
        {
            return new PlayerProfileInfo
            {
                UserId = userId,
                AvatarUrl = "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80",
                DisplayName = string.IsNullOrWhiteSpace(displayName) ? "演示玩家" : displayName,
                DisplayTitle = "剧本杀互动玩家",
                    Motto = "把喜欢的本、聊得来的朋友和送出的礼物都认真留在这里。",
                FavoriteGenre = "本格推理",
                JoinDays = 120,
                CompletedScripts = 16,
                WinRate = 78.4M,
                ReputationLevel = "A 级玩家"
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
    }
}
