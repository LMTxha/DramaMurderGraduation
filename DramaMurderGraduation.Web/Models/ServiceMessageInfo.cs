using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// ServiceMessageInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class ServiceMessageInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string BusinessType { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int BusinessId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int SenderUserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string SenderName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string SenderRole { get; set; }
        /// <summary>正文内容。</summary>
        public string Content { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsReadByAdmin { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsReadByUser { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
    }
}
