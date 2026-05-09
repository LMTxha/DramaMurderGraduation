using System;
using DramaMurderGraduation.Web.Data;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// GameLobby.aspx 页面后台逻辑，负责当前 Web Forms 页面的权限校验、数据绑定和事件处理。
    /// </summary>
    public partial class GameLobbyPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();

        /// <summary>
        /// 页面生命周期入口，负责权限校验和首次加载时的数据初始化。
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireApprovedUser();

            if (!IsPostBack)
            {
                BindLobby();
            }
        }

        /// <summary>
        /// 处理页面按钮点击事件，并根据当前表单输入刷新或提交业务数据。
        /// </summary>
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

        /// <summary>
        /// 处理页面按钮点击事件，并根据当前表单输入刷新或提交业务数据。
        /// </summary>
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

        protected void btnLeaveReservation_Click(object sender, EventArgs e)
        {
            pnlLobbyMessage.Visible = true;
            var currentUser = AuthManager.GetCurrentUser();
            int reservationId;
            if (!TryGetReservationId(out reservationId) || currentUser == null || currentUser.CanManageGameRoom)
            {
                ShowLobbyMessage("未找到可退出的游戏预约。", false);
                return;
            }

            var success = _repository.LeaveReservationByPlayer(reservationId, currentUser.UserId, out var message);
            if (success)
            {
                Response.Redirect("~/PlayerHub.aspx?tab=orders", true);
                return;
            }

            ShowLobbyMessage(message, false);
            BindLobby();
        }

        /// <summary>
        /// 绑定页面展示数据到对应控件。
        /// </summary>
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
            litRoomName.Text = RoomNavigationHelper.RenderRoomSelectLink(reservation);
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
            btnLeaveReservation.Visible = currentUser != null
                && !currentUser.CanManageGameRoom
                && CanLeaveReservation(reservation.Status);
        }

        /// <summary>
        /// 设置页面控件状态或提示信息。
        /// </summary>
        private void ShowNotFound()
        {
            pnlLobby.Visible = false;
            pnlNotFound.Visible = true;
        }

        /// <summary>
        /// 尝试解析或校验输入，并通过返回值表示是否成功。
        /// </summary>
        private bool TryGetReservationId(out int reservationId)
        {
            return int.TryParse(Request.QueryString["reservationId"], out reservationId) && reservationId > 0;
        }

        private static bool CanLeaveReservation(string status)
        {
            switch (status)
            {
                case "待确认":
                case "已确认":
                case "玩家已确认":
                case "申请改期":
                case "已到店":
                    return true;
                default:
                    return false;
            }
        }

        /// <summary>
        /// 设置页面控件状态或提示信息。
        /// </summary>
        private void ShowLobbyMessage(string message, bool success)
        {
            pnlLobbyMessage.CssClass = success ? "status-message success" : "status-message error";
            litLobbyMessage.Text = message;
        }
    }
}
