using System;

namespace DramaMurderGraduation.Web.Models
{
    public class AnalyticsMetricInfo
    {
        public DateTime SnapshotDate { get; set; }
        public int ActiveUsers { get; set; }
        public decimal AverageSessionMinutes { get; set; }
        public int TotalBookings { get; set; }
        public decimal RevenueAmount { get; set; }
        public decimal ConversionRate { get; set; }
    }
}
