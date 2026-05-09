using System;

namespace DramaMurderGraduation.Web.Models
{
    public class GameVoteDetailInfo
    {
        public int ReservationId { get; set; }
        public string PlayerName { get; set; }
        public string ContactName { get; set; }
        public int PlayerCount { get; set; }
        public int CharacterId { get; set; }
        public string CharacterName { get; set; }
        public bool IsEliminated { get; set; }
        public DateTime? EliminatedAt { get; set; }
        public int? SuspectCharacterId { get; set; }
        public string SuspectCharacterName { get; set; }
        public string VoteComment { get; set; }
        public DateTime? VotedAt { get; set; }
        public bool HasVoted
        {
            get { return SuspectCharacterId.HasValue; }
        }
    }
}
