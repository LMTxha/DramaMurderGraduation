using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// UserAccountInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class UserAccountInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>登录用户名。</summary>
        public string Username { get; set; }
        /// <summary>页面展示名称。</summary>
        public string DisplayName { get; set; }
        /// <summary>业务编码，用于数据库存储或权限判断。</summary>
        public string PublicUserCode { get; set; }
        /// <summary>电子邮箱地址。</summary>
        public string Email { get; set; }
        /// <summary>联系电话。</summary>
        public string Phone { get; set; }
        /// <summary>角色编码。</summary>
        public string RoleCode { get; set; }
        /// <summary>审核状态。</summary>
        public string ReviewStatus { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ReviewRemark { get; set; }
        /// <summary>钱包余额。</summary>
        public decimal Balance { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? ReviewedAt { get; set; }
    }
}
