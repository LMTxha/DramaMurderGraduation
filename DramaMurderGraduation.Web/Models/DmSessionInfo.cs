using System;

namespace DramaMurderGraduation.Web.Models
{
    public class DmSessionInfo
    {
        public int SessionId { get; set; }
        public int ScriptId { get; set; }
        public string ScriptName { get; set; }
        public string RoomName { get; set; }
        public string HostName { get; set; }
        public int? HostUserId { get; set; }
        public string HostBriefing { get; set; }
        public DateTime? HostAcceptedAt { get; set; }
        public DateTime SessionDateTime { get; set; }
        public string Status { get; set; }
        public int MaxPlayers { get; set; }
        public int ReservationCount { get; set; }
        public int AssignedCount { get; set; }
        public int ReadyCount { get; set; }
        public int VoteCount { get; set; }
        public string CurrentStageName { get; set; }
        public bool IsGameStarted { get; set; }
        public bool IsGameEnded { get; set; }
        public bool IsSettled { get; set; }
        public int HostReservationId { get; set; }
        public string PlayerNoteSummary { get; set; }
    }
}
