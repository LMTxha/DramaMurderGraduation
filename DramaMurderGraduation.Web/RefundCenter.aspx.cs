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
    /// <summary>
    /// 玩家退款售后中心，复用 AfterSaleRequests 审核链路。
    /// </summary>
    public partial class RefundCenterPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireApprovedUser();

            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser != null && currentUser.CanAccessAdminConsole)
            {
                Response.Redirect("~/AdminReview.aspx#after-sale-admin", true);
                return;
            }

            if (!IsPostBack)
            {
                BindPage();
            }
        }

        protected void btnSubmitAfterSale_Click(object sender, EventArgs e)
        {
            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser == null)
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            if (!int.TryParse(ddlReservations.SelectedValue, out var reservationId) || reservationId <= 0)
            {
                ShowMessage("请先选择需要退款或售后的订单。", false);
                BindPage();
                return;
            }

            var amount = 0M;
            if (!string.IsNullOrWhiteSpace(txtRequestedAmount.Text) && !decimal.TryParse(txtRequestedAmount.Text.Trim(), out amount))
            {
                ShowMessage("退款金额格式不正确，可以留空或填写数字。", false);
                BindPage();
                return;
            }

            if (!UploadHelper.TrySave(fuEvidence, "aftersale", out var evidenceUrl, out var uploadError))
            {
                ShowMessage(uploadError, false);
                BindPage();
                return;
            }

            var success = _repository.CreateAfterSaleRequest(
                reservationId,
                currentUser.UserId,
                ddlAfterSaleType.SelectedValue,
                txtReason.Text.Trim(),
                amount,
                evidenceUrl,
                out var message);

            if (success)
            {
                txtReason.Text = string.Empty;
                txtRequestedAmount.Text = string.Empty;
            }

            ShowMessage(message, success);
            BindPage();
        }

        protected void rptAfterSaleRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "SubmitAfterSaleAppeal" || !int.TryParse(Convert.ToString(e.CommandArgument), out var requestId))
            {
                return;
            }

            var currentUser = AuthManager.GetCurrentUser();
            var appealBox = e.Item.FindControl("txtAppealReason") as TextBox;
            var upload = e.Item.FindControl("fuAppealEvidence") as FileUpload;
            if (!UploadHelper.TrySave(upload, "aftersale", out var evidenceUrl, out var uploadError))
            {
                ShowMessage(uploadError, false);
                BindPage();
                return;
            }

            var success = _repository.SubmitAfterSaleAppeal(
                requestId,
                currentUser.UserId,
                appealBox?.Text.Trim(),
                evidenceUrl,
                out var message);

            ShowMessage(message, success);
            BindPage();
        }

        private void BindPage()
        {
            var currentUser = AuthManager.GetCurrentUser();
            var reservations = currentUser == null
                ? new List<ReservationInfo>()
                : _repository.GetReservationsForUser(currentUser.UserId, 50)
                    .Where(item => !string.Equals(item.Status, "已取消", StringComparison.OrdinalIgnoreCase))
                    .ToList();

            rptReservations.DataSource = reservations;
            rptReservations.DataBind();

            ddlReservations.Items.Clear();
            foreach (var item in reservations)
            {
                var text = "订单 #" + item.Id + " · " + item.ScriptName + " · ￥" + item.TotalAmount.ToString("F2") + " · " + item.Status;
                ddlReservations.Items.Add(new ListItem(text, item.Id.ToString()));
            }

            if (ddlReservations.Items.Count == 0)
            {
                ddlReservations.Items.Add(new ListItem("暂无可申请售后的订单", "0"));
            }

            rptAfterSaleRequests.DataSource = currentUser == null
                ? new List<AfterSaleRequestInfo>()
                : _repository.GetAfterSaleRequests(50, null, currentUser.UserId);
            rptAfterSaleRequests.DataBind();
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
            litMessage.Text = Server.HtmlEncode(message);
        }
    }
}
