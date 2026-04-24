using System;

namespace DramaMurderGraduation.Web.Models
{
    public class AfterSaleRequestInfo
    {
        public int Id { get; set; }
        public int ReservationId { get; set; }
        public int UserId { get; set; }
        public string ContactName { get; set; }
        public string PhoneMasked { get; set; }
        public string ScriptName { get; set; }
        public string RoomName { get; set; }
        public string HostName { get; set; }
        public DateTime SessionDateTime { get; set; }
        public decimal ReservationAmount { get; set; }
        public string RequestType { get; set; }
        public string Reason { get; set; }
        public decimal RequestedAmount { get; set; }
        public string Status { get; set; }
        public string AdminReply { get; set; }
        public string AdminRemark { get; set; }
        public string EvidenceUrl { get; set; }
        public string RejectReason { get; set; }
        public string AppealReason { get; set; }
        public int? RefundTransactionId { get; set; }
        public decimal RefundedAmount { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? AcceptedAt { get; set; }
        public DateTime? RejectedAt { get; set; }
        public DateTime? AppealedAt { get; set; }
        public DateTime? ProcessedAt { get; set; }
    }
}
