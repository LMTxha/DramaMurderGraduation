using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class BookingPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();
        private readonly AccountRepository _accountRepository = new AccountRepository();
        private int? _scriptIdFilter;
        private IList<SessionInfo> _sessionOptions;

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireApprovedUser();
            _scriptIdFilter = ParseScriptIdFilter();

            if (!IsPostBack)
            {
                BindScriptFilter();
                BindSessions();
                BindWaitlistSessions();
                BindCurrentUser();
                BindRecentReservations();
                BindMyWaitlists();
                BindMyReservations();
                BindAfterSaleRequests();
                FillContactInfo();
                UpdateBookingSummary();
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(ddlSessions.SelectedValue, out var sessionId))
            {
                ShowMessage("请选择有效场次。", false);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtContactName.Text) || string.IsNullOrWhiteSpace(txtPhone.Text))
            {
                ShowMessage("联系人和联系电话不能为空。", false);
                return;
            }

            if (!int.TryParse(txtPlayerCount.Text, out var playerCount) || playerCount <= 0 || playerCount > 8)
            {
                ShowMessage("预约人数请输入 1 到 8 之间的整数。", false);
                return;
            }

            var session = _repository.GetSessionById(sessionId);
            if (session == null || session.RemainingSeats <= 0)
            {
                BindSessions();
                UpdateBookingSummary();
                ShowMessage("当前场次已满或不可预约，请选择其他场次。", false);
                return;
            }

            if (session.RemainingSeats < playerCount)
            {
                ShowMessage("当前场次剩余名额不足，请减少人数或选择其他场次。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var request = new BookingCreateRequest
            {
                UserId = currentUser.UserId,
                SessionId = sessionId,
                ContactName = txtContactName.Text.Trim(),
                Phone = txtPhone.Text.Trim(),
                PlayerCount = playerCount,
                Remark = txtRemark.Text.Trim(),
                CouponId = int.TryParse(ddlCoupons.SelectedValue, out var couponId) ? (int?)couponId : null
            };

            var success = _repository.CreateReservation(request, out var reservationId, out var message);
            ShowMessage(message, success);

            if (success)
            {
                Response.Redirect("~/GameLobby.aspx?reservationId=" + reservationId, true);
                return;
            }

            BindSessions();
            UpdateBookingSummary();
        }

        protected void rptMyReservations_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "CreateAfterSale" || !int.TryParse(Convert.ToString(e.CommandArgument), out var reservationId))
            {
                return;
            }

            var typeList = e.Item.FindControl("ddlAfterSaleType") as DropDownList;
            var amountBox = e.Item.FindControl("txtAfterSaleAmount") as TextBox;
            var reasonBox = e.Item.FindControl("txtAfterSaleReason") as TextBox;
            var evidenceUpload = e.Item.FindControl("fuAfterSaleEvidence") as FileUpload;
            var amount = 0M;
            if (!string.IsNullOrWhiteSpace(amountBox?.Text) && !decimal.TryParse(amountBox.Text.Trim(), out amount))
            {
                ShowMessage("退款金额格式不正确，可以留空或填写数字。", false);
                return;
            }

            if (!UploadHelper.TrySave(evidenceUpload, "aftersale", out var evidenceUrl, out var uploadError))
            {
                ShowMessage(uploadError, false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _repository.CreateAfterSaleRequest(
                reservationId,
                currentUser.UserId,
                typeList?.SelectedValue,
                reasonBox?.Text.Trim(),
                amount,
                evidenceUrl,
                out var message);

            ShowMessage(message, success);
            BindMyReservations();
            BindAfterSaleRequests();
        }

        protected void rptAfterSaleRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "SubmitAfterSaleAppeal" || !int.TryParse(Convert.ToString(e.CommandArgument), out var requestId))
            {
                return;
            }

            var appealBox = e.Item.FindControl("txtAppealReason") as TextBox;
            var evidenceUpload = e.Item.FindControl("fuAppealEvidence") as FileUpload;
            if (!UploadHelper.TrySave(evidenceUpload, "aftersale", out var evidenceUrl, out var uploadError))
            {
                ShowMessage(uploadError, false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _repository.SubmitAfterSaleAppeal(
                requestId,
                currentUser.UserId,
                appealBox?.Text.Trim(),
                evidenceUrl,
                out var message);

            ShowMessage(message, success);
            BindAfterSaleRequests();
        }

        protected void btnJoinWaitlist_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(ddlWaitlistSessions.SelectedValue, out var sessionId))
            {
                ShowMessage("请选择要候补的场次。", false);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtContactName.Text) || string.IsNullOrWhiteSpace(txtPhone.Text))
            {
                ShowMessage("加入候补前请先填写联系人和联系电话。", false);
                return;
            }

            if (!int.TryParse(txtPlayerCount.Text, out var playerCount) || playerCount <= 0 || playerCount > 8)
            {
                ShowMessage("候补人数请输入 1 到 8 之间的整数。", false);
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var success = _repository.JoinReservationWaitlist(
                currentUser.UserId,
                sessionId,
                txtContactName.Text.Trim(),
                txtPhone.Text.Trim(),
                playerCount,
                txtRemark.Text.Trim(),
                out var message);

            ShowMessage(message, success);
            BindWaitlistSessions();
            BindMyWaitlists();
        }

        private void BindSessions()
        {
            _sessionOptions = _repository.GetUpcomingSessions(50, _scriptIdFilter)
                .Where(session => session.RemainingSeats > 0)
                .ToList();

            ddlSessions.Items.Clear();
            foreach (var session in _sessionOptions)
            {
                var text = $"{session.SessionDateTime:MM-dd HH:mm} | {session.ScriptName} | {session.RoomName} | ￥{session.BasePrice:F0}/人 | 剩余 {session.RemainingSeats} 位";
                ddlSessions.Items.Add(new ListItem(text, session.Id.ToString()));
            }

            if (ddlSessions.Items.Count == 0)
            {
                ddlSessions.Items.Add(new ListItem("暂无可预约场次，请稍后再试", string.Empty));
                ddlSessions.Enabled = false;
                btnSubmit.Enabled = false;
                btnSubmit.Text = "暂无可预约场次";
                btnSubmit.CssClass = "btn-primary wide-button booking-submit-button booking-submit-disabled";
                ShowMessage("当前剧本的开放场次已经满员，暂时不能继续预约。请等待管理员新增排期，或选择其他剧本/场次。", false);
                return;
            }

            ddlSessions.Enabled = true;
            btnSubmit.Enabled = true;
            btnSubmit.Text = "提交预约";
            btnSubmit.CssClass = "btn-primary wide-button booking-submit-button";

            if (int.TryParse(Request.QueryString["sessionId"], out var sessionId))
            {
                var item = ddlSessions.Items.FindByValue(sessionId.ToString());
                if (item != null)
                {
                    ddlSessions.ClearSelection();
                    item.Selected = true;
                }
                return;
            }

            SelectBestSession();
        }

        private void BindWaitlistSessions()
        {
            var waitlistSessions = _repository.GetUpcomingSessionsForWaitlist(50, _scriptIdFilter)
                .Where(session => session.RemainingSeats <= 0)
                .ToList();

            ddlWaitlistSessions.Items.Clear();
            foreach (var session in waitlistSessions)
            {
                var text = $"{session.SessionDateTime:MM-dd HH:mm} | {session.ScriptName} | {session.RoomName} | 满员 {Math.Abs(session.RemainingSeats)} 位";
                ddlWaitlistSessions.Items.Add(new ListItem(text, session.Id.ToString()));
            }

            if (ddlWaitlistSessions.Items.Count == 0)
            {
                ddlWaitlistSessions.Items.Add(new ListItem("当前没有需要候补的满员场次", string.Empty));
                ddlWaitlistSessions.Enabled = false;
                btnJoinWaitlist.Enabled = false;
                return;
            }

            ddlWaitlistSessions.Enabled = true;
            btnJoinWaitlist.Enabled = true;

            if (int.TryParse(Request.QueryString["sessionId"], out var sessionId))
            {
                var item = ddlWaitlistSessions.Items.FindByValue(sessionId.ToString());
                if (item != null)
                {
                    ddlWaitlistSessions.ClearSelection();
                    item.Selected = true;
                }
            }
        }

        protected void ddlSessions_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdateBookingSummary();
        }

        protected void txtPlayerCount_TextChanged(object sender, EventArgs e)
        {
            UpdateBookingSummary();
        }

        protected void ddlCoupons_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdateBookingSummary();
        }

        private void BindRecentReservations()
        {
            rptRecentReservations.DataSource = _repository.GetRecentReservations(6);
            rptRecentReservations.DataBind();
        }

        private void BindMyReservations()
        {
            var currentUser = AuthManager.GetCurrentUser();
            rptMyReservations.DataSource = currentUser == null
                ? new List<ReservationInfo>()
                : _repository.GetReservationsForUser(currentUser.UserId, 8);
            rptMyReservations.DataBind();
        }

        private void BindMyWaitlists()
        {
            var currentUser = AuthManager.GetCurrentUser();
            rptMyWaitlists.DataSource = currentUser == null
                ? new List<ReservationWaitlistInfo>()
                : _repository.GetReservationWaitlistsForUser(currentUser.UserId, 8);
            rptMyWaitlists.DataBind();
        }

        private void BindAfterSaleRequests()
        {
            var currentUser = AuthManager.GetCurrentUser();
            rptAfterSaleRequests.DataSource = currentUser == null
                ? new List<AfterSaleRequestInfo>()
                : _repository.GetAfterSaleRequests(20, null, currentUser.UserId);
            rptAfterSaleRequests.DataBind();
        }

        private void BindCurrentUser()
        {
            var currentUser = AuthManager.GetCurrentUser();
            var latestUser = _accountRepository.GetUserById(currentUser.UserId);
            if (latestUser == null)
            {
                AuthManager.SignOut();
                Response.Redirect("~/Login.aspx");
                return;
            }

            AuthManager.SignIn(AuthManager.CreateCurrentUser(latestUser));
            litWalletBalance.Text = latestUser.Balance.ToString("F2");
        }

        private void FillContactInfo()
        {
            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser == null)
            {
                return;
            }

            if (string.IsNullOrWhiteSpace(txtContactName.Text))
            {
                txtContactName.Text = currentUser.DisplayName;
            }

            if (string.IsNullOrWhiteSpace(txtPhone.Text))
            {
                txtPhone.Text = currentUser.Phone;
            }
        }

        private void UpdateBookingSummary()
        {
            if (!int.TryParse(ddlSessions.SelectedValue, out var sessionId))
            {
                litSelectedSession.Text = "暂无可预约场次";
                litRemainingSeats.Text = "0";
                litUnitPrice.Text = "0.00";
                litEstimatedAmount.Text = "0.00";
                litCouponDiscount.Text = "0.00";
                BindCoupons(0);
                return;
            }

            var session = _repository.GetSessionById(sessionId);
            if (session == null || session.RemainingSeats <= 0)
            {
                litSelectedSession.Text = "当前场次不可预约";
                litRemainingSeats.Text = "0";
                litUnitPrice.Text = "0.00";
                litEstimatedAmount.Text = "0.00";
                litCouponDiscount.Text = "0.00";
                BindCoupons(0);
                return;
            }

            var playerCount = 0;
            if (!int.TryParse(txtPlayerCount.Text, out playerCount) || playerCount <= 0)
            {
                playerCount = 1;
            }

            litSelectedSession.Text = session.ScriptName + " / " + session.RoomName;
            litRemainingSeats.Text = session.RemainingSeats.ToString();
            litUnitPrice.Text = session.BasePrice.ToString("F2");
            var originalAmount = session.BasePrice * playerCount;
            var availableCoupons = BindCoupons(originalAmount);
            var selectedCoupon = availableCoupons.FirstOrDefault(item => item.Id.ToString() == ddlCoupons.SelectedValue);
            var discountAmount = selectedCoupon == null ? 0M : Math.Min(selectedCoupon.DiscountAmount, originalAmount);
            litCouponDiscount.Text = discountAmount.ToString("F2");
            litEstimatedAmount.Text = Math.Max(0M, originalAmount - discountAmount).ToString("F2");
        }

        private IList<CouponInfo> BindCoupons(decimal orderAmount)
        {
            var selectedValue = ddlCoupons.SelectedValue;
            ddlCoupons.Items.Clear();
            ddlCoupons.Items.Add(new ListItem("不使用优惠券", string.Empty));

            var currentUser = AuthManager.GetCurrentUser();
            var coupons = currentUser == null || orderAmount <= 0
                ? new List<CouponInfo>()
                : _repository.GetAvailableCoupons(currentUser.UserId, orderAmount);

            foreach (var coupon in coupons)
            {
                var text = $"{coupon.Title} · 抵扣 ￥{coupon.DiscountAmount:F2} · 满 ￥{coupon.MinSpend:F2} · {coupon.ValidUntil:MM-dd} 到期";
                ddlCoupons.Items.Add(new ListItem(text, coupon.Id.ToString()));
            }

            var selectedItem = ddlCoupons.Items.FindByValue(selectedValue);
            if (selectedItem != null)
            {
                ddlCoupons.ClearSelection();
                selectedItem.Selected = true;
            }

            ddlCoupons.Enabled = coupons.Count > 0;
            return coupons;
        }

        private void SelectBestSession()
        {
            if (_sessionOptions == null || _sessionOptions.Count == 0)
            {
                return;
            }

            var desiredPlayerCount = 1;
            if (int.TryParse(txtPlayerCount.Text, out var parsedPlayerCount) && parsedPlayerCount > 0)
            {
                desiredPlayerCount = parsedPlayerCount;
            }

            var preferredSession = _sessionOptions
                .Where(session => session.RemainingSeats >= desiredPlayerCount)
                .OrderByDescending(session => session.RemainingSeats)
                .ThenBy(session => session.SessionDateTime)
                .FirstOrDefault()
                ?? _sessionOptions
                    .OrderByDescending(session => session.RemainingSeats)
                    .ThenBy(session => session.SessionDateTime)
                    .FirstOrDefault();

            if (preferredSession == null)
            {
                return;
            }

            var selectedItem = ddlSessions.Items.FindByValue(preferredSession.Id.ToString());
            if (selectedItem == null)
            {
                return;
            }

            ddlSessions.ClearSelection();
            selectedItem.Selected = true;
        }

        private void BindScriptFilter()
        {
            if (!_scriptIdFilter.HasValue)
            {
                phScriptFilter.Visible = false;
                litBookingIntro.Text = "登录后可先充值站内余额，再按场次单价完成预约扣费，系统会同步写入预约记录与支付流水。";
                return;
            }

            var script = _repository.GetScriptDetail(_scriptIdFilter.Value);
            if (script == null)
            {
                phScriptFilter.Visible = false;
                litBookingIntro.Text = "当前筛选剧本不存在或未开放预约，下面将展示全部可预约场次。";
                _scriptIdFilter = null;
                return;
            }

            phScriptFilter.Visible = true;
            litCurrentScriptName.Text = script.Name;
            litBookingIntro.Text = "你正在预约《" + script.Name + "》，页面已自动筛选出这个剧本的可预约场次。";
        }

        private int? ParseScriptIdFilter()
        {
            if (!int.TryParse(Request.QueryString["scriptId"], out var scriptId) || scriptId <= 0)
            {
                return null;
            }

            return scriptId;
        }

        public IHtmlString RenderAfterSaleSummary(object requestType, object status, object createdAt)
        {
            var typeText = Convert.ToString(requestType);
            var statusText = Convert.ToString(status);
            if (string.IsNullOrWhiteSpace(typeText) || string.IsNullOrWhiteSpace(statusText))
            {
                return new HtmlString("<p class=\"after-sale-empty\">暂无售后申请</p>");
            }

            var timeText = string.Empty;
            if (createdAt != null && DateTime.TryParse(Convert.ToString(createdAt), out var parsedTime))
            {
                timeText = " · " + parsedTime.ToString("MM-dd HH:mm");
            }

            return new HtmlString("<p class=\"after-sale-status\">售后：" +
                HttpUtility.HtmlEncode(typeText) + " / " +
                HttpUtility.HtmlEncode(statusText) +
                HttpUtility.HtmlEncode(timeText) + "</p>");
        }

        public bool CanAppealAfterSale(object dataItem)
        {
            var item = dataItem as AfterSaleRequestInfo;
            return item != null
                   && string.Equals(item.Status, "已驳回", StringComparison.OrdinalIgnoreCase)
                   && !item.AppealedAt.HasValue;
        }

        public IHtmlString RenderAfterSaleTimeline(object dataItem)
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

        public IHtmlString RenderAfterSaleEvidence(object evidenceUrl)
        {
            var url = Convert.ToString(evidenceUrl);
            if (string.IsNullOrWhiteSpace(url))
            {
                return new HtmlString("<p class=\"after-sale-empty\">未上传售后凭证</p>");
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

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = success ? "status-message success" : "status-message error";
            litMessage.Text = message;
        }
    }
}



