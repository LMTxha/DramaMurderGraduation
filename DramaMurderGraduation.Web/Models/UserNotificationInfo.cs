using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// UserNotificationInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class UserNotificationInfo
    {
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string NotificationKey { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Category { get; set; }
        /// <summary>页面或卡片展示标题。</summary>
        public string Title { get; set; }
        /// <summary>正文内容。</summary>
        public string Content { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string TargetUrl { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsRead { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
    }
}
