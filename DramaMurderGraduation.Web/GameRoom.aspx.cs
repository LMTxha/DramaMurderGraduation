using System;
using System.Linq;
using System.Web.Script.Services;
using System.Web.Services;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class GameRoomPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();
        private readonly GameRepository _gameRepository = new GameRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireApprovedUser();

            if (!IsPostBack)
            {
                BindRoom();
            }
        }

        private void BindRoom()
        {
            var currentUser = AuthManager.GetCurrentUser();
            int reservationId;
            if (!int.TryParse(Request.QueryString["reservationId"], out reservationId) || reservationId <= 0)
            {
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

            _gameRepository.EnsureSessionGameData(reservation.SessionId);

            pnlNotFound.Visible = false;
            pnlRoom.Visible = true;

            litReservationId.Text = reservation.Id.ToString();
            litReservationStatus.Text = reservation.Status;
            litRoomCode.Text = GetRoomCode(reservation.SessionId);
            litScriptName.Text = reservation.ScriptName;
            litHostName.Text = reservation.HostName;
            litHostNameAside.Text = reservation.HostName;
            litTotalAmount.Text = reservation.TotalAmount.ToString("F2");
            litPlayerCount.Text = reservation.PlayerCount.ToString();
            litPaymentStatus.Text = reservation.PaymentStatus;
            litRoomName.Text = reservation.RoomName;
            litSessionTime.Text = reservation.SessionDateTime.ToString("yyyy-MM-dd HH:mm");
            litContactName.Text = reservation.ContactName;
        }

        private void ShowNotFound()
        {
            pnlRoom.Visible = false;
            pnlNotFound.Visible = true;
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
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
                        game.CurrentAssignment.IsReady
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
                        item.IsReady
                    }).ToList(),
                    clues = game.Clues.Select(item => new
                    {
                        item.Id,
                        item.StageName,
                        item.Title,
                        item.Summary,
                        item.Detail,
                        item.ClueType,
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
                            item.ClueType,
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
            return repository.GetReservationDetail(reservationId, currentUser.CanManageGameRoom ? (int?)null : currentUser.UserId);
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

