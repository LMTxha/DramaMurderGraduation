using System;

namespace DramaMurderGraduation.Web.Models
{
    public class AnalyticsMetricInfo
    {
        public DateTime SnapshotDate { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int ActiveUsers { get; set; }
        public decimal AverageSessionMinutes { get; set; }
        public int TotalBookings { get; set; }
        public decimal RevenueAmount { get; set; }
        public decimal ConversionRate { get; set; }
        public int ConfirmedBookings { get; set; }
        public int CompletedBookings { get; set; }
        public decimal AverageOrderValue { get; set; }
        public decimal RepurchaseRate { get; set; }
        public decimal RefundRate { get; set; }
        public int DmSessionCount { get; set; }
        public int RefundCount { get; set; }
        public decimal RefundAmount { get; set; }
        public int OrderingUsers { get; set; }
        public int ReturningUsers { get; set; }
    }
}
