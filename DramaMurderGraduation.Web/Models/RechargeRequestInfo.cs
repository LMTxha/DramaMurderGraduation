using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// RechargeRequestInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class RechargeRequestInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>关联的用户主键。</summary>
        public int UserId { get; set; }
        /// <summary>登录用户名。</summary>
        public string Username { get; set; }
        /// <summary>页面展示名称。</summary>
        public string DisplayName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string RechargeOrderNo { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string PaymentMethod { get; set; }
        /// <summary>业务金额。</summary>
        public decimal Amount { get; set; }
        /// <summary>统计数量。</summary>
        public string PaymentAccount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string PaymentAccountMasked { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string RequestStatus { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ReviewRemark { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ReviewedByName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int? WalletTransactionId { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime SubmittedAt { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? ReviewedAt { get; set; }
    }
}
