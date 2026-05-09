using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// SessionInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class SessionInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ScriptId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int RoomId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ScriptName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string RoomName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public DateTime SessionDateTime { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string HostName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int? HostUserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string HostBriefing { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? HostAcceptedAt { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public decimal BasePrice { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int MaxPlayers { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ReservedPlayers { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int RemainingSeats { get; set; }
        /// <summary>当前业务状态。</summary>
        public string Status { get; set; }
    }
}
