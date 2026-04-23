using System;
using DramaMurderGraduation.Web.Data;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web
{
    public partial class AnalyticsPage : System.Web.UI.Page
    {
        private readonly FeatureRepository _repository = new FeatureRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            BindPage();
        }

        private void BindPage()
        {
            var metric = _repository.GetAnalyticsMetric() ?? BuildFallbackMetric();
            var heatmapZones = _repository.GetHeatmapZones();
            var completionInsights = _repository.GetCompletionInsights();
            var economyInsights = _repository.GetEconomyInsights();

            litSnapshotDate.Text = metric.SnapshotDate.ToString("yyyy-MM-dd HH:mm");
            litConversionRate.Text = metric.ConversionRate.ToString("F1") + "%";
            litActiveUsers.Text = metric.ActiveUsers.ToString();
            litAverageSessionMinutes.Text = metric.AverageSessionMinutes.ToString("F1") + " 分钟";
            litTotalBookings.Text = metric.TotalBookings.ToString();
            litRevenueAmount.Text = "¥" + metric.RevenueAmount.ToString("F2");

            rptHeatmapZones.DataSource = heatmapZones;
            rptHeatmapZones.DataBind();

            rptCompletionInsights.DataSource = completionInsights;
            rptCompletionInsights.DataBind();

            rptEconomyInsights.DataSource = economyInsights;
            rptEconomyInsights.DataBind();
        }

        private static AnalyticsMetricInfo BuildFallbackMetric()
        {
            return new AnalyticsMetricInfo
            {
                SnapshotDate = DateTime.Now,
                ActiveUsers = 0,
                AverageSessionMinutes = 0,
                TotalBookings = 0,
                RevenueAmount = 0,
                ConversionRate = 0
            };
        }
    }
}
