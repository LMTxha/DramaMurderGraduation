using System;
using System.IO;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// CharacterDossier.aspx 页面后台逻辑，负责当前 Web Forms 页面的权限校验、数据绑定和事件处理。
    /// </summary>
    public partial class CharacterDossierPage : System.Web.UI.Page
    {
        private readonly ContentRepository _contentRepository = new ContentRepository();
        private readonly GameRepository _gameRepository = new GameRepository();

        /// <summary>
        /// 页面生命周期入口，负责权限校验和首次加载时的数据初始化。
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireApprovedUser();

            if (!IsPostBack)
            {
                BindDossier();
            }
        }

        /// <summary>
        /// 绑定页面展示数据到对应控件。
        /// </summary>
        private void BindDossier()
        {
            var currentUser = AuthManager.GetCurrentUser();
            int reservationId;
            if (!int.TryParse(Request.QueryString["reservationId"], out reservationId) || reservationId <= 0)
            {
                ShowNotFound();
                return;
            }

            var reservation = _contentRepository.GetReservationDetail(
                reservationId,
                currentUser != null && !currentUser.CanManageGameRoom ? currentUser.UserId : (int?)null);

            if (reservation == null)
            {
                ShowNotFound();
                return;
            }

            var gameState = _gameRepository.GetGameRoomState(reservation.SessionId, reservation.Id);
            if (gameState.CurrentAssignment == null)
            {
                ShowNotFound();
                return;
            }

            pnlNotFound.Visible = false;
            pnlDossier.Visible = true;

            var currentStage = gameState.CurrentStage;
            var assignment = gameState.CurrentAssignment;
            var stageKey = currentStage == null ? string.Empty : currentStage.StageKey;
            var isEnded = gameState.Lifecycle != null && gameState.Lifecycle.IsGameEnded;

            litScriptName.Text = reservation.ScriptName;
            litCharacterName.Text = assignment.CharacterName;
            litRoomName.Text = RoomNavigationHelper.RenderRoomSelectLink(reservation);
            litStageName.Text = currentStage == null ? "未初始化阶段" : currentStage.StageName;
            litGuideTitle.Text = GetGuideTitle(stageKey, isEnded);
            litGuideSummary.Text = GetGuideSummary(stageKey, isEnded);
            BindSideNavigation(currentUser, gameState);

            litReadyStatus.Text = assignment.IsReady ? "已就位" : "待就位";
            litRoleName.Text = assignment.CharacterName;
            litCharacterDescription.Text = string.IsNullOrWhiteSpace(assignment.CharacterDescription) ? "当前角色暂无详细描述，请查看下方原始角色 PDF。" : assignment.CharacterDescription;
            litPlayerName.Text = assignment.PlayerName;
            litPlayerCount.Text = assignment.PlayerCount.ToString();
            litGender.Text = string.IsNullOrWhiteSpace(assignment.Gender) ? "未标注" : assignment.Gender;
            litAgeRange.Text = string.IsNullOrWhiteSpace(assignment.AgeRange) ? "详见原始资料包" : assignment.AgeRange;
            litProfession.Text = string.IsNullOrWhiteSpace(assignment.Profession) ? "详见原始资料包" : assignment.Profession;
            litPersonality.Text = string.IsNullOrWhiteSpace(assignment.Personality) ? "详见原始资料包" : assignment.Personality;
            litSecretLine.Text = string.IsNullOrWhiteSpace(assignment.SecretLine)
                ? "当前角色暂未写入结构化私密信息，请打开下方原始角色 PDF 查看完整角色剧本。"
                : assignment.SecretLine;

            BindRolePdf(reservation.ScriptId, assignment.CharacterName);

            litRoomCode.Text = "ROOM-" + reservation.SessionId.ToString("D4");
            litHostName.Text = reservation.HostName;
            litReservationId.Text = reservation.Id.ToString();
            litSessionTime.Text = reservation.SessionDateTime.ToString("yyyy-MM-dd HH:mm");

            lnkBackRoom.NavigateUrl = "GameRoom.aspx?reservationId=" + reservation.Id;
            lnkResult.NavigateUrl = "GameResult.aspx?reservationId=" + reservation.Id;
            BindGuideActions(reservation.Id, stageKey, isEnded, gameState.Clues.Count, gameState.ActionLogs.Count);

            rptClues.DataSource = gameState.Clues;
            rptClues.DataBind();

            rptActionLogs.DataSource = gameState.ActionLogs;
            rptActionLogs.DataBind();
        }

        /// <summary>
        /// 绑定角色本页左侧房间功能导航的状态提示。
        /// </summary>
        private void BindSideNavigation(CurrentUserInfo currentUser, GameRoomStateInfo gameState)
        {
            var lifecycle = gameState.Lifecycle;
            litDossierSideStage.Text = gameState.CurrentStage == null ? "阶段同步中" : gameState.CurrentStage.StageName;
            litDossierSideReady.Text = lifecycle == null
                ? "就位 0/0"
                : "就位 " + lifecycle.ReadyCount + "/" + lifecycle.TotalAssignments;
            litDossierSideVote.Text = lifecycle == null
                ? "投票 0/0"
                : "投票 " + lifecycle.VoteCount + "/" + lifecycle.TotalAssignments;
            phDossierDmLink.Visible = currentUser != null && currentUser.CanManageGameRoom;
        }

        protected string DossierFeatureUrl(string featureKey)
        {
            var key = (featureKey ?? string.Empty).Trim().ToLowerInvariant();
            var reservationId = Request.QueryString["reservationId"];
            if (string.IsNullOrWhiteSpace(reservationId))
            {
                return "GameRoom.aspx";
            }

            var reservationQuery = "reservationId=" + Server.UrlEncode(reservationId);
            switch (key)
            {
                case "character":
                    return "CharacterDossier.aspx?" + reservationQuery;
                case "ending":
                    return "GameResult.aspx?" + reservationQuery;
                case "chat":
                    return "RoomGroupChat.aspx?" + reservationQuery;
                case "vote-status":
                    return "VoteStatus.aspx?" + reservationQuery;
                case "stage":
                case "clue":
                case "action":
                case "vote":
                case "participants":
                case "media":
                case "host":
                    return "GameRoom.aspx?" + reservationQuery + "&module=" + Server.UrlEncode(key);
                default:
                    return "GameRoom.aspx?" + reservationQuery;
            }
        }

        /// <summary>
        /// 绑定当前阶段任务卡片中的统计和快捷入口。
        /// </summary>
        private void BindGuideActions(int reservationId, string stageKey, bool isEnded, int clueCount, int actionCount)
        {
            litGuideClueCount.Text = clueCount + " 条可查看线索";
            litGuideActionCount.Text = actionCount + " 条行动记录";

            if (isEnded)
            {
                lnkGuidePrimary.Text = "查看结案复盘";
                lnkGuidePrimary.NavigateUrl = "GameResult.aspx?reservationId=" + reservationId;
                lnkGuideSecondary.Text = "查看行动记录";
                lnkGuideSecondary.NavigateUrl = "CharacterDossier.aspx?reservationId=" + reservationId + "#dossier-actions";
                return;
            }

            switch ((stageKey ?? string.Empty).ToLowerInvariant())
            {
                case "opening":
                    lnkGuidePrimary.Text = "查看角色设定";
                    lnkGuidePrimary.NavigateUrl = "CharacterDossier.aspx?reservationId=" + reservationId + "#dossier-character";
                    break;
                case "investigation":
                    lnkGuidePrimary.Text = "查看相关线索";
                    lnkGuidePrimary.NavigateUrl = "CharacterDossier.aspx?reservationId=" + reservationId + "#dossier-clues";
                    break;
                case "deduction":
                    lnkGuidePrimary.Text = "查看行动记录";
                    lnkGuidePrimary.NavigateUrl = "CharacterDossier.aspx?reservationId=" + reservationId + "#dossier-actions";
                    break;
                case "ending":
                    lnkGuidePrimary.Text = "进入投票与复盘";
                    lnkGuidePrimary.NavigateUrl = "GameResult.aspx?reservationId=" + reservationId;
                    break;
                default:
                    lnkGuidePrimary.Text = "回到游戏房间";
                    lnkGuidePrimary.NavigateUrl = "GameRoom.aspx?reservationId=" + reservationId;
                    break;
            }

            lnkGuideSecondary.Text = "回到游戏房间";
            lnkGuideSecondary.NavigateUrl = "GameRoom.aspx?reservationId=" + reservationId;
        }

        /// <summary>
        /// 绑定页面展示数据到对应控件。
        /// </summary>
        private void BindRolePdf(int scriptId, string characterName)
        {
            var roleAsset = FindRoleAsset(scriptId, characterName);
            phRolePdf.Visible = roleAsset != null;

            if (roleAsset == null)
            {
                lnkRolePdf.NavigateUrl = string.Empty;
                litRolePdfName.Text = string.Empty;
                return;
            }

            var publicUrl = (roleAsset.PublicUrl ?? string.Empty).Replace('\\', '/').TrimStart('/');
            lnkRolePdf.NavigateUrl = ResolveUrl("~/" + publicUrl);
            lnkRolePdf.Attributes["rel"] = "noopener";
            litRolePdfName.Text = Server.HtmlEncode("已匹配到：" + roleAsset.FileName + "（" + roleAsset.RelativePath + "）");
        }

        /// <summary>
        /// 页面辅助方法，封装当前页面使用的局部业务逻辑。
        /// </summary>
        private ScriptAssetInfo FindRoleAsset(int scriptId, string characterName)
        {
            var normalizedCharacterName = NormalizeAssetName(characterName);
            if (string.IsNullOrWhiteSpace(normalizedCharacterName))
            {
                return null;
            }

            ScriptAssetInfo looseMatch = null;
            foreach (var asset in _contentRepository.GetScriptAssets(scriptId))
            {
                if (!string.Equals(asset.FileExtension, ".pdf", StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                var relativePath = (asset.RelativePath ?? string.Empty).Replace('\\', '/');
                var isRoleBook =
                    relativePath.StartsWith("剧本/", StringComparison.Ordinal) ||
                    relativePath.StartsWith("人物剧本/", StringComparison.Ordinal) ||
                    relativePath.StartsWith("角色剧本/", StringComparison.Ordinal) ||
                    relativePath.IndexOf("/剧本/", StringComparison.Ordinal) >= 0 ||
                    relativePath.IndexOf("/人物剧本/", StringComparison.Ordinal) >= 0 ||
                    relativePath.IndexOf("/角色剧本/", StringComparison.Ordinal) >= 0;
                var normalizedTitle = NormalizeAssetName(asset.Title);
                var normalizedFileName = NormalizeAssetName(Path.GetFileNameWithoutExtension(asset.FileName ?? string.Empty));

                if (isRoleBook && (normalizedTitle == normalizedCharacterName || normalizedFileName == normalizedCharacterName))
                {
                    return asset;
                }

                if (looseMatch == null && (normalizedTitle == normalizedCharacterName || normalizedFileName == normalizedCharacterName))
                {
                    looseMatch = asset;
                }
            }

            return looseMatch;
        }

        /// <summary>
        /// 页面辅助方法，封装当前页面使用的局部业务逻辑。
        /// </summary>
        private static string NormalizeAssetName(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return string.Empty;
            }

            var normalized = value
                .Replace(" ", string.Empty)
                .Replace("　", string.Empty)
                .Replace(".pdf", string.Empty)
                .Trim()
                .ToLowerInvariant();

            while (normalized.Length > 0 && char.IsDigit(normalized[0]))
            {
                normalized = normalized.Substring(1);
            }

            return normalized.TrimStart('-', '_', '.', '、');
        }

        /// <summary>
        /// 获取页面展示或业务判断所需的数据。
        /// </summary>
        private static string GetGuideTitle(string stageKey, bool isEnded)
        {
            if (isEnded)
            {
                return "查看结案复盘，整理你的推理结果";
            }

            switch ((stageKey ?? string.Empty).ToLowerInvariant())
            {
                case "opening":
                    return "先建立你的公开形象";
                case "investigation":
                    return "优先锁定关键物证";
                case "deduction":
                    return "拼时间线并试探其他玩家";
                case "ending":
                    return "准备终局投票与复盘";
                default:
                    return "等待 DM 推进当前流程";
            }
        }

        /// <summary>
        /// 获取页面展示或业务判断所需的数据。
        /// </summary>
        private static string GetGuideSummary(string stageKey, bool isEnded)
        {
            if (isEnded)
            {
                return "本局已经结算，可以查看结案归档和投票结果。";
            }

            switch ((stageKey ?? string.Empty).ToLowerInvariant())
            {
                case "opening":
                    return "这一阶段适合介绍角色立场，理清与其他角色的关系，并隐藏对自己不利的信息。";
                case "investigation":
                    return "优先关注物证、时间点和房间动线，把 DM 发放的公共线索与你的私密线索拼接起来。";
                case "deduction":
                    return "尝试构造完整时间线，判断谁同时具备动机、机会与布置现场的条件。";
                case "ending":
                    return "整理最终结论，提交投票，并在结算后确认真相链条。";
                default:
                    return "等待 DM 推进到有效阶段后，再根据提示调整你的调查策略。";
            }
        }

        /// <summary>
        /// 设置页面控件状态或提示信息。
        /// </summary>
        private void ShowNotFound()
        {
            pnlDossier.Visible = false;
            pnlNotFound.Visible = true;
        }
    }
}
