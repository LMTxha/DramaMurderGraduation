namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// FinanceAuditSummaryInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class FinanceAuditSummaryInfo
    {
        /// <summary>统计总量。</summary>
        public decimal RechargeTotal { get; set; }
        /// <summary>统计总量。</summary>
        public decimal BookingPaidTotal { get; set; }
        /// <summary>统计总量。</summary>
        public decimal RefundTotal { get; set; }
        /// <summary>统计总量。</summary>
        public decimal CouponDiscountTotal { get; set; }
        /// <summary>统计数量。</summary>
        public int PendingRechargeCount { get; set; }
        /// <summary>统计数量。</summary>
        public int PendingAfterSaleCount { get; set; }
        /// <summary>统计数量。</summary>
        public int RejectedRechargeCount { get; set; }
        /// <summary>统计数量。</summary>
        public int AnomalyTransactionCount { get; set; }
        /// <summary>金额指标。</summary>
        public decimal PendingRefundAmount { get; set; }
    }
}
