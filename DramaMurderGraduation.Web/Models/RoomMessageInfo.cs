using System;

namespace DramaMurderGraduation.Web.Models
{
    public class RoomMessageInfo
    {
        public int Id { get; set; }
        public int SessionId { get; set; }
        public int ReservationId { get; set; }
        public int? UserId { get; set; }
        public string SenderName { get; set; }
        public string MessageType { get; set; }
        public string Content { get; set; }
        public string MediaData { get; set; }
        public int? DurationSeconds { get; set; }
        public DateTime SentAt { get; set; }
    }
}
