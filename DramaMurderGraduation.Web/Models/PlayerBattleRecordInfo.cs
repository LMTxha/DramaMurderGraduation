using System;

namespace DramaMurderGraduation.Web.Models
{
    public class PlayerBattleRecordInfo
    {
        public int Id { get; set; }
        public int SessionId { get; set; }
        public int ReservationId { get; set; }
        public string ScriptName { get; set; }
        public string RoomName { get; set; }
        public string CharacterName { get; set; }
        public bool WasCorrect { get; set; }
        public string ResultTag { get; set; }
        public string VotedCharacterName { get; set; }
        public string CorrectCharacterName { get; set; }
        public DateTime CompletedAt { get; set; }
    }
}
