using System;

namespace DramaMurderGraduation.Web.Models
{
    public class SpectatorMessageInfo
    {
        public int Id { get; set; }
        public int SpectatorRoomId { get; set; }
        public string SenderName { get; set; }
        public string Content { get; set; }
        public string BadgeText { get; set; }
        public DateTime SentAt { get; set; }
    }
}
