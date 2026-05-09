using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// ReviewInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class ReviewInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ScriptId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ScriptName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ReviewerName { get; set; }
        /// <summary>评分值。</summary>
        public int Rating { get; set; }
        /// <summary>正文内容。</summary>
        public string Content { get; set; }
        /// <summary>对应业务日期。</summary>
        public DateTime ReviewDate { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string HighlightTag { get; set; }
        /// <summary>关联的用户主键。</summary>
        public int? UserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int? ReservationId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string RoomName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public DateTime? SessionDateTime { get; set; }
        /// <summary>金额指标。</summary>
        public decimal ReservationAmount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ReservationStatus { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsFeatured { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsHidden { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AdminReply { get; set; }
    }
}
