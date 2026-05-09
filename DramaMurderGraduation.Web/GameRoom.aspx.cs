using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// 游戏房间页面。
    /// 首屏渲染房间基本信息，实时状态、聊天、准备、搜证、投票和 DM 操作通过 WebMethod 提供给前端轮询/调用。
    /// </summary>
    public partial class GameRoomPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();
        private readonly GameRepository _gameRepository = new GameRepository();

        /// <summary>
        /// 页面首次加载时校验登录，并绑定预约对应的房间基础信息。
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireApprovedUser();

            if (!IsPostBack)
            {
                BindRoom();
            }
        }

        /// <summary>
        /// 根据 reservationId 查询订单和场次，并初始化游戏数据。
        /// 普通玩家只能访问自己的预约，DM/后台角色可以查看所管理的房间。
        /// </summary>
        private void BindRoom()
        {
            var currentUser = AuthManager.GetCurrentUser();
            int reservationId;
            if (!int.TryParse(Request.QueryString["reservationId"], out reservationId) || reservationId <= 0)
            {
                if (currentUser != null && currentUser.CanManageGameRoom &&
                    int.TryParse(Request.QueryString["sessionId"], out var sessionId) && sessionId > 0)
                {
                    if (_repository.EnsureHostReservationForSession(sessionId, currentUser.UserId, currentUser.IsAdmin, out reservationId, out var ignoredMessage))
                    {
                        Response.Redirect("GameRoom.aspx?reservationId=" + reservationId + "&module=" + HttpUtility.UrlEncode(RoomModuleKey) + "&host=1", false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                }

                ShowNotFound();
                return;
            }

            var reservation = _repository.GetReservationDetail(
                reservationId,
                currentUser != null && !currentUser.CanManageGameRoom ? currentUser.UserId : (int?)null);

            if (reservation == null)
            {
                ShowNotFound();
                return;
            }

            if (!IsActiveReservation(reservation.Status) && !(currentUser != null && currentUser.CanManageGameRoom && IsHostEntryReservation(reservation.Status)))
            {
                ShowNotFound();
                return;
            }

            _gameRepository.EnsureSessionGameData(reservation.SessionId);

            pnlNotFound.Visible = false;
            pnlRoom.Visible = true;
            pnlRoom.CssClass = "game-room-module-page game-room-module-" + RoomModuleKey;

            litReservationId.Text = reservation.Id.ToString();
            litReservationStatus.Text = reservation.Status;
            litRoomCode.Text = GetRoomCode(reservation.SessionId);
            litScriptName.Text = reservation.ScriptName;
            litHostName.Text = reservation.HostName;
            litHostNameAside.Text = reservation.HostName;
            litTotalAmount.Text = reservation.TotalAmount.ToString("F2");
            litPlayerCount.Text = reservation.PlayerCount.ToString();
            litPaymentStatus.Text = reservation.PaymentStatus;
            litRoomName.Text = RoomNavigationHelper.RenderRoomSelectLink(reservation);
            litSessionTime.Text = reservation.SessionDateTime.ToString("yyyy-MM-dd HH:mm");
            litContactName.Text = reservation.ContactName;
            btnLeaveGame.Visible = currentUser != null && !currentUser.CanManageGameRoom;
        }

        private void ShowNotFound()
        {
            pnlRoom.Visible = false;
            pnlNotFound.Visible = true;
        }

        protected void btnLeaveGame_Click(object sender, EventArgs e)
        {
            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser == null || currentUser.CanManageGameRoom)
            {
                ShowNotFound();
                return;
            }

            if (!int.TryParse(Request.QueryString["reservationId"], out var reservationId) || reservationId <= 0)
            {
                ShowNotFound();
                return;
            }

            _repository.LeaveReservationByPlayer(reservationId, currentUser.UserId, out var message);
            Response.Redirect("~/PlayerHub.aspx?tab=orders", true);
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        /// <summary>
        /// 前端轮询用接口：返回房间参与者、消息、阶段、线索、投票等完整状态。
        /// </summary>
        public static object GetRoomState(int reservationId)
        {
            var reservation = ResolveReservation(reservationId);
            if (reservation == null)
            {
                return Fail("未找到对应的游戏房间。");
            }

            var currentUser = AuthManager.GetCurrentUser();
            var repository = new ContentRepository();
            var gameRepository = new GameRepository();
            gameRepository.EnsureSessionGameData(reservation.SessionId);

            var game = gameRepository.GetGameRoomState(reservation.SessionId, reservation.Id);
            game.CanManageRoom = currentUser != null && currentUser.CanManageGameRoom;

            var canSeeTruth = game.Lifecycle != null && game.Lifecycle.IsGameEnded;
            if (currentUser != null && currentUser.CanManageGameRoom)
            {
                canSeeTruth = true;
            }

            var participants = repository.GetRoomParticipants(reservation.SessionId)
                .Select(item => new
                {
                    item.ReservationId,
                    item.DisplayName,
                    item.ContactName,
                    item.PlayerCount,
                    item.Status,
                    item.CameraEnabled,
                    item.MicrophoneEnabled,
                    item.VideoSnapshot,
                    UpdatedAtText = item.UpdatedAt.HasValue ? item.UpdatedAt.Value.ToString("HH:mm:ss") : "尚未同步"
                })
                .ToList();

            var messages = repository.GetRoomMessages(reservation.SessionId, 40)
                .Select(item => new
                {
                    item.Id,
                    item.SenderName,
                    item.MessageType,
                    item.Content,
                    item.MediaData,
                    item.DurationSeconds,
                    SentAtText = item.SentAt.ToString("HH:mm:ss")
                })
                .ToList();

            return new
            {
                success = true,
                reservationId = reservation.Id,
                sessionId = reservation.SessionId,
                roomCode = GetRoomCode(reservation.SessionId),
                scriptName = reservation.ScriptName,
                roomName = reservation.RoomName,
                hostName = reservation.HostName,
                participants,
                messages,
                game = new
                {
                    lifecycle = game.Lifecycle == null ? null : new
                    {
                        isGameStarted = game.Lifecycle.IsGameStarted,
                        isGameEnded = game.Lifecycle.IsGameEnded,
                        isSettled = game.Lifecycle.IsSettled,
                        readyCount = game.Lifecycle.ReadyCount,
                        totalAssignments = game.Lifecycle.TotalAssignments,
                        voteCount = game.Lifecycle.VoteCount,
                        everyoneReady = game.Lifecycle.EveryoneReady,
                        everyoneVoted = game.Lifecycle.EveryoneVoted,
                        canStartGame = game.Lifecycle.CanStartGame,
                        canFinishGame = game.Lifecycle.CanFinishGame,
                        canSubmitAction = game.Lifecycle.CanSubmitAction,
                        canSubmitVote = game.Lifecycle.CanSubmitVote,
                        eliminatedCount = game.Lifecycle.EliminatedCount,
                        eliminatedCharacterName = game.Lifecycle.EliminatedCharacterName,
                        eliminatedPlayerName = game.Lifecycle.EliminatedPlayerName,
                        statusText = game.Lifecycle.StatusText,
                        resumeSummary = game.Lifecycle.ResumeSummary,
                        gameStartedAtText = ToFullDateTimeText(game.Lifecycle.GameStartedAt),
                        gameEndedAtText = ToFullDateTimeText(game.Lifecycle.GameEndedAt),
                        settledAtText = ToFullDateTimeText(game.Lifecycle.SettledAt),
                        dmNotes = game.CanManageRoom ? game.Lifecycle.DmNotes : string.Empty,
                        stageTimerStartedAtText = ToFullDateTimeText(game.Lifecycle.StageTimerStartedAt),
                        stageTimerDurationMinutes = game.Lifecycle.StageTimerDurationMinutes
                    },
                    currentStage = game.CurrentStage == null ? null : new
                    {
                        game.CurrentStage.Id,
                        game.CurrentStage.StageKey,
                        game.CurrentStage.StageName,
                        game.CurrentStage.StageDescription,
                        game.CurrentStage.SortOrder,
                        game.CurrentStage.DurationMinutes,
                        UpdatedAtText = ToFullDateTimeText(game.CurrentStage.UpdatedAt)
                    },
                    stages = game.Stages.Select(item => new
                    {
                        item.Id,
                        item.StageKey,
                        item.StageName,
                        item.StageDescription,
                        item.SortOrder,
                        item.DurationMinutes,
                        item.StatusText,
                        item.IsCurrent
                    }).ToList(),
                    currentAssignment = game.CurrentAssignment == null ? null : new
                    {
                        game.CurrentAssignment.ReservationId,
                        game.CurrentAssignment.CharacterId,
                        game.CurrentAssignment.PlayerName,
                        game.CurrentAssignment.ContactName,
                        game.CurrentAssignment.PlayerCount,
                        game.CurrentAssignment.CharacterName,
                        game.CurrentAssignment.Gender,
                        game.CurrentAssignment.AgeRange,
                        game.CurrentAssignment.Profession,
                        game.CurrentAssignment.Personality,
                        game.CurrentAssignment.CharacterDescription,
                        game.CurrentAssignment.SecretLine,
                        game.CurrentAssignment.IsReady,
                        game.CurrentAssignment.IsEliminated,
                        EliminatedAtText = ToShortDateTimeText(game.CurrentAssignment.EliminatedAt)
                    },
                    assignments = game.Assignments.Select(item => new
                    {
                        item.ReservationId,
                        item.CharacterId,
                        item.PlayerName,
                        item.ContactName,
                        item.PlayerCount,
                        item.CharacterName,
                        item.Profession,
                        item.Personality,
                        item.IsReady,
                        item.IsEliminated,
                        EliminatedAtText = ToShortDateTimeText(item.EliminatedAt)
                    }).ToList(),
                    clues = game.Clues.Select(item => new
                    {
                        item.Id,
                        item.StageName,
                        item.Title,
                        item.Summary,
                        item.Detail,
                        item.ClueType,
                        item.AssetType,
                        item.AssetUrl,
                        item.FileName,
                        item.FileExtension,
                        item.IsPublic,
                        item.SortOrder,
                        item.RevealMethod,
                        RevealedAtText = item.RevealedAt.ToString("MM-dd HH:mm"),
                        item.UnlockedByName
                    }).ToList(),
                    actionLogs = game.ActionLogs.Select(item => new
                    {
                        item.Id,
                        item.ReservationId,
                        item.PlayerName,
                        item.ActionType,
                        item.ActionTitle,
                        item.ActionContent,
                        CreatedAtText = item.CreatedAt.ToString("HH:mm:ss")
                    }).ToList(),
                    currentVote = game.CurrentVote == null ? null : new
                    {
                        game.CurrentVote.SuspectCharacterId,
                        game.CurrentVote.SuspectCharacterName,
                        game.CurrentVote.VoteComment,
                        VotedAtText = ToShortDateTimeText(game.CurrentVote.VotedAt)
                    },
                    voteSummary = game.VoteSummary.Select(item => new
                    {
                        item.SuspectCharacterId,
                        item.SuspectCharacterName,
                        item.VoteCount,
                        IsCorrect = canSeeTruth && item.IsCorrect
                    }).ToList(),
                    pendingClues = game.CanManageRoom
                        ? game.PendingClues.Select(item => new
                        {
                            item.Id,
                            item.Title,
                            item.StageName,
                            item.Summary,
                            item.Detail,
                            item.ClueType,
                            item.AssetType,
                            item.AssetUrl,
                            item.FileName,
                            item.FileExtension,
                            item.SourceLabel,
                            item.IsAssetSource,
                            item.IsRevealed,
                            item.ReleaseStatus,
                            item.IsPublic
                        }).ToList()
                        : null,
                    game.CanVote,
                    game.CanManageRoom,
                    correctCharacterName = canSeeTruth ? game.CorrectCharacterName : string.Empty,
                    truthSummary = canSeeTruth ? game.TruthSummary : string.Empty,
                    canSeeTruth
                },
                resultPageUrl = "GameResult.aspx?reservationId=" + reservation.Id
            };
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object SendTextMessage(int reservationId, string content)
        {
            var reservation = ResolveReservation(reservationId);
            if (reservation == null)
            {
                return Fail("未找到对应的游戏房间。");
            }

            var sanitizedContent = (content ?? string.Empty).Trim();
            if (string.IsNullOrWhiteSpace(sanitizedContent))
            {
                return Fail("消息内容不能为空。");
            }

            if (sanitizedContent.Length > 300)
            {
                return Fail("消息内容请控制在 300 字以内。");
            }

            var gameRepository = new GameRepository();
            gameRepository.EnsureSessionGameData(reservation.SessionId);
            if (gameRepository.IsReservationEliminatedBeforeGameEnd(reservation.Id))
            {
                return Fail("你已被投票出局，本局结束前只能观战，不能继续发言。结案后可以参与复盘讨论。");
            }

            var currentUser = AuthManager.GetCurrentUser();
            var repository = new ContentRepository();
            repository.AddRoomTextMessage(
                reservation.SessionId,
                reservation.Id,
                currentUser == null ? (int?)null : currentUser.UserId,
                reservation.ContactName,
                sanitizedContent,
                out var message);

            return Ok(message);
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object SendVoiceMessage(int reservationId, string audioDataUrl, int durationSeconds)
        {
            var reservation = ResolveReservation(reservationId);
            if (reservation == null)
            {
                return Fail("未找到对应的游戏房间。");
            }

            var audioContent = audioDataUrl ?? string.Empty;
            if (!audioContent.StartsWith("data:audio/", StringComparison.OrdinalIgnoreCase))
            {
                return Fail("语音数据格式无效。");
            }

            if (audioContent.Length > 2000000)
            {
                return Fail("语音留言过大，请缩短录音时长后再试。");
            }

            var gameRepository = new GameRepository();
            gameRepository.EnsureSessionGameData(reservation.SessionId);
            if (gameRepository.IsReservationEliminatedBeforeGameEnd(reservation.Id))
            {
                return Fail("你已被投票出局，本局结束前只能观战，不能继续发送语音。结案后可以参与复盘讨论。");
            }

            var currentUser = AuthManager.GetCurrentUser();
            var repository = new ContentRepository();
            repository.AddRoomVoiceMessage(
                reservation.SessionId,
                reservation.Id,
                currentUser == null ? (int?)null : currentUser.UserId,
                reservation.ContactName,
                audioContent,
                durationSeconds,
                out var message);

            return Ok(message);
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object UpdatePresence(int reservationId, bool cameraEnabled, bool microphoneEnabled, string snapshotDataUrl)
        {
            var reservation = ResolveReservation(reservationId);
            if (reservation == null)
            {
                return Fail("未找到对应的游戏房间。");
            }

            var snapshot = snapshotDataUrl ?? string.Empty;
            if (!string.IsNullOrWhiteSpace(snapshot) && snapshot.Length > 500000)
            {
                return Fail("画面快照过大，请稍后重试。");
            }

            var currentUser = AuthManager.GetCurrentUser();
            var repository = new ContentRepository();
            repository.UpsertRoomPresence(
                reservation.SessionId,
                reservation.Id,
                currentUser == null ? (int?)null : currentUser.UserId,
                reservation.ContactName,
                cameraEnabled,
                microphoneEnabled,
                snapshot);

            return Ok("房间状态已同步。");
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object ToggleReady(int reservationId, bool isReady)
        {
            var reservation = ResolveReservation(reservationId);
            if (reservation == null)
            {
                return Fail("未找到对应的游戏房间。");
            }

            var repository = new GameRepository();
            var success = repository.SetReadyState(reservation.SessionId, reservation.Id, isReady, out var message);
            return new { success, message };
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object SubmitAction(int reservationId, string title, string content)
        {
            var reservation = ResolveReservation(reservationId);
            if (reservation == null)
            {
                return Fail("未找到对应的游戏房间。");
            }

            var actionTitle = (title ?? string.Empty).Trim();
            var actionContent = (content ?? string.Empty).Trim();

            if (string.IsNullOrWhiteSpace(actionTitle))
            {
                return Fail("请输入本次行动的标题。");
            }

            if (actionTitle.Length > 40)
            {
                return Fail("行动标题请控制在 40 个字以内。");
            }

            if (string.IsNullOrWhiteSpace(actionContent))
            {
                return Fail("请输入本次调查或推理内容。");
            }

            if (actionContent.Length > 300)
            {
                return Fail("行动内容请控制在 300 个字以内。");
            }

            var repository = new GameRepository();
            var success = repository.SubmitInvestigation(reservation.Id, actionTitle, actionContent, out var unlockedClueTitle, out var message);
            return new { success, message, unlockedClueTitle };
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object SubmitVote(int reservationId, int suspectCharacterId, string comment)
        {
            var reservation = ResolveReservation(reservationId);
            if (reservation == null)
            {
                return Fail("未找到对应的游戏房间。");
            }

            var voteComment = (comment ?? string.Empty).Trim();
            if (voteComment.Length > 300)
            {
                return Fail("投票理由请控制在 300 字以内。");
            }

            var repository = new GameRepository();
            var success = repository.SubmitVote(reservation.Id, suspectCharacterId, voteComment, out var message);
            return new { success, message };
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object StartGame(int reservationId)
        {
            var reservation = ResolveReservation(reservationId);
            if (reservation == null)
            {
                return Fail("未找到对应的游戏房间。");
            }

            var currentUser = AuthManager.GetGameManagerUser();
            if (currentUser == null)
            {
                return Fail("只有管理员或 DM 可以正式开局。");
            }

            var repository = new GameRepository();
            var success = repository.StartGame(reservation.Id, currentUser.UserId, out var message);
            return new { success, message };
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object AdvanceStage(int reservationId)
        {
            var reservation = ResolveReservation(reservationId);
            if (reservation == null)
            {
                return Fail("未找到对应的游戏房间。");
            }

            var currentUser = AuthManager.GetGameManagerUser();
            if (currentUser == null)
            {
                return Fail("只有管理员或 DM 可以推进房间阶段。");
            }

            var repository = new GameRepository();
            var success = repository.AdvanceStage(reservation.Id, out var stageName, out var message);
            return new { success, message, stageName };
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object SetStage(int reservationId, int stageId)
        {
            var reservation = ResolveReservation(reservationId);
            if (reservation == null)
            {
                return Fail("未找到对应的游戏房间。");
            }

            var currentUser = AuthManager.GetGameManagerUser();
            if (currentUser == null)
            {
                return Fail("只有管理员或 DM 可以切换阶段。");
            }

            var repository = new GameRepository();
            var success = repository.SetStage(reservation.Id, stageId, out var stageName, out var message);
            return new { success, message, stageName };
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object FinishGame(int reservationId)
        {
            var reservation = ResolveReservation(reservationId);
            if (reservation == null)
            {
                return Fail("未找到对应的游戏房间。");
            }

            var currentUser = AuthManager.GetGameManagerUser();
            if (currentUser == null)
            {
                return Fail("只有管理员或 DM 可以执行正式结算。");
            }

            var repository = new GameRepository();
            var success = repository.FinishGame(reservation.Id, currentUser.UserId, out var message);
            return new { success, message };
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object BroadcastNotice(int reservationId, string content)
        {
            var reservation = ResolveReservation(reservationId);
            if (reservation == null)
            {
                return Fail("未找到对应的游戏房间。");
            }

            var currentUser = AuthManager.GetGameManagerUser();
            if (currentUser == null)
            {
                return Fail("只有管理员或 DM 可以发布房间公告。");
            }

            var messageContent = (content ?? string.Empty).Trim();
            if (string.IsNullOrWhiteSpace(messageContent))
            {
                return Fail("请输入要广播的房间公告。");
            }

            if (messageContent.Length > 200)
            {
                return Fail("房间公告请控制在 200 字以内。");
            }

            var repository = new GameRepository();
            var success = repository.BroadcastNotice(reservation.Id, messageContent, out var message);
            return new { success, message };
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object RevealClue(int reservationId, int clueId, int? targetReservationId)
        {
            var reservation = ResolveReservation(reservationId);
            if (reservation == null)
            {
                return Fail("未找到对应的游戏房间。");
            }

            var currentUser = AuthManager.GetGameManagerUser();
            if (currentUser == null)
            {
                return Fail("只有管理员或 DM 可以发放线索。");
            }

            var repository = new GameRepository();
            var success = repository.RevealClueByDm(reservation.Id, clueId, targetReservationId, out var message);
            return new { success, message };
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object SaveTruth(int reservationId, int characterId, string truthSummary)
        {
            var reservation = ResolveReservation(reservationId);
            if (reservation == null)
            {
                return Fail("未找到对应的游戏房间。");
            }

            var currentUser = AuthManager.GetGameManagerUser();
            if (currentUser == null)
            {
                return Fail("只有管理员或 DM 可以设置结案真相。");
            }

            var summary = (truthSummary ?? string.Empty).Trim();
            if (characterId <= 0)
            {
                return Fail("请选择真凶角色。");
            }

            if (string.IsNullOrWhiteSpace(summary))
            {
                return Fail("请填写真相摘要。");
            }

            if (summary.Length > 500)
            {
                return Fail("真相摘要请控制在 500 字以内。");
            }

            var repository = new GameRepository();
            var success = repository.SetCaseTruth(reservation.Id, characterId, summary, currentUser.UserId, out var message);
            return new { success, message };
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object SaveDmNotes(int reservationId, string notes)
        {
            var reservation = ResolveReservation(reservationId);
            if (reservation == null)
            {
                return Fail("未找到对应的游戏房间。");
            }

            var currentUser = AuthManager.GetGameManagerUser();
            if (currentUser == null)
            {
                return Fail("只有管理员或 DM 可以保存控场备注。");
            }

            var content = (notes ?? string.Empty).Trim();
            if (content.Length > 2000)
            {
                return Fail("DM 备注请控制在 2000 字以内。");
            }

            var repository = new GameRepository();
            var success = repository.SaveDmNotes(reservation.Id, content, currentUser.UserId, out var message);
            return new { success, message };
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object StartTimer(int reservationId, int durationMinutes)
        {
            var reservation = ResolveReservation(reservationId);
            if (reservation == null)
            {
                return Fail("未找到对应的游戏房间。");
            }

            var currentUser = AuthManager.GetGameManagerUser();
            if (currentUser == null)
            {
                return Fail("只有管理员或 DM 可以开启阶段计时。");
            }

            var repository = new GameRepository();
            var success = repository.StartStageTimer(reservation.Id, durationMinutes, currentUser.UserId, out var message);
            return new { success, message };
        }

        private static ReservationInfo ResolveReservation(int reservationId)
        {
            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser == null || reservationId <= 0)
            {
                return null;
            }

            var repository = new ContentRepository();
            var reservation = repository.GetReservationDetail(reservationId, currentUser.CanManageGameRoom ? (int?)null : currentUser.UserId);
            return reservation != null &&
                   (IsActiveReservation(reservation.Status) || (currentUser.CanManageGameRoom && IsHostEntryReservation(reservation.Status)))
                ? reservation
                : null;
        }

        private static bool IsHostEntryReservation(string status)
        {
            return string.Equals(status, "主持入口", StringComparison.Ordinal);
        }

        private static bool IsActiveReservation(string status)
        {
            switch (status)
            {
                case "待确认":
                case "已确认":
                case "玩家已确认":
                case "已到店":
                    return true;
                default:
                    return false;
            }
        }

        private static object Ok(string message)
        {
            return new { success = true, message };
        }

        private static object Fail(string message)
        {
            return new { success = false, message };
        }

        private static string GetRoomCode(int sessionId)
        {
            return "ROOM-" + sessionId.ToString("D4");
        }

        protected string RoomModuleKey
        {
            get
            {
                var module = (Request.QueryString["module"] ?? string.Empty).Trim().ToLowerInvariant();
                switch (module)
                {
                    case "stage":
                    case "character":
                    case "clue":
                    case "action":
                    case "vote":
                    case "ending":
                    case "participants":
                    case "media":
                    case "host":
                        return module;
                    default:
                        return "stage";
                }
            }
        }

        protected string RoomModuleUrl(string moduleKey)
        {
            var query = new List<string>();
            var reservationId = Request.QueryString["reservationId"];
            var sessionId = Request.QueryString["sessionId"];
            var host = Request.QueryString["host"];

            if (!string.IsNullOrWhiteSpace(reservationId))
            {
                query.Add("reservationId=" + HttpUtility.UrlEncode(reservationId));
            }
            else if (!string.IsNullOrWhiteSpace(sessionId))
            {
                query.Add("sessionId=" + HttpUtility.UrlEncode(sessionId));
            }

            query.Add("module=" + HttpUtility.UrlEncode((moduleKey ?? "stage").ToLowerInvariant()));

            if (!string.IsNullOrWhiteSpace(host))
            {
                query.Add("host=" + HttpUtility.UrlEncode(host));
            }

            return "GameRoom.aspx?" + string.Join("&", query);
        }

        protected string RoomFeatureUrl(string featureKey)
        {
            var key = (featureKey ?? string.Empty).Trim().ToLowerInvariant();
            var reservationId = Request.QueryString["reservationId"];
            if (string.IsNullOrWhiteSpace(reservationId))
            {
                return RoomModuleUrl(key);
            }

            var reservationQuery = "reservationId=" + HttpUtility.UrlEncode(reservationId);
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
                default:
                    return RoomModuleUrl(key);
            }
        }

        protected bool IsModuleActive(params string[] moduleKeys)
        {
            return moduleKeys.Any(moduleKey =>
                string.Equals(moduleKey, RoomModuleKey, StringComparison.OrdinalIgnoreCase));
        }

        protected string ModuleNavClass(string moduleKey)
        {
            return IsModuleActive(moduleKey) ? "is-active" : string.Empty;
        }

        protected string ModuleSectionClass(params string[] moduleKeys)
        {
            return IsModuleActive(moduleKeys) ? string.Empty : " room-module-page-hidden";
        }

        protected string ModuleItemClass(string moduleKey)
        {
            return IsModuleActive(moduleKey) ? string.Empty : " room-module-page-hidden";
        }

        private static string ToFullDateTimeText(DateTime? value)
        {
            return value.HasValue ? value.Value.ToString("yyyy-MM-dd HH:mm:ss") : string.Empty;
        }

        private static string ToShortDateTimeText(DateTime? value)
        {
            return value.HasValue ? value.Value.ToString("MM-dd HH:mm") : string.Empty;
        }
    }
}

