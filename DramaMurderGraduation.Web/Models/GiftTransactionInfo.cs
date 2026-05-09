using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// GiftTransactionInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class GiftTransactionInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int SenderUserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string SenderDisplayName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ReceiverUserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ReceiverDisplayName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string GiftName { get; set; }
        /// <summary>页面展示文案。</summary>
        public string GiftIconText { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int Quantity { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int TotalCoins { get; set; }
        /// <summary>简短摘要文案。</summary>
        public string Summary { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
    }
}
