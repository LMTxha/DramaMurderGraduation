using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class OrderConversationPage : Page
    {
        private readonly ContentRepository _repository = new ContentRepository();

        protected int ReservationId { get; private set; }
        protected bool CurrentUserIsAdmin { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireLogin();

            if (!IsPostBack)
            {
                BindPage();
            }
        }

        protected void btnSendMessage_Click(object sender, EventArgs e)
        {
            pnlComposeMessage.Visible = true;

            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser == null || !TryGetReservationId(out var reservationId))
            {
                ShowComposeMessage("未找到对应订单。", false);
                return;
            }

            var reservation = _repository.GetReservationDetail(
                reservationId,
                currentUser.IsAdmin ? (int?)null : currentUser.UserId);

            if (reservation == null)
            {
                ShowComposeMessage("当前账号不能向这笔订单发送消息。", false);
                ShowNotFound();
                return;
            }

            var success = _repository.AddServiceMessage(
                "Reservation",
                reservationId,
                currentUser.UserId,
                currentUser.IsAdmin,
                txtMessageContent.Text.Trim(),
                out var message);

            ShowComposeMessage(message, success);
            if (success)
            {
                txtMessageContent.Text = string.Empty;
            }

            BindPage();
        }

        private void BindPage()
        {
            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser == null || !TryGetReservationId(out var reservationId))
            {
                ShowNotFound();
                return;
            }

            var reservation = _repository.GetReservationDetail(
                reservationId,
                currentUser.IsAdmin ? (int?)null : currentUser.UserId);

            if (reservation == null)
            {
                ShowNotFound();
                return;
            }

            ReservationId = reservation.Id;
            CurrentUserIsAdmin = currentUser.IsAdmin;

            _repository.MarkServiceMessagesAsRead("Reservation", reservation.Id, currentUser.UserId, currentUser.IsAdmin, out _);
            var messages = _repository.GetServiceMessages("Reservation", reservation.Id, currentUser.UserId, currentUser.IsAdmin, 120);

            pnlNotFound.Visible = false;
            pnlConversation.Visible = true;
            pnlComposeMessage.Visible = false;

            litReservationId.Text = reservation.Id.ToString();
            litScriptName.Text = Server.HtmlEncode(reservation.ScriptName);
            litSessionTime.Text = reservation.SessionDateTime.ToString("yyyy-MM-dd HH:mm");
            litRoomName.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(reservation.RoomName) ? "待安排" : reservation.RoomName);
            litHostName.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(reservation.HostName) ? "待分配" : reservation.HostName);
            litContactName.Text = Server.HtmlEncode(reservation.ContactName);
            litReservationStatus.Text = Server.HtmlEncode(reservation.Status);
            litPaymentStatus.Text = Server.HtmlEncode(reservation.PaymentStatus);
            litMessageCount.Text = messages.Count.ToString();
            litLastMessageTime.Text = messages.Count > 0
                ? messages[messages.Count - 1].CreatedAt.ToString("yyyy-MM-dd HH:mm")
                : "暂无消息";
            litUnreadSummary.Text = BuildUnreadSummary(messages, currentUser.IsAdmin);
            litUserRemark.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(reservation.Remark) ? "未填写订单备注。" : reservation.Remark);
            litAdminRemark.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(reservation.AdminRemark) ? "门店暂未填写内部备注。" : reservation.AdminRemark);

            lnkOrderDetails.NavigateUrl = "OrderDetails.aspx?reservationId=" + reservation.Id;
            lnkPlayerHub.Visible = !currentUser.IsAdmin;
            lnkAdminReview.Visible = currentUser.IsAdmin;

            rptMessages.DataSource = messages;
            rptMessages.DataBind();
            litThreadEmpty.Text = messages.Count == 0
                ? "<p class=\"inline-note\">当前订单还没有沟通记录，发送首条消息后会按时间沉淀在这里。</p>"
                : string.Empty;
        }

        protected string GetMessageCssClass(object dataItem)
        {
            var message = dataItem as ServiceMessageInfo;
            if (message == null)
            {
                return "system";
            }

            return string.Equals(message.SenderRole, "Admin", StringComparison.OrdinalIgnoreCase)
                ? "admin"
                : "user";
        }

        protected string GetSenderRoleText(object senderRole)
        {
            return string.Equals(Convert.ToString(senderRole), "Admin", StringComparison.OrdinalIgnoreCase)
                ? "门店客服"
                : "玩家";
        }

        protected string GetReadStateText(object dataItem)
        {
            var message = dataItem as ServiceMessageInfo;
            if (message == null)
            {
                return string.Empty;
            }

            if (string.Equals(message.SenderRole, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                return message.IsReadByUser ? "玩家已查看" : "玩家未查看";
            }

            return message.IsReadByAdmin ? "门店已查看" : "门店未查看";
        }

        private static string BuildUnreadSummary(IList<ServiceMessageInfo> messages, bool currentUserIsAdmin)
        {
            var unreadIncomingCount = messages.Count(item =>
                currentUserIsAdmin
                    ? string.Equals(item.SenderRole, "User", StringComparison.OrdinalIgnoreCase) && !item.IsReadByAdmin
                    : string.Equals(item.SenderRole, "Admin", StringComparison.OrdinalIgnoreCase) && !item.IsReadByUser);

            return unreadIncomingCount > 0
                ? "共 " + unreadIncomingCount + " 条未读来信"
                : "当前没有未读消息";
        }

        private void ShowComposeMessage(string message, bool success)
        {
            pnlComposeMessage.Visible = true;
            pnlComposeMessage.CssClass = success ? "status-message success" : "status-message error";
            litComposeMessage.Text = Server.HtmlEncode(message);
        }

        private void ShowNotFound()
        {
            pnlNotFound.Visible = true;
            pnlConversation.Visible = false;
        }

        private bool TryGetReservationId(out int reservationId)
        {
            return int.TryParse(Request.QueryString["reservationId"], out reservationId) && reservationId > 0;
        }
    }
}
