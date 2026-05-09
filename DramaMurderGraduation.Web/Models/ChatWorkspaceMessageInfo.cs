using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// ChatWorkspaceMessageInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class ChatWorkspaceMessageInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ConversationKind { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ConversationId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int SenderUserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string SenderDisplayName { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string SenderAvatarUrl { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsCurrentUser { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string MessageType { get; set; }
        /// <summary>正文内容。</summary>
        public string Content { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string AttachmentUrl { get; set; }
        /// <summary>页面展示文案。</summary>
        public string LocationText { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsRevoked { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
    }
}
