using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// LoginSecurityLogInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class LoginSecurityLogInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>关联的用户主键。</summary>
        public int? UserId { get; set; }
        /// <summary>登录用户名。</summary>
        public string Username { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ResultType { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string IpAddress { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string UserAgent { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Detail { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
    }
}
