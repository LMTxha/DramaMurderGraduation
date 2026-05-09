namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// UserRegistrationRequest 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class UserRegistrationRequest
    {
        /// <summary>登录用户名。</summary>
        public string Username { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Password { get; set; }
        /// <summary>页面展示名称。</summary>
        public string DisplayName { get; set; }
        /// <summary>电子邮箱地址。</summary>
        public string Email { get; set; }
        /// <summary>联系电话。</summary>
        public string Phone { get; set; }
    }
}
