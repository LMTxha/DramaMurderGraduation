using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// DmSessionInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class DmSessionInfo
    {
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int SessionId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ScriptId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ScriptName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string RoomName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string HostName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int? HostUserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string HostBriefing { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? HostAcceptedAt { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public DateTime SessionDateTime { get; set; }
        /// <summary>当前业务状态。</summary>
        public string Status { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int MaxPlayers { get; set; }
        /// <summary>统计数量。</summary>
        public int ReservationCount { get; set; }
        /// <summary>统计数量。</summary>
        public int AssignedCount { get; set; }
        /// <summary>统计数量。</summary>
        public int ReadyCount { get; set; }
        /// <summary>统计数量。</summary>
        public int VoteCount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string CurrentStageName { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsGameStarted { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsGameEnded { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsSettled { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int HostReservationId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string PlayerNoteSummary { get; set; }
    }
}
