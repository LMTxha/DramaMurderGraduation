namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// BookingCreateRequest 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class BookingCreateRequest
    {
        /// <summary>关联的用户主键。</summary>
        public int UserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int SessionId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ContactName { get; set; }
        /// <summary>联系电话。</summary>
        public string Phone { get; set; }
        /// <summary>统计数量。</summary>
        public int PlayerCount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Remark { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int? CouponId { get; set; }
    }
}
