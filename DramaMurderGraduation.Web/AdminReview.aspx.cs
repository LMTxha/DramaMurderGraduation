using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class AdminReviewPage : System.Web.UI.Page
    {
        private readonly AccountRepository _accountRepository = new AccountRepository();
        private readonly ContentRepository _contentRepository = new ContentRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireAdmin();

            if (!IsPostBack)
            {
                BindFilterOptions();
                BindAll();
            }
        }

        protected void btnApplyAdminFilter_Click(object sender, EventArgs e)
        {
            BindAll();
        }

        protected void btnResetAdminFilter_Click(object sender, EventArgs e)
        {
            txtAdminKeyword.Text = string.Empty;
            ddlStoreStatusFilter.SelectedValue = string.Empty;
            ddlReservationStatusFilter.SelectedValue = string.Empty;
            ddlAdminDateFilter.SelectedValue = string.Empty;
            BindAll();
        }

        protected void rptPendingUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var userId))
            {
                return;
            }

            var remarkBox = e.Item.FindControl("txtUserRemark") as TextBox;
            var success = _accountRepository.ReviewUser(userId, e.CommandName == "ApproveUser", remarkBox?.Text.Trim(), out var message);
            ShowMessage(message, success);
            BindAll();
        }

        protected void rptPendingScripts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var scriptId))
            {
                return;
            }

            var remarkBox = e.Item.FindControl("txtScriptRemark") as TextBox;
            var success = _contentRepository.ReviewScriptSubmission(scriptId, e.CommandName == "ApproveScript", remarkBox?.Text.Trim(), out var message);
            ShowMessage(message, success);
            BindAll();
        }

        protected void rptPendingRechargeRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var requestId))
            {
                return;
            }

            var remarkBox = e.Item.FindControl("txtRechargeRemark") as TextBox;
            var currentUser = AuthManager.GetCurrentUser();
            var success = _accountRepository.ReviewRechargeRequest(
                requestId,
                e.CommandName == "ApproveRecharge",
                remarkBox?.Text.Trim(),
                currentUser == null ? 0 : currentUser.UserId,
                out var message);

            ShowMessage(message, success);
            BindAll();
        }

        protected void rptStoreVisitRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var requestId))
            {
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var assignedRoomBox = e.Item.FindControl("txtAssignedRoomName") as TextBox;
            var remarkBox = e.Item.FindControl("txtStoreRemark") as TextBox;
            var replyBox = e.Item.FindControl("txtStoreReply") as TextBox;
            var requestStatus = MapStoreVisitStatus(e.CommandName);

            if (string.IsNullOrWhiteSpace(requestStatus))
            {
                return;
            }

            var success = _contentRepository.ReviewStoreVisitRequest(
                requestId,
                requestStatus,
                assignedRoomBox?.Text.Trim(),
                remarkBox?.Text.Trim(),
                BuildStoreVisitReply(e.CommandName, assignedRoomBox?.Text.Trim(), replyBox?.Text.Trim()),
                currentUser == null ? 0 : currentUser.UserId,
                out var message);

            ShowMessage(message, success);
            BindAll();
        }

        protected void rptReservationOrders_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var reservationId))
            {
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var remarkBox = e.Item.FindControl("txtReservationRemark") as TextBox;
            var replyBox = e.Item.FindControl("txtReservationReply") as TextBox;
            var reservationStatus = MapReservationStatus(e.CommandName);

            if (string.IsNullOrWhiteSpace(reservationStatus))
            {
                return;
            }

            var success = _contentRepository.ReviewReservation(
                reservationId,
                reservationStatus,
                null,
                remarkBox?.Text.Trim(),
                BuildReservationReply(e.CommandName, replyBox?.Text.Trim()),
                currentUser == null ? 0 : currentUser.UserId,
                out var message);

            ShowMessage(message, success);
            BindAll();
        }

        protected void rptAllScripts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "DeleteScript")
            {
                return;
            }

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var scriptId))
            {
                return;
            }

            var success = _contentRepository.DeleteScript(scriptId, out var message);
            ShowMessage(message, success);
            BindAll();
        }

        protected void btnCreateSession_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(ddlScheduleScript.SelectedValue, out var scriptId) || scriptId <= 0)
            {
                ShowMessage("请选择要排期的剧本。", false);
                return;
            }

            if (!int.TryParse(ddlScheduleRoom.SelectedValue, out var roomId) || roomId <= 0)
            {
                ShowMessage("请选择要安排的房间。", false);
                return;
            }

            if (!TryParseScheduleDateTime(txtScheduleDateTime.Text, out var sessionDateTime))
            {
                ShowMessage("请填写正确的开场时间，格式如 2026-04-18 19:30。", false);
                return;
            }

            if (!decimal.TryParse(txtSchedulePrice.Text, NumberStyles.Number, CultureInfo.InvariantCulture, out var basePrice) &&
                !decimal.TryParse(txtSchedulePrice.Text, NumberStyles.Number, CultureInfo.GetCultureInfo("zh-CN"), out basePrice))
            {
                ShowMessage("请填写正确的人均价格。", false);
                return;
            }

            if (!int.TryParse(txtScheduleMaxPlayers.Text, out var maxPlayers))
            {
                ShowMessage("请填写正确的最大人数。", false);
                return;
            }

            var success = _contentRepository.CreateAdminSession(
                scriptId,
                roomId,
                sessionDateTime,
                txtScheduleHostName.Text.Trim(),
                basePrice,
                maxPlayers,
                out var message);

            ShowMessage(message, success);
            BindAll();
        }

        protected void btnPublishAnnouncement_Click(object sender, EventArgs e)
        {
            var success = _contentRepository.CreateAnnouncement(
                txtAnnouncementTitle.Text.Trim(),
                txtAnnouncementSummary.Text.Trim(),
                chkAnnouncementImportant.Checked,
                out var message);

            ShowMessage(message, success);
            BindAll();
        }

        protected void rptAdminRooms_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var roomId))
            {
                return;
            }

            var roomStatus = MapRoomStatus(e.CommandName);
            if (string.IsNullOrWhiteSpace(roomStatus))
            {
                return;
            }

            var success = _contentRepository.UpdateRoomStatus(roomId, roomStatus, out var message);
            ShowMessage(message, success);
            BindAll();
        }

        public string TranslateAuditStatus(object value)
        {
            var status = Convert.ToString(value);
            switch (status)
            {
                case "Approved":
                    return "已通过";
                case "Rejected":
                    return "已驳回";
                default:
                    return "待审核";
            }
        }

        public string TranslatePaymentMethod(object value)
        {
            switch (Convert.ToString(value))
            {
                case "BankCard":
                    return "银行卡支付";
                case "ScanCode":
                    return "扫码支付";
                default:
                    return "微信支付";
            }
        }

        public string TranslateStoreVisitStatus(object value)
        {
            var status = Convert.ToString(value);
            switch (status)
            {
                case "已安排排期":
                    return "已安排排期";
                case "已到店完成":
                    return "已到店完成";
                case "已关闭":
                    return "已关闭";
                case "待门店联系":
                    return "待门店联系";
                default:
                    return string.IsNullOrWhiteSpace(status) ? "待门店联系" : status;
            }
        }

        public string TranslateReservationStatus(object value)
        {
            var status = Convert.ToString(value);
            switch (status)
            {
                case "待确认":
                    return "待确认";
                case "已确认":
                    return "已确认";
                case "已到店":
                    return "已到店";
                case "已取消":
                    return "已取消";
                default:
                    return string.IsNullOrWhiteSpace(status) ? "待确认" : status;
            }
        }

        public string TranslateBusinessType(object value)
        {
            switch (Convert.ToString(value))
            {
                case "StoreVisit":
                    return "到店联系单";
                case "Reservation":
                    return "预约订单";
                case "Session":
                    return "场次排期";
                default:
                    return Convert.ToString(value);
            }
        }

        private void BindAll()
        {
            var pendingUsers = _accountRepository.GetPendingUsers();
            var pendingRechargeRequests = _accountRepository.GetPendingRechargeRequests();
            var pendingScripts = _contentRepository.GetPendingScriptSubmissions();
            var keyword = txtAdminKeyword == null ? string.Empty : txtAdminKeyword.Text.Trim();
            var dateFilter = GetSelectedValue(ddlAdminDateFilter);
            var storeVisitRequests = _contentRepository.GetStoreVisitRequests(30, null, GetSelectedValue(ddlStoreStatusFilter), keyword, dateFilter);
            var reservationOrders = _contentRepository.GetReservationsForAdmin(30, GetSelectedValue(ddlReservationStatusFilter), keyword, dateFilter);
            var allStoreVisitRequests = _contentRepository.GetStoreVisitRequests(999);
            var allReservationOrders = _contentRepository.GetReservationsForAdmin(999);
            var allScripts = _contentRepository.GetAllScriptsForAdmin();
            var rooms = _contentRepository.GetRooms();
            var upcomingSessions = _contentRepository.GetUpcomingSessions(12);
            var announcements = _contentRepository.GetAnnouncements(6);
            var approvedScripts = allScripts
                .Where(item => string.Equals(item.AuditStatus, "Approved", StringComparison.OrdinalIgnoreCase))
                .OrderBy(item => item.Name)
                .ToList();

            rptPendingUsers.DataSource = pendingUsers;
            rptPendingUsers.DataBind();

            rptPendingRechargeRequests.DataSource = pendingRechargeRequests;
            rptPendingRechargeRequests.DataBind();

            rptPendingScripts.DataSource = pendingScripts;
            rptPendingScripts.DataBind();

            rptStoreVisitRequests.DataSource = storeVisitRequests;
            rptStoreVisitRequests.DataBind();

            rptReservationOrders.DataSource = reservationOrders;
            rptReservationOrders.DataBind();

            rptAdminReplyLogs.DataSource = _contentRepository.GetRecentAdminReplyLogs(8);
            rptAdminReplyLogs.DataBind();

            rptBusinessActionLogs.DataSource = _contentRepository.GetRecentBusinessActionLogs(8);
            rptBusinessActionLogs.DataBind();

            rptAdminRooms.DataSource = rooms;
            rptAdminRooms.DataBind();

            rptAdminSessions.DataSource = upcomingSessions;
            rptAdminSessions.DataBind();

            rptAdminAnnouncements.DataSource = announcements;
            rptAdminAnnouncements.DataBind();

            rptAllScripts.DataSource = allScripts;
            rptAllScripts.DataBind();

            BindAdminForms(approvedScripts, rooms);
            BindSummary(pendingUsers, pendingRechargeRequests, pendingScripts, allStoreVisitRequests, allReservationOrders, allScripts);
        }

        private void BindFilterOptions()
        {
            ddlStoreStatusFilter.Items.Clear();
            ddlStoreStatusFilter.Items.Add(new ListItem("全部到店联系单", string.Empty));
            ddlStoreStatusFilter.Items.Add(new ListItem("待门店联系", "待门店联系"));
            ddlStoreStatusFilter.Items.Add(new ListItem("已安排排期", "已安排排期"));
            ddlStoreStatusFilter.Items.Add(new ListItem("玩家已确认", "玩家已确认"));
            ddlStoreStatusFilter.Items.Add(new ListItem("玩家申请改期", "玩家申请改期"));
            ddlStoreStatusFilter.Items.Add(new ListItem("已到店完成", "已到店完成"));
            ddlStoreStatusFilter.Items.Add(new ListItem("已关闭", "已关闭"));

            ddlReservationStatusFilter.Items.Clear();
            ddlReservationStatusFilter.Items.Add(new ListItem("全部预约订单", string.Empty));
            ddlReservationStatusFilter.Items.Add(new ListItem("待确认", "待确认"));
            ddlReservationStatusFilter.Items.Add(new ListItem("已确认", "已确认"));
            ddlReservationStatusFilter.Items.Add(new ListItem("玩家已确认", "玩家已确认"));
            ddlReservationStatusFilter.Items.Add(new ListItem("申请改期", "申请改期"));
            ddlReservationStatusFilter.Items.Add(new ListItem("已到店", "已到店"));
            ddlReservationStatusFilter.Items.Add(new ListItem("已完成", "已完成"));
            ddlReservationStatusFilter.Items.Add(new ListItem("已取消", "已取消"));

            ddlAdminDateFilter.Items.Clear();
            ddlAdminDateFilter.Items.Add(new ListItem("全部日期", string.Empty));
            ddlAdminDateFilter.Items.Add(new ListItem("今天", "Today"));
            ddlAdminDateFilter.Items.Add(new ListItem("明天", "Tomorrow"));
            ddlAdminDateFilter.Items.Add(new ListItem("未来 7 天", "Next7Days"));
        }

        private static string GetSelectedValue(DropDownList list)
        {
            return list == null || string.IsNullOrWhiteSpace(list.SelectedValue) ? null : list.SelectedValue;
        }

        private void BindSummary(
            IList<UserAccountInfo> pendingUsers,
            IList<RechargeRequestInfo> pendingRechargeRequests,
            IList<ScriptInfo> pendingScripts,
            IList<StoreVisitRequestInfo> storeVisitRequests,
            IList<ReservationInfo> reservationOrders,
            IList<ScriptInfo> allScripts)
        {
            litPendingUserCount.Text = pendingUsers.Count.ToString();
            litPendingRechargeCount.Text = pendingRechargeRequests.Count.ToString();
            litPendingScriptCount.Text = pendingScripts.Count.ToString();
            litStoreVisitCount.Text = storeVisitRequests.Count.ToString();
            litReservationCount.Text = reservationOrders.Count.ToString();
            litTotalScriptCount.Text = allScripts.Count.ToString();
            litPendingUserCountSummary.Text = litPendingUserCount.Text;
            litPendingRechargeCountSummary.Text = litPendingRechargeCount.Text;
            litStoreVisitCountSummary.Text = litStoreVisitCount.Text;
            litReservationCountSummary.Text = litReservationCount.Text;

            var today = DateTime.Today;
            litTodayStoreCount.Text = storeVisitRequests.Count(item => item.PreferredArriveTime.Date == today).ToString();
            litTodayReservationCount.Text = reservationOrders.Count(item => item.SessionDateTime.Date == today).ToString();
            litUpcomingSessionCount.Text = _contentRepository.GetUpcomingSessions(999).Count.ToString();
            litAnnouncementCount.Text = _contentRepository.GetAnnouncements(999).Count.ToString();
            litArrangedStoreCount.Text = storeVisitRequests.Count(item => item.RequestStatus == "已安排排期" || item.RequestStatus == "已到店完成").ToString();
            litConfirmedReservationCount.Text = reservationOrders.Count(item => item.Status == "已确认" || item.Status == "已到店").ToString();
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = success ? "status-message success" : "status-message error";
            litMessage.Text = message;
        }

        private static string MapStoreVisitStatus(string commandName)
        {
            switch (commandName)
            {
                case "ArrangeStore":
                    return "已安排排期";
                case "CompleteStore":
                    return "已到店完成";
                case "CloseStore":
                    return "已关闭";
                default:
                    return string.Empty;
            }
        }

        private static string BuildStoreVisitReply(string commandName, string assignedRoomName, string customReply)
        {
            if (!string.IsNullOrWhiteSpace(customReply))
            {
                return customReply.Trim();
            }

            var roomName = string.IsNullOrWhiteSpace(assignedRoomName) ? "门店待确认房间" : assignedRoomName.Trim();
            switch (commandName)
            {
                case "ArrangeStore":
                    return "门店已为你安排排期，房间：" + roomName + "。请按预约到店时间到店，现场会协助开本。";
                case "CompleteStore":
                    return "已登记到店完成，感谢你选择本店，后续可以在个人页面查看这次到店记录。";
                case "CloseStore":
                    return "这张到店联系单已关闭，如需重新安排请再次提交到店需求。";
                default:
                    return string.Empty;
            }
        }

        private static string MapReservationStatus(string commandName)
        {
            switch (commandName)
            {
                case "ConfirmReservation":
                    return "已确认";
                case "ArriveReservation":
                    return "已到店";
                case "CancelReservation":
                    return "已取消";
                default:
                    return string.Empty;
            }
        }

        private static string BuildReservationReply(string commandName, string customReply)
        {
            if (!string.IsNullOrWhiteSpace(customReply))
            {
                return customReply.Trim();
            }

            switch (commandName)
            {
                case "ConfirmReservation":
                    return "预约已确认，门店会按场次时间为你保留席位。";
                case "ArriveReservation":
                    return "已登记到店，工作人员会协助你进入房间并开始游戏。";
                case "CancelReservation":
                    return "预约已取消，如需改期请重新选择场次预约。";
                default:
                    return string.Empty;
            }
        }

        private void BindAdminForms(IList<ScriptInfo> approvedScripts, IList<RoomInfo> rooms)
        {
            ddlScheduleScript.DataSource = approvedScripts;
            ddlScheduleScript.DataTextField = "Name";
            ddlScheduleScript.DataValueField = "Id";
            ddlScheduleScript.DataBind();
            ddlScheduleScript.Items.Insert(0, new ListItem("请选择剧本", string.Empty));

            ddlScheduleRoom.DataSource = rooms.OrderBy(item => item.Name).ToList();
            ddlScheduleRoom.DataTextField = "Name";
            ddlScheduleRoom.DataValueField = "Id";
            ddlScheduleRoom.DataBind();
            ddlScheduleRoom.Items.Insert(0, new ListItem("请选择房间", string.Empty));

            txtScheduleDateTime.Text = DateTime.Now.AddDays(1).Date.AddHours(19).AddMinutes(30).ToString("yyyy-MM-dd HH:mm");
            if (string.IsNullOrWhiteSpace(txtScheduleHostName.Text))
            {
                txtScheduleHostName.Text = "门店 DM";
            }

            txtSchedulePrice.Text = "228";
            txtScheduleMaxPlayers.Text = "6";
            txtAnnouncementTitle.Text = string.Empty;
            txtAnnouncementSummary.Text = string.Empty;
            chkAnnouncementImportant.Checked = false;
        }

        private static bool TryParseScheduleDateTime(string rawText, out DateTime value)
        {
            var formats = new[]
            {
                "yyyy-MM-dd HH:mm",
                "yyyy-M-d H:mm",
                "yyyy-MM-ddTHH:mm",
                "yyyy-M-dTH:mm",
                "yyyy/MM/dd HH:mm"
            };

            return DateTime.TryParseExact(rawText ?? string.Empty, formats, CultureInfo.InvariantCulture, DateTimeStyles.None, out value) ||
                   DateTime.TryParse(rawText, CultureInfo.GetCultureInfo("zh-CN"), DateTimeStyles.None, out value);
        }

        private static string MapRoomStatus(string commandName)
        {
            switch (commandName)
            {
                case "EnableRoom":
                    return "启用中";
                case "MaintainRoom":
                    return "维护中";
                case "PauseRoom":
                    return "暂停接待";
                default:
                    return string.Empty;
            }
        }
    }
}
