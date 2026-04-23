using System;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    public partial class GameLobbyPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireLogin();

            if (!IsPostBack)
            {
                BindLobby();
            }
        }

        protected void btnConfirmReservationReceived_Click(object sender, EventArgs e)
        {
            pnlLobbyMessage.Visible = true;
            var currentUser = AuthManager.GetCurrentUser();
            int reservationId;
            if (!TryGetReservationId(out reservationId) || currentUser == null)
            {
                ShowLobbyMessage("未找到可确认的预约订单。", false);
                return;
            }

            var success = _repository.ConfirmReservationByPlayer(reservationId, currentUser.UserId, out var message);
            ShowLobbyMessage(message, success);
            BindLobby();
        }

        protected void btnRequestReservationReschedule_Click(object sender, EventArgs e)
        {
            pnlLobbyMessage.Visible = true;
            var currentUser = AuthManager.GetCurrentUser();
            int reservationId;
            if (!TryGetReservationId(out reservationId) || currentUser == null)
            {
                ShowLobbyMessage("未找到可申请改期的预约订单。", false);
                return;
            }

            var success = _repository.RequestReservationReschedule(
                reservationId,
                currentUser.UserId,
                txtReservationRescheduleRemark.Text.Trim(),
                out var message);

            ShowLobbyMessage(message, success);
            BindLobby();
        }

        private void BindLobby()
        {
            var currentUser = AuthManager.GetCurrentUser();
            int reservationId;
            if (!TryGetReservationId(out reservationId))
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

            pnlNotFound.Visible = false;
            pnlLobby.Visible = true;

            var roomCode = "ROOM-" + reservation.SessionId.ToString("D4");
            var sessionText = reservation.SessionDateTime.ToString("yyyy-MM-dd HH:mm");

            litReservationId.Text = reservation.Id.ToString();
            litScriptName.Text = reservation.ScriptName;
            litRoomName.Text = reservation.RoomName;
            litHostName.Text = reservation.HostName;
            litTotalAmount.Text = reservation.TotalAmount.ToString("F2");
            litPlayerCount.Text = reservation.PlayerCount.ToString();
            litPaymentStatus.Text = reservation.PaymentStatus;
            litContactName.Text = reservation.ContactName;
            litSessionTime.Text = sessionText;
            litReservationStatus.Text = reservation.Status;
            litRoomCode.Text = roomCode;
            litAdminReply.Text = string.IsNullOrWhiteSpace(reservation.AdminReply)
                ? "门店暂未线上回复，请等待管理员确认。"
                : reservation.AdminReply;

            litRoomCodePreview.Text = roomCode;
            litSessionTimePreview.Text = sessionText;
            litHostNamePreview.Text = reservation.HostName;
            litScriptNamePreview.Text = reservation.ScriptName;
        }

        private void ShowNotFound()
        {
            pnlLobby.Visible = false;
            pnlNotFound.Visible = true;
        }

        private bool TryGetReservationId(out int reservationId)
        {
            return int.TryParse(Request.QueryString["reservationId"], out reservationId) && reservationId > 0;
        }

        private void ShowLobbyMessage(string message, bool success)
        {
            pnlLobbyMessage.CssClass = success ? "status-message success" : "status-message error";
            litLobbyMessage.Text = message;
        }
    }
}
