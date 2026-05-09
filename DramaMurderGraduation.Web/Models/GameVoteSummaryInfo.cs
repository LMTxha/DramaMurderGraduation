namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// GameVoteSummaryInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class GameVoteSummaryInfo
    {
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int SuspectCharacterId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string SuspectCharacterName { get; set; }
        /// <summary>统计数量。</summary>
        public int VoteCount { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsCorrect { get; set; }
    }
}
