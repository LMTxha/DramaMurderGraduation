using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// WalletTransactionInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class WalletTransactionInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>关联的用户主键。</summary>
        public int UserId { get; set; }
        /// <summary>登录用户名。</summary>
        public string Username { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string UserDisplayName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string TransactionType { get; set; }
        /// <summary>业务金额。</summary>
        public decimal Amount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public decimal BalanceBefore { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public decimal BalanceAfter { get; set; }
        /// <summary>简短摘要文案。</summary>
        public string Summary { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsAnomaly { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AuditNote { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
    }
}
