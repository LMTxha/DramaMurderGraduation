using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// RoomMessageInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class RoomMessageInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int SessionId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ReservationId { get; set; }
        /// <summary>关联的用户主键。</summary>
        public int? UserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string SenderName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string MessageType { get; set; }
        /// <summary>正文内容。</summary>
        public string Content { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string MediaData { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int? DurationSeconds { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime SentAt { get; set; }
    }
}
