using System;

namespace DramaMurderGraduation.Web.Models
{
    public class ReservationWaitlistInfo
    {
        public int Id { get; set; }
        public int SessionId { get; set; }
        public int UserId { get; set; }
        public string ContactName { get; set; }
        public string PhoneMasked { get; set; }
        public string ScriptName { get; set; }
        public string RoomName { get; set; }
        public string HostName { get; set; }
        public DateTime SessionDateTime { get; set; }
        public int PlayerCount { get; set; }
        public string Note { get; set; }
        public string Status { get; set; }
        public int RemainingSeats { get; set; }
        public bool CanBookNow { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
