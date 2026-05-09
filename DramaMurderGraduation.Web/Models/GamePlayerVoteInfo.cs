using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// GamePlayerVoteInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class GamePlayerVoteInfo
    {
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int SuspectCharacterId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string SuspectCharacterName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string VoteComment { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? VotedAt { get; set; }
    }
}
