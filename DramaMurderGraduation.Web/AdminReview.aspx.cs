using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class AdminReviewPage : System.Web.UI.Page
    {
        private readonly AccountRepository _accountRepository = new AccountRepository();
        private readonly ContentRepository _contentRepository = new ContentRepository();
        protected bool CanManageMembers { get; private set; }
        protected bool CanManageFinance { get; private set; }
        protected bool CanManageOperations { get; private set; }
        protected bool CanManageContent { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireAdminConsole();
            ApplyCapabilityState();

            if (string.Equals(Request.QueryString["export"], "finance", StringComparison.OrdinalIgnoreCase))
            {
                if (!EnsureCapability(CanManageFinance, "当前账号没有导出财务报表的权限。"))
                {
                    return;
                }

                ExportFinanceAuditCsv();
                return;
            }

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
            if (!EnsureCapability(CanManageMembers, "当前账号不能处理账号审核和角色管理。"))
            {
                return;
            }

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out var userId))
            {
                return;
            }

            var remarkBox = e.Item.FindControl("txtUserRemark") as TextBox;
            bool success;
            string message;
            if (string.Equals(e.CommandName, "UpdateRole", StringComparison.OrdinalIgnoreCase))
            {
                var roleList = e.Item.FindControl("ddlUserRole") as DropDownList;
                success = _accountRepository.UpdateUserRole(userId, roleList == null ? string.Empty : roleList.SelectedValue, out message);
            }
            else
            {
                success = _accountRepository.ReviewUser(userId, e.CommandName == "ApproveUser", remarkBox?.Text.Trim(), out message);
            }
            ShowMessage(message, success);
            BindAll();
        }

        protected void rptPendingScripts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!EnsureCapability(CanManageContent, "当前账号不能处理剧本审核。"))
            {
                return;
            }

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
            if (!EnsureCapability(CanManageFinance, "当前账号不能处理充值审核。"))
            {
                return;
            }

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
            if (!EnsureCapability(CanManageOperations, "当前账号不能处理到店联系单。"))
            {
                return;
            }

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
            if (!EnsureCapability(CanManageOperations, "当前账号不能处理预约履约。"))
            {
                return;
            }

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

        protected void rptAfterSaleRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!EnsureCapability(CanManageOperations, "当前账号不能处理售后和退款。"))
            {
                return;
            }

            if (e.CommandName != "ReviewAfterSale" || !int.TryParse(Convert.ToString(e.CommandArgument), out var requestId))
            {
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var statusList = e.Item.FindControl("ddlAfterSaleStatus") as DropDownList;
            var replyBox = e.Item.FindControl("txtAfterSaleReply") as TextBox;
            var rejectReasonBox = e.Item.FindControl("txtAfterSaleRejectReason") as TextBox;
            var remarkBox = e.Item.FindControl("txtAfterSaleRemark") as TextBox;
            var success = _contentRepository.ReviewAfterSaleRequest(
                requestId,
                statusList?.SelectedValue,
                replyBox?.Text.Trim(),
                remarkBox?.Text.Trim(),
                rejectReasonBox?.Text.Trim(),
                currentUser == null ? 0 : currentUser.UserId,
                out var message);

            ShowMessage(message, success);
            BindAll();
        }

        protected void btnCheckInReservation_Click(object sender, EventArgs e)
        {
            if (!EnsureCapability(CanManageOperations, "当前账号不能执行到店核销。"))
            {
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _contentRepository.CheckInReservationByCode(
                txtCheckInCode.Text.Trim(),
                currentUser == null ? 0 : currentUser.UserId,
                out var message);

            ShowMessage(message, success);
            if (success)
            {
                txtCheckInCode.Text = string.Empty;
            }

            BindAll();
        }

        protected void rptServiceMessages_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!EnsureCapability(CanManageOperations, "当前账号不能回复服务会话。"))
            {
                return;
            }

            if (e.CommandName != "ReplyService")
            {
                return;
            }

            var parts = Convert.ToString(e.CommandArgument).Split('|');
            if (parts.Length != 2 || !int.TryParse(parts[1], out var businessId))
            {
                return;
            }

            var replyBox = e.Item.FindControl("txtServiceReply") as TextBox;
            var currentUser = AuthManager.GetCurrentUser();
            var success = _contentRepository.AddServiceMessage(
                parts[0],
                businessId,
                currentUser == null ? 0 : currentUser.UserId,
                true,
                replyBox?.Text.Trim(),
                out var message);

            ShowMessage(message, success);
            BindAll();
        }

        protected void rptAdminReviews_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!EnsureCapability(CanManageContent, "当前账号不能处理评价审核。"))
            {
                return;
            }

            if (e.CommandName != "ModerateReview" || !int.TryParse(Convert.ToString(e.CommandArgument), out var reviewId))
            {
                return;
            }

            var featuredBox = e.Item.FindControl("chkReviewFeatured") as CheckBox;
            var hiddenBox = e.Item.FindControl("chkReviewHidden") as CheckBox;
            var replyBox = e.Item.FindControl("txtReviewReply") as TextBox;
            var currentUser = AuthManager.GetCurrentUser();
            var success = _contentRepository.ModerateReview(
                reviewId,
                featuredBox != null && featuredBox.Checked,
                hiddenBox != null && hiddenBox.Checked,
                replyBox?.Text.Trim(),
                currentUser == null ? 0 : currentUser.UserId,
                out var message);

            ShowMessage(message, success);
            BindAll();
        }

        protected void btnIssueCoupon_Click(object sender, EventArgs e)
        {
            if (!EnsureCapability(CanManageOperations, "当前账号不能发放优惠券。"))
            {
                return;
            }

            if (!int.TryParse(ddlCouponUser.SelectedValue, out var userId) || userId <= 0)
            {
                ShowMessage("请选择要发放优惠券的用户。", false);
                return;
            }

            if (!decimal.TryParse(txtCouponAmount.Text.Trim(), out var discountAmount) || discountAmount <= 0)
            {
                ShowMessage("抵扣金额必须是大于 0 的数字。", false);
                return;
            }

            if (!decimal.TryParse(txtCouponMinSpend.Text.Trim(), out var minSpend))
            {
                minSpend = 0;
            }

            if (!int.TryParse(txtCouponValidDays.Text.Trim(), out var validDays) || validDays <= 0)
            {
                validDays = 30;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _contentRepository.IssueCoupon(
                userId,
                txtCouponTitle.Text.Trim(),
                discountAmount,
                minSpend,
                validDays,
                txtCouponSource.Text.Trim(),
                currentUser == null ? 0 : currentUser.UserId,
                out var message);

            ShowMessage(message, success);
            BindAll();
        }

        protected void rptAllScripts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!EnsureCapability(CanManageContent, "当前账号不能管理剧本库。"))
            {
                return;
            }

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
            if (!EnsureCapability(CanManageOperations, "当前账号不能创建排期场次。"))
            {
                return;
            }

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
                int.TryParse(ddlScheduleDm.SelectedValue, out var hostUserId) ? (int?)hostUserId : null,
                txtScheduleBriefing.Text.Trim(),
                basePrice,
                maxPlayers,
                out var message);

            ShowMessage(message, success);
            BindAll();
        }

        protected void btnPublishAnnouncement_Click(object sender, EventArgs e)
        {
            if (!EnsureCapability(CanManageOperations || CanManageContent, "当前账号不能发布站内公告。"))
            {
                return;
            }

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
            if (!EnsureCapability(CanManageOperations, "当前账号不能管理房间状态。"))
            {
                return;
            }

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

        protected void rptRoleMatrixUsers_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            var user = e.Item.DataItem as UserAccountInfo;
            var roleList = e.Item.FindControl("ddlUserRole") as DropDownList;
            if (user == null || roleList == null)
            {
                return;
            }

            roleList.Items.Clear();
            roleList.Items.Add(new ListItem("玩家", "Player"));
            roleList.Items.Add(new ListItem("主持 DM", "DM"));
            roleList.Items.Add(new ListItem("主持人", "Host"));
            roleList.Items.Add(new ListItem("控场导演", "Director"));
            roleList.Items.Add(new ListItem("财务审核", "Finance"));
            roleList.Items.Add(new ListItem("运营排期", "Ops"));
            roleList.Items.Add(new ListItem("客服售后", "Service"));
            roleList.Items.Add(new ListItem("内容审核", "Content"));
            roleList.Items.Add(new ListItem("系统管理员", "Admin"));

            var selectedItem = roleList.Items.FindByValue(user.RoleCode ?? string.Empty);
            if (selectedItem != null)
            {
                roleList.ClearSelection();
                selectedItem.Selected = true;
            }
        }

        protected string GetRoleDisplayName(object roleCode)
        {
            var currentUser = new CurrentUserInfo { RoleCode = Convert.ToString(roleCode), ReviewStatus = "Approved" };
            return currentUser.RoleDisplayName;
        }

        private void ApplyCapabilityState()
        {
            var currentUser = AuthManager.GetBackofficeUser();
            CanManageMembers = currentUser != null && currentUser.CanManageMembers;
            CanManageFinance = currentUser != null && currentUser.CanManageFinance;
            CanManageOperations = currentUser != null && currentUser.CanManageOperations;
            CanManageContent = currentUser != null && currentUser.CanManageContent;
        }

        private bool EnsureCapability(bool allowed, string deniedMessage)
        {
            if (allowed)
            {
                return true;
            }

            ShowMessage(deniedMessage, false);
            return false;
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
                    return "快捷支付";
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

        public string DisplayAuditStatus(object value)
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

        public string DisplayPaymentMethod(object value)
        {
            switch (Convert.ToString(value))
            {
                case "BankCard":
                    return "银行卡支付";
                case "ScanCode":
                    return "扫码支付";
                default:
                    return "快捷支付";
            }
        }

        public string DisplayStoreVisitStatus(object value)
        {
            var status = Convert.ToString(value);
            return string.IsNullOrWhiteSpace(status) ? "待门店联系" : status;
        }

        public string DisplayReservationStatus(object value)
        {
            var status = Convert.ToString(value);
            return string.IsNullOrWhiteSpace(status) ? "待确认" : status;
        }

        public string DisplayBusinessType(object value)
        {
            switch (Convert.ToString(value))
            {
                case "StoreVisit":
                    return "到店联系单";
                case "Reservation":
                    return "预约订单";
                case "Session":
                    return "场次排期";
                case "AfterSale":
                    return "售后单";
                default:
                    return Convert.ToString(value);
            }
        }

        protected IHtmlString DisplayAfterSaleTimeline(object dataItem)
        {
            var item = dataItem as AfterSaleRequestInfo;
            if (item == null)
            {
                return new HtmlString(string.Empty);
            }

            var html = new StringBuilder();
            html.Append(BuildTimelineStep("已提交", item.CreatedAt.ToString("MM-dd HH:mm"), true));
            html.Append(BuildTimelineStep("已受理", item.AcceptedAt.HasValue ? item.AcceptedAt.Value.ToString("MM-dd HH:mm") : "等待管理员受理", item.AcceptedAt.HasValue));
            html.Append(BuildTimelineStep("已驳回", item.RejectedAt.HasValue ? item.RejectedAt.Value.ToString("MM-dd HH:mm") : "未驳回", item.RejectedAt.HasValue));
            html.Append(BuildTimelineStep("已申诉", item.AppealedAt.HasValue ? item.AppealedAt.Value.ToString("MM-dd HH:mm") : "未发起申诉", item.AppealedAt.HasValue));
            html.Append(BuildTimelineStep("已完成", item.ProcessedAt.HasValue ? item.ProcessedAt.Value.ToString("MM-dd HH:mm") : "处理中", item.ProcessedAt.HasValue));
            return new HtmlString(html.ToString());
        }

        protected IHtmlString DisplayAfterSaleEvidence(object evidenceUrl)
        {
            var url = Convert.ToString(evidenceUrl);
            if (string.IsNullOrWhiteSpace(url))
            {
                return new HtmlString("<p class=\"after-sale-empty\">未上传凭证</p>");
            }

            var resolvedUrl = ResolveUrl("~/" + url.TrimStart('/'));
            var safeUrl = HttpUtility.HtmlAttributeEncode(resolvedUrl);
            var lower = resolvedUrl.ToLowerInvariant();
            if (lower.EndsWith(".jpg") || lower.EndsWith(".jpeg") || lower.EndsWith(".png") || lower.EndsWith(".gif") || lower.EndsWith(".webp"))
            {
                return new HtmlString("<a class=\"after-sale-evidence\" href=\"" + safeUrl + "\" target=\"_blank\" rel=\"noopener\"><img src=\"" + safeUrl + "\" alt=\"售后凭证\" /></a>");
            }

            return new HtmlString("<p class=\"after-sale-status\">售后凭证：<a href=\"" + safeUrl + "\" target=\"_blank\" rel=\"noopener\">查看附件</a></p>");
        }

        public string DisplayReviewTags(object value)
        {
            var tags = (Convert.ToString(value) ?? string.Empty)
                .Split(new[] { '，', ',', '、', ';', '；' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(item => item.Trim())
                .Where(item => !string.IsNullOrWhiteSpace(item))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();

            return tags.Count == 0 ? "真实体验" : string.Join(" / ", tags);
        }

        public string DisplayReviewBinding(object dataItem)
        {
            var review = dataItem as ReviewInfo;
            if (review == null || !review.ReservationId.HasValue)
            {
                return "未绑定订单";
            }

            var sessionText = review.SessionDateTime.HasValue
                ? review.SessionDateTime.Value.ToString("MM-dd HH:mm")
                : "时间待补充";
            return "订单 #" + review.ReservationId.Value
                + " / " + (string.IsNullOrWhiteSpace(review.RoomName) ? "房间待安排" : review.RoomName)
                + " / " + sessionText
                + " / 状态：" + (string.IsNullOrWhiteSpace(review.ReservationStatus) ? "待确认" : review.ReservationStatus);
        }

        private static string BuildTimelineStep(string title, string summary, bool active)
        {
            return "<span class=\"service-timeline-step" + (active ? " active" : string.Empty) + "\"><span class=\"service-timeline-dot\"></span><span class=\"service-timeline-copy\"><strong>"
                + HttpUtility.HtmlEncode(title)
                + "</strong><small>"
                + HttpUtility.HtmlEncode(summary)
                + "</small></span></span>";
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
            var approvedUsers = _accountRepository.GetApprovedUsers(200);
            var dmUsers = _accountRepository.GetDmUsers(100);
            var financeSummary = _accountRepository.GetExtendedFinanceAuditSummary();
            var rechargeAuditRecords = _accountRepository.GetRechargeAuditRecords(12);
            var adminReviews = _contentRepository.GetReviewsForAdmin(20);
            var refundAuditRecords = _contentRepository.GetAfterSaleRequests(20)
                .Where(item => item.RefundTransactionId.HasValue || item.RefundedAmount > 0 || string.Equals(item.Status, "退款完成", StringComparison.OrdinalIgnoreCase))
                .OrderByDescending(item => item.ProcessedAt ?? item.CreatedAt)
                .ToList();
            var approvedScripts = allScripts
                .Where(item => string.Equals(item.AuditStatus, "Approved", StringComparison.OrdinalIgnoreCase))
                .OrderBy(item => item.Name)
                .ToList();
            var today = DateTime.Today;
            var adminTodoItems = BuildAdminTodoItems(
                storeVisitRequests,
                reservationOrders,
                _contentRepository.GetAfterSaleRequests(30),
                upcomingSessions,
                today);

            rptPendingUsers.DataSource = pendingUsers;
            rptPendingUsers.DataBind();

            rptRoleMatrixUsers.DataSource = approvedUsers
                .OrderBy(item => item.DisplayName)
                .Take(80)
                .ToList();
            rptRoleMatrixUsers.DataBind();
            pnlRoleMatrix.Visible = CanManageMembers;

            rptPendingRechargeRequests.DataSource = pendingRechargeRequests;
            rptPendingRechargeRequests.DataBind();

            rptPendingScripts.DataSource = pendingScripts;
            rptPendingScripts.DataBind();

            rptStoreVisitRequests.DataSource = storeVisitRequests;
            rptStoreVisitRequests.DataBind();

            rptReservationOrders.DataSource = reservationOrders;
            rptReservationOrders.DataBind();

            rptAfterSaleRequests.DataSource = _contentRepository.GetAfterSaleRequests(30);
            rptAfterSaleRequests.DataBind();

            rptAdminTodoItems.DataSource = adminTodoItems;
            rptAdminTodoItems.DataBind();

            rptRecentCoupons.DataSource = _contentRepository.GetRecentCouponsForAdmin(12);
            rptRecentCoupons.DataBind();

            rptAdminWalletTransactions.DataSource = _accountRepository.GetAdminWalletTransactions(20);
            rptAdminWalletTransactions.DataBind();

            rptRechargeAuditRecords.DataSource = rechargeAuditRecords;
            rptRechargeAuditRecords.DataBind();

            rptRefundAuditRecords.DataSource = refundAuditRecords;
            rptRefundAuditRecords.DataBind();

            rptServiceMessages.DataSource = _contentRepository.GetRecentServiceMessagesForAdmin(20);
            rptServiceMessages.DataBind();

            rptAdminReviews.DataSource = adminReviews;
            rptAdminReviews.DataBind();
            litReviewAdminTotal.Text = adminReviews.Count.ToString();
            litReviewAdminAverage.Text = adminReviews.Count == 0 ? "0.0" : adminReviews.Average(item => item.Rating).ToString("F1");
            litReviewLowPendingCount.Text = adminReviews.Count(item => item.Rating <= 2 && string.IsNullOrWhiteSpace(item.AdminReply)).ToString() + " 条";
            litReviewOrderBoundCount.Text = adminReviews.Count(item => item.ReservationId.HasValue).ToString() + " 条";

            litAuditRechargeTotal.Text = financeSummary.RechargeTotal.ToString("F2");
            litAuditBookingTotal.Text = financeSummary.BookingPaidTotal.ToString("F2");
            litAuditRefundTotal.Text = financeSummary.RefundTotal.ToString("F2");
            litAuditCouponTotal.Text = financeSummary.CouponDiscountTotal.ToString("F2");
            litAuditPendingRefundTotal.Text = financeSummary.PendingRefundAmount.ToString("F2");
            litAuditAnomalyCount.Text = financeSummary.AnomalyTransactionCount.ToString() + " 条";
            litAuditRejectedRechargeCount.Text = financeSummary.RejectedRechargeCount.ToString() + " 笔";

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

            BindAdminForms(approvedScripts, rooms, approvedUsers, dmUsers);
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

        private void ExportFinanceAuditCsv()
        {
            var rechargeRecords = _accountRepository.GetRechargeAuditRecords(500);
            var walletTransactions = _accountRepository.GetAdminWalletTransactions(500);
            var builder = new StringBuilder();

            builder.AppendLine("Section,OrderNo,User,PaymentMethod,Amount,Status,SubmittedAt,ReviewedAt,Remark,TransactionType,BalanceBefore,BalanceAfter,Summary,AuditNote");

            foreach (var item in rechargeRecords)
            {
                builder.AppendLine(string.Join(",",
                    EscapeCsv("Recharge"),
                    EscapeCsv(item.RechargeOrderNo),
                    EscapeCsv(item.DisplayName),
                    EscapeCsv(DisplayPaymentMethod(item.PaymentMethod)),
                    EscapeCsv(item.Amount.ToString("F2")),
                    EscapeCsv(item.RequestStatus),
                    EscapeCsv(item.SubmittedAt.ToString("yyyy-MM-dd HH:mm")),
                    EscapeCsv(item.ReviewedAt.HasValue ? item.ReviewedAt.Value.ToString("yyyy-MM-dd HH:mm") : string.Empty),
                    EscapeCsv(item.ReviewRemark),
                    string.Empty,
                    string.Empty,
                    string.Empty,
                    string.Empty,
                    string.Empty));
            }

            foreach (var item in walletTransactions)
            {
                builder.AppendLine(string.Join(",",
                    EscapeCsv("WalletTransaction"),
                    string.Empty,
                    EscapeCsv(item.UserDisplayName),
                    string.Empty,
                    EscapeCsv(item.Amount.ToString("F2")),
                    string.Empty,
                    EscapeCsv(item.CreatedAt.ToString("yyyy-MM-dd HH:mm")),
                    string.Empty,
                    string.Empty,
                    EscapeCsv(item.TransactionType),
                    EscapeCsv(item.BalanceBefore.ToString("F2")),
                    EscapeCsv(item.BalanceAfter.ToString("F2")),
                    EscapeCsv(item.Summary),
                    EscapeCsv(item.AuditNote)));
            }

            Response.Clear();
            Response.ContentType = "text/csv; charset=utf-8";
            Response.ContentEncoding = Encoding.UTF8;
            Response.AddHeader("Content-Disposition", "attachment; filename=finance-audit-" + DateTime.Now.ToString("yyyyMMdd-HHmmss") + ".csv");
            Response.Write('\uFEFF');
            Response.Write(builder.ToString());
            Response.End();
        }

        private static string EscapeCsv(string value)
        {
            var normalized = value ?? string.Empty;
            if (normalized.IndexOfAny(new[] { ',', '"', '\r', '\n' }) >= 0)
            {
                return "\"" + normalized.Replace("\"", "\"\"") + "\"";
            }

            return normalized;
        }

        private static IList<AdminTodoItemInfo> BuildAdminTodoItems(
            IList<StoreVisitRequestInfo> storeVisitRequests,
            IList<ReservationInfo> reservationOrders,
            IList<AfterSaleRequestInfo> afterSaleRequests,
            IList<SessionInfo> upcomingSessions,
            DateTime today)
        {
            return new List<AdminTodoItemInfo>
            {
                new AdminTodoItemInfo
                {
                    Title = "待确认预约订单",
                    CountText = reservationOrders.Count(item => item.Status == "待确认" || item.Status == "申请改期").ToString() + " 条",
                    Summary = "优先处理未接单和改期中的预约订单，避免玩家下单后长时间无反馈。",
                    TargetAnchor = "#reservation-orders",
                    Priority = "high"
                },
                new AdminTodoItemInfo
                {
                    Title = "待安排到店联系单",
                    CountText = storeVisitRequests.Count(item => string.IsNullOrWhiteSpace(item.AssignedRoomName) || item.RequestStatus == "待门店联系").ToString() + " 条",
                    Summary = "需要补房间、时间或特殊需求确认，安排后会直接影响门店到店履约。",
                    TargetAnchor = "#store-requests",
                    Priority = "high"
                },
                new AdminTodoItemInfo
                {
                    Title = "今日待核销场次",
                    CountText = reservationOrders.Count(item => item.SessionDateTime.Date == today && !item.CheckedInAt.HasValue && item.Status != "已取消").ToString() + " 场",
                    Summary = "今天开场但尚未核销的预约，前台可直接使用核销码完成签到。",
                    TargetAnchor = "#finance-audit-admin",
                    Priority = "medium"
                },
                new AdminTodoItemInfo
                {
                    Title = "待处理售后申请",
                CountText = afterSaleRequests.Count(item => item.Status == "待处理" || item.Status == "已受理" || item.Status == "待复审").ToString() + " 条",
                    Summary = "退款、改期和体验投诉需要尽快回复，避免影响评价和复购。",
                    TargetAnchor = "#after-sale-admin",
                    Priority = "high"
                },
                new AdminTodoItemInfo
                {
                    Title = "待 DM 接收主持任务",
                    CountText = upcomingSessions.Count(item => item.SessionDateTime >= today && string.IsNullOrWhiteSpace(item.HostName) == false).ToString() + " 场",
                    Summary = "检查场次是否已安排主持人，并同步主持备注，避免临场信息脱节。",
                    TargetAnchor = "#room-session-admin",
                    Priority = "medium"
                }
            };
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

        private void BindAdminForms(IList<ScriptInfo> approvedScripts, IList<RoomInfo> rooms, IList<UserAccountInfo> approvedUsers, IList<UserAccountInfo> dmUsers)
        {
            ddlCouponUser.DataSource = approvedUsers
                .Select(item => new
                {
                    item.Id,
                    Text = item.DisplayName + "（" + item.Username + "）"
                })
                .ToList();
            ddlCouponUser.DataTextField = "Text";
            ddlCouponUser.DataValueField = "Id";
            ddlCouponUser.DataBind();
            ddlCouponUser.Items.Insert(0, new ListItem("请选择用户", string.Empty));

            if (string.IsNullOrWhiteSpace(txtCouponTitle.Text))
            {
                txtCouponTitle.Text = "老客复购券";
            }

            if (string.IsNullOrWhiteSpace(txtCouponAmount.Text))
            {
                txtCouponAmount.Text = "30";
            }

            if (string.IsNullOrWhiteSpace(txtCouponMinSpend.Text))
            {
                txtCouponMinSpend.Text = "0";
            }

            if (string.IsNullOrWhiteSpace(txtCouponValidDays.Text))
            {
                txtCouponValidDays.Text = "30";
            }

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

            ddlScheduleDm.DataSource = dmUsers
                .Select(item => new
                {
                    item.Id,
                    Text = item.DisplayName + "（" + item.RoleCode + "）"
                })
                .ToList();
            ddlScheduleDm.DataTextField = "Text";
            ddlScheduleDm.DataValueField = "Id";
            ddlScheduleDm.DataBind();
            ddlScheduleDm.Items.Insert(0, new ListItem("暂不绑定具体 DM", string.Empty));

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

        protected IHtmlString RenderAfterSaleTimeline(object dataItem)
        {
            var item = dataItem as AfterSaleRequestInfo;
            if (item == null)
            {
                return new HtmlString(string.Empty);
            }

            var html = new StringBuilder();
            html.Append(RenderTimelineStep("已提交", item.CreatedAt.ToString("MM-dd HH:mm"), true));
            html.Append(RenderTimelineStep("已受理", item.AcceptedAt.HasValue ? item.AcceptedAt.Value.ToString("MM-dd HH:mm") : "等待门店受理", item.AcceptedAt.HasValue));
            html.Append(RenderTimelineStep("已驳回", item.RejectedAt.HasValue ? item.RejectedAt.Value.ToString("MM-dd HH:mm") : "未驳回", item.RejectedAt.HasValue));
            html.Append(RenderTimelineStep("已申诉", item.AppealedAt.HasValue ? item.AppealedAt.Value.ToString("MM-dd HH:mm") : "未发起", item.AppealedAt.HasValue));
            html.Append(RenderTimelineStep("已完成", item.ProcessedAt.HasValue ? item.ProcessedAt.Value.ToString("MM-dd HH:mm") : "处理中", item.ProcessedAt.HasValue));
            return new HtmlString(html.ToString());
        }

        protected IHtmlString RenderAfterSaleEvidence(object evidenceUrl)
        {
            var url = Convert.ToString(evidenceUrl);
            if (string.IsNullOrWhiteSpace(url))
            {
                return new HtmlString("<p class=\"after-sale-empty\">未上传凭证</p>");
            }

            var resolvedUrl = ResolveUrl("~/" + url.TrimStart('/'));
            var safeUrl = HttpUtility.HtmlAttributeEncode(resolvedUrl);
            var lower = resolvedUrl.ToLowerInvariant();
            if (lower.EndsWith(".jpg") || lower.EndsWith(".jpeg") || lower.EndsWith(".png") || lower.EndsWith(".gif") || lower.EndsWith(".webp"))
            {
                return new HtmlString("<a class=\"after-sale-evidence\" href=\"" + safeUrl + "\" target=\"_blank\" rel=\"noopener\"><img src=\"" + safeUrl + "\" alt=\"售后凭证\" /></a>");
            }

            return new HtmlString("<p class=\"after-sale-status\">售后凭证：<a href=\"" + safeUrl + "\" target=\"_blank\" rel=\"noopener\">查看附件</a></p>");
        }

        private static string RenderTimelineStep(string title, string summary, bool active)
        {
            return "<span class=\"service-timeline-step" + (active ? " active" : string.Empty) + "\"><span class=\"service-timeline-dot\"></span><span class=\"service-timeline-copy\"><strong>"
                + HttpUtility.HtmlEncode(title)
                + "</strong><small>"
                + HttpUtility.HtmlEncode(summary)
                + "</small></span></span>";
        }

        protected bool HasBusinessConversation(object businessType)
        {
            return string.Equals(Convert.ToString(businessType), "Reservation", StringComparison.OrdinalIgnoreCase);
        }

        protected string RenderAdminReviewTags(object value)
        {
            var tags = SplitReviewTags(Convert.ToString(value));
            return tags.Count == 0 ? "真实体验" : string.Join(" / ", tags);
        }

        protected string GetAdminReviewBindingText(object dataItem)
        {
            var review = dataItem as ReviewInfo;
            if (review == null || !review.ReservationId.HasValue)
            {
                return "未绑定订单";
            }

            var sessionText = review.SessionDateTime.HasValue
                ? review.SessionDateTime.Value.ToString("MM-dd HH:mm")
                : "时间待补充";
            return "订单 #" + review.ReservationId.Value
                + " / " + (string.IsNullOrWhiteSpace(review.RoomName) ? "房间待安排" : review.RoomName)
                + " / " + sessionText
                + " / 状态 " + (string.IsNullOrWhiteSpace(review.ReservationStatus) ? "待确认" : review.ReservationStatus);
        }

        private static List<string> SplitReviewTags(string raw)
        {
            return (raw ?? string.Empty)
                .Split(new[] { '，', ',', '、', ';', '；' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(item => item.Trim())
                .Where(item => !string.IsNullOrWhiteSpace(item))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();
        }

        protected string GetBusinessConversationUrl(object businessType, object businessId)
        {
            if (!HasBusinessConversation(businessType))
            {
                return string.Empty;
            }

            return "OrderConversation.aspx?reservationId=" + Convert.ToString(businessId);
        }
    }
}
