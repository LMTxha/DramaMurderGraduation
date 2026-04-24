using System;

namespace DramaMurderGraduation.Web.Models
{
    public class ReviewInfo
    {
        public int Id { get; set; }
        public int ScriptId { get; set; }
        public string ScriptName { get; set; }
        public string ReviewerName { get; set; }
        public int Rating { get; set; }
        public string Content { get; set; }
        public DateTime ReviewDate { get; set; }
        public string HighlightTag { get; set; }
        public int? UserId { get; set; }
        public int? ReservationId { get; set; }
        public string RoomName { get; set; }
        public DateTime? SessionDateTime { get; set; }
        public decimal ReservationAmount { get; set; }
        public string ReservationStatus { get; set; }
        public bool IsFeatured { get; set; }
        public bool IsHidden { get; set; }
        public string AdminReply { get; set; }
    }
}
