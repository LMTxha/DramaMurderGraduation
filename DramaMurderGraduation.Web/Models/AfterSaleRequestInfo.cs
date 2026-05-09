using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// AfterSaleRequestInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class AfterSaleRequestInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ReservationId { get; set; }
        /// <summary>关联的用户主键。</summary>
        public int UserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ContactName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string PhoneMasked { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ScriptName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string RoomName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string HostName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public DateTime SessionDateTime { get; set; }
        /// <summary>金额指标。</summary>
        public decimal ReservationAmount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string RequestType { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Reason { get; set; }
        /// <summary>金额指标。</summary>
        public decimal RequestedAmount { get; set; }
        /// <summary>当前业务状态。</summary>
        public string Status { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AdminReply { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AdminRemark { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string EvidenceUrl { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string RejectReason { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AppealReason { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int? RefundTransactionId { get; set; }
        /// <summary>金额指标。</summary>
        public decimal RefundedAmount { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? AcceptedAt { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? RejectedAt { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? AppealedAt { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? ProcessedAt { get; set; }
    }
}
