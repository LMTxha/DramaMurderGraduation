using System;
using System.Linq;
using System.Web;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class VoteStatusPage : System.Web.UI.Page
    {
        private readonly ContentRepository _contentRepository = new ContentRepository();
        private readonly GameRepository _gameRepository = new GameRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireApprovedUser();

            if (!IsPostBack)
            {
                BindVoteStatus();
            }
        }

        protected string VoteFeatureUrl(string featureKey)
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

        private void BindVoteStatus()
        {
            var currentUser = AuthManager.GetCurrentUser();
            var reservation = ResolveReservation(currentUser);
            if (reservation == null)
            {
                ShowNotFound();
                return;
            }

            _gameRepository.EnsureSessionGameData(reservation.SessionId);
            var roomState = _gameRepository.GetGameRoomState(reservation.SessionId, reservation.Id);
            var lifecycle = roomState.Lifecycle ?? new GameSessionLifecycleInfo();
            var voteDetails = _gameRepository.GetVoteDetails(reservation.SessionId);
            var canManageRoom = currentUser != null && currentUser.CanManageGameRoom;
            var canSeeVoteTarget = canManageRoom || lifecycle.IsGameEnded;

            pnlNotFound.Visible = false;
            pnlVote.Visible = true;

            litScriptName.Text = HttpUtility.HtmlEncode(reservation.ScriptName);
            litRoomName.Text = RoomNavigationHelper.RenderRoomSelectLink(reservation);
            litSessionTime.Text = reservation.SessionDateTime.ToString("yyyy-MM-dd HH:mm");
            litCurrentStage.Text = roomState.CurrentStage == null ? "阶段同步中" : HttpUtility.HtmlEncode(roomState.CurrentStage.StageName);
            litVoteProgress.Text = "投票 " + lifecycle.VoteCount + " / " + lifecycle.TotalAssignments;
            litVoteProgressCard.Text = lifecycle.VoteCount + " / " + lifecycle.TotalAssignments;
            litVotedCount.Text = lifecycle.VoteCount.ToString();
            litUnvotedCount.Text = Math.Max(0, lifecycle.TotalAssignments - lifecycle.VoteCount).ToString();
            litVisibilityNote.Text = canSeeVoteTarget
                ? "当前身份可以查看投票对象；普通玩家在结算前只显示谁已投、谁未投，避免提前剧透。"
                : "你可以查看每位玩家是否已经投票。为避免提前剧透，结算前不会显示其他人的投票对象。";

            lnkBackVote.NavigateUrl = "GameRoom.aspx?reservationId=" + reservation.Id + "&module=vote";
            lnkBackRoom.NavigateUrl = "GameRoom.aspx?reservationId=" + reservation.Id;
            BindSideNavigation(currentUser, roomState);

            rptVoteDetails.DataSource = voteDetails.Select(item => new
            {
                item.ReservationId,
                PlayerName = HttpUtility.HtmlEncode(item.PlayerName),
                item.PlayerCount,
                CharacterName = HttpUtility.HtmlEncode(item.CharacterName),
                StatusText = item.IsEliminated ? "已出局" : (item.HasVoted ? "已投票" : "未投票"),
                StatusCssClass = item.IsEliminated ? "not-voted" : (item.HasVoted ? "has-voted" : "not-voted"),
                VoteTargetText = BuildVoteTargetText(item, canSeeVoteTarget),
                VotedAtText = item.IsEliminated && item.EliminatedAt.HasValue
                    ? "出局时间：" + item.EliminatedAt.Value.ToString("MM-dd HH:mm:ss")
                    : (item.VotedAt.HasValue ? "提交时间：" + item.VotedAt.Value.ToString("MM-dd HH:mm:ss") : "等待提交")
            }).ToList();
            rptVoteDetails.DataBind();

            rptVoteSummary.DataSource = (roomState.VoteSummary ?? Enumerable.Empty<GameVoteSummaryInfo>()).Select(item => new
            {
                item.SuspectCharacterId,
                SuspectCharacterName = HttpUtility.HtmlEncode(item.SuspectCharacterName),
                item.VoteCount,
                IsCorrectVisible = canSeeVoteTarget && item.IsCorrect,
                SummaryText = canSeeVoteTarget && item.IsCorrect ? "系统设定真凶" : "候选角色"
            }).ToList();
            rptVoteSummary.DataBind();
        }

        private void BindSideNavigation(CurrentUserInfo currentUser, GameRoomStateInfo roomState)
        {
            var lifecycle = roomState.Lifecycle;
            litVoteSideStage.Text = roomState.CurrentStage == null ? "阶段同步中" : roomState.CurrentStage.StageName;
            litVoteSideReady.Text = lifecycle == null ? "就位 0/0" : "就位 " + lifecycle.ReadyCount + "/" + lifecycle.TotalAssignments;
            litVoteSideVote.Text = lifecycle == null ? "投票 0/0" : "投票 " + lifecycle.VoteCount + "/" + lifecycle.TotalAssignments;
            phVoteDmLink.Visible = currentUser != null && currentUser.CanManageGameRoom;
        }

        private ReservationInfo ResolveReservation(CurrentUserInfo currentUser)
        {
            if (currentUser == null)
            {
                return null;
            }

            int reservationId;
            if (!int.TryParse(Request.QueryString["reservationId"], out reservationId) || reservationId <= 0)
            {
                return null;
            }

            return _contentRepository.GetReservationDetail(
                reservationId,
                currentUser.CanManageGameRoom ? (int?)null : currentUser.UserId);
        }

        private static string BuildVoteTargetText(GameVoteDetailInfo item, bool canSeeVoteTarget)
        {
            if (item.IsEliminated)
            {
                return "该玩家已被投票出局，当前处于观战状态";
            }

            if (!item.HasVoted)
            {
                return "尚未提交终局投票";
            }

            if (!canSeeVoteTarget)
            {
                return "已提交，投票对象暂时保密";
            }

            return "投给：" + HttpUtility.HtmlEncode(string.IsNullOrWhiteSpace(item.SuspectCharacterName) ? "未记录目标" : item.SuspectCharacterName);
        }

        private void ShowNotFound()
        {
            pnlVote.Visible = false;
            pnlNotFound.Visible = true;
        }
    }
}
