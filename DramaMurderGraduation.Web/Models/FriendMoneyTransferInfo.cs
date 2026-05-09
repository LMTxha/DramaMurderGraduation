using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// FriendMoneyTransferInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class FriendMoneyTransferInfo
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
        public string TransferType { get; set; }
        /// <summary>业务金额。</summary>
        public decimal Amount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Note { get; set; }
        /// <summary>当前业务状态。</summary>
        public string Status { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? ClaimedAt { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
    }
}
