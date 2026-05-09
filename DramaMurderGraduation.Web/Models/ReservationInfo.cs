using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// 预约订单在页面上的聚合展示模型。
    /// 它把预约主表、场次、剧本、房间、优惠券、核销和售后摘要字段放在一起，减少页面二次查询。
    /// </summary>
    public class ReservationInfo
    {
        /// <summary>预约订单 Id。</summary>
        public int Id { get; set; }

        /// <summary>关联场次 Id。</summary>
        public int SessionId { get; set; }

        /// <summary>关联剧本 Id。</summary>
        public int ScriptId { get; set; }

        /// <summary>关联房间 Id。</summary>
        public int RoomId { get; set; }

        /// <summary>预约联系人姓名。</summary>
        public string ContactName { get; set; }

        /// <summary>联系人手机号原文，仅在有权限的页面使用。</summary>
        public string Phone { get; set; }

        /// <summary>脱敏后的手机号，用于列表展示。</summary>
        public string PhoneMasked { get; set; }

        /// <summary>剧本名称。</summary>
        public string ScriptName { get; set; }

        /// <summary>房间名称。</summary>
        public string RoomName { get; set; }

        /// <summary>DM/主持人名称。</summary>
        public string HostName { get; set; }

        /// <summary>预约玩家人数。</summary>
        public int PlayerCount { get; set; }

        /// <summary>单人价格。</summary>
        public decimal UnitPrice { get; set; }

        /// <summary>折扣前订单总额。</summary>
        public decimal TotalAmount { get; set; }

        /// <summary>使用的优惠券 Id，未使用时为空。</summary>
        public int? CouponId { get; set; }

        /// <summary>优惠抵扣金额。</summary>
        public decimal DiscountAmount { get; set; }

        /// <summary>优惠券标题，便于订单详情展示。</summary>
        public string CouponTitle { get; set; }

        /// <summary>支付状态，例如待支付、已支付、退款中。</summary>
        public string PaymentStatus { get; set; }

        /// <summary>到店核销码。</summary>
        public string CheckInCode { get; set; }

        /// <summary>到店核销时间。</summary>
        public DateTime? CheckedInAt { get; set; }

        /// <summary>玩家预约备注。</summary>
        public string Remark { get; set; }

        /// <summary>后台处理备注。</summary>
        public string AdminRemark { get; set; }

        /// <summary>后台给玩家可见的回复。</summary>
        public string AdminReply { get; set; }

        /// <summary>玩家确认状态，用于到店前确认或改期沟通。</summary>
        public string ConfirmStatus { get; set; }

        /// <summary>玩家确认或改期时填写的说明。</summary>
        public string PlayerConfirmRemark { get; set; }

        /// <summary>预约创建时间。</summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>场次开始时间。</summary>
        public DateTime SessionDateTime { get; set; }

        /// <summary>预约业务状态，例如待确认、已确认、已取消。</summary>
        public string Status { get; set; }

        /// <summary>后台最近一次处理时间。</summary>
        public DateTime? ProcessedAt { get; set; }

        /// <summary>后台最近一次回复时间。</summary>
        public DateTime? RepliedAt { get; set; }

        /// <summary>玩家最近一次确认时间。</summary>
        public DateTime? PlayerConfirmedAt { get; set; }

        /// <summary>当前预约是否已经提交评价。</summary>
        public bool HasReview { get; set; }

        /// <summary>最新售后单 Id，用于从订单跳转到售后处理。</summary>
        public int? LatestAfterSaleId { get; set; }

        /// <summary>最新售后状态。</summary>
        public string LatestAfterSaleStatus { get; set; }

        /// <summary>最新售后类型，例如退款、改期、投诉。</summary>
        public string LatestAfterSaleType { get; set; }

        /// <summary>最新售后创建时间。</summary>
        public DateTime? LatestAfterSaleCreatedAt { get; set; }
    }
}
