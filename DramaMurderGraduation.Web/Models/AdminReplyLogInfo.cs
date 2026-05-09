using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// AdminReplyLogInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class AdminReplyLogInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string BusinessType { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int BusinessId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int? AdminUserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AdminName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ReplyContent { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public bool VisibleToUser { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
    }
}
