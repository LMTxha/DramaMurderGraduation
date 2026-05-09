using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// AiConversationEntryInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class AiConversationEntryInfo
    {
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Role { get; set; }
        /// <summary>正文内容。</summary>
        public string Content { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ProviderDisplayName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Model { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsError { get; set; }
    }
}