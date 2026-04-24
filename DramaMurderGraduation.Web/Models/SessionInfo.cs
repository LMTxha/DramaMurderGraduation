using System;

namespace DramaMurderGraduation.Web.Models
{
    public class SessionInfo
    {
        public int Id { get; set; }
        public int ScriptId { get; set; }
        public int RoomId { get; set; }
        public string ScriptName { get; set; }
        public string RoomName { get; set; }
        public DateTime SessionDateTime { get; set; }
        public string HostName { get; set; }
        public int? HostUserId { get; set; }
        public string HostBriefing { get; set; }
        public DateTime? HostAcceptedAt { get; set; }
        public decimal BasePrice { get; set; }
        public int MaxPlayers { get; set; }
        public int ReservedPlayers { get; set; }
        public int RemainingSeats { get; set; }
        public string Status { get; set; }
    }
}
