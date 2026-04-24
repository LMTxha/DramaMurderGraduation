using System;
using System.IO;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class CharacterDossierPage : System.Web.UI.Page
    {
        private readonly ContentRepository _contentRepository = new ContentRepository();
        private readonly GameRepository _gameRepository = new GameRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireApprovedUser();

            if (!IsPostBack)
            {
                BindDossier();
            }
        }

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

            litScriptName.Text = reservation.ScriptName;
            litCharacterName.Text = assignment.CharacterName;
            litRoomName.Text = reservation.RoomName;
            litStageName.Text = currentStage == null ? "未初始化阶段" : currentStage.StageName;
            litGuideTitle.Text = GetGuideTitle(currentStage == null ? string.Empty : currentStage.StageKey, gameState.Lifecycle != null && gameState.Lifecycle.IsGameEnded);
            litGuideSummary.Text = GetGuideSummary(currentStage == null ? string.Empty : currentStage.StageKey, gameState.Lifecycle != null && gameState.Lifecycle.IsGameEnded);

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

            rptClues.DataSource = gameState.Clues;
            rptClues.DataBind();

            rptActionLogs.DataSource = gameState.ActionLogs;
            rptActionLogs.DataBind();
        }

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

        private void ShowNotFound()
        {
            pnlDossier.Visible = false;
            pnlNotFound.Visible = true;
        }
    }
}
