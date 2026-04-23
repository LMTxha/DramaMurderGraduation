using System;

namespace DramaMurderGraduation.Web.Models
{
    public class GameActionLogInfo
    {
        public int Id { get; set; }
        public int? ReservationId { get; set; }
        public string PlayerName { get; set; }
        public string ActionType { get; set; }
        public string ActionTitle { get; set; }
        public string ActionContent { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
