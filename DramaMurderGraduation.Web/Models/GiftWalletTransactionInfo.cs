using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// GiftWalletTransactionInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class GiftWalletTransactionInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string TransactionType { get; set; }
        /// <summary>金额指标。</summary>
        public int CoinAmount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int BalanceAfter { get; set; }
        /// <summary>简短摘要文案。</summary>
        public string Summary { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
    }
}
