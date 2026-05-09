namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// UserSettingsInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class UserSettingsInfo
    {
        /// <summary>关联的用户主键。</summary>
        public int UserId { get; set; }
        /// <summary>登录用户名。</summary>
        public string Username { get; set; }
        /// <summary>页面展示名称。</summary>
        public string DisplayName { get; set; }
        /// <summary>业务编码，用于数据库存储或权限判断。</summary>
        public string PublicUserCode { get; set; }
        /// <summary>联系电话。</summary>
        public string Phone { get; set; }
        /// <summary>电子邮箱地址。</summary>
        public string Email { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string AvatarUrl { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string FavoriteGenre { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Gender { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Region { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Signature { get; set; }
    }
}
