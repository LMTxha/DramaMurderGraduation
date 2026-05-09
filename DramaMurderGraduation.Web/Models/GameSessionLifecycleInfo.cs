using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// GameSessionLifecycleInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class GameSessionLifecycleInfo
    {
        /// <summary>布尔状态标记。</summary>
        public bool IsGameStarted { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsGameEnded { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsSettled { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? GameStartedAt { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? GameEndedAt { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? SettledAt { get; set; }
        /// <summary>统计数量。</summary>
        public int ReadyCount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int TotalAssignments { get; set; }
        /// <summary>统计数量。</summary>
        public int VoteCount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public bool EveryoneReady { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public bool EveryoneVoted { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool CanStartGame { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool CanFinishGame { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool CanSubmitAction { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool CanSubmitVote { get; set; }
        public int EliminatedCount { get; set; }
        public string EliminatedCharacterName { get; set; }
        public string EliminatedPlayerName { get; set; }
        /// <summary>页面展示文案。</summary>
        public string StatusText { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ResumeSummary { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string DmNotes { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? StageTimerStartedAt { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int StageTimerDurationMinutes { get; set; }
    }
}
