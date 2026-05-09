using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// CouponInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class CouponInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>关联的用户主键。</summary>
        public int UserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string UserDisplayName { get; set; }
        /// <summary>登录用户名。</summary>
        public string Username { get; set; }
        /// <summary>页面或卡片展示标题。</summary>
        public string Title { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string CouponType { get; set; }
        /// <summary>金额指标。</summary>
        public decimal DiscountAmount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public decimal MinSpend { get; set; }
        /// <summary>当前业务状态。</summary>
        public string Status { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Source { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime IssuedAt { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public DateTime ValidFrom { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public DateTime ValidUntil { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int? UsedReservationId { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? UsedAt { get; set; }
    }
}
