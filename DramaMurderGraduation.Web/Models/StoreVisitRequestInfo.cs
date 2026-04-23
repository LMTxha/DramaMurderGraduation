using System;

namespace DramaMurderGraduation.Web.Models
{
    public class StoreVisitRequestInfo
    {
        public int Id { get; set; }
        public int? UserId { get; set; }
        public int? ScriptId { get; set; }
        public string ScriptName { get; set; }
        public string ContactName { get; set; }
        public string Phone { get; set; }
        public string PhoneMasked { get; set; }
        public DateTime PreferredArriveTime { get; set; }
        public int TeamSize { get; set; }
        public string RequestStatus { get; set; }
        public string AssignedRoomName { get; set; }
        public string AdminRemark { get; set; }
        public string AdminReply { get; set; }
        public string Note { get; set; }
        public string ConfirmStatus { get; set; }
        public string PlayerConfirmRemark { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ProcessedAt { get; set; }
        public DateTime? RepliedAt { get; set; }
        public DateTime? PlayerConfirmedAt { get; set; }
    }
}
