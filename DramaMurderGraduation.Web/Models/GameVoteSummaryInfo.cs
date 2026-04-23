namespace DramaMurderGraduation.Web.Models
{
    public class GameVoteSummaryInfo
    {
        public int SuspectCharacterId { get; set; }
        public string SuspectCharacterName { get; set; }
        public int VoteCount { get; set; }
        public bool IsCorrect { get; set; }
    }
}
