using System;

namespace DramaMurderGraduation.Web.Models
{
    public class RoomParticipantInfo
    {
        public int ReservationId { get; set; }
        public int? UserId { get; set; }
        public string DisplayName { get; set; }
        public string ContactName { get; set; }
        public string RoomName { get; set; }
        public int PlayerCount { get; set; }
        public string Status { get; set; }
        public bool CameraEnabled { get; set; }
        public bool MicrophoneEnabled { get; set; }
        public string VideoSnapshot { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
