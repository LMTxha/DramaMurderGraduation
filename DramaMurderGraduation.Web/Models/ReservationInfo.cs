using System;

namespace DramaMurderGraduation.Web.Models
{
    public class ReservationInfo
    {
        public int Id { get; set; }
        public int SessionId { get; set; }
        public int ScriptId { get; set; }
        public string ContactName { get; set; }
        public string Phone { get; set; }
        public string PhoneMasked { get; set; }
        public string ScriptName { get; set; }
        public string RoomName { get; set; }
        public string HostName { get; set; }
        public int PlayerCount { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal TotalAmount { get; set; }
        public int? CouponId { get; set; }
        public decimal DiscountAmount { get; set; }
        public string CouponTitle { get; set; }
        public string PaymentStatus { get; set; }
        public string CheckInCode { get; set; }
        public DateTime? CheckedInAt { get; set; }
        public string Remark { get; set; }
        public string AdminRemark { get; set; }
        public string AdminReply { get; set; }
        public string ConfirmStatus { get; set; }
        public string PlayerConfirmRemark { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime SessionDateTime { get; set; }
        public string Status { get; set; }
        public DateTime? ProcessedAt { get; set; }
        public DateTime? RepliedAt { get; set; }
        public DateTime? PlayerConfirmedAt { get; set; }
        public bool HasReview { get; set; }
        public int? LatestAfterSaleId { get; set; }
        public string LatestAfterSaleStatus { get; set; }
        public string LatestAfterSaleType { get; set; }
        public DateTime? LatestAfterSaleCreatedAt { get; set; }
    }
}
