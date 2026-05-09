using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// StoreVisitRequestInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class StoreVisitRequestInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>关联的用户主键。</summary>
        public int? UserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int? ScriptId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ScriptName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ContactName { get; set; }
        /// <summary>联系电话。</summary>
        public string Phone { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string PhoneMasked { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public DateTime PreferredArriveTime { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int TeamSize { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string RequestStatus { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AssignedRoomName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AdminRemark { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AdminReply { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Note { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ConfirmStatus { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string PlayerConfirmRemark { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? ProcessedAt { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? RepliedAt { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? PlayerConfirmedAt { get; set; }
    }
}
