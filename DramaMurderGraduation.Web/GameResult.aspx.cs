using System;
using System.Linq;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// GameResult.aspx 页面后台逻辑，负责当前 Web Forms 页面的权限校验、数据绑定和事件处理。
    /// </summary>
    public partial class GameResultPage : System.Web.UI.Page
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
                BindResult();
            }
        }

        /// <summary>
        /// 绑定页面展示数据到对应控件。
        /// </summary>
        private void BindResult()
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

            _gameRepository.EnsureGameSettlement(reservation.SessionId);
            var gameState = _gameRepository.GetGameRoomState(reservation.SessionId, reservation.Id);
            var currentStageName = gameState.CurrentStage == null ? "未初始化阶段" : gameState.CurrentStage.StageName;
            var isEnding = gameState.CurrentStage != null && string.Equals(gameState.CurrentStage.StageKey, "ending", StringComparison.OrdinalIgnoreCase);
            var canSeeTruth = currentUser != null && currentUser.CanManageGameRoom;
            if (gameState.Lifecycle != null && gameState.Lifecycle.IsGameEnded)
            {
                canSeeTruth = true;
            }
            BindSideNavigation(currentUser, gameState);

            pnlNotFound.Visible = false;
            pnlResult.Visible = true;

            litScriptName.Text = reservation.ScriptName;
            litRoomName.Text = RoomNavigationHelper.RenderRoomSelectLink(reservation);
            litHostName.Text = reservation.HostName;
            litReservationId.Text = reservation.Id.ToString();
            litRoomCode.Text = "ROOM-" + reservation.SessionId.ToString("D4");
            litCurrentStage.Text = currentStageName;
            litResultBadge.Text = canSeeTruth ? "结案信息已开放" : (isEnding ? "终局投票中" : "尚未进入终局");
            litCorrectCharacterName.Text = canSeeTruth
                ? (string.IsNullOrWhiteSpace(gameState.CorrectCharacterName) ? "DM 尚未设置" : gameState.CorrectCharacterName)
                : "终局前隐藏";
            litTruthSummary.Text = canSeeTruth
                ? (string.IsNullOrWhiteSpace(gameState.TruthSummary) ? "当前剧本尚未录入详细真相摘要，请 DM 在游戏房间的结案设置中补充。" : Server.HtmlEncode(gameState.TruthSummary))
                : "为避免提前剧透，真凶与真相摘要会在 DM 完成结算后开放。";

            lnkBackToRoom.NavigateUrl = "GameRoom.aspx?reservationId=" + reservation.Id;
            lnkBackToLobby.NavigateUrl = "GameLobby.aspx?reservationId=" + reservation.Id;

            rptVotes.DataSource = gameState.VoteSummary.Select(item => new
            {
                item.SuspectCharacterId,
                item.SuspectCharacterName,
                item.VoteCount,
                IsCorrect = canSeeTruth && item.IsCorrect
            });
            rptVotes.DataBind();

            rptStages.DataSource = gameState.Stages;
            rptStages.DataBind();

            rptActionLogs.DataSource = gameState.ActionLogs;
            rptActionLogs.DataBind();

            rptAssignments.DataSource = gameState.Assignments;
            rptAssignments.DataBind();
        }

        /// <summary>
        /// 绑定结案页左侧房间功能导航的状态提示。
        /// </summary>
        private void BindSideNavigation(Models.CurrentUserInfo currentUser, Models.GameRoomStateInfo gameState)
        {
            var lifecycle = gameState.Lifecycle;
            litResultSideStage.Text = gameState.CurrentStage == null ? "阶段同步中" : gameState.CurrentStage.StageName;
            litResultSideReady.Text = lifecycle == null
                ? "就位 0/0"
                : "就位 " + lifecycle.ReadyCount + "/" + lifecycle.TotalAssignments;
            litResultSideVote.Text = lifecycle == null
                ? "投票 0/0"
                : "投票 " + lifecycle.VoteCount + "/" + lifecycle.TotalAssignments;
            phResultDmLink.Visible = currentUser != null && currentUser.CanManageGameRoom;
        }

        protected string ResultFeatureUrl(string featureKey)
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
        /// 设置页面控件状态或提示信息。
        /// </summary>
        private void ShowNotFound()
        {
            pnlResult.Visible = false;
            pnlNotFound.Visible = true;
        }
    }
}
