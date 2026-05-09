using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// BlockedUserInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class BlockedUserInfo
    {
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int BlockedUserId { get; set; }
        /// <summary>登录用户名。</summary>
        public string Username { get; set; }
        /// <summary>页面展示名称。</summary>
        public string DisplayName { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string AvatarUrl { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
    }
}
