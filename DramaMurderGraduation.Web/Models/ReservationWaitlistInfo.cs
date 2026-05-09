using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// ReservationWaitlistInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class ReservationWaitlistInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int SessionId { get; set; }
        /// <summary>关联的用户主键。</summary>
        public int UserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ContactName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string PhoneMasked { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ScriptName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string RoomName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string HostName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public DateTime SessionDateTime { get; set; }
        /// <summary>统计数量。</summary>
        public int PlayerCount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Note { get; set; }
        /// <summary>当前业务状态。</summary>
        public string Status { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int RemainingSeats { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool CanBookNow { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
    }
}
