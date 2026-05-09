using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// ChatGroupMemberInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class ChatGroupMemberInfo
    {
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int GroupId { get; set; }
        /// <summary>关联的用户主键。</summary>
        public int UserId { get; set; }
        /// <summary>页面展示名称。</summary>
        public string DisplayName { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string AvatarUrl { get; set; }
        /// <summary>业务编码，用于数据库存储或权限判断。</summary>
        public string PublicUserCode { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsOwner { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime JoinedAt { get; set; }
    }
}
