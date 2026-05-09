using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// RoomParticipantInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class RoomParticipantInfo
    {
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ReservationId { get; set; }
        /// <summary>关联的用户主键。</summary>
        public int? UserId { get; set; }
        /// <summary>页面展示名称。</summary>
        public string DisplayName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ContactName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string RoomName { get; set; }
        /// <summary>统计数量。</summary>
        public int PlayerCount { get; set; }
        /// <summary>当前业务状态。</summary>
        public string Status { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public bool CameraEnabled { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public bool MicrophoneEnabled { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string VideoSnapshot { get; set; }
        /// <summary>最近更新时间。</summary>
        public DateTime? UpdatedAt { get; set; }
    }
}
