using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class OrderDetailsPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();

        protected int ReservationId { get; private set; }
        protected bool HasReview { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireApprovedUser();

            if (!IsPostBack)
            {
                BindPage();
            }
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
            HasReview = reservation.HasReview;
            pnlNotFound.Visible = false;
            pnlDetail.Visible = true;

            litReservationId.Text = reservation.Id.ToString();
            litScriptName.Text = Server.HtmlEncode(reservation.ScriptName);
            litOrderStatus.Text = Server.HtmlEncode(reservation.Status);
            litSessionTime.Text = reservation.SessionDateTime.ToString("yyyy-MM-dd HH:mm");
            litRoomName.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(reservation.RoomName) ? "待安排" : reservation.RoomName);
            litHostName.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(reservation.HostName) ? "待分配" : reservation.HostName);
            lnkLobby.NavigateUrl = "GameLobby.aspx?reservationId=" + reservation.Id;
            lnkConversation.NavigateUrl = "OrderConversation.aspx?reservationId=" + reservation.Id;
            lnkConversationInline.NavigateUrl = "OrderConversation.aspx?reservationId=" + reservation.Id;
            lnkCheckInPass.NavigateUrl = "CheckInPass.aspx?reservationId=" + reservation.Id;
            lnkCheckInPassInline.NavigateUrl = "CheckInPass.aspx?reservationId=" + reservation.Id;
            litContactName.Text = Server.HtmlEncode(reservation.ContactName);
            litPhoneMasked.Text = Server.HtmlEncode(reservation.PhoneMasked);
            litPlayerCount.Text = reservation.PlayerCount.ToString();
            litPaymentStatus.Text = Server.HtmlEncode(reservation.PaymentStatus);
            litTotalAmount.Text = reservation.TotalAmount.ToString("F2");
            litDiscountSummary.Text = reservation.DiscountAmount > 0
                ? Server.HtmlEncode((string.IsNullOrWhiteSpace(reservation.CouponTitle) ? "优惠券" : reservation.CouponTitle) + " / -￥" + reservation.DiscountAmount.ToString("F2"))
                : "未使用优惠券";
            litCheckInCode.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(reservation.CheckInCode) ? "待生成" : reservation.CheckInCode);
            litAdminReply.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(reservation.AdminReply) ? "门店暂未回复。" : reservation.AdminReply);
            litUserRemark.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(reservation.Remark) ? "玩家未填写订单备注。" : reservation.Remark);
            litAdminRemark.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(reservation.AdminRemark) ? "门店暂未填写内部备注。" : reservation.AdminRemark);
            litConfirmRemark.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(reservation.ConfirmStatus)
                ? "玩家暂未确认。"
                : reservation.ConfirmStatus + (string.IsNullOrWhiteSpace(reservation.PlayerConfirmRemark) ? string.Empty : " / " + reservation.PlayerConfirmRemark));
            litReviewBadge.Text = reservation.HasReview
                ? "<span class=\"badge-inline success\">该订单已评价</span>"
                : "<span class=\"badge-inline soft\">该订单暂未评价</span>";
            var boundReview = _repository.GetReservationReview(reservation.Id, currentUser.IsAdmin ? (int?)null : currentUser.UserId);
            pnlOrderReview.Visible = boundReview != null;
            if (boundReview != null)
            {
                litOrderReviewRating.Text = boundReview.Rating + " / 5";
                litOrderReviewTags.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(boundReview.HighlightTag) ? "标签：真实体验" : "标签：" + boundReview.HighlightTag);
                litOrderReviewContent.Text = Server.HtmlEncode(boundReview.Content);
                litOrderReviewAdminReply.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(boundReview.AdminReply) ? "门店暂未回复评价。" : "门店回复：" + boundReview.AdminReply);
                litOrderReviewTime.Text = boundReview.ReviewDate.ToString("yyyy-MM-dd HH:mm");
            }

            rptTimeline.DataSource = BuildTimeline(reservation);
            rptTimeline.DataBind();

            rptServiceMessages.DataSource = _repository.GetServiceMessages(
                "Reservation",
                reservation.Id,
                currentUser.UserId,
                currentUser.IsAdmin,
                20);
            rptServiceMessages.DataBind();

            rptReplyLogs.DataSource = currentUser.IsAdmin
                ? _repository.GetRecentAdminReplyLogs(20, "Reservation", reservation.Id)
                : _repository.GetUserVisibleReplyLogs(currentUser.UserId, 40)
                    .Where(item => string.Equals(item.BusinessType, "Reservation", StringComparison.OrdinalIgnoreCase) && item.BusinessId == reservation.Id)
                    .ToList();
            rptReplyLogs.DataBind();

            rptAfterSaleRequests.DataSource = _repository.GetAfterSaleRequests(
                20,
                null,
                currentUser.IsAdmin ? (int?)null : currentUser.UserId)
                .Where(item => item.ReservationId == reservation.Id)
                .ToList();
            rptAfterSaleRequests.DataBind();
        }

        private static IList<TimelineNode> BuildTimeline(ReservationInfo reservation)
        {
            return new List<TimelineNode>
            {
                CreateNode("已下单", reservation.CreatedAt, true, "玩家已提交预约订单"),
                CreateNode("已支付", reservation.CreatedAt, !string.IsNullOrWhiteSpace(reservation.PaymentStatus), string.IsNullOrWhiteSpace(reservation.PaymentStatus) ? "待支付" : reservation.PaymentStatus),
                CreateNode("已接单", reservation.ProcessedAt, reservation.ProcessedAt.HasValue || !string.IsNullOrWhiteSpace(reservation.AdminReply), string.IsNullOrWhiteSpace(reservation.AdminReply) ? "门店已开始处理" : reservation.AdminReply),
                CreateNode("已排房", reservation.ProcessedAt, !string.IsNullOrWhiteSpace(reservation.RoomName), "房间 " + (string.IsNullOrWhiteSpace(reservation.RoomName) ? "待安排" : reservation.RoomName) + " / DM " + (string.IsNullOrWhiteSpace(reservation.HostName) ? "待分配" : reservation.HostName)),
                CreateNode("已核销", reservation.CheckedInAt, reservation.CheckedInAt.HasValue, string.IsNullOrWhiteSpace(reservation.CheckInCode) ? "待生成核销码" : "核销码 " + reservation.CheckInCode),
                CreateNode("已完成", reservation.Status == "已完成" ? reservation.CheckedInAt ?? reservation.ProcessedAt ?? reservation.SessionDateTime : (DateTime?)null, reservation.Status == "已完成", reservation.Status == "已完成" ? "本场履约已完成" : "待完成"),
                CreateNode("已评价", reservation.HasReview ? reservation.CheckedInAt ?? reservation.SessionDateTime : (DateTime?)null, reservation.HasReview, reservation.HasReview ? "用户已提交评价" : "暂未评价")
            };
        }

        private static TimelineNode CreateNode(string title, DateTime? time, bool isActive, string summary)
        {
            return new TimelineNode
            {
                Title = title,
                CssClass = isActive ? "active" : string.Empty,
                Summary = (time.HasValue ? time.Value.ToString("yyyy-MM-dd HH:mm") : "待处理") + " / " + summary
            };
        }

        protected string GetServiceMessageRoleText(object senderRole)
        {
            return string.Equals(Convert.ToString(senderRole), "Admin", StringComparison.OrdinalIgnoreCase)
                ? "门店客服"
                : "玩家";
        }

        protected string RenderTextLine(string prefix, object value)
        {
            var text = Convert.ToString(value);
            return string.IsNullOrWhiteSpace(text)
                ? string.Empty
                : Server.HtmlEncode(prefix + text);
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

        private void ShowNotFound()
        {
            pnlNotFound.Visible = true;
            pnlDetail.Visible = false;
        }

        private bool TryGetReservationId(out int reservationId)
        {
            return int.TryParse(Request.QueryString["reservationId"], out reservationId) && reservationId > 0;
        }

        private sealed class TimelineNode
        {
            public string Title { get; set; }
            public string CssClass { get; set; }
            public string Summary { get; set; }
        }
    }
}
