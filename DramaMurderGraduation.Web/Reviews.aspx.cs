using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    /// <summary>
    /// 玩家评价页面。
    /// 展示剧本评价列表，并允许已登录玩家对可评价预约提交评分和标签。
    /// </summary>
    public partial class ReviewsPage : System.Web.UI.Page
    {
        private readonly ContentRepository _repository = new ContentRepository();
        private static readonly string[] ReviewTags =
        {
            "高还原", "氛围沉浸", "推理过瘾", "适合新手",
            "演绎到位", "DM控场稳", "机制精彩", "服务细致"
        };

        /// <summary>
        /// 首次加载时绑定剧本筛选、评价标签、可评价订单和评价列表。
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindScripts();
                ApplyScriptQueryFilter();
                BindTagOptions();
                BindReviewForm();
                BindReviews();
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            BindReviews();
        }

        /// <summary>
        /// 提交预约评价。
        /// 服务端会再次确认用户登录、订单可评价和评分有效。
        /// </summary>
        protected void btnSubmitReview_Click(object sender, EventArgs e)
        {
            var currentUser = AuthManager.GetCurrentUser();
            if (currentUser == null)
            {
                ShowReviewMessage("请先登录后再提交评价。", false);
                return;
            }

            if (!int.TryParse(ddlReviewReservation.SelectedValue, out var reservationId) || reservationId <= 0)
            {
                ShowReviewMessage("请选择可评价的预约订单。", false);
                return;
            }

            if (!int.TryParse(ddlReviewRating.SelectedValue, out var rating))
            {
                rating = 5;
            }

            var success = _repository.CreateReservationReview(
                reservationId,
                currentUser.UserId,
                rating,
                txtReviewContent.Text.Trim(),
                BuildReviewTagText(),
                out var message);

            ShowReviewMessage(message, success);
            if (success)
            {
                txtReviewContent.Text = string.Empty;
                txtReviewTag.Text = string.Empty;
                foreach (ListItem item in cblReviewTags.Items)
                {
                    item.Selected = false;
                }
            }

            BindReviewForm();
            BindReviews();
        }

        private void BindScripts()
        {
            ddlScripts.Items.Clear();
            ddlScripts.Items.Add(new ListItem("全部剧本", string.Empty));

            foreach (var script in _repository.GetScripts(string.Empty, null))
            {
                ddlScripts.Items.Add(new ListItem(script.Name, script.Id.ToString()));
            }
        }

        private void ApplyScriptQueryFilter()
        {
            if (!int.TryParse(Request.QueryString["scriptId"], out var scriptId) || scriptId <= 0)
            {
                return;
            }

            var item = ddlScripts.Items.FindByValue(scriptId.ToString());
            if (item == null)
            {
                return;
            }

            ddlScripts.ClearSelection();
            item.Selected = true;
        }

        private void BindReviewForm()
        {
            var currentUser = AuthManager.GetCurrentUser();
            pnlSubmitReview.Visible = currentUser != null;
            ddlReviewReservation.Items.Clear();

            if (currentUser == null)
            {
                return;
            }

            ddlReviewReservation.Items.Add(new ListItem("请选择要评价的预约订单", string.Empty));
            foreach (var reservation in _repository.GetReviewableReservations(currentUser.UserId, 30))
            {
                var text = $"{reservation.SessionDateTime:MM-dd HH:mm} | {reservation.ScriptName} | {reservation.RoomName} | ￥{reservation.TotalAmount:F2}";
                ddlReviewReservation.Items.Add(new ListItem(text, reservation.Id.ToString()));
            }

            if (ddlReviewReservation.Items.Count == 1)
            {
                ddlReviewReservation.Items[0].Text = "暂无可评价订单";
                btnSubmitReview.Enabled = false;
            }
            else
            {
                btnSubmitReview.Enabled = true;
            }
        }

        private void BindReviews()
        {
            int? scriptId = null;
            if (int.TryParse(ddlScripts.SelectedValue, out var parsedScriptId))
            {
                scriptId = parsedScriptId;
            }

            var reviews = _repository.GetLatestReviews(200, scriptId);
            litReviewTotal.Text = reviews.Count.ToString();
            litAverageScore.Text = reviews.Count == 0 ? "0.0" : reviews.Average(item => item.Rating).ToString("F1");
            litFiveStarCount.Text = reviews.Count(item => item.Rating == 5).ToString();
            litGoodRate.Text = reviews.Count == 0 ? "0%" : ((reviews.Count(item => item.Rating >= 4) * 100.0) / reviews.Count).ToString("F0") + "%";
            litLowScoreCount.Text = reviews.Count(item => item.Rating <= 2 && string.IsNullOrWhiteSpace(item.AdminReply)).ToString();
            litTopTags.Text = GetTopTags(reviews);

            rptReviews.DataSource = reviews;
            rptReviews.DataBind();
        }

        private void BindTagOptions()
        {
            cblReviewTags.Items.Clear();
            foreach (var tag in ReviewTags)
            {
                cblReviewTags.Items.Add(new ListItem(tag, tag));
            }
        }

        private string BuildReviewTagText()
        {
            var tags = new List<string>();
            tags.AddRange(cblReviewTags.Items.Cast<ListItem>().Where(item => item.Selected).Select(item => item.Value));

            var customTags = (txtReviewTag.Text ?? string.Empty)
                .Split(new[] { '，', ',', '、', ';', '；', ' ' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(item => item.Trim())
                .Where(item => !string.IsNullOrWhiteSpace(item));

            foreach (var tag in customTags)
            {
                if (!tags.Contains(tag))
                {
                    tags.Add(tag);
                }
            }

            if (tags.Count == 0)
            {
                tags.Add("真实体验");
            }

            return string.Join("、", tags.Take(4));
        }

        private static string GetTopTags(IList<ReviewInfo> reviews)
        {
            var topTags = reviews
                .SelectMany(item => SplitTags(item.HighlightTag))
                .GroupBy(item => item)
                .OrderByDescending(group => group.Count())
                .ThenBy(group => group.Key)
                .Take(3)
                .Select(group => group.Key)
                .ToList();

            return topTags.Count == 0 ? "暂无" : string.Join(" / ", topTags);
        }

        protected string GetPrimaryTag(object value)
        {
            return SplitTags(Convert.ToString(value)).FirstOrDefault() ?? "真实体验";
        }

        protected string RenderReviewTags(object value)
        {
            var tags = SplitTags(Convert.ToString(value)).ToList();
            return tags.Count == 0 ? "标签：真实体验" : "标签：" + string.Join(" / ", tags);
        }

        protected string GetReservationBindingText(object dataItem)
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
                + " / ￥" + review.ReservationAmount.ToString("F2");
        }

        private static IEnumerable<string> SplitTags(string raw)
        {
            return (raw ?? string.Empty)
                .Split(new[] { '，', ',', '、', ';', '；' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(item => item.Trim())
                .Where(item => !string.IsNullOrWhiteSpace(item))
                .Distinct(StringComparer.OrdinalIgnoreCase);
        }

        private void ShowReviewMessage(string message, bool success)
        {
            pnlReviewMessage.Visible = true;
            pnlReviewMessage.CssClass = success ? "status-message success" : "status-message error";
            litReviewMessage.Text = message;
        }
    }
}
