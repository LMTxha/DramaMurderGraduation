using System;

namespace DramaMurderGraduation.Web.Models
{
    public class GamePlayerVoteInfo
    {
        public int SuspectCharacterId { get; set; }
        public string SuspectCharacterName { get; set; }
        public string VoteComment { get; set; }
        public DateTime? VotedAt { get; set; }
    }
}
