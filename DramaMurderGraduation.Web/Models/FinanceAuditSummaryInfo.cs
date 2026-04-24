namespace DramaMurderGraduation.Web.Models
{
    public class FinanceAuditSummaryInfo
    {
        public decimal RechargeTotal { get; set; }
        public decimal BookingPaidTotal { get; set; }
        public decimal RefundTotal { get; set; }
        public decimal CouponDiscountTotal { get; set; }
        public int PendingRechargeCount { get; set; }
        public int PendingAfterSaleCount { get; set; }
        public int RejectedRechargeCount { get; set; }
        public int AnomalyTransactionCount { get; set; }
        public decimal PendingRefundAmount { get; set; }
    }
}
