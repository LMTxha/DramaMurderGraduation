using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// FriendChatSummaryInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class FriendChatSummaryInfo
    {
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int FriendUserId { get; set; }
        /// <summary>登录用户名。</summary>
        public string Username { get; set; }
        /// <summary>页面展示名称。</summary>
        public string DisplayName { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string AvatarUrl { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string FavoriteGenre { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ReputationLevel { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string LastMessagePreview { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? LastMessageAt { get; set; }
        /// <summary>统计数量。</summary>
        public int UnreadCount { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsPinned { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsHidden { get; set; }
    }
}
