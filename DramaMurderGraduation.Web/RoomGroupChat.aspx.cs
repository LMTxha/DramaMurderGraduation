using System;
using System.Web;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// 房间群聊页后台逻辑，按预约场次加载同房玩家消息。
    /// </summary>
    public partial class RoomGroupChatPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();
        private readonly GameRepository _gameRepository = new GameRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireApprovedUser();

            if (!IsPostBack)
            {
                BindChat();
            }
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            var reservation = GetCurrentReservation();
            if (reservation == null)
            {
                ShowNotFound();
                return;
            }

            var content = (txtMessage.Text ?? string.Empty).Trim();
            if (string.IsNullOrWhiteSpace(content))
            {
                ShowFeedback("消息内容不能为空。");
                BindChat(reservation);
                return;
            }

            if (content.Length > 300)
            {
                ShowFeedback("消息内容请控制在 300 字以内。");
                BindChat(reservation);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            if (!CanReservationSpeak(reservation, currentUser, out var speechMessage))
            {
                ShowFeedback(speechMessage);
                BindChat(reservation);
                return;
            }

            _repository.AddRoomTextMessage(
                reservation.SessionId,
                reservation.Id,
                currentUser == null ? (int?)null : currentUser.UserId,
                GetRoomSenderName(currentUser, reservation),
                content,
                out var message);

            txtMessage.Text = string.Empty;
            ShowFeedback(message);
            BindChat(reservation);
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            pnlFeedback.Visible = false;
            BindChat();
        }

        protected string Encode(object value)
        {
            return HttpUtility.HtmlEncode(Convert.ToString(value) ?? string.Empty);
        }

        protected string FormatSentAt(object value)
        {
            if (value is DateTime sentAt)
            {
                return sentAt.ToString("MM-dd HH:mm:ss");
            }

            return string.Empty;
        }

        protected bool IsVoiceMessage(object value)
        {
            return string.Equals(Convert.ToString(value), "Voice", StringComparison.OrdinalIgnoreCase);
        }

        protected bool IsAssetMessage(object value)
        {
            return string.Equals(Convert.ToString(value), "Asset", StringComparison.OrdinalIgnoreCase);
        }

        protected bool IsPdfAsset(object value)
        {
            return HasMediaExtension(value, ".pdf");
        }

        protected bool IsAudioAsset(object value)
        {
            return HasMediaExtension(value, ".mp3", ".wav", ".m4a", ".aac", ".ogg");
        }

        protected bool IsVideoAsset(object value)
        {
            return HasMediaExtension(value, ".mp4", ".webm", ".mov", ".avi");
        }

        protected string GetAudioSource(object value)
        {
            var source = Convert.ToString(value) ?? string.Empty;
            return source.StartsWith("data:audio/", StringComparison.OrdinalIgnoreCase)
                ? HttpUtility.HtmlAttributeEncode(source)
                : string.Empty;
        }

        protected string GetMediaSource(object value)
        {
            return HttpUtility.HtmlAttributeEncode(Convert.ToString(value) ?? string.Empty);
        }

        private void BindChat(ReservationInfo existingReservation = null)
        {
            var reservation = existingReservation ?? GetCurrentReservation();
            if (reservation == null)
            {
                ShowNotFound();
                return;
            }

            _gameRepository.EnsureSessionGameData(reservation.SessionId);

            pnlNotFound.Visible = false;
            pnlChat.Visible = true;

            litRoomName.Text = RoomNavigationHelper.RenderRoomSelectLink(reservation);
            litScriptName.Text = Encode(reservation.ScriptName);
            litSessionTime.Text = reservation.SessionDateTime.ToString("yyyy-MM-dd HH:mm");
            lnkBackRoom.NavigateUrl = "GameRoom.aspx?reservationId=" + reservation.Id;
            lnkBackLobby.NavigateUrl = "GameLobby.aspx?reservationId=" + reservation.Id;

            rptParticipants.DataSource = _repository.GetRoomParticipants(reservation.SessionId);
            rptParticipants.DataBind();

            rptMessages.DataSource = _repository.GetRoomMessages(reservation.SessionId, 120);
            rptMessages.DataBind();
        }

        private ReservationInfo GetCurrentReservation()
        {
            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser == null)
            {
                return null;
            }

            if (!int.TryParse(Request.QueryString["reservationId"], out var reservationId) || reservationId <= 0)
            {
                return null;
            }

            return _repository.GetReservationDetail(reservationId, currentUser.CanManageGameRoom ? (int?)null : currentUser.UserId);
        }

        private bool CanReservationSpeak(ReservationInfo reservation, CurrentUserInfo currentUser, out string message)
        {
            message = string.Empty;
            if (reservation == null)
            {
                message = "未找到对应的游戏房间。";
                return false;
            }

            if (currentUser != null && currentUser.CanManageGameRoom)
            {
                return true;
            }

            var gameState = _gameRepository.GetGameRoomState(reservation.SessionId, reservation.Id);
            if (gameState.Lifecycle != null && gameState.Lifecycle.IsGameEnded)
            {
                message = "当前房间已经结算，不能继续发送群聊消息。";
                return false;
            }

            return true;
        }

        private void ShowNotFound()
        {
            pnlChat.Visible = false;
            pnlNotFound.Visible = true;
        }

        private void ShowFeedback(string message)
        {
            pnlFeedback.Visible = true;
            litFeedback.Text = Encode(message);
        }

        private static string GetRoomSenderName(CurrentUserInfo currentUser, ReservationInfo reservation)
        {
            if (currentUser != null && currentUser.CanManageGameRoom)
            {
                var displayName = string.IsNullOrWhiteSpace(currentUser.DisplayName)
                    ? currentUser.Username
                    : currentUser.DisplayName;
                var roleName = currentUser.IsAdmin ? "管理员" : "DM";
                return string.IsNullOrWhiteSpace(displayName) ? roleName : roleName + " " + displayName;
            }

            if (currentUser != null && !string.IsNullOrWhiteSpace(currentUser.DisplayName))
            {
                return currentUser.DisplayName;
            }

            return reservation == null ? "玩家" : reservation.ContactName;
        }

        private static bool HasMediaExtension(object value, params string[] extensions)
        {
            var source = (Convert.ToString(value) ?? string.Empty).ToLowerInvariant();
            foreach (var extension in extensions)
            {
                if (source.EndsWith(extension, StringComparison.OrdinalIgnoreCase) || source.IndexOf(extension + "?", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    return true;
                }
            }

            return false;
        }
    }
}
