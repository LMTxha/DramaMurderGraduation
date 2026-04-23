using System;
using System.Linq;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    public partial class GameResultPage : System.Web.UI.Page
    {
        private readonly ContentRepository _contentRepository = new ContentRepository();
        private readonly GameRepository _gameRepository = new GameRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireLogin();

            if (!IsPostBack)
            {
                BindResult();
            }
        }

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

            pnlNotFound.Visible = false;
            pnlResult.Visible = true;

            litScriptName.Text = reservation.ScriptName;
            litRoomName.Text = reservation.RoomName;
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

        private void ShowNotFound()
        {
            pnlResult.Visible = false;
            pnlNotFound.Visible = true;
        }
    }
}
