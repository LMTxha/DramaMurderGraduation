using System;

namespace DramaMurderGraduation.Web.Models
{
    public class GameSessionLifecycleInfo
    {
        public bool IsGameStarted { get; set; }
        public bool IsGameEnded { get; set; }
        public bool IsSettled { get; set; }
        public DateTime? GameStartedAt { get; set; }
        public DateTime? GameEndedAt { get; set; }
        public DateTime? SettledAt { get; set; }
        public int ReadyCount { get; set; }
        public int TotalAssignments { get; set; }
        public int VoteCount { get; set; }
        public bool EveryoneReady { get; set; }
        public bool EveryoneVoted { get; set; }
        public bool CanStartGame { get; set; }
        public bool CanFinishGame { get; set; }
        public bool CanSubmitAction { get; set; }
        public bool CanSubmitVote { get; set; }
        public string StatusText { get; set; }
        public string ResumeSummary { get; set; }
        public string DmNotes { get; set; }
        public DateTime? StageTimerStartedAt { get; set; }
        public int StageTimerDurationMinutes { get; set; }
    }
}
