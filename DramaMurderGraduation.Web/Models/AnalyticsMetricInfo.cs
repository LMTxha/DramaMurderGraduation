using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// AnalyticsMetricInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class AnalyticsMetricInfo
    {
        /// <summary>对应业务日期。</summary>
        public DateTime SnapshotDate { get; set; }
        /// <summary>对应业务日期。</summary>
        public DateTime StartDate { get; set; }
        /// <summary>对应业务日期。</summary>
        public DateTime EndDate { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ActiveUsers { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public decimal AverageSessionMinutes { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int TotalBookings { get; set; }
        /// <summary>金额指标。</summary>
        public decimal RevenueAmount { get; set; }
        /// <summary>比例指标，通常按百分比展示。</summary>
        public decimal ConversionRate { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ConfirmedBookings { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int CompletedBookings { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public decimal AverageOrderValue { get; set; }
        /// <summary>比例指标，通常按百分比展示。</summary>
        public decimal RepurchaseRate { get; set; }
        /// <summary>比例指标，通常按百分比展示。</summary>
        public decimal RefundRate { get; set; }
        /// <summary>统计数量。</summary>
        public int DmSessionCount { get; set; }
        /// <summary>统计数量。</summary>
        public int RefundCount { get; set; }
        /// <summary>金额指标。</summary>
        public decimal RefundAmount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int OrderingUsers { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ReturningUsers { get; set; }
    }
}
