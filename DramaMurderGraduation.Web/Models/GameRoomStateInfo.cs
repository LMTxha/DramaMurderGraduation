using System.Collections.Generic;

namespace DramaMurderGraduation.Web.Models
{
    public class GameRoomStateInfo
    {
        public GameStageInfo CurrentStage { get; set; }
        public GameSessionLifecycleInfo Lifecycle { get; set; }
        public IList<GameStageInfo> Stages { get; set; }
        public GameAssignmentInfo CurrentAssignment { get; set; }
        public IList<GameAssignmentInfo> Assignments { get; set; }
        public IList<GameClueInfo> Clues { get; set; }
        public IList<GameActionLogInfo> ActionLogs { get; set; }
        public GamePlayerVoteInfo CurrentVote { get; set; }
        public IList<GameVoteSummaryInfo> VoteSummary { get; set; }
        public bool CanVote { get; set; }
        public bool CanManageRoom { get; set; }
        public string CorrectCharacterName { get; set; }
        public string TruthSummary { get; set; }
        public IList<GameHostClueOptionInfo> PendingClues { get; set; }
    }
}
