using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// MomentPostInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class MomentPostInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>关联的用户主键。</summary>
        public int UserId { get; set; }
        /// <summary>页面展示名称。</summary>
        public string DisplayName { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string AvatarUrl { get; set; }
        /// <summary>正文内容。</summary>
        public string Content { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string ImageUrl { get; set; }
        /// <summary>页面展示文案。</summary>
        public string LocationText { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Visibility { get; set; }
        /// <summary>统计数量。</summary>
        public int LikeCount { get; set; }
        /// <summary>统计数量。</summary>
        public int CommentCount { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsLikedByCurrentUser { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
    }
}
