using System;
using System.Collections.Generic;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class AnalyticsPage : System.Web.UI.Page
    {
        private readonly FeatureRepository _repository = new FeatureRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthManager.RequireAnalytics();

            if (IsPostBack)
            {
                return;
            }

            txtEndDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtStartDate.Text = DateTime.Today.AddDays(-29).ToString("yyyy-MM-dd");
            BindPage();
        }

        protected void btnApplyFilter_Click(object sender, EventArgs e)
        {
            BindPage();
        }

        private void BindPage()
        {
            pnlFilterMessage.Visible = false;

            if (!TryGetDateRange(out var startDate, out var endDate, out var message))
            {
                pnlFilterMessage.Visible = true;
                pnlFilterMessage.CssClass = "status-message error";
                litFilterMessage.Text = message;
                startDate = DateTime.Today.AddDays(-29);
                endDate = DateTime.Today;
                txtStartDate.Text = startDate.ToString("yyyy-MM-dd");
                txtEndDate.Text = endDate.ToString("yyyy-MM-dd");
            }

            var metric = _repository.GetOperationalAnalyticsMetric(startDate, endDate) ?? BuildFallbackMetric(startDate, endDate);

            litSnapshotDate.Text = metric.SnapshotDate.ToString("yyyy-MM-dd HH:mm");
            litDateRange.Text = metric.StartDate.ToString("yyyy-MM-dd") + " 至 " + metric.EndDate.ToString("yyyy-MM-dd");
            litConversionRate.Text = metric.ConversionRate.ToString("F1") + "%";
            litActiveUsers.Text = metric.ActiveUsers.ToString();
            litAverageSessionMinutes.Text = metric.AverageSessionMinutes.ToString("F1") + " 分钟";
            litTotalBookings.Text = metric.TotalBookings.ToString();
            litRevenueAmount.Text = "￥" + metric.RevenueAmount.ToString("F2");
            litAverageOrderValue.Text = "￥" + metric.AverageOrderValue.ToString("F2");
            litRepurchaseRate.Text = metric.RepurchaseRate.ToString("F1") + "%";
            litRefundRate.Text = metric.RefundRate.ToString("F1") + "%";
            litDmSessionCount.Text = metric.DmSessionCount.ToString();
            litCompletedBookings.Text = metric.CompletedBookings.ToString();

            rptCompletionInsights.DataSource = BuildCompletionInsights(metric);
            rptCompletionInsights.DataBind();

            rptEconomyInsights.DataSource = BuildEconomyInsights(metric);
            rptEconomyInsights.DataBind();
        }

        protected string GetInsightUnit(object dataItem)
        {
            var item = dataItem as CompletionInsightInfo;
            if (item == null)
            {
                return string.Empty;
            }

            return string.Equals(item.MetricType, "DM", StringComparison.OrdinalIgnoreCase) ? string.Empty : "%";
        }

        protected string GetEconomyUnit(object dataItem)
        {
            var item = dataItem as EconomyInsightInfo;
            if (item == null)
            {
                return string.Empty;
            }

            return string.Equals(item.CategoryName, "金额", StringComparison.OrdinalIgnoreCase) ? " 元" : string.Empty;
        }

        private bool TryGetDateRange(out DateTime startDate, out DateTime endDate, out string message)
        {
            var today = DateTime.Today;
            startDate = today.AddDays(-29);
            endDate = today;
            message = string.Empty;

            if (!string.IsNullOrWhiteSpace(txtStartDate.Text) && !DateTime.TryParse(txtStartDate.Text, out startDate))
            {
                message = "开始日期格式不正确。";
                return false;
            }

            if (!string.IsNullOrWhiteSpace(txtEndDate.Text) && !DateTime.TryParse(txtEndDate.Text, out endDate))
            {
                message = "结束日期格式不正确。";
                return false;
            }

            startDate = startDate.Date;
            endDate = endDate.Date;

            if (endDate < startDate)
            {
                message = "结束日期不能早于开始日期。";
                return false;
            }

            if ((endDate - startDate).TotalDays > 366)
            {
                message = "单次统计区间请控制在 366 天以内。";
                return false;
            }

            return true;
        }

        private static AnalyticsMetricInfo BuildFallbackMetric(DateTime startDate, DateTime endDate)
        {
            return new AnalyticsMetricInfo
            {
                SnapshotDate = DateTime.Now,
                StartDate = startDate,
                EndDate = endDate,
                ActiveUsers = 0,
                AverageSessionMinutes = 0,
                TotalBookings = 0,
                RevenueAmount = 0,
                ConversionRate = 0,
                ConfirmedBookings = 0,
                CompletedBookings = 0,
                AverageOrderValue = 0,
                RepurchaseRate = 0,
                RefundRate = 0,
                DmSessionCount = 0,
                RefundCount = 0,
                RefundAmount = 0,
                OrderingUsers = 0,
                ReturningUsers = 0
            };
        }

        private static IList<CompletionInsightInfo> BuildCompletionInsights(AnalyticsMetricInfo metric)
        {
            return new List<CompletionInsightInfo>
            {
                new CompletionInsightInfo
                {
                    Id = 1,
                    MetricType = "转化",
                    Name = "订单转化率",
                    ValueDecimal = metric.ConversionRate,
                    Summary = "已确认订单 " + metric.ConfirmedBookings + " / 总预约 " + metric.TotalBookings
                },
                new CompletionInsightInfo
                {
                    Id = 2,
                    MetricType = "复购",
                    Name = "回头客复购率",
                    ValueDecimal = metric.RepurchaseRate,
                    Summary = "回头客 " + metric.ReturningUsers + " / 下单用户 " + metric.OrderingUsers
                },
                new CompletionInsightInfo
                {
                    Id = 3,
                    MetricType = "退款",
                    Name = "退款完成率",
                    ValueDecimal = metric.RefundRate,
                    Summary = "完成退款 " + metric.RefundCount + " 单，用于观察售后压力与履约质量"
                },
                new CompletionInsightInfo
                {
                    Id = 4,
                    MetricType = "DM",
                    Name = "DM 场次统计",
                    ValueDecimal = metric.DmSessionCount,
                    Summary = "统计区间内已排班的主持场次，用于展示门店执行能力"
                }
            };
        }

        private static IList<EconomyInsightInfo> BuildEconomyInsights(AnalyticsMetricInfo metric)
        {
            return new List<EconomyInsightInfo>
            {
                new EconomyInsightInfo
                {
                    Id = 1,
                    CategoryName = "金额",
                    MetricName = "统计区间营收",
                    MetricValue = metric.RevenueAmount,
                    TrendText = "按预约订单汇总的有效营收"
                },
                new EconomyInsightInfo
                {
                    Id = 2,
                    CategoryName = "金额",
                    MetricName = "平均客单价",
                    MetricValue = metric.AverageOrderValue,
                    TrendText = "仅按已确认订单计算，避免取消订单干扰结果"
                },
                new EconomyInsightInfo
                {
                    Id = 3,
                    CategoryName = "金额",
                    MetricName = "退款金额",
                    MetricValue = metric.RefundAmount,
                    TrendText = "已完成退款申请的累计金额"
                },
                new EconomyInsightInfo
                {
                    Id = 4,
                    CategoryName = "用户",
                    MetricName = "回头客数量",
                    MetricValue = metric.ReturningUsers,
                    TrendText = "统计区间内下单且历史有消费记录的用户数"
                }
            };
        }
    }
}
